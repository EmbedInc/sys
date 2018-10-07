{   Subroutine SYS_SYS_ERR_ABORT (SUBSYS, MSG, PARMS, N_PARMS, YESNO_ERR)
*
*   Abort with error message if YESNO_ERR is not set to 0.  In that case,
*   it is assumed that the ERRNO global error number is valid, and reflects
*   the system error.
}
module sys_SYS_ERR_ABORT;
define sys_sys_err_abort;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';

procedure sys_sys_err_abort (          {abort with error given error yes/no flag}
  in      subsys: string;              {name of subsystem of error message}
  in      msg: string;                 {error message name within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t;  {number of parameters in PARMS}
  in      yesno_err: sys_sys_yesno_err_t); {error yes/no flag returned by sys call}
  val_param;

var
  stat: sys_err_t;                     {error status code}

begin
  if yesno_err >= 0 then return;       {no error ?}

  sys_error_none (stat);               {init error status descriptor}
  stat.sys := errno;                   {get system error number}
  errno := 0;                          {reset system status to no error}

  if stat.sys = 0
    then begin                         {no system error indicated}
      sys_message_bomb (subsys, msg, parms, n_parms);
      end
    else begin                         {system is signalling an error}
      sys_error_print (stat, subsys, msg, parms, n_parms);
      sys_bomb;
      end
    ;
  end;
