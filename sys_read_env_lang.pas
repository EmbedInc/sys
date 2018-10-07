{   Subroutine SYS_READ_ENV_LANG (LNAME,LANG)
*
*   Read and process the <language>.lan environment descriptor files, where
*   <language> is the name of the language in LNAME.  LANG is returned as
*   the descriptor for the language.
}
module sys_READ_ENV_LANG;
define sys_read_env_lang;
%include 'sys2.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';

const
  n_commands = 9;                      {number of commands in env files}
  max_command_len = 17;                {max allowed command name length}

  cmd_name_len =                       {actual storage length for command name}
    max_command_len + 1;

type
  cmd_t =                              {one command name}
    array[1..cmd_name_len] of char;

  cmds_t =                             {array of all command names}
    array[1..n_commands] of cmd_t;

var
  cmds: cmds_t := [                    {all the env file command names}
    'DECIMAL          ',               {1}
    'DIGITS_GROUP_CHAR',               {2}
    'DIGITS_GROUP_SIZE',               {3}
    'EXP10            ',               {4}
    'MSG_ESC          ',               {5}
    'MSG_ECMD_PARM    ',               {6}
    'MSG_PARM_STRING  ',               {7}
    'MSG_PARM_INT     ',               {8}
    'MSG_PARM_FLOAT   '];              {9}

procedure sys_read_env_lang (          {read <language>.lan environment file set}
  in      lname: univ string_var_arg_t; {name of language to return info about}
  out     lang: sys_lang_t);           {language descriptor to fill in}

var
  stat: sys_err_t;                     {completion status code}
  conn: file_conn_t;                   {connection to our environment files}
  buf: string_var132_t;                {one line input buffer}
  p: string_index_t;                   {input line parse index}
  cmd: string_var32_t;                 {command name}
  parm: string_var32_t;                {command parameter}
  pick: sys_int_machine_t;             {number of token picked from list}
  ecmd: sys_msg_ecmd_k_t;              {index to .msg file escaped commands}
  ecmd_parm: sys_msg_parm_k_t;         {index to .msg parm subcommands}
  fnam: string_treename_t;             {.lan environment file set name}

label
  next_line, bad_parm, eof;
{
************************************************************
*
*   Local subroutine READ_ERROR
*   This subroutine is local to READ_ENV_FILES.
*
*   An error has occured while reading the environment files.  Print general
*   information about the error and bomb.  Specific information has already
*   been printed.
}
procedure read_error;
  options (noreturn);

var
  token: string_var16_t;               {scratch token for string conversion}
  msg: string_treename_t;              {output message buffer}

begin
  token.max := sizeof(token.str);      {init var strings}
  msg.max := sizeof(msg.str);

  writeln ('Error reading ', lang.name.str:lang.name.len,
    '.lan language descriptor file set.');

  msg.len := 0;
  string_appends (msg, 'Error on line');
  string_append1 (msg, ' ');
  string_f_int (token, conn.lnum);
  string_append (msg, token);
  string_appends (msg, ' of file');
  writeln (msg.str:msg.len);
  writeln (conn.tnam.str:conn.tnam.len);
  sys_bomb;
  end;
{
************************************************************
*
*   Start of main routine.
}
begin
  buf.max := sizeof(buf.str);          {init var strings}
  cmd.max := sizeof(cmd.str);
  parm.max := sizeof(parm.str);
  fnam.max := sizeof(fnam.str);
{
*   Init LANG language descriptor data structure.
}
  lang.name.max := sizeof(lang.name.str);
  lang.exponent.max := sizeof(lang.exponent.str);
  lang.msg_esc.max := sizeof(lang.msg_esc.str);
  for ecmd := firstof(ecmd) to lastof(ecmd) do begin {each .msg escape command}
    lang.msg_ecmd[ecmd].max :=
      sizeof(lang.msg_ecmd[ecmd].str);
    lang.msg_ecmd[ecmd].len := 0;
    end;
  for ecmd_parm := firstof(ecmd_parm) to lastof(ecmd_parm) do begin
    lang.msg_ecmd_parm[ecmd_parm].max :=
      sizeof(lang.msg_ecmd_parm[ecmd_parm].str);
    lang.msg_ecmd_parm[ecmd_parm].len := 0;
    end;
{
*   Set hard wired defaults for initial language descriptor values.
}
  lang.decimal := '.';
  lang.digits_group_c := ',';
  lang.digits_group_n := 3;
  string_vstring (lang.exponent, 'E', 1);
  string_vstring (lang.msg_esc, '%', 1);
  string_vstring (lang.msg_ecmd[sys_msg_ecmd_parm_k], 'P', 1);
  string_vstring (lang.msg_ecmd_parm[sys_msg_parm_str_k], 'S', 1);
  string_vstring (lang.msg_ecmd_parm[sys_msg_parm_int_k], 'I', 1);
  string_vstring (lang.msg_ecmd_parm[sys_msg_parm_float_k], 'F', 1);

  string_copy (lname, lang.name);      {fill in language name field}
  string_upcase (lang.name);           {language names are always upper case}
  string_copy (lname, fnam);           {init language file generic name}
  string_downcase (fnam);              {.lan file names a always lower case}
  string_appendn (fnam, '.lan', 4);    {make full .lan file set name}

  file_open_read_env (                 {open our environment files for read}
    fnam,                              {generic name of env files}
    '',                                {file name suffix}
    true,                              {read in global to local order}
    conn,                              {returned connection handle}
    stat);
  if file_not_found(stat) then return; {no .lan files for this language ?}
  if sys_error(stat) then begin
    writeln ('Unable to open ', lang.name.str:lang.name.len,
      '.lan language descriptor file set.');
    sys_error_print (stat, '', '', nil, 0);
    sys_bomb;
    end;

