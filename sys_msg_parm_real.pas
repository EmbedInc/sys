{   Subroutine SYS_MSG_PARM_REAL (MSG_PARM, S)
*
*   Fill in the message parameter MSG_PARM.  This is usually one entry in
*   an array of message parameters.
*   R is the parameter that will be referenced, and is of type REAL.
}
module sys_MSG_PARM_REAL;
define sys_msg_parm_real;
%include 'sys2.ins.pas';

procedure sys_msg_parm_real (          {add single prec floating parameter to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      r: real);                    {data for parameter}

begin
  case sizeof(real) of
sizeof(single): begin                  {REAL is same as SINGLE}
      msg_parm.dtype := sys_msg_dtype_fp1_k; {indicate data type of this parameter}
      msg_parm.fp1_p := univ_ptr(addr(r));
      end;
sizeof(double): begin                  {REAL is same as DOUBLE}
      msg_parm.dtype := sys_msg_dtype_fp2_k; {indicate data type of this parameter}
      msg_parm.fp2_p := univ_ptr(addr(r));
      end;
otherwise
    writeln ('REAL is not the same size as SINGLE or DOUBLE. (SYS_MSG_PARM_REAL)');
    sys_bomb;
    end;
  end;
