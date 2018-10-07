{   Subroutine SYS_STAT_PARM_INT (I, STAT)
*
*   Add the machine integer I as the next parameter to STAT.
*   STAT.N_PARMS will be updated to include this new parameter.  Nothing will
*   be done if STAT already contains the maximum allowable number of parameters.
}
module sys_STAT_PARM_INT;
define sys_stat_parm_int;
%include 'sys2.ins.pas';

procedure sys_stat_parm_int (          {add integer parameter to STAT}
  in      i: sys_int_machine_t;        {data for parameter}
  in out  stat: sys_err_t);            {status code to add parameter to}
  val_param;

begin
  if stat.n_parms >= sys_err_t_max_parms then return; {all STAT parms filled ?}
  stat.n_parms := stat.n_parms + 1;    {make number of this parameter}

  stat.parm[stat.n_parms].int := i;

  stat.parm_ind[stat.n_parms].dtype := sys_msg_dtype_int_k;
  stat.parm_ind[stat.n_parms].int_p :=
    addr(stat.parm[stat.n_parms].int);
  end;
