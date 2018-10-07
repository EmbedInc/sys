{   Subroutine SYS_MSG_PARM_STR (MSG_PARM,S)
*
*   Fill in the message parameter MSG_PARM.  This is usually one entry in
*   an array of message parameters.
*   S is the parameter that will be referenced, and is a STRING.
}
module sys_MSG_PARM_STR;
define sys_msg_parm_str;
%include 'sys2.ins.pas';
%include 'string.ins.pas';

procedure sys_msg_parm_str (           {add string parameter to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      s: string);                  {data for parameter}

var
  vs: string_var132_t;                 {local string for finding string length}

begin
  vs.max := sizeof(vs.str);            {init local var string}

  msg_parm.dtype := sys_msg_dtype_str_k; {indicate data type of this parameter}
  string_vstring (vs, s, sizeof(s));   {copy into local var string}
  msg_parm.str_len := vs.len;          {set useable length of string}
  msg_parm.str_p := addr(s);
  end;
