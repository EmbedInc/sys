{   Routines for handling MX (mail exchange) lookups.
}
module sys_mxlookup;
define sys_mx_lookup;
define sys_mx_dealloc;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
%include 'string.ins.pas';
{
********************************************************************************
*
*   Subroutine SYS_MX_LOOKUP (MEM, DOMAIN, MXDOM_P, STAT)
*
*   Find the mail exchange servers for a domain.
*
*   MEM is the parent memory context.  A subordinate memory context will be
*   created, and all new memory will be allocated under this subordinat memory
*   context.
*
*   DOMAIN is the name of the domain to find the mail exchange servers for.
*
*   MXDOM_P is returned pointing to the mail exchange servers information.  The
*   MEM_P field of this structure points to the private memory context created
*   just for the returned MX data.  All the MX data can be deallocated by
*   deleting this memory context.  On error, MXDOM_P is returned NIL.
*
*   STAT is the completion status.  No memory context is created, and no dynamic
*   memory is allocated unless STAT indicates no error.
}
procedure sys_mx_lookup (              {find mail exchange servers for a domain}
  in out  mem: util_mem_context_t;     {parent mem context, will make subordinate context}
  in      domain: univ string_var_arg_t; {domain name}
  out     mxdom_p: sys_mxdom_p_t;      {pointer to returned data}
  out     stat: sys_err_t);            {completion status, no mem allocated on error}
  val_param;

var
  dom: string_var256_t;                {NULL-terminated domain name}
  sysdata_p: dns_rec_p_t;              {pointer to data returned by DnsQuery}
  sysrec_p: dns_rec_p_t;               {pointer to current record in DnsQuery data}
  mem_p: util_mem_context_p_t;         {pointer to our private memory context}
  mxrec_p: sys_mxrec_p_t;              {pointer to a returned MX record}
  prec_p: sys_mxrec_p_t;               {pointer to previously existing record in list}
  name: string_var256_t;               {scratch system name}

label
  nextrec, no_mem, abort, leave;

