{   Module of routines for aborting program.
*
*   This is the generic version for systems where there is no control over
*   how much information is saved on exit.
}
module sys_bomb;
define sys_bomb;
define sys_bomb_no_tb;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
{
**************************************************************
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
**************************************************************
*
*   Subroutine SYS_BOMB_NO_TB
*
*   Abort from the current program with error condition.  Cause as little
*   data to be saved about the program state at the time of the error as
*   possible.
}
procedure sys_bomb_no_tb;
  noreturn;

begin
  sys_exit_error;
  end;
