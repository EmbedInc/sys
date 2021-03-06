module sys_stat_parm_vstr;
define sys_stat_parm_char;
define sys_stat_parm_vstr;
%include 'sys2.ins.pas';
%include 'string.ins.pas';
{
*****************************************************************
*
*   Subroutine SYS_STAT_PARM_VSTR (S, STAT)
*
*   Add the variable string S as the next parameter to STAT.
*   STAT.N_PARMS will be updated to include this new parameter.  Nothing will
*   be done if STAT already contains the maximum allowable number of parameters.
}
procedure sys_stat_parm_vstr (         {add var string parameter to STAT}
  in      s: univ string_var_arg_t;    {data for parameter}
  in out  stat: sys_err_t);            {status code to add parameter to}
  val_param;

begin
  if stat.n_parms >= sys_err_t_max_parms then return; {all STAT parms filled ?}
  stat.n_parms := stat.n_parms + 1;    {make number of this parameter}

  stat.parm[stat.n_parms].vstr.max := sizeof(stat.parm[stat.n_parms].vstr.str);
  string_copy (s, stat.parm[stat.n_parms].vstr);

  stat.parm_ind[stat.n_parms].dtype := sys_msg_dtype_vstr_k;
  stat.parm_ind[stat.n_parms].vstr_p :=
    univ_ptr(addr(stat.parm[stat.n_parms].vstr));
  end;
{
*****************************************************************
*
*   Subroutine SYS_STAT_PARM_CHAR (C, STAT)
*
*   Add the character C as the next parameter to STAT.
*   STAT.N_PARMS will be updated to include this new parameter.  Nothing will
*   be done if STAT already contains the maximum allowable number of parameters.
}
procedure sys_stat_parm_char (         {add character parameter to STAT}
  in      c: char;                     {data for parameter}
  in out  stat: sys_err_t);            {status code to add parameter to}
  val_param;

begin
  if stat.n_parms >= sys_err_t_max_parms then return; {all STAT parms filled ?}
  stat.n_parms := stat.n_parms + 1;    {make number of this parameter}

  stat.parm[stat.n_parms].vstr.max := sizeof(stat.parm[stat.n_parms].vstr.str);
  stat.parm[stat.n_parms].vstr.str[1] := c;
  stat.parm[stat.n_parms].vstr.len := 1;

  stat.parm_ind[stat.n_parms].dtype := sys_msg_dtype_vstr_k;
  stat.parm_ind[stat.n_parms].vstr_p :=
    univ_ptr(addr(stat.parm[stat.n_parms].vstr));
  end;
