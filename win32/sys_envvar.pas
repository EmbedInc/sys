{   Module of routines that manipulate environment variables.
*
*   This version is for the Microsoft Win32 API.
}
module sys_envvar;
define sys_envvar_del;
define sys_envvar_get;
define sys_envvar_set;
define sys_envvar_startup_get;
define sys_envvar_startup_set;
define sys_envvar_startup_del;
%include 'sys2.ins.pas';
%include 'string.ins.pas';
%include 'sys_sys2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYS_ENVVAR_DEL (VARNAME, STAT)
*
*   Delete the environment variable named in VARNAME.
}
procedure sys_envvar_del (             {delete environment variable}
  in      varname: univ string_var_arg_t; {name of environment variable to delete}
  out     stat: sys_err_t);
  val_param;

const
  name_len = 132;

var
  name: array[1..name_len] of char;    {variable name in system format}
  ok: win_bool_t;                      {not WIN_BOOL_FALSE_K on system call success}
  null: char;                          {null variable value, used to cause delete}

begin
  string_t_c (varname, name, size_char(name)); {make system variable name}
  null := chr(0);                      {make null string to indicate variable delete}
  sys_error_none (stat);               {init to no error occurred}

  ok := SetEnvironmentVariableA (name, null); {try to delete variable}
  if ok = win_bool_false_k then begin  {failed to delete environment variable ?}
    stat.sys := GetLastError;
    end;
  end;
{
********************************************************************************
*
*   Subroutine SYS_ENVVAR_GET (VARNAME, VARVAL, STAT)
*
*   Return the value of an "environment" variable.  The environment variable's
*   name is VARNAME, and the returned value is a string in VARVAL.  STAT is
*   the completion status code.  When VARNAME is not the name of an existing
*   environment variable, then STAT is returned with status
*   SYS_STAT_ENVVAR_NOEXIST_K.
}
procedure sys_envvar_get (             {get value of system "environment" variable}
  in      varname: univ string_var_arg_t; {name of environment variable}
  in out  varval: univ string_var_arg_t; {value of environment variable}
  out     stat: sys_err_t);
  val_param;

const
  name_len = 132;                      {variable name max length}
  val_len = 2048;                      {variable value max length}

var
  name: array[1..name_len] of char;    {variable name}
  val: array[1..val_len] of char;      {variable value}
  len: win_dword_t;                    {length value returned by system routine}

begin
  string_t_c (varname, name, size_char(name)); {make system variable name}

  len := GetEnvironmentVariableA (     {try to get value of variable}
    name,                              {variable name}
    val,                               {returned value string}
    size_char(val));                   {max chars allowed to write into VAL}

  if len = 0 then begin                {variable not found ?}
    sys_stat_set (sys_subsys_k, sys_stat_envvar_noexist_k, stat); {set error status}
    sys_stat_parm_vstr (varname, stat);
    return;
    end;

  string_vstring (varval, val, size_char(val)); {convert value from system format}
  sys_error_none (stat);               {indicate all went well}
  end;
{
********************************************************************************
*
*   Subroutine SYS_ENVVAR_SET (VARNAME, VARVAL)
*
*   Set the environment variable VARNAME to the string VARVAL.
}
procedure sys_envvar_set (             {set env variable value, created if needed}
  in      varname: univ string_var_arg_t; {name of environment variable}
  in      varval: univ string_var_arg_t; {value of environment variable}
  out     stat: sys_err_t);
  val_param;

const
  name_len = 132;                      {variable name max length}
  val_len = 2048;                      {variable value max length}

var
  name: array[1..name_len] of char;    {variable name}
  val: array[1..val_len] of char;      {variable value}
  ok: win_bool_t;                      {not WIN_BOOL_FALSE_K on system call success}

