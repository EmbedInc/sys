{   Module of routines for creating date/time strings.
}
module sys_date_string;
define sys_date_string;
define sys_clock_str1;
define sys_clock_str2;
define sys_date_time1;
define sys_date_time2;
define sys_date_time3;
%include '(cog)source/sys/sys2.ins.pas';
%include 'string.ins.pas';

var
  month: array[0..11] of string_var16_t := [ {full month names}
    [str := 'January  ', len := 7, max := 16],
    [str := 'February ', len := 8, max := 16],
    [str := 'March    ', len := 5, max := 16],
    [str := 'April    ', len := 5, max := 16],
    [str := 'May      ', len := 3, max := 16],
    [str := 'June     ', len := 4, max := 16],
    [str := 'July     ', len := 4, max := 16],
    [str := 'August   ', len := 6, max := 16],
    [str := 'September', len := 9, max := 16],
    [str := 'October  ', len := 7, max := 16],
    [str := 'November ', len := 8, max := 16],
    [str := 'December ', len := 8, max := 16]];
  mon: array[0..11] of string_var16_t := [ {abbreviated month names}
    [str := 'Jan', len := 3, max := 4],
    [str := 'Feb', len := 3, max := 4],
    [str := 'Mar', len := 3, max := 4],
    [str := 'Apr', len := 3, max := 4],
    [str := 'May', len := 3, max := 4],
    [str := 'Jun', len := 3, max := 4],
    [str := 'Jul', len := 3, max := 4],
    [str := 'Aug', len := 3, max := 4],
    [str := 'Sep', len := 3, max := 4],
    [str := 'Oct', len := 3, max := 4],
    [str := 'Nov', len := 3, max := 4],
    [str := 'Dec', len := 3, max := 4]];
  tz:                                  {time zone name, no daysave}
    array[firstof(sys_tzone_k_t)..lastof(sys_tzone_k_t)] of string_var4_t := [
    [str := 'CUT', len := 3, max := 4],
    [str := 'EST', len := 3, max := 4],
    [str := 'CST', len := 3, max := 4],
    [str := 'MST', len := 3, max := 4],
    [str := 'PST', len := 3, max := 4],
    [str := '', len := 0, max := 4]];
  tzd:                                 {time zone name with day save}
    array[firstof(sys_tzone_k_t)..lastof(sys_tzone_k_t)] of string_var4_t := [
    [str := 'CUDT', len := 4, max := 4],
    [str := 'EDT', len := 3, max := 4],
    [str := 'CDT', len := 3, max := 4],
    [str := 'MDT', len := 3, max := 4],
    [str := 'PDT', len := 3, max := 4],
    [str := '', len := 0, max := 4]];
  tz_name:                             {tzonw full names without "daylight" or "time"}
    array[firstof(sys_tzone_k_t)..lastof(sys_tzone_k_t)] of string_var32_t := [
    [str := 'Coordinated Universal', len := 21, max := 32],
    [str := 'Eastern', len := 7, max := 32],
    [str := 'Central', len := 7, max := 32],
    [str := 'Mountain', len := 8, max := 32],
    [str := 'Pacific', len := 7, max := 32],
    [str := '', len := 0, max := 32]];
  dweek:                               {day of week abbreviation}
    array[0..6] of string_var4_t := [
    [str := 'Sun', len := 3, max := 4],
    [str := 'Mon', len := 3, max := 4],
    [str := 'Tue', len := 3, max := 4],
    [str := 'Wed', len := 3, max := 4],
    [str := 'Thu', len := 3, max := 4],
    [str := 'Fri', len := 3, max := 4],
    [str := 'Sat', len := 3, max := 4]];
  dweek_full:                          {day of week full names}
    array[0..6] of string_var16_t := [
    [str := 'Sunday   ', len := 6, max := 16],
    [str := 'Monday   ', len := 6, max := 16],
    [str := 'Tuesday  ', len := 7, max := 16],
    [str := 'Wednesday', len := 9, max := 16],
    [str := 'Thursday ', len := 8, max := 16],
    [str := 'Friday   ', len := 6, max := 16],
    [str := 'Saturday ', len := 8, max := 16]];
{
********************************************************************************
*
*   Subroutine SYS_DATE_STRING (DATE, STRING_ID, FW, S, STAT)
*
*   Return a portion of a complete date/time string.  DATE is the descriptor
*   for the complete date/time.  STRING_ID selects which of the various
*   string fragments of this date to create.  FW is the field width.
*   FW values must be either greater than zero to specify fixed field widths,
*   or one of the constants named STRING_FW_xxx_K.  Use STRING_FW_FREEFORM_K
*   to indicate free format.  S will contain the returned string.  STAT
*   is the returned completion status code.
}
procedure sys_date_string (            {make string for part of a complete date}
  in      date: sys_date_t;            {describes the complete date}
  in      string_id: sys_dstr_k_t;     {identifies which string, use SYS_DSTR_xxx_K}
  in      fw: sys_int_machine_t;       {fixed field width or use STRING_FW_xxx_K}
  in out  s: univ string_var_arg_t;    {returned string}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  s80: string_var80_t;                 {scratch string}
{
****************************************
*
*   Local subroutine RETURN_STRING (SI, SO, FW)
*   This routine is local to SYS_DATE_STRING.
*
*   Return string SI into string SO, given field width requirement FW.
}
procedure return_string (
  in      si: univ string_var_arg_t;   {string value to return}
  in out  so: univ string_var_arg_t;   {string to write into}
  in      fw: sys_int_machine_t);      {field width requirement}
  val_param;

var
  i, n: sys_int_machine_t;             {scratch integers}

begin
  if fw <= 0
    then begin                         {free format field width}
      string_copy (si, so);
      end
    else begin                         {fixed field width requested}
      n := fw - si.len;                {number of padding chars needed}
      if n >= 0
        then begin                     {whole string fits, may need padding ?}
          so.len := 0;
          for i := 1 to n do begin     {once for each padding character}
            string_append1 (so, ' ');
            end;
          string_append (so, si);
          end
        else begin                     {only partial name fits}
          string_substr (si, 1, fw - 1, so);
          end
        ;
      end
    ;
  end;
{
********************************************************************************
*
*   Start of executable code for SYS_DATE_STRING.
}
begin
  s80.max := sizeof(s80.str);          {init local var string}
  sys_error_none(stat);                {init to no error}
  s.len := 0;                          {init returned string to empty}
  case string_id of                    {which string is being requested ?}

sys_dstr_year_k: begin                 {full year number, blank pad left}
  string_f_int_max_base (
    s, date.year, 10, fw, [string_fi_unsig_k], stat);
  end;

sys_dstr_mon_k: begin                  {month number, zero pad left}
  string_f_int_max_base (
    s, date.month + 1, 10, fw, [string_fi_unsig_k, string_fi_leadz_k], stat);
  end;

sys_dstr_mon_name_k: begin             {full month name, blank pad left}
  if (date.month >= 0) and (date.month <= 11) then begin {within range ?}
    return_string (month[date.month], s, fw);
    end;
  end;

sys_dstr_mon_abbr_k: begin             {month abbreviation, blank pad left}
  if (date.month >= 0) and (date.month <= 11) then begin {within range ?}
    return_string (mon[date.month], s, fw);
    end;
  end;

sys_dstr_day_k: begin                  {day number within month, zero pad left}
  string_f_int_max_base (
    s, date.day + 1, 10, fw, [string_fi_unsig_k, string_fi_leadz_k], stat);
  end;

sys_dstr_daywk_name_k: begin           {day of week full name, blank pad left}
  return_string (dweek_full[sys_date_dayofweek(date)], s, fw);
  end;

sys_dstr_daywk_abbr_k: begin           {day of week name abbreviation, blank pad left}
  return_string (dweek[sys_date_dayofweek(date)], s, fw);
  end;

sys_dstr_hour_k: begin                 {hour of day, zero pad left}
  string_f_int_max_base (
    s, date.hour, 10, fw, [string_fi_unsig_k, string_fi_leadz_k], stat);
  end;

sys_dstr_min_k: begin                  {whole minutes within hour, zero pad left}
  string_f_int_max_base (
    s, date.minute, 10, fw, [string_fi_unsig_k, string_fi_leadz_k], stat);
  end;

sys_dstr_sec_k: begin                  {whole seconds within minute, zero pad left}
  string_f_int_max_base (
    s, date.second, 10, fw, [string_fi_unsig_k, string_fi_leadz_k], stat);
  end;

sys_dstr_sec_frac_k: begin             {real seconds with fractional digits}
  if fw <= 0
    then begin                         {free form}
      string_f_fp (                    {make seconds fraction digits string}
        s,                             {output string}
        date.sec_frac + date.second,   {input value}
        0,                             {total field width}
        0,                             {field width for exponent}
        6,                             {min required significant digits}
        6,                             {max digits allowed left of point}
        1,                             {min digits required right of point}
        6,                             {max digits allowed right of point}
        [string_ffp_exp_no_k],         {don't allow exponential notation}
        stat);
      end
    else begin                         {fixed format}
      string_f_fp (                    {make seconds fraction digits string}
        s,                             {output string}
        date.sec_frac + date.second,   {input value}
        fw,                            {total field width}
        0,                             {field width for exponent}
        1,                             {min required significant digits}
        2,                             {max digits allowed left of point}
        fw - 3,                        {min digits required right of point}
        fw - 3,                        {max digits allowed right of point}
        [ string_ffp_exp_no_k,         {don't allow exponential notation}
          string_ffp_leadz_k],         {pad with leading zeros}
        stat);
      end
    ;
  end;

sys_dstr_tz_name_k: begin              {full time zone name, blank pad left}
  string_copy (tz_name[date.tzone_id], s80); {init to raw time zone name}
  if date.daysave_on
    then begin                         {daylight savings time is in effect}
      string_appends (s80, ' Daylight'(0));
      end
    else begin                         {daylight savings time not in effect}
      string_appends (s80, ' Standard'(0));
      end
    ;
  string_appends (s80, ' Time'(0));
  return_string (s80, s, fw);          {pass back final string}
  end;

sys_dstr_tz_abbr_k: begin              {time zone name abbreviation, blank pad left}
  if date.daysave_on
    then begin                         {daylight savings time is in effect}
      return_string (tzd[date.tzone_id], s, fw);
      end
    else begin                         {daylight savings time not in effect}
      return_string (tz[date.tzone_id], s, fw);
      end
    ;
  end;

    end;                               {end of string type cases}
  end;
{
********************************************************************************
*
*   Subroutine SYS_CLOCK_STR2 (CLOCK, NSF, STR)
*
*   Create the date/time string in the format YYYY/MM/DD.MM:HH:SS.xxx.  This is
*   a common Cognivision date/time format.  Note that strings of this format can
*   be sorted as text strings without needing to understand the individual
*   fields.  NSF is the number of fractional seconds digits to create.  The
*   decimal point is not written when NSF is zero.
*
*   The time is always with respect to the current time zone, as returned by
*   SYS_TIMEZONE_HERE.
}
procedure sys_clock_str2 (             {make date string YYYY/MM/DD.hh:mm:ss.xxx}
  in      clock: sys_clock_t;          {clock time to convert to string}
  in      nsf: sys_int_machine_t;      {number of seconds fraction digits}
  in out  str: univ string_var_arg_t); {returned date/time string}
  val_param;

const
  max_msg_parms = 1;                   {max parameters we can pass to a message}

var
  date: sys_date_t;                    {expanded date descriptor}
  tzone: sys_tzone_k_t;                {info about our time zone}
  hours_west: real;
  daysave: sys_daysave_k_t;
  tk: string_var16_t;                  {scratch token}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;
  stat: sys_err_t;

begin
  tk.max := sizeof(tk.str);            {init local var string}

  sys_timezone_here (tzone, hours_west, daysave); {get local time zone info}
  sys_clock_to_date (                  {expand clock time to date/time descriptor}
    clock, tzone, hours_west, daysave, date);
  str.len := 0;                        {init length of returned string}

  sys_date_string (date, sys_dstr_year_k, 4, str, stat);
  if sys_error(stat) then begin
    sys_msg_parm_int (msg_parm[1], date.year);
    sys_error_print (stat, 'sys', 'date_conv_year', msg_parm, 1);
    sys_bomb;
    end;

  string_append1 (str, '/');
  sys_date_string (date, sys_dstr_mon_k, 2, tk, stat);
  if sys_error(stat) then begin
    sys_msg_parm_int (msg_parm[1], date.month);
    sys_error_print (stat, 'sys', 'date_conv_month', msg_parm, 1);
    sys_bomb;
    end;
  string_append (str, tk);

  string_append1 (str, '/');
  sys_date_string (date, sys_dstr_day_k, 2, tk, stat);
  if sys_error(stat) then begin
    sys_msg_parm_int (msg_parm[1], date.day);
    sys_error_print (stat, 'sys', 'date_conv_day', msg_parm, 1);
    sys_bomb;
    end;
  string_append (str, tk);

  string_append1 (str, '.');
  sys_date_string (date, sys_dstr_hour_k, 2, tk, stat);
  if sys_error(stat) then begin
    sys_msg_parm_int (msg_parm[1], date.hour);
    sys_error_print (stat, 'sys', 'date_conv_hour', msg_parm, 1);
    sys_bomb;
    end;
  string_append (str, tk);

  string_append1 (str, ':');
  sys_date_string (date, sys_dstr_min_k, 2, tk, stat);
  if sys_error(stat) then begin
    sys_msg_parm_int (msg_parm[1], date.minute);
    sys_error_print (stat, 'sys', 'date_conv_minute', msg_parm, 1);
    sys_bomb;
    end;
  string_append (str, tk);

  string_append1 (str, ':');
  if nsf <= 0
    then begin                         {integer seconds}
      sys_date_string (date, sys_dstr_sec_k, 2, tk, stat);
      if sys_error(stat) then begin
        sys_msg_parm_int (msg_parm[1], date.second);
        sys_error_print (stat, 'sys', 'date_conv_isec', msg_parm, 1);
        sys_bomb;
        end;
      end
    else begin                         {seconds with NSF fraction digits}
      sys_date_string (date, sys_dstr_sec_frac_k, nsf + 3, tk, stat);
      if sys_error(stat) then begin
        sys_msg_parm_fp1 (msg_parm[1], date.second + date.sec_frac);
        sys_error_print (stat, 'sys', 'date_conv_fpsec', msg_parm, 1);
        sys_bomb;
        end;
      end
    ;
  string_append (str, tk);
  end;
{
*******************************************************************
*
*   Subroutine SYS_CLOCK_STR1 (CLOCK, STR)
*
*   Create the date/time string in the fixed 19 character format
*   YYYY/MM/DD.MM:HH:SS.  This is a common Cognivision date/time format.
*   Note that strings of this format can be sorted as text strings without
*   needing to understand the individual fields.
*
*   The time is always with respect to the current time zone, as returned by
*   SYS_TIMEZONE_HERE.
}
procedure sys_clock_str1 (             {make date string YYYY/MM/DD.MM:HH:SS}
  in      clock: sys_clock_t;          {clock time to convert to string}
  in out  str: univ string_var_arg_t); {returned date/time string}
  val_param;

begin
  sys_clock_str2 (clock, 0, str);
  end;
{
*******************************************************************
*
*   Subroutine SYS_DATE_TIME1 (DATE_STR)
*
*   Return the current date/time in the string DATE_STR.  DATE_STR will contain
*   25 characters in the format "YYYY MMM DD HH:MM:SS ZZZZ".  The fields in order
*   are year, month, date, hour, minute, second, time zone name.
}
procedure sys_date_time1 (             {return current local date/time in a string}
  out     date_str: univ string_var_arg_t); {25 chars, "YYYY MMM DD HH:MM:SS ZZZZ"}
  val_param;

var
  date: sys_date_t;                    {expanded date descriptor}
  tzone: sys_tzone_k_t;                {info about our time zone}
  hours_west: real;
  daysave: sys_daysave_k_t;
  tk: string_var16_t;                  {scratch token}
  stat: sys_err_t;

begin
  tk.max := sizeof(tk.str);            {init local var string}

  sys_timezone_here (tzone, hours_west, daysave); {get local time zone info}
  sys_clock_to_date (                  {expand clock time to date/time descriptor}
    sys_clock, tzone, hours_west, daysave, date);
  date_str.len := 0;                   {init length of returned string}

  sys_date_string (date, sys_dstr_year_k, 4, date_str, stat);
  sys_error_abort (stat, '', '', nil, 0);

  string_append1 (date_str, ' ');
  sys_date_string (date, sys_dstr_mon_abbr_k, 3, tk, stat);
  sys_error_abort (stat, '', '', nil, 0);
  string_upcase (tk);
  string_append (date_str, tk);

  string_append1 (date_str, ' ');
  sys_date_string (date, sys_dstr_day_k, 2, tk, stat);
  sys_error_abort (stat, '', '', nil, 0);
  string_append (date_str, tk);

  string_append1 (date_str, ' ');
  sys_date_string (date, sys_dstr_hour_k, 2, tk, stat);
  sys_error_abort (stat, '', '', nil, 0);
  string_append (date_str, tk);

  string_append1 (date_str, ':');
  sys_date_string (date, sys_dstr_min_k, 2, tk, stat);
  sys_error_abort (stat, '', '', nil, 0);
  string_append (date_str, tk);

  string_append1 (date_str, ':');
  sys_date_string (date, sys_dstr_sec_k, 2, tk, stat);
  sys_error_abort (stat, '', '', nil, 0);
  string_append (date_str, tk);

  string_append1 (date_str, ' ');
  sys_date_string (date, sys_dstr_tz_abbr_k, 4, tk, stat);
  sys_error_abort (stat, '', '', nil, 0);
  string_append (date_str, tk);
  end;
{
*******************************************************************
*
*   Subroutine SYS_DATE_TIME2 (DATE_STR)
*
*   Return the current date/time in the string DATE_STR.  DATE_STR will contain
*   19 characters in the format "YYYY/MM/DD.hh:mm:ss".  These types of date/time
*   strings can be sorted as text strings without having to parse the individual
*   fields.
}
procedure sys_date_time2 (             {return current local date/time in a string}
  out     date_str: univ string_var_arg_t); {19 chars, "YYYY/MM/DD.hh:mm:ss"}
  val_param;

begin
  sys_clock_str2 (sys_clock, 0, date_str); {convert the current time}
  end;
{
********************************************************************************
*
*   Subroutine SYS_DATE_TIME3 (NSF, DATE_STR)
*
*   Return the current date/time in the string DATE_STR.  DATE_STR will be in
*   the format "YYYY/MM/DD.hh:mm:ss.xxx" where XXX is a optional number of
*   seconds fraction digits.  The number of seconds fraction digits to create
*   is specified by NSF.
}
procedure sys_date_time3 (             {return current local date/time in a string}
  in      nsf: sys_int_machine_t;      {number of seconds fraction digits to create}
  out     date_str: univ string_var_arg_t); {YYYY/MM/DD.hh:mm:ss.xxx}
  val_param;

begin
  sys_clock_str2 (sys_clock, nsf, date_str); {convert the current time}
  end;
