{   Module of routines that deal with messages associated with system error
*   codes.
}
module sys_sys_message;
define sys_sys_message_get;
define sys_sys_message;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
%include 'string.ins.pas';

var
  ras_err_name: string := 'RasGetErrorStringA'(0); {name of dyn loaded routine}
{
***************************************************************************
*
*   Function SYS_SYS_MESSAGE_GET (STAT_SYS, EMESS)
*
*   Return the message string in EMESS for the system status code STAT_SYS.
*   The function will return TRUE if STAT_SYS was other than normal status.
*   EMESS will be returned the empty string if system error message text
*   was not available.  EMESS is guaranteed not to have any trailing blanks.
}
function sys_sys_message_get (         {return string for a system error code}
  in      stat_sys: sys_sys_err_t;     {system error status code}
  in out  emess: univ string_var_arg_t) {returned error message text, NULL on no err}
  :boolean;                            {TRUE on error status, message not empty}
  val_param;

type
  buf_t = array[1..32767] of char;     {sufficiently long array}
  buf_p_t = ^buf_t;

  rascall_p_t =
    ^function (                        {get error message string from RAS err code}
      in      err_stat: sys_sys_err_t; {error status code to get string for}
      out     str: univ string;        {returned string, 256 chars max}
      in      str_len: win_dword_t)    {number of chars available in STR}
      :sys_sys_err_t;                  {0 on no error}
      val_param;

var
  flags: win_dword_t;                  {FLAGS argument to FormatMessage}
  buf_p: buf_p_t;                      {pointer to message text from system}
  len: win_dword_t;                    {number of chars in BUF_P^}
  err: sys_sys_err_t;                  {system error flag}
  raserr: array[1..256] of char;       {max size RAS error string buffer}
  h: win_handle_t;                     {scartch win32 handle}
  rascall_p: rascall_p_t;              {pointer to dyn loaded call}

label
  not_ras_error2, not_ras_error, got_msg;

