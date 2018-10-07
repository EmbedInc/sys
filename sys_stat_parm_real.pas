{   Subroutine SYS_STAT_PARM_REAL (R,STAT)
*
*   Add the floating point value R as the next parameter to STAT.
*   STAT.N_PARMS will be updated to include this new parameter.  Nothing will
*   be done if STAT already contains the maximum allowable number of parameters.
}
module sys_STAT_PARM_REAL;
define sys_stat_parm_real;
%include 'sys2.ins.pas';

procedure sys_stat_parm_real (         {add floating point parameter to STAT}
  in      r: double;                   {data for parameter}
  in out  stat: sys_err_t);            {status code to add parameter to}
  val_param;

begin
  if stat.n_parms >= sys_err_t_max_parms then return; {all STAT parms filled ?}
  stat.n_parms := stat.n_parms + 1;    {make number of this parameter}

  stat.parm[stat.n_parms].fp2 := r;

  stat.parm_ind[stat.n_parms].dtype := sys_msg_dtype_fp2_k;
  stat.parm_ind[stat.n_parms].fp2_p :=
    addr(stat.parm[stat.n_parms].fp2);
  end;