next_line:                             {back here each new input line}
  file_read_env (conn, buf, stat);     {read next line from file set}
  if file_eof(stat) then goto eof;     {hit end of last file ?}
  if sys_error(stat) then read_error;
  p := 1;                              {init parse index into BUF}
  string_token (buf, p, cmd, stat);    {get command name}
  if sys_error(stat) then read_error;
  string_upcase (cmd);                 {make upper case for token matching}
  string_tkpick_s (cmd, cmds, sizeof(cmds), pick); {pick command token from list}
  case pick of
{
*   DECIMAL <decimal "point" character>
*
*   Declare the character that separates the integer part from the fraction part
*   of a real number.  For example, in English this is ".", and in German ",".
}
1: begin
  string_token (buf, p, parm, stat);
  if sys_error(stat) then goto bad_parm;
  if parm.len <> 1 then goto bad_parm;
  lang.decimal := parm.str[1];
  end;
{
*   DIGITS_GROUP_CHAR <char>
*
*   Declare the optional separater character used to group digits in an integer.
*   For example, in English this is ",", and in German ".".
}
2: begin
  string_token (buf, p, parm, stat);
  if sys_error(stat) then goto bad_parm;
  if parm.len <> 1 then goto bad_parm;
  lang.digits_group_c := parm.str[1];
  end;
{
*   DIGITS_GROUP_SIZE n
*
*   Declare the number of digits between successive DIGTIS_GROUP_CHARs.
*   For example, in English this is 3.
}
3: begin
  string_token (buf, p, parm, stat);
  if sys_error(stat) then goto bad_parm;
  string_t_int (parm, lang.digits_group_n, stat);
  if sys_error(stat) then goto bad_parm;
  end;
{
*   EXP10 <string>
*
*   Declare the string that separates the integer and fraction parts of a real
*   number from is power of 10 exponent.  This is customarily "E" since this
*   is required by FORTRAN.  For example, the real number "1.23E3" has the
*   same value as "1230".
}
4: begin
  string_token (buf, p, parm, stat);
  if sys_error(stat) then goto bad_parm;
  if parm.len <= 0 then goto bad_parm;
  string_copy (parm, lang.exponent);
  end;
{
*   MSG_ESC <string>
*
*   Specify the "escape" string used in the message files.  This escape string
*   precedes any directives imbedded directly in the message text, such as
*   parameter references.  Note that this is different from formatting directives
*   that take up a whole line.
}
5: begin
  string_token (buf, p, parm, stat);
  string_upcase (parm);
  if sys_error(stat) then goto bad_parm;
  if parm.len <= 0 then goto bad_parm;
  string_copy (parm, lang.msg_esc);
  end;
{
*   MSG_PARM <string>
*
*   Specify the name of the "substitute parameter" .msg file command.
}
6: begin
  string_token (buf, p, parm, stat);
  string_upcase (parm);
  if sys_error(stat) then goto bad_parm;
  if parm.len <= 0 then goto bad_parm;
  string_copy (parm, lang.msg_ecmd[sys_msg_ecmd_parm_k]);
  end;
{
*   MSG_PARM_STRING <string>
*
*   Specify the name of the STRING data type subcommand to the SUBSTITUTE PARM
*   .msg file escape command.
}
7: begin
  string_token (buf, p, parm, stat);
  string_upcase (parm);
  if sys_error(stat) then goto bad_parm;
  if parm.len <= 0 then goto bad_parm;
  string_copy (parm, lang.msg_ecmd_parm[sys_msg_parm_str_k]);
  end;
{
*   MSG_PARM_INT <string>
*
*   Specify the name of the INTEGER data type subcommand to the SUBSTITUTE PARM
*   .msg file escape command.
}
8: begin
  string_token (buf, p, parm, stat);
  string_upcase (parm);
  if sys_error(stat) then goto bad_parm;
  if parm.len <= 0 then goto bad_parm;
  string_copy (parm, lang.msg_ecmd_parm[sys_msg_parm_int_k]);
  end;
{
*   MSG_PARM_FLOAT <string>
*
*   Specify the name of the FLOATING POINT data type subcommand to the
*   SUBSTITUTE PARM .msg file escape command.
}
9: begin
  string_token (buf, p, parm, stat);
  string_upcase (parm);
  if sys_error(stat) then goto bad_parm;
  if parm.len <= 0 then goto bad_parm;
  string_copy (parm, lang.msg_ecmd_parm[sys_msg_parm_float_k]);
  end;
{
*   Unrecognized command name.
}
otherwise
  writeln ('Unrecognized command name "', cmd.str:cmd.len, '".');
  read_error;
  end;                                 {end of command name cases}
{
*   Done parsing a command.  Make sure there are no additional tokens on line.
}
  string_token (buf, p, parm, stat);
  if not string_eos(stat) then begin
    writeln ('Extraneous token "', parm.str:parm.len,
      '" for command "', cmd.str:cmd.len, '".');
    read_error;
    end;
  goto next_line;                      {back and process next env file line}

bad_parm:                              {jump here on bad parameter to command}
  writeln ('Bad parameter "', parm.str:parm.len,
    '" to command "', cmd.str:cmd.len, '".');
  read_error;

eof:                                   {encountered end of environment file set}
  file_close (conn);                   {close connection to environment file set}
  end;
