{   Module of routines for dealing with the executable used to run this
*   process.
*
*   This version is for the Microsoft Win32 API.
}
module sys_exec;
define sys_exec_tnam_get;
%include 'sys2.ins.pas';
%include 'string.ins.pas';
%include 'sys_sys2.ins.pas';
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

var
  tnam2: string_treename_t;            {scratch pathname}

begin
  tnam2.max := sizeof(tnam2.str);      {init local var string}
  sys_error_none (stat);               {init to no errors encountered}

  tnam2.len := GetModuleFileNameA (    {get pathname of executable for this process}
    handle_none_k,                     {indicate to use process executable}
    tnam2.str,                         {returned name string}
    tnam2.max);                        {max chars allowed to return}
  if tnam2.len = 0 then begin          {system call reported error ?}
    stat.sys := GetLastError;
    return;
    end;

  string_treename (tnam2, tnam);       {make full treename and pass back}
  end;
