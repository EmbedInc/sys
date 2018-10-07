{   Subroutine SYS_ERROR_ABORT (STAT, SUBSYS_NAME, MSG_NAME)
*
*   If STAT is indicating an error condition, then print error message related
*   to that error code, print the caller's message indicated by SUBSYS_NAME
*   and MSG_NAME, and then bomb out of the program.  PARMS is an array containing
*   N_PARMS number of paramters to pass to the message.  No message other than that
*   implied by STAT will be printed if either SUBSYS_NAME or MSG_NAME is all
*   blank.
}
module sys_error_abort;
define sys_error_abort;
%include 'sys2.ins.pas';

procedure sys_error_abort (            {print message and abort only if error}
  in      stat: sys_err_t;             {error code}
  in      subsys_name: string;         {subsystem name of caller's message}
  in      msg_name: string;            {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param;

begin
  if not sys_error(stat) then return;  {no error indicated ?}
  sys_error_print (stat, subsys_name, msg_name, parms, n_parms); {print messages}
  sys_bomb;                            {abort with error}
  end;
