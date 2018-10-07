module sys_mem;
define sys_mem_alloc;
define sys_mem_dealloc;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
%debug; %include 'sys_mem.ins.pas';

function HeapCreate (                  {create a new dynamic memory heap}
  in      options: win_dword_t;        {set of option flags}
  in      size_init: win_dword_t;      {initial heap size}
  in      size_max: win_dword_t)       {max heap size, 0 = can grow automatically}
  :win_handle_t;                       {handle to the new heap}
  val_param; extern;

function HeapAlloc (                   {allocate memory from a heap}
  in      h: win_handle_t;             {handle to the heap}
  in      options: win_dword_t;        {set of option flags}
  in      size: win_dword_t)           {size of memory to allocate}
  :univ_ptr;                           {returned pointer to start of new memory}
  val_param; extern;

function HeapFree (                    {release memory from a heap}
  in      h: win_handle_t;             {handle to the heap}
  in      options: win_dword_t;        {set of option flags}
  in      adr: univ_ptr)               {pointer to the start of the mem to release}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

var
  h: win_handle_t := handle_none_k;    {handle to our private memory heap}
{
***************************************************
*
*   Subroutine SYS_MEM_ALLOC (SIZE, ADR)
*
*   Allocate memory dynamically.  SIZE is the amount of memory to allocate in
*   machine address units.  ADR is the returned machine address to the start of
*   the newly allocated region.
}
procedure sys_mem_alloc (              {allocate a block of virtual memory}
  in      size: sys_int_adr_t;         {size in machine address units}
  out     adr: univ_ptr);              {start adr of region, NIL for unavailable}
  val_param;

var
  p: ^char;
  stat: sys_err_t;

begin
  if h = handle_none_k then begin      {no heap created yet ?}
    h := HeapCreate (0, 1024, 0);      {create our private heap}
    if h = handle_none_k then begin
      sys_error_none (stat);
      stat.sys := GetLastError;
      sys_error_print (stat, '', '', nil, 0);
      sys_bomb;
      end;
    end;                               {heap now definitely exists}

  adr := HeapAlloc (h, 0, size);       {allocate the memory}
  %debug; test_alloc (sys_int_adr_t(adr), size); {do runtime checking}

  p := adr;
  p^ := chr(0);

  end;
{
***************************************************
*
*   Subroutine SYS_MEM_DEALLOC (ADR)
*
*   Deallocate a dynamically allocated block of virtual memory.  ADR must be the
*   starting address of the block.
}
procedure sys_mem_dealloc (            {deallocate a block of virtual memory}
  in out  adr: univ_ptr);              {starting address of block, returned NIL}

begin
  %debug; test_dealloc (sys_int_adr_t(adr)); {do runtime checking}

  discard( HeapFree (h, 0, adr) );
  adr := nil;                          {return pointer as invalid}
  end;
