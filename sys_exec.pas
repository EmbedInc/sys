{   Module of routines for dealing with the executable used to run this
*   process.
*
*   This is the generic version that is not customized for any particular
*   environment.
}
module sys_exec;
define sys_exec_tnam_get;
%include 'sys2.ins.pas';
{
***************************************************************************
*
*   Subroutine SYS_EXEC_TNAM_GET (TNAM, STAT)
*
*   Return the complete treename of the executable file used to run this
*   process.
}
procedure sys_exec_tnam_get (          {get the complete pathname of this executable}
  in out  tnam: univ string_var_arg_t; {executable file treename}
  out     stat: sys_err_t);            {completion status code}
  val_param;

begin
  sys_stat_set (sys_subsys_k, sys_stat_not_impl_name_k, stat);
  sys_stat_parm_str ('SYS_EXEC_TNAM_GET', stat);
  end;
