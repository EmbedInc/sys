{   Module of routines that manipulate environment variables.
*
*   This is the main line of decent of these routines.  This version is
*   used only on systems that don't have any environment variables.
}
module sys_envvar;
define sys_envvar_del;
define sys_envvar_get;
define sys_envvar_set;
%include 'sys2.ins.pas';
%include 'string.ins.pas';
%include 'sys_sys2.ins.pas';
{
************************************************************
*
*   Subroutine SYS_ENVVAR_DEL (VARNAME, STAT)
*
*   Delete the environment variable named in VARNAME.
}
procedure sys_envvar_del (             {delete environment variable}
  in      varname: univ string_var_arg_t; {name of environment variable to delete}
  out     stat: sys_err_t);

begin
  sys_error_none (stat);
  end;
{
************************************************************
*
*   Subroutine SYS_ENVVAR_GET (VARNAME, VARVAL, STAT)
*
*   Return the value of an "environment" variable.  The environment variable's
*   name is VARNAME, and the returned value is a string in VARVAL.  STAT is
*   the completion status code.  When VARNAME is not the name of an existing
*   environment variable, then STAT is returned with status
*   SYS_STAT_ENVVAR_NOEXIST_K.
*
*   This version is for the main line of decent, which assumes that environment
*   variables don't exists at all.
}
procedure sys_envvar_get (             {get value of system "environment" variable}
  in      varname: univ string_var_arg_t; {name of environment variable}
  in out  varval: univ string_var_arg_t; {value of environment variable}
  out     stat: sys_err_t);

begin
  sys_stat_set (sys_subsys_k, sys_stat_envvar_noexist_k, stat); {set error status}
  sys_stat_parm_vstr (varname, stat);
  end;
{
************************************************************
*
*   Subroutine SYS_ENVVAR_SET (VARNAME, VARVAL)
*
*   Set the environment variable VARNAME to the string VARVAL.
}
procedure sys_envvar_set (             {set env variable value, created if needed}
  in      varname: univ string_var_arg_t; {name of environment variable}
  in      varval: univ string_var_arg_t; {value of environment variable}
  out     stat: sys_err_t);

begin
  sys_stat_set (sys_subsys_k, sys_stat_envvar_noset_k, stat); {set error status}
  sys_stat_parm_vstr (varname, stat);
  end;
