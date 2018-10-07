{   Subroutine SYS_MSG_PARM_VSTR (MSG_PARM,S)
*
*   Fill in the message parameter MSG_PARM.  This is usually one entry in
*   an array of message parameters.
*   S is the parameter that will be referenced, and is a var string.
}
module sys_MSG_PARM_VSTR;
define sys_msg_parm_vstr;
%include 'sys2.ins.pas';

procedure sys_msg_parm_vstr (          {add var string parameter to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      s: univ string_var_arg_t);   {data for parameter}

begin
  msg_parm.dtype := sys_msg_dtype_vstr_k; {indicate data type of this parameter}
  msg_parm.vstr_p := addr(s);
  end;
