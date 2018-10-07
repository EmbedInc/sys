{   Subroutine SYS_MEM_ERROR (ADR, SUBSYS_NAME, MSG_NAME, PARMS, N_PARMS)
*
*   Print error message and bomb if ADR is NIL.  This is compatible with
*   SYS_MEM_ALLOC, which sets the ADR argument to NIL if it was unable to
*   allocate the requested virtual memory.  SUBSYS_NAME, and MSG_NAME indicate
*   the caller's specific message to print on error.  PARMS is an array
*   containing N_PARMS number of paramters to pass to the message.
*   No message other than that implied by STAT will be printed if either
*   SUBSYS_NAME or MSG_NAME is all blank.
}
module sys_mem_error;
define sys_mem_error;
%include 'sys2.ins.pas';

procedure sys_mem_error (              {print err message and bomb on no mem}
  in      adr: univ_ptr;               {adr of new mem, NIL triggers error}
  in      subsys_name: string;         {subsystem name of caller's message}
  in      msg_name: string;            {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param;

begin
  if adr <> nil then return;           {no error, memory was allocated ?}
  sys_message ('sys', 'no_mem');       {print general "no memory" message}
  sys_message_parms (subsys_name, msg_name, nil, 0); {print caller's specific message}
  sys_bomb;
  end;
