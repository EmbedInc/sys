{   Test subroutine SYS_EXIT_ERROR.
*
*   This program should exit with an error status.
}
program test_exit_error;
%include 'sys.ins.pas';

begin
  sys_exit_error;
  end.
