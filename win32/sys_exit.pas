{   Collection of subroutines used to exit the program quietly.  Each differs
*   in the status it passes back to the invoking process.
*
*   This version is for the Microsoft Win32s API.
}
module sys_exit;
define sys_exit;
define sys_exit_error;
define sys_exit_false;
define sys_exit_true;
define sys_exit_n;
define sys_sys_fault;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYS_EXIT
*
*   Exit program quietly.  Indicate everything is normal.
}
procedure sys_exit;                    {exit quietly, indicate everything normal}
  options (noreturn);

begin
  sys_sys_exit (sys_sys_exstat_ok_k);
  end;
{
********************************************************************************
*
*   Subroutine SYS_EXIT_ERROR
*
*   Exit program quietly.  Indicate ERROR condition.  This means the program
*   was unable to perform its intended function.
}
procedure sys_exit_error;              {exit quietly, indicate ERROR condition}
  options (noreturn);

begin
  sys_sys_exit (sys_sys_exstat_err_k);
  end;
{
********************************************************************************
*
*   Subroutine SYS_EXIT_FALSE
*
*   Exit program quietly.  Indicate FALSE condition.  This means the program
*   performed its intended function, part of which was to evaluate a TRUE/FALSE
*   condition.  The value of that condition is FALSE.
}
procedure sys_exit_false;              {exit quietly, indicate FALSE condition}
  options (noreturn);

begin
  sys_sys_exit (sys_sys_exstat_false_k);
  end;
{
********************************************************************************
*
*   Subroutine SYS_EXIT_TRUE
*
*   Exit program quietly.  Indicate TRUE condition.  This means the program
*   performed its intended function, part of which was to evaluate a TRUE/FALSE
*   condition.  The value of that condition is TRUE.
}
procedure sys_exit_true;               {exit quietly, indicate TRUE condition}
  options (noreturn);

begin
  sys_sys_exit (sys_sys_exstat_true_k);
  end;
{
********************************************************************************
*
*   Subroutine SYS_EXIT_N (N)
*
*   Exit the program quietly with exit status N.
}
procedure sys_exit_n (                 {exit quietly with specific exit status code}
  in      n: sys_int_machine_t);       {exit status code of program}
  options (noreturn);

begin
  sys_sys_exit (n);
  end;
{
********************************************************************************
*
*   Subroutine SYS_SYS_FAULT
*
*   Create a fault.  This may be useful for triggering the just-in-time
*   debugging.
}
procedure sys_sys_fault;

var
  p: sys_int_machine_p_t;
  i: sys_int_machine_t;

begin
  p := nil;                            {create NIL pointer}
  sys_dummy (p);                       {prevent compiler optimization}
  i := p^ + 13;                        {dereference NIL pointer}
  sys_dummy (i);                       {prevent compiler optimization}
  end;
