{   Subroutine SYS_WAIT (WAIT)
*
*   Suspend the process for WAIT number of seconds.  WAIT is a floating point
*   quantity.  The accuracy of this routine is system-dependent.  This routine
*   should not be used for accurate timing.
}
module sys_wait;
define sys_wait;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';

procedure sys_wait (                   {suspend process for specified seconds}
  in      wait: real);                 {number of seconds to wait}
  val_param;

begin
  if wait <= 0.0 then return;
  Sleep (round(wait * 1000.0));        {delay process for integer milliseconds}
  end;
