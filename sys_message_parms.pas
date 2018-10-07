{   Subroutine SYS_MESSAGE_PARMS (SUBSYS, MSG, PARMS, N_PARMS)
*
*   Write message from message file to standard output.  SUBSYS is the name of
*   the subsystem the message is coming from.  The message file name will be
*   <subsys>.msg.  MSG is the name of the specific message within the message
*   file indicated by SUBSYS.  PARMS is an array of pointers to parameters
*   whos values can be inserted into the message.  The parameters are referenced
*   by special commands in the message text.  The data types of the parameters
*   must match with those expected by the special commands in the message text.
*   N_PARMS is the number of parameters referenced by PARMS.
}
module sys_MESSAGE_PARMS;
define sys_message_parms;
%include 'sys2.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';

var
  gnam: string_treename_t :=           {generic message file name}
    [max := sizeof(gnam.str)];
  msg_name: string_var80_t :=          {message name}
    [max := sizeof(msg_name.str)];
  printed: boolean := true;            {TRUE if printed GNAM and MSG_NAME already}

procedure sys_message_parms (          {write message with parameters from caller}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string;                 {message name withing subsystem file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param;

var
  conn: file_conn_t;                   {connection handle to message}
  buf: string_var132_t;                {message text buffer}
  width: sys_int_machine_t;            {width to use for writing message}
  stat: sys_err_t;                     {completion status code}

label
  next_line, eof, leave;
{
********************************************************
*
*   Local subroutine PRINT_MSG_NAME
*
*   Print the name of the message instead of the message.
}
procedure print_msg_name;

begin
  string_upcase (gnam);                {make upper case for printing}
  string_upcase (msg_name);
  writeln ('Status "', msg_name.str:msg_name.len,
    '" in subsystem "', gnam.str:gnam.len, '".');
  printed := true;                     {prevent printing message twice}
  end;
{
********************************************************
*
*   Start of main routine.
}
begin
  buf.max := sizeof(buf.str);          {init var string}

  message_enter_level := message_enter_level + 1; {update recursive nesting level}
  if message_enter_level > 1 then begin {this is a recursive call ?}
    if not printed then begin
      writeln;
      writeln ('Recursive call to message routine.  Original message:');
      print_msg_name;
      end;
    end;

  string_vstring (gnam, subsys, sizeof(subsys)); {get generic message file name}
  string_unpad (gnam);                 {delete trailing blanks}
  string_vstring (msg_name, msg, sizeof(msg)); {get name of message within file}
  string_unpad (msg_name);             {delete trailing blanks}
  printed := false;                    {not printed new message yet}
  if (gnam.len <= 0) or (msg_name.len <= 0) then goto leave; {nothing to print ?}

  if message_enter_level > 1 then begin {this is a recursive call ?}
    writeln;
    writeln ('Message requested while attempting to print previous message:');
    print_msg_name;
    goto leave;
    end;

  file_open_read_msg (                 {open connection to this message}
    gnam,                              {generic message file name}
    msg_name,                          {name of message within file}
    parms,                             {parameters to be inserted into message}
    n_parms,                           {number of paramters referenced in PARMS}
    conn,                              {returned connection handle to message}
    stat);
  if file_not_found(stat) then begin   {couldn't find message or message files ?}
    print_msg_name;
    goto leave;
    end;
  if sys_error(stat) then begin
    print_msg_name;
    sys_error_print (stat, 'sys', 'open_msg', nil, 0);
    goto leave;
    end;

  width := sys_width_stdout - 1;       {max width to allow for message lines}

next_line:                             {back here each new line in message}
  file_read_msg (conn, width, buf, stat); {read next line from message}
  if file_eof(stat) then goto eof;     {hit end of message ?}
  if sys_error(stat) then begin
    print_msg_name;
    sys_error_print (stat, 'sys', 'read_msg', nil, 0);
    goto eof;
    end;
  writeln (buf.str:buf.len);           {write line of message to output}
  goto next_line;                      {back for next message line}

eof:                                   {encountered end of message}
  printed := true;                     {we definately printed our message}
  file_close (conn);                   {close connection to message}

leave:                                 {must exit thru here}
  message_enter_level := message_enter_level - 1; {one less recursion level}
  end;