begin
  emess.len := 0;                      {init to no message text returned}
  if stat_sys = 0 then begin           {normal condition indicated ?}
    sys_sys_message_get := false;
    return;
    end;
  sys_sys_message_get := true;         {error status is indicated}
  if emess.max <= 0 then return;       {no point looking up message text ?}
{
*   Try to get normal system error message from error ID.
}
  flags := win_dword_t(setof(fmsg_flags_t, {build FLAGS argument to FormatMessage}
      fmsg_flag_allocbuf_k,            {dynamically allocate message text buffer}
      fmsg_flag_f_sys_k)) !            {search system message tables for message}
    fmsg_width_max_k;                  {disable line wrapping to the extent possible}

  buf_p := nil;                        {init to no buffer allocated}
  len := FormatMessageA (              {try to get regular system message}
    flags,                             {control flags and text flow width}
    nil,                               {no explicity source string supplied}
    stat_sys,                          {error code to get message for}
    win_userlanguage_k,                {use user's default language}
    buf_p,                             {returned pointing to new message chars}
    0,                                 {max bufsize, ignored}
    nil);                              {no message parameters supplied}

  if len <> 0 then begin               {actually got message text ?}
    string_vstring (emess, buf_p^, len); {convert error message to our format}
    discard( LocalFree(buf_p) );       {deallocate system message text buffer}
    goto got_msg;
    end;

  if buf_p <> nil then begin           {FormatMessage did allocate a buffer ?}
    discard( LocalFree(buf_p) );       {deallocate system message text buffer}
    end;
{
*   Try to interpret STAT_SYS as a RAS error ID.
}
  err := 1;                            {init to not got RAS error string}
  h := LoadLibraryA ('RASAPI32.DLL'(0)); {try to load library with RAS routines}
  if h = handle_none_k then begin
    writeln ('Could not load RASAIP32.DLL.');
    goto not_ras_error;
    end;

  rascall_p := GetProcAddress (h, sys_int_adr_t(addr(ras_err_name)));
  if rascall_p = nil then begin
    writeln ('Could not find RasGetErrorStringA entry point.');
    goto not_ras_error2;
    end;

  err := rascall_p^ (                  {call RasGetErrorStringA}
    stat_sys,                          {error ID to look up}
    raserr,                            {returned error message string}
    size_char(raserr));                {number of chars sys can write to RASERR}

not_ras_error2:                        {jump here to abort after loaded library}
  discard( FreeLibrary (h) );          {release RAS library}

  if err = 0 then begin                {successfully got RAS error string ?}
    string_vstring (emess, raserr, size_char(raserr)); {convert to our format}
    goto got_msg;
    end;
not_ras_error:                         {jump here if couldn't interpret as RAS err}
  return;                              {return with no message string}

got_msg:                               {we have a message string}
  string_unpad (emess);                {truncate any trailing blanks}
  end;
{
***************************************************************************
*
*   Function SYS_SYS_MESSAGE (STAT_SYS)
*
*   Write the message indicated by the system error status code STAT_SYS,
*   unless STAT_SYS is specifically indicating no error.  The function will
*   return TRUE when a message is actually printed, meaning STAT_SYS was
*   not specifically indicating the "normal" condition.
*
*   Note that this version of SYS_SYS_MESSAGE is portable, since the system
*   dependencies are in SYS_SYS_MESSAGE_GET.
}
function sys_sys_message (             {write message indicated by system err code}
  in      stat_sys: sys_sys_err_t)     {system error code}
  :boolean;                            {TRUE on error status, message printed}
  val_param;

var
  emess: string_var8192_t;             {error message string in our format}
  tk1, tk2: string_var16_t;            {scratch tokens for assembling error message}
  width: sys_int_machine_t;            {width to wrap message text to}
  st: sys_int_machine_t;               {start index of current message line}
  en: sys_int_machine_t;               {end index of current message line}
  p: sys_int_machine_t;                {current messsage string index}
  w: sys_int_machine_t;                {string width}
  err: boolean;                        {TRUE if STAT_SYS indicating an error}

label
  new_line;
{
********************
*
*   Local subroutine WRITE_STRING (S, LEN)
*
*   Write the first LEN characters of the arbitrary string S to standard output.
}
type
  s_t = array[1..65535] of char;       {arbitrarily long string}

procedure write_string (               {write string to output}
  in      s: univ s_t;                 {arbitrarily long string}
  in      len: sys_int_machine_t);     {number of characters from S to write}
  val_param;

begin
  writeln (s:len);
  end;
{
********************
*
*   Start of main routine.
}
begin
  emess.max := sizeof(emess.str);      {init local var strings}
  tk1.max := sizeof(tk1.str);
  tk2.max := sizeof(tk2.str);

  err := sys_sys_message_get (stat_sys, emess); {get error message string}
  sys_sys_message := err;              {TRUE if STAT_SYS indicated error}
  if not err then return;              {no error status, no message to print ?}

  string_f_int (tk1, stat_sys);        {make decimal error code string}
  string_f_int32h (tk2, stat_sys);     {make hex error code string}
  writeln ('*** System error ', tk1.str:tk1.len, ' (h', tk2.str:tk2.len, ').');

  if emess.len <= 0 then return;       {no additional message text available ?}
{
*   Write message text wrapped to standard output width.
}
  width := sys_width_stdout;           {get width to wrap message text to}

  st := 1;                             {init start index for first line}
new_line:                              {back here when starting a new line}
  while emess.str[st] = ' ' do st := st + 1; {skip over leading blanks}
  w := emess.len - st + 1;             {make width of all remaining characters}
  if w <= 0 then return;               {nothing left to write ?}
  if w <= width then begin             {all remaining chars fit on one line ?}
    write_string (emess.str[st], w);   {write last line of message}
    return;
    end;
  en := emess.len;                     {init next line to all remaining chars}
  for p := st+1 to emess.len do begin  {scan from line start towards end of string}
    if emess.str[p] <> ' ' then next;  {skip to next possible line break}
    if (p - st) <= width
      then begin                       {up to here still fits on this line}
        if emess.str[p-1] <> ' ' then en := p - 1; {update best line break so far}
        end
      else begin                       {to here is too long for this line}
        en := min(en, p - 1);          {use last best break, if possible}
        exit;                          {done finding next line}
        end
      ;
    end;                               {back to check next message character}
  write_string (emess.str[st], en - st + 1); {write this line of message}
  st := en + 1;                        {set start index of next line}
  goto new_line;                       {back to do new output line from this message}
  end;
