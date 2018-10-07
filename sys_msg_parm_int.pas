{   Subroutine SYS_MSG_PARM_INT (MSG_PARM, S)
*
*   Fill in the message parameter MSG_PARM.  This is usually one entry in
*   an array of message parameters.
*   I is the parameter that will be referenced, and is a machine integer.
}
module sys_MSG_PARM_INT;
define sys_msg_parm_int;
%include 'sys2.ins.pas';

procedure sys_msg_parm_int (           {add integer parameter to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      i: sys_int_machine_t);       {data for parameter}

begin
  msg_parm.dtype := sys_msg_dtype_int_k; {indicate data type of this parameter}
  msg_parm.int_p := addr(i);
  end;
