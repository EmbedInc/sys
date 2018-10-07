{   Subroutine SYS_MSG_PARM_DBLR (MSG_PARM,S)
*
*   Fill in the message parameter MSG_PARM.  This is usually one entry in
*   an array of message parameters.
*   D is the parameter that will be referenced, and is a double precision real.
}
module sys_MSG_PARM_DBLR;
define sys_msg_parm_dblr;
%include 'sys2.ins.pas';

procedure sys_msg_parm_dblr (          {add double prec floating parameter to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      d: double);                  {data for parameter}

begin
  msg_parm.dtype := sys_msg_dtype_dblr_k; {indicate data type of this parameter}
  msg_parm.dblr_p := addr(d);
  end;
