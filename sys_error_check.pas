{   Subroutine SYS_ERROR_CHECK (STAT, SUBSYS_NAME, MSG_NAME, PARMS, N_PARMS)
*
*   If STAT is indicating an error condition, then print error message related
*   to that error code, print the user supplied error message, and
*   return TRUE.  Otherwise return FALSE.  PARMS is an array containing N_PARMS
*   number of paramters to pass to the message.  No message other than that
*   implied by STAT will be printed if either SUBSYS_NAME or MSG_NAME is all
*   blank.
}
module sys_error_check;
define sys_error_check;
%include 'sys2.ins.pas';

function sys_error_check (             {print message and return TRUE on error}
  in      stat: sys_err_t;             {error code}
  in      subsys_name: string;         {subsystem name of caller's message}
  in      msg_name: string;            {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t)  {number of parameters in PARMS}
  :boolean;                            {TRUE if STAT indicates error condition}
  val_param;

begin
  if not sys_error(stat) then begin    {no error ?}
    sys_error_check := false;          {indicate no error}
    return;
    end;
  sys_error_print (stat, subsys_name, msg_name, parms, n_parms); {print messages}
  sys_error_check := true;             {indicate error}
  end;
