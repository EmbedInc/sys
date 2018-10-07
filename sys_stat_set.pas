{   Subroutine SYS_STAT_SET (SUBSYS, N, STAT)
*
*   Properly set the status code STAT to the non-system status of subsystem
*   SUBSYS, and status code ID within the subsystem to N.
}
module sys_stat_set;
define sys_stat_set;
%include 'sys2.ins.pas';

procedure sys_stat_set (               {set status code to a non-system value}
  in      subsys: sys_int_machine_t;   {subsystem ID code}
  in      n: sys_int_machine_t;        {status ID within subsystem}
  out     stat: sys_err_t);            {returned properly set status code}
  val_param;

begin
  stat.err := true;                    {indicate non-system status active}
  stat.subsys := subsys;
  stat.code := n;
  stat.n_parms := 0;                   {init to no arguments passed to message}
  end;