begin
  sys_error_none (stat);               {init to no error occurred}
  string_t_c (varname, name, name_len); {make system variable name}
  string_t_c (varval, val, val_len);   {make system variable value string}
  ok := SetEnvironmentVariableA (name, val); {try to set variable to new value}
  if ok = win_bool_false_k then begin  {failed to get environment variable value ?}
    stat.sys := GetLastError;
    end;
  end;
{
********************************************************************************
*
*   Local subroutine OPEN_ENVVAR_KEY (ACCESS, H, STAT)
*
*   Open the registry key that contains the startup environment variables
*   as values.  H is returned as the handle to the open key if no errors
*   were encountered.  H must eventually be closed with RegCloseKey.
*   ACCESS is the access flags the key is to be opened with.
}
procedure open_envvar_key (            {open registry key with startup envvars}
  in      access: raccess_t;           {access required to the open key}
  out     h: win_handle_t;             {handle to open registry key}
  out     stat: sys_err_t);            {completion status code}
  val_param; internal;

var
  h1, h2: win_handle_t;                {scratch handles}

begin
  sys_error_none (stat);               {init to no errors encountered}

  stat.sys := RegOpenKeyExA (          {open the top registry key}
    hkey_local_machine,                {parent key}
    'SYSTEM'(0),                       {name of key to open}
    [],                                {options}
    [raccess_enum_k],                  {access required}
    h1);                               {returned handle to newly opened key}
  if sys_error(stat) then return;

  stat.sys := RegOpenKeyExA (
    h1,                                {parent key}
    'CurrentControlSet'(0),            {name of key to open}
    [],                                {options}
    [raccess_enum_k],                  {access required}
    h2);                               {returned handle to newly opened key}
  discard( RegCloseKey (h1) );
  if sys_error(stat) then return;

  stat.sys := RegOpenKeyExA (
    h2,                                {parent key}
    'Control'(0),                      {name of key to open}
    [],                                {options}
    [raccess_enum_k],                  {access required}
    h1);                               {returned handle to newly opened key}
  discard( RegCloseKey (h2) );
  if sys_error(stat) then return;

  stat.sys := RegOpenKeyExA (
    h1,                                {parent key}
    'Session Manager'(0),              {name of key to open}
    [],                                {options}
    [raccess_enum_k],                  {access required}
    h2);                               {returned handle to newly opened key}
  discard( RegCloseKey (h1) );
  if sys_error(stat) then return;

  stat.sys := RegOpenKeyExA (
    h2,                                {parent key}
    'Environment'(0),                  {name of key to open}
    [],                                {options}
    access,                            {access required}
    h);                                {returned handle to newly opened key}
  discard( RegCloseKey (h2) );
  end;
{
********************************************************************************
*
*   Subroutine SYS_ENVVAR_STARTUP_GET (VARNAME, VAL, FLAGS, STAT)
*
*   Get the system startup value for the environment variable VARNAME.
}
procedure sys_envvar_startup_get (     {get environment value startup value}
  in      varname: univ string_var_arg_t; {name of environment variable}
  in out  val: univ string_var_arg_t;  {returned startup value}
  out     flags: sys_envvar_t;         {set of indicator flags}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  key_h: win_handle_t;                 {handle to registry key containing envvar}
  dtype: reg_dtype_k_t;                {registry value data type ID}
  size: win_dword_t;                   {data size}
  vname: string_var80_t;               {var string variable name}

begin
  vname.max := size_char(vname.str);   {init local var string}
  flags := [];                         {init to no indicator flags selected}

  string_copy (varname, vname);        {make local copy of variable name}
  string_terminate_null (vname);       {ensure STR field is NULL terminated}

  open_envvar_key (                    {open registry key that holds environ vars}
    [raccess_query_k],                 {access we need to the registry key}
    key_h,                             {returned handle to open key}
    stat);
  if sys_error(stat) then return;

  size := val.max;                     {get max size data we can receive}
  stat.sys := RegQueryValueExA (       {read a named value of the key}
    key_h,                             {handle to open key}
    vname.str,                         {name of the value to query}
    nil,                               {reserved, must be NIL}
    dtype,                             {returned data type ID}
    val.str,                           {returned value data}
    size);                             {data buffer size in, data size out}
  val.len := size;
  if stat.sys = err_more_data_k
    then begin                         {VAL string too small for the data ?}
      sys_error_none (stat);           {not error, we silently truncate}
      end
    else begin                         {all the data fit into VAL}
      if                               {string has terminating NULL ?}
          (val.len > 0) and            {at least one character ?}
          (val.str[val.len] = chr(0))  {last character is NULL ?}
          then begin
        val.len := val.len - 1;        {truncate the terminating NULL}
        end;
      end
    ;
  discard( RegCloseKey (key_h) );      {close the envvars registry key}
  if sys_error(stat) then return;

  case dtype of                        {what data type is this variable ?}
reg_dtype_str_k: flags := flags + [sys_envvar_noexp_k];
reg_dtype_str_envvar_k: flags := flags + [sys_envvar_expvar_k];
    end;
  end;
{
********************************************************************************
*
*   Subroutine SYS_ENVVAR_STARTUP_SET (NAME, VAL, FLAGS, STAT)
*
*   Set the initial system startup value for the environment variable NAME.  The
*   system state is not altered if it can be reliably determined that it is
*   already set as desired.  In that case the function returns FALSE.  The
*   function returns TRUE if system state was updated.  The function always
*   returns FALSE when STAT is returned indicating other than success.
*
*   FLAGS selects additional options.  Only the following elements of FLAGS
*   are meaningful.  Any other elements are ignored.
*
*     SYS_ENVVAR_NOEXP_K  -  References to environment variables in the data
*       string will not be expanded when the string is queried.  All string
*       characters will be returned as indicated.  The result is undefined
*       if this flag is unsed in conjunction with SYS_ENVVAR_EXPVAR_K.  This
*       is the default of the environment variable does not previously exist.
*
*     SYS_ENVVAR_EXPVAR_K  -  References to environment variables in the data
*       string will be expaneded when the string is queried.  The syntax for
*       embedding environment variable references is dependent on the operating
*       system.  On Windows the string between two percent (%) signs is taken
*       as a environment variable name that will be expanded.  For example,
*       %PATH% in the string will be substituted for the expansion of %PATH%
*       when the string value is returned.  The result is undefined if this flag
*       is used in conjunction with SYS_ENVVAR_NOEXP_K.
*
*   If the environment variable previously exists and neither SYS_ENVVAR_NOEXP_K
*   or SYS_ENVVAR_EXPVAR_K is set, then the existing setting is preserved.
}
function sys_envvar_startup_set (      {set environment variable to be created at startup}
  in      varname: univ string_var_arg_t; {name of environment variable}
  in      val: univ string_var_arg_t;  {value to set variable to at system startup}
  in      flags: sys_envvar_t;         {set of option flags}
  out     stat: sys_err_t)
  :boolean;                            {TRUE if any startup state was changed}
  val_param;

var
  key_h: win_handle_t;                 {handle to registry key containing envvar}
  dtype: reg_dtype_k_t;                {registry value data type ID}
  size: win_dword_t;                   {data size}
  vname: string_var80_t;               {var string variable name}
  lval: string_var8192_t;              {local copy of variable value}

label
  dowrite, abort;

begin
  vname.max := size_char(vname.str);   {init local var strings}
  lval.max := size_char(lval.str);
  sys_envvar_startup_set := false;     {init to no system changes were made}

  string_copy (varname, vname);        {make local copy of variable name}
  string_terminate_null (vname);       {ensure STR field is NULL terminated}

  open_envvar_key (                    {open registry key that holds environ vars}
    [raccess_query_k, raccess_set_k],  {access we need to the registry key}
    key_h,                             {returned handle to open key}
    stat);
  if sys_error(stat) then return;

  size := lval.max;                    {get max size data we can receive}
  stat.sys := RegQueryValueExA (       {read a named value of the key}
    key_h,                             {handle to open key}
    vname.str,                         {name of the value to query}
    nil,                               {reserved, must be NIL}
    dtype,                             {returned data type ID}
    lval.str,                          {returned value data}
    size);                             {data buffer size in, data size out}
  lval.len := size;
  if stat.sys = err_more_data_k
    then begin                         {LVAL string too small for the data ?}
      sys_error_none (stat);           {not error, we silently truncate}
      end
    else begin                         {didn't overflow LVAL}
      if                               {string has terminating NULL ?}
          (lval.len > 0) and           {at least one character ?}
          (lval.str[lval.len] = chr(0)) {last character is NULL ?}
          then begin
        lval.len := lval.len - 1;      {truncate the terminating NULL}
        end;
      end
    ;

  if sys_error(stat) then begin        {error on trying to read existing value}
    dtype := reg_dtype_str_k;          {default to verbatim string}
    goto dowrite;
    end;
  if                                   {not required data type ?}
      (sys_envvar_noexp_k in flags) and
      (dtype <> reg_dtype_str_k)
    then goto dowrite;
  if                                   {not required data type ?}
      (sys_envvar_expvar_k in flags) and
      (dtype <> reg_dtype_str_envvar_k)
    then goto dowrite;
  if not string_equal (lval, val) then goto dowrite; {string value not as desired ?}
{
*   A variable of the indicated name exists, contains the desired value, and is
*   of the right data type.  Do not set the value.
}
  discard( RegCloseKey (key_h) );      {close the envvars registry key}
  return;                              {nothing more to do}
{
*   The existing state is not definitely known to be as desired.  DTYPE indicates
*   the data type of the registry entry to use for writing.
}
dowrite:                               {definitely set the value}
  string_copy (val, lval);             {make local copy of data string}
  string_terminate_null (lval);        {ensure STR field is NULL terminated}

  if sys_envvar_noexp_k in flags then begin {find data type to set}
    dtype := reg_dtype_str_k;
    end;
  if sys_envvar_expvar_k in flags then begin
    dtype := reg_dtype_str_envvar_k;
    end;

  stat.sys := RegSetValueExA (         {set/create the registry value}
    key_h,                             {handle to key to set value in}
    vname.str,                         {name of value to set}
    0,                                 {reserved, must be 0}
    dtype,                             {value data type ID}
    lval.str,                          {value data buffer}
    lval.len + 1);                     {data buffer size, includes terminating NULL}
  if sys_error(stat) then goto abort;
  sys_envvar_startup_set := true;      {indicate system startup changes were made}

  stat.sys := RegFlushKey (key_h);     {force changes to be written now}
  if sys_error(stat) then goto abort;

  stat.sys := RegCloseKey (key_h);     {close the registry key}
  return;
{
*   Error has occurred with the registry key open.  STAT is set to indicate the
*   error.
}
abort:
  discard( RegCloseKey (key_h) );      {close the envvars registry key}
  end;
{
********************************************************************************
*
*   Subroutine SYS_ENVVAR_STARTUP_DEL (VARNAME, STAT)
*
*   Delete the indicated environment variable system startup value.  VARNAME is
*   the name of the environment variable to delete the system startup value of.
}
procedure sys_envvar_startup_del (     {delete environment variable startup value}
  in      varname: univ string_var_arg_t; {name of environment variable}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  h: win_handle_t;                     {handle to parent registry key}
  vname: string_var80_t;               {local copy of variable name}

begin
  vname.max := size_char(vname.str);   {init local var strings}

  string_copy (varname, vname);        {make local copy of variable name}
  string_terminate_null (vname);       {ensure STR field is NULL terminated}

  open_envvar_key (                    {open registry key for envvar startup values}
    [raccess_set_k],                   {access required to the key}
    h,                                 {returned handle to the key}
    stat);
  if sys_error(stat) then return;

  sys_error_none (stat);
  stat.sys := RegDeleteValueA (        {delete the registry value}
    h,                                 {handle to registry key containing the value}
    vname.str);                        {NULL terminated name of value to delete}
  end;
