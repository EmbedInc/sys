{   This module contains all the routines for the "minimal" SYS library.
*   This is just enough to make the UTIL library work.  This SYS_MIN library
*   is used, for example, for shipping source code to the VOX library and
*   everything it calls.
}
module sys_min_lib;
define sys_exit;
define sys_exit_error;
define sys_exit_false;
define sys_exit_true;
define sys_mem_alloc;
define sys_mem_dealloc;
define sys_bomb;
define sys_message;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
{
***************************************************
*
*   Subroutine SYS_MESSAGE (SUBSYS, MSG)
*
*   Write message MSG from subsystem SUBSYS.  This version just shows the
*   subsystem and message names.
}
procedure sys_message (                {write message to user}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string);                {message name withing subsystem file}

var
  len_s, len_m: sys_int_machine_t;     {unpadded call argument string lengths}
  i: sys_int_machine_t;                {loop counter}

begin
  len_s := 0;                          {get length of subsystem string}
  for i := 1 to sizeof(subsys) do begin
    if subsys[i] = chr(0) then exit;   {hit null terminator ?}
    if subsys[i] <> ' ' then len_s := i; {string extends at least to here ?}
    end;

  len_m := 0;                          {get length of message string}
  for i := 1 to sizeof(msg) do begin
    if msg[i] = chr(0) then exit;      {hit null terminator ?}
    if msg[i] <> ' ' then len_m := i;  {string extends at least to here ?}
    end;

  writeln ('***  Call to minimal version of SYS_MESSAGE  ***');
  writeln ('  Subsystem name: ', subsys:len_s);
  writeln ('  Message name: ', msg:len_m);
  end;
{
***************************************************
*
*   Subroutine SYS_BOMB
*
*   Abort from the current program with error condition.  Cause as much
*   data to be saved about the program state at the time of the error as
*   possible.
}
procedure sys_bomb;                    {abort with err, leave traceback if possible}
  noreturn;

begin
  writeln ('*** Program aborted on error. ***');
  sys_exit_error;
  end;
{
***************************************************
*
*   SYS_EXIT
*
*   Exit program quitely.  Indicate everything is normal.
}
procedure sys_exit;                    {exit quitely, indicate everything normal}
  options (noreturn);

begin
  call exit (0);
  end;
{
***************************************************
*
*   SYS_EXIT_ERROR
*
*   Exit program quitely.  Indicate ERROR condition.  This means the program
*   was unable to perform its intended function.
}
procedure sys_exit_error;              {exit quitely, indicate ERROR condition}
  options (noreturn);

begin
  call exit (3);
  end;
{
***************************************************
*
*   SYS_EXIT_FALSE
*
*   Exit program quitely.  Indicate FALSE condition.  This means the program
*   performed its intended function, part of which was to evaluate a TRUE/FALSE
*   condition.  The value of that condition is FALSE.
}
procedure sys_exit_false;              {exit quitely, indicate FALSE condition}
  options (noreturn);

begin
  call exit (1);
  end;
{
***************************************************
*
*   SYS_EXIT_TRUE
*
*   Exit program quitely.  Indicate TRUE condition.  This means the program
*   performed its intended function, part of which was to evaluate a TRUE/FALSE
*   condition.  The value of that condition is TRUE.
}
procedure sys_exit_true;               {exit quitely, indicate TRUE condition}
  options (noreturn);

begin
  call exit (0);
  end;
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

begin
  adr := malloc(size);                 {allocate the memory}
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
  errno := 0;
  free (adr);                          {release the memory}
  adr := nil;                          {return pointer as invalid}
  end;
