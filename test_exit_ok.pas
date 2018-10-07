{   Test subroutine SYS_EXIT.
*
*   This program should exit with the OK status.
}
program test_exit_ok;
%include 'sys.ins.pas';

begin
  sys_exit;
  end.
