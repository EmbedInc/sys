module sys_width_stdout;
define sys_width_stdout;
define sys_height_stdout;
%include 'sys2.ins.pas';
%include 'string.ins.pas';

const
  width_default_k = 78;
  height_default_k = 40;

var
  envvar_columns: string_var16_t :=    {name of COLUMNS environment variable}
    [str := 'COLUMNS', len := 7, max := sizeof(envvar_columns.str)];
  envvar_lines: string_var16_t :=      {name of LINES environment variable}
    [str := 'LINES', len := 5, max := sizeof(envvar_lines.str)];
{
***************************************************************
*
*   Function SYS_WIDTH_STDOUT
*
*   Return the width in characters of standard output.
}
function sys_width_stdout              {return character width of standard output}
  :sys_int_machine_t;
  val_param;

const
  max_msg_parms = 2;                   {max parameters we can pass to a message}

var
  token: string_var16_t;               {scratch token}
  i: sys_int_machine_t;                {scratch integer}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;
  stat: sys_err_t;                     {completion status code}

begin
  token.max := sizeof(token.str);      {init local var string}

  sys_envvar_get (envvar_columns, token, stat); {try to read environment variable}
  if sys_error(stat) then begin        {couldn't get environment variable value}
    sys_width_stdout := width_default_k; {return default value}
    return;                            {all done}
    end;

  string_t_int (token, i, stat);       {convert env var value to an integer}
  if sys_error(stat) then begin
    sys_msg_parm_vstr (msg_parm[1], token);
    sys_msg_parm_vstr (msg_parm[2], envvar_columns);
    sys_error_abort (stat, 'sys', 'envvar_val_bad', msg_parm, 2);
    end;
  sys_width_stdout := i;               {pass back value from environment variable}
  end;
{
***************************************************************
*
*   Function SYS_HEIGHT_STDOUT
*
*   Return the height in characters of the displayed part of standard output.
}
function sys_height_stdout             {return character height of standard output}
  :sys_int_machine_t;
  val_param;

const
  max_msg_parms = 2;                   {max parameters we can pass to a message}

var
  token: string_var16_t;               {scratch token}
  i: sys_int_machine_t;                {scratch integer}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;
  stat: sys_err_t;                     {completion status code}

begin
  token.max := sizeof(token.str);      {init local var string}

  sys_envvar_get (envvar_lines, token, stat); {try to read environment variable}
  if sys_error(stat) then begin        {couldn't get environment variable value}
    sys_height_stdout := height_default_k; {return default value}
    return;
    end;

  string_t_int (token, i, stat);       {convert env var value to an integer}
  if sys_error(stat) then begin
    sys_msg_parm_vstr (msg_parm[1], token);
    sys_msg_parm_vstr (msg_parm[2], envvar_lines);
    sys_error_abort (stat, 'sys', 'envvar_val_bad', msg_parm, 2);
    end;
  sys_height_stdout := i;              {pass back value from environment variable}
  end;
