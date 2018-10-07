{   Subroutine SYS_ERROR_PRINT (STAT, SUBSYS_NAME, MSG_NAME, PARMS, N_PARMS)
*
*   Print error message if STAT is indicating an abnormal condition.  Nothing
*   is done if STAT is indicating the "normal" condition.  If a message is
*   printed due to STAT, then the caller's message indicated by SUBSYS_NAME,
*   MSG_NAME, PARMS, and N_PARMS is also printed.  See SYS_MESSAGE_PARMS
*   for details on these parameters.
}
module sys_error_print;
define sys_error_print;
%include 'sys2.ins.pas';
%include 'string.ins.pas';

procedure sys_error_print (            {print system error message}
  in      stat: sys_err_t;             {system error code to print message for}
  in      subsys_name: string;         {subsystem name of caller's message}
  in      msg_name: string;            {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param;

var
  emess: string_var132_t;              {scratch error message string}
  token: string_var16_t;               {scratch token for integer/string conversion}
  subsys_v: string_var80_t;            {subsystem name}
  message_v: string_var80_t;           {message name within subsystem}

label
  punt, u_err;

begin
  emess.max := sizeof(emess.str);      {init local var strings}
  token.max := sizeof(token.str);
  subsys_v.max := sizeof(subsys_v.str);
  message_v.max := sizeof(message_v.str);
{
****************************
*
*   Process case where STAT is indicating a Cognivision error status.
}
  if stat.err then begin               {indicating a non-system error ?}
{
*   Get the Cognivision subsystem name in SUBSYS_V.
}
    subsys_v.len := 0;
    case stat.subsys of
%include 'sys_subsys_resolve.ins.pas';
otherwise
      if stat.subsys > 0
        then begin                     {user subsystem number}
          string_appends (subsys_v, 'subsys');
          string_f_int (token, stat.subsys); {make subsystem number string}
          string_append (subsys_v, token);
          end
        else begin                     {unrecognized Cognivision subsystem number}
          goto punt;                   {just print raw numbers from status code}
          end
        ;
      end;                             {done with subsystem number cases}
    string_fill (subsys_v);            {finish subsystem name string}
{
*   Write the appropriate error message.
}
    message_v.len := 0;
    if stat.code > 0
      then begin                       {normal CODE value}
        string_appends (message_v, 'err');
        string_f_int (token, stat.code); {make code number string}
        string_append (message_v, token);
        string_fill (message_v);       {finish message name string}
        sys_message_parms (subsys_v.str, message_v.str, stat.parm_ind, stat.n_parms);
        end
      else begin                       {illegal CODE value}
punt:                                  {jump here to just print raw info}
        emess.len := 0;
        string_appends (emess, 'ERROR, subsystem =');
        string_append1 (emess, ' ');
        string_f_int32 (token, stat.subsys);
        string_append (emess, token);
        string_appends (emess, ', code =');
        string_append1 (emess, ' ');
        string_f_int32 (token, stat.code);
        string_append (emess, token);
        string_append1 (emess, '.');
        writeln (emess.str:emess.len);
        end
      ;
    goto u_err;                        {print user's error message}
    end;                               {done with STAT is non-system status}
{
****************************
*
*   Process case where STAT is indicating a system error.
}
  if sys_sys_message (stat.sys)
    then goto u_err;                   {go print user's error message}
{
****************************
*
*   STAT indicates no error condition at all.
}
  return;
{
****************************
*
*   All done printing message implied by STAT.  Now print user's specific message.
}
u_err:                                 {jump here to print caller's error message}
  sys_message_parms (subsys_name, msg_name, parms, n_parms); {printer caller's message}
  end;
