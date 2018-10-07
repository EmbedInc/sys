{   Subroutine SYS_MESSAGE_BOMB (SUBSYS, MSG, PARMS, N_PARMS)
*
*   Print message and then abort program with an error condition.
}
module sys_MESSAGE_BOMB;
define sys_message_bomb;
%include 'sys2.ins.pas';

procedure sys_message_bomb (           {write message and abort program with error}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string;                 {message name withing subsystem file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  options (val_param, noreturn);

begin
  sys_message_parms (subsys, msg, parms, n_parms);
  sys_bomb;
  end;
