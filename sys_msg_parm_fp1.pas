{   Subroutine SYS_MSG_PARM_FP1 (MSG_PARM, R)
*
*   Fill in the message parameter MSG_PARM.  This is usually one entry in
*   an array of message parameters.
*   R is the parameter that will be referenced, and is a single precision real.
}
module sys_msg_parm_fp1;
define sys_msg_parm_fp1;
%include 'sys2.ins.pas';

procedure sys_msg_parm_fp1 (           {add single prec floating parm to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      r: single);                  {data for parameter}

begin
  msg_parm.dtype := sys_msg_dtype_fp1_k; {indicate data type of this parameter}
  msg_parm.fp1_p := addr(r);
  end;

