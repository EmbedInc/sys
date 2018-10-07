{   Subroutine SYS_MSG_PARM_FP2 (MSG_PARM, R)
*
*   Fill in the message parameter MSG_PARM.  This is usually one entry in
*   an array of message parameters.
*   R is the parameter that will be referenced, and is a single precision real.
}
module sys_msg_parm_fp2;
define sys_msg_parm_fp2;
%include 'sys2.ins.pas';

procedure sys_msg_parm_fp2 (           {add double prec floating parm to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      r: double);                  {data for parameter}

begin
  msg_parm.dtype := sys_msg_dtype_fp2_k; {indicate data type of this parameter}
  msg_parm.fp2_p := addr(r);
  end;
