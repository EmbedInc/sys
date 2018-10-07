{   Subroutine SYS_ERROR_STRING (STAT, MSTR)
*
*   Return the string associated with the completion status code STAT.
*   The empty string is returned if STAT is indicating normal condition.
}
module sys_error_string;
define sys_error_string;
%include 'sys2.ins.pas';
%include 'string.ins.pas';

procedure sys_error_string (           {return string associated with status code}
  in      stat: sys_err_t;             {status code to return string for}
  in out  mstr: univ string_var_arg_t); {returned string, empty on no error}
  val_param;

var
  token: string_var16_t;               {scratch token for integer/string conversion}
  subsys_v: string_var80_t;            {subsystem name}
  message_v: string_var80_t;           {message name within subsystem}

label
  punt;

begin
  token.max := sizeof(token.str);      {init local var strings}
  subsys_v.max := sizeof(subsys_v.str);
  message_v.max := sizeof(message_v.str);
{
****************************
*
*   Process case where STAT is indicating a Cognivision error status.
}
  if stat.err then begin               {indicating a non-system error ?}
    if stat.code <= 0 then goto punt;  {not a normal status code value ?}
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
*   Make the message name within the subsystem.
}
    string_vstring (message_v, 'err', 3); {init static part of message name}
    string_f_int (token, stat.code);   {make code number string}
    string_append (message_v, token);
    string_fill (message_v);           {finish message name string}

    string_f_message (                 {get string from the selected message}
      mstr,                            {returned string}
      subsys_v.str,                    {message file name}
      message_v.str,                   {name of message within message file}
      stat.parm_ind,                   {array of parameters for the message}
      stat.n_parms);                   {number of parameters for the message}
    return;
{
*   Jump here if unable to make message file and message names.
}
punt:
    string_vstring (mstr, 'ERROR, subsystem = '(0), -1);
    string_f_int32 (token, stat.subsys);
    string_append (mstr, token);
    string_appends (mstr, ', code = '(0));
    string_f_int32 (token, stat.code);
    string_append (mstr, token);
    string_append1 (mstr, '.');
    return;
    end;                               {done with STAT is non-system status}
{
****************************
*
*   STAT is not indicating a Cognivision status.
}
  if sys_sys_message_get (stat.sys, mstr) {get system message string on system err}
    then return;

  mstr.len := 0;                       {not a system error either}
  return;
  end;