begin
  dom.max := size_char(dom.str);       {init local var strings}
  name.max := size_char(name.str);

  sys_error_none (stat);               {init to no error encountered}
  mem_p := nil;                        {indicate private memory context not allocated}
  sysrec_p := nil;                     {indicate no system MX data allocated}
  mxdom_p := nil;                      {init to not returning with data}

  string_copy (domain, dom);           {make local copy of domain name}
  string_terminate_null (dom);         {ensure local copy is NULL-terminated}

  stat.sys := DnsQuery_A (             {look up MX record}
    dom.str,                           {domain name to look up}
    dns_rectype_mx_k,                  {look up MX record}
    [],                                {set of options}
    nil,                               {unused}
    sysdata_p,                         {returned pointer to the DNS data}
    nil);                              {reserved, must be NIL}
  if sys_error(stat) then return;

  util_mem_context_get (mem, mem_p);   {create our private memory context}
  if mem_p = nil then goto no_mem;
  util_mem_grab (                      {allocate mem for top level descriptor}
    sizeof(mxdom_p^),                  {size of memory to allocate}
    mem_p^,                            {parent memory context}
    false,                             {won't need to individually deallocate}
    mxdom_p);                          {returned pointer to the new memory}

  mxdom_p^.mem_p := mem_p;             {save pointer to memory context}
  mxdom_p^.n := 0;                     {init number of MX hosts found}
  mxdom_p^.list_p := nil;              {init list of MX hosts to empty}

  sysrec_p := sysdata_p;               {point to first record in system list}
  while sysrec_p <> nil do begin       {process this system record}
    if sysrec_p^.rectype <> dns_rectype_mx_k {this is not a MX record ?}
      then goto nextrec;
    if sysrec_p^.mx_name_p = nil       {no host name ?}
      then goto nextrec;
    string_vstring (name, sysrec_p^.mx_name_p^, -1); {make var string host name}
    if name.len < 3 then goto nextrec; {name is too short to be valid ?}
    mxdom_p^.n := mxdom_p^.n + 1;      {count one more entry will be in list}

    util_mem_grab (sizeof(mxrec_p^), mem_p^, false, mxrec_p); {allocate returned record}
    if mxrec_p = nil then goto no_mem;
    mxrec_p^.prev_p := nil;            {init to no previous record in chain}
    mxrec_p^.next_p := nil;            {init to no following record in chain}
    string_alloc (name.len, mem_p^, false, mxrec_p^.name_p); {alloc mem for host name}
    if mxrec_p^.name_p = nil then goto no_mem;
    string_copy (name, mxrec_p^.name_p^); {save this host name}
    mxrec_p^.pref := sysrec_p^.mx_pref; {save preference distance}
    mxrec_p^.ttl := sysrec_p^.ttl;     {save time to live}
    if mxdom_p^.list_p = nil then begin {this is first host record in list ?}
      mxdom_p^.list_p := mxrec_p;      {init list with this record}
      goto nextrec;                    {all done with this record}
      end;
    prec_p := mxdom_p^.list_p;         {init to first record in existing list}
    while true do begin                {scan the existing list}
      if mxrec_p^.ttl < prec_p^.ttl then begin {new record is more preferred ?}
        mxrec_p^.prev_p := prec_p^.prev_p;
        mxrec_p^.next_p := prec_p;     {link into chain before previous record}
        prec_p^.prev_p := mxrec_p;
        if mxrec_p^.prev_p = nil
          then mxdom_p^.list_p := mxrec_p
          else mxrec_p^.prev_p^.next_p := mxrec_p;
        goto nextrec;                  {all done with this source record}
        end;
      if prec_p^.next_p = nil then begin {previous record is last in list ?}
        prec_p^.next_p := mxrec_p;     {link new record to end of chain}
        mxrec_p^.prev_p := prec_p;
        goto nextrec;                  {all done with this source record}
        end;
      prec_p := prec_p^.next_p;        {advance to next previous list record}
      end;                             {back to check against this next previous record}

nextrec:                               {advance to next record in system list}
    sysrec_p := sysrec_p^.next_p;      {point to next record in chain}
    end;                               {back to process this new record}

  if mxdom_p^.n <= 0 then begin        {no MX records found ?}
    sys_stat_set (sys_subsys_k, sys_stat_no_mxrec_k, stat);
    sys_stat_parm_vstr (dom, stat);
    goto abort;
    end;

  goto leave;                          {return normally}

no_mem:                                {failed to allocate dynamic memory}
  sys_stat_set (sys_subsys_k, sys_stat_no_mem_k, stat);

abort:                                 {abort with error, STAT all set}
  if mem_p <> nil then begin           {private memory context created ?}
    util_mem_context_del (mem_p);
    end;

leave:                                 {common exit point}
  if sysdata_p <> nil then begin       {system MX data allocated ?}
    DnsFree (sysdata_p, dns_free_list_k);
    end;
  end;
{
********************************************************************************
*
*   Subroutine SYS_MX_DEALLOC (MXDOM_P)
*
*   Deallocate the data returned by SYS_MX_LOOKUP.  MXDOM_P is the pointer to
*   the MX records returned by SYS_MX_LOOKUP.  The data being pointed to will be
*   deallocated, and MXDOM_P will be returned NIL.
}
procedure sys_mx_dealloc (             {deallocate result of MX lookup}
  in out  mxdom_p: sys_mxdom_p_t);     {pointer to MX lookup result, returned NIL}
  val_param;

var
  mem_p: util_mem_context_p_t;         {pointer to mem context for the allocated data}

begin
  if mxdom_p = nil then return;        {nothing to do ?}

  mem_p := mxdom_p^.mem_p;             {get pointer to the private memory context}
  util_mem_context_del (mem_p);        {delete the private memory context}
  mxdom_p := nil;                      {invalidate the caller's pointer}
  end;
