module sys_message_resolve;
define sys_message_resolve;
%include 'sys2.ins.pas';
%include 'string.ins.pas';
{
********************************************************************************
*
*   Subroutine SYS_MESSAGE_RESOLVE (SUBSYS, MSG, SUBSV, MSGV)
*
*   Resolve the absolute subsystem and message names of a message.  SUBSYS and
*   MSG are the usual strings for specifying a subsystem and message within that
*   subsystem.  These strings can have defaults, which this routine resolves.
*   The final subsystem and message names are also returned as var strings.
*
*   SUBSYS is the name of the subsystem the message is from.  It may be the
*   empty string (after truncating trailing blanks) to indicate default.  In
*   that case, the program name followed by "_prog" is used as the subsystem
*   name.  For example, if SUBSYS is blank in the program "xyzz", then the
*   default subsystem name of "xyzz_prog" will be used.
*
*   MSG is nominally name of the message within the subsystem.  However, it can
*   have two tokens.  In that case, the first is the subsystem name and the
*   second the message name.  Specifying the subsystem name in MSG overrides
*   SUBSYS.  The contents of SUBSYS becomes irrelevant in that case.
}
procedure sys_message_resolve (        {resolve full absolute subsystem and message names}
  in      subsys: string;              {subsystem name, default is <progname>_prog}
  in      msg: string;                 {[subsys] message-name}
  in out  subsv: univ string_var_arg_t; {returned subsystem name}
  in out  msgv: univ string_var_arg_t); {returned message name within subsystem}
  val_param;

var
  str: string_var256_t;                {string to parse}
  p: string_index_t;                   {parse index}
  tk: string_var256_t;                 {scratch token}
  stat: sys_err_t;                     {completion status}

begin
  str.max := size_char(str.str);       {init local var strings}
  tk.max := size_char(tk.str);

  string_vstring (subsv, subsys, sizeof(subsys)); {make var string from SUBSYS}
  string_unpad (subsv);                {delete trailing blanks}

  string_vstring (str, msg, sizeof(msg)); {make var string from MSG}
  string_unpad (str);                  {delete trailing blanks}
  p := 1;                              {init parse index into MSG string}
  string_token (str, p, tk, stat);     {get first MSG token into TK}
  if p <= str.len
    then begin                         {more left in MSG, token was subsystem name}
      string_copy (tk, subsv);         {set subsystem name}
      string_token (str, p, msgv, stat); {get the message name}
      end
    else begin                         {MSG is message name only}
      string_copy (tk, msgv);          {set message name}
      end
    ;

  if subsv.len <= 0 then begin         {didn't get subsystem name at all ?}
    string_progname (subsv);           {init subsystem name with program name}
    string_appends (subsv, '_prog'(0)); {append "_prog"}
    end;
  end;
