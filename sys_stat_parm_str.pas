{   Subroutine SYS_STAT_PARM_STR (S, STAT)
*
*   Add the string S as the next parameter to STAT.
*   STAT.N_PARMS will be updated to include this new parameter.  Nothing will
*   be done if STAT already contains the maximum allowable number of parameters.
}
module sys_STAT_PARM_STR;
define sys_stat_parm_str;
%include 'sys2.ins.pas';
%include 'string.ins.pas';

procedure sys_stat_parm_str (          {add string parameter to STAT}
  in      s: string;                   {data for parameter}
  in out  stat: sys_err_t);            {status code to add parameter to}
  val_param;

begin
  if stat.n_parms >= sys_err_t_max_parms then return; {all STAT parms filled ?}
  stat.n_parms := stat.n_parms + 1;    {make number of this parameter}

  stat.parm[stat.n_parms].vstr.max := sizeof(stat.parm[stat.n_parms].vstr.str);
  string_vstring (stat.parm[stat.n_parms].vstr, s, sizeof(s));

  stat.parm_ind[stat.n_parms].dtype := sys_msg_dtype_vstr_k;
  stat.parm_ind[stat.n_parms].vstr_p :=
    univ_ptr(addr(stat.parm[stat.n_parms].vstr));
  end;
