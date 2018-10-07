{   Collection of subroutines used to exit the program quitely.  Each differs
*   in the status it passes back to the invoking process.
}
module sys_exit;
define sys_exit;
define sys_exit_error;
define sys_exit_false;
define sys_exit_true;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
{
**************************
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
**************************
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
**************************
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
**************************
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
