{   Module of routines that directly manipulate system error codes.
*
*   This version is for any operating system where the system error code
*   is an integer with no error indicated by 0.
}
module sys_error;
define sys_error;
define sys_error_none;
%include 'sys2.ins.pas';
{
***********************************************************
*
*   function SYS_ERROR (STAT)
*
*   Return TRUE if STAT indicates anything other than "normal" status.
}
function sys_error (                   {determine whether error code signals error}
  in      stat: sys_err_t)             {system error code to check}
  :boolean;                            {TRUE if STAT indicates error condition}

begin
  sys_error := stat.err or (stat.sys <> 0);
  end;
{
***********************************************************
*
*   Subroutine SYS_ERROR_NONE (STAT)
*
*   Return the error status descriptor STAT to indicate no error.
}
procedure sys_error_none (             {return NO ERROR error status code}
  out     stat: sys_err_t);            {returned error status code}

begin
  stat.err := false;
  stat.subsys := 0;
  stat.code := 0;
  stat.sys := 0;
  stat.n_parms := 0;
  end;
