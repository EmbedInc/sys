{   This file is included in SYS_MEM when debug compilation is enabled.
*
*   The routines here are provide some runtime memory useage checking.
*   A table is kept of all our dynamically allocated memory.
}
const
  table_size_k = 8192;                 {number of memory blocks we can keep track of}

type
  table_entry_t = record               {template for each entry in mem regions table}
    adr: sys_int_adr_t;                {start address of region}
    len: sys_int_adr_t;                {length of allocated region}
    end;

var                                    {unnamed static storage local to SYS_MEM}
  total: sys_int_adr_t := 0;           {total memory allocated}
  n_table: sys_int_machine_t := 0;     {number of valid entries in TABLE}
  table:                               {list of all our dynamic memory regions}
    array[1..table_size_k] of table_entry_t;
{
********************************************
*
*   Global subroutine SYS_MEM_ERROR_DETECTED
*
*   This subroutine is called when any kind of dynamic memory error
*   is detected.  It is made global so that a debugger breakpoint can
*   be easily set for it.
}
procedure sys_mem_error_detected;

begin
  writeln ('Dynamic memory error detected.');
  end;
{
********************************************
*
*   Global subroutine SYS_MEM_CHECK (M, LEN)
*
*   Check legality of access to memory M of LEN system address units.  The entire
*   access must be within one of the explicitly allocated regions.
}
procedure sys_mem_check (              {check for legal access to dynamic memory}
  in      m: univ sys_size1_t;         {start memory to be accessed}
  in      len: sys_int_adr_t);         {length of access starting at M}
  val_param;

var
  i: sys_int_machine_t;                {loop counter}
  adr1, adr2: sys_int_adr_t;           {starting and ending addresses of M}

begin
  adr1 := sys_int_adr_t(addr(m));      {first address in M}
  adr2 := adr1 + len - 1;              {last address in M}

  for i := 1 to n_table do begin       {once for each dynamically allocated region}
    if adr2 < table[i].adr             {M ends before this region ?}
      then next;
    if adr1 >= (table[i].adr + table[i].len) {M starts after this region ?}
      then next;
    if                                 {M completely within region ?}
        (adr1 >= table[i].adr) and
        (adr2 < (table[i].adr + table[i].len))
      then return;                     {this is a legal dynamic memory access}
    writeln ('Attempted memory access crosses end of dynamically allocated region.');
    sys_mem_error_detected;            {this is definately a bad access}
    sys_bomb;
    end;

  writeln ('Attempted memory access is not within any dynamically allocated region.');
  sys_mem_error_detected;
  sys_bomb;
  end;
{
********************************************
*
*   Local subroutine TEST_ALLOC (ADR, SIZE)
*
*   This is called when a new region of memory was requested.
}
procedure test_alloc (
  in      adr: sys_int_adr_t;          {first address of new region}
  in      size: sys_int_adr_t);        {length of new region}
  val_param;

var
  last: sys_int_adr_t;                 {last address in new region}
  i: sys_int_machine_t;                {loop counter}

begin
  last := adr + size - 1;              {make last address in new region}
  for i := 1 to n_table do begin       {once for each existing region}
    if
        (last < table[i].adr) or       {completly before this table entry ?}
        (adr >= (table[i].adr + table[i].len)) {completly after this table entry ?}
      then next;                       {no problem here, go to next table entry}
    sys_mem_error_detected;
    sys_message_bomb ('sys', 'mem_alloc_overlap', nil, 0);
    end;
{
*   New region looks OK.  Add it to table.
}
  n_table := n_table + 1;              {one more entry in mem table}
  if n_table > table_size_k then begin {memory regions table overflowed ?}
    sys_message_bomb ('sys', 'mem_table_overflow', nil, 0);
    end;
  table[n_table].adr := adr;
  table[n_table].len := size;

(*
  total := total + size;
  writeln (total);
*)
  end;
{
********************************************
*
*   Local subroutine TEST_DEALLOC (ADR)
*
*   The application has requested that the dynamic memory region starting
*   at ADR be deallocated.
}
procedure test_dealloc (
  in      adr: sys_int_adr_t);         {start of region applications wants to dealloc}
  val_param;

var
  i: sys_int_machine_t;                {loop counter}

label
  found;

begin
  for i := 1 to n_table do begin       {once for each existing region}
    if table[i].adr = adr then goto found; {found table entry for this region ?}
    end;                               {back and check next table entry}
  sys_mem_error_detected;
  sys_message_bomb ('sys', 'mem_dealloc_not_found', nil, 0);

found:                                 {I is TABLE index for this region}
(*
  total := total - table[i].len;
  writeln (total);
*)

  table[i] := table[n_table];          {copy last TABLE entry into vacated entry}
  n_table := n_table - 1;              {one less entry in TABLE}
  end;
