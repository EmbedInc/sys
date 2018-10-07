module sys_clock_from_str;
define sys_clock_from_str;
%include '(cog)source/sys/sys2.ins.pas';
%include '(cog)lib/string.ins.pas';
{
********************************************************************************
*
*   Subroutine SYS_CLOCK_FROM_STR (S, TIME, STAT)
*
*   Convert the date/time string S to the clock value in TIME.  The date/time
*   format is expected to be:
*
*     YYYY/MM/DD.hh:mm:ss.sss
}
procedure sys_clock_from_str (         {make clock value from date/time string}
  in      s: univ string_var_arg_t;    {date/time string YYYY/MM/DD.hh:mm:ss.ss}
  out     time: sys_clock_t;           {returned clock value, CUT}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  pick: sys_int_machine_t;             {number of delimiter picked from list}
  tk: string_var80_t;                  {token parsed from input string}
  date: sys_date_t;                    {expanded date/time descriptor}
  p: string_index_t;                   {input string parse index}

label
  have_date, syerr;

begin
  tk.max := size_char(tk.str);         {init local var string}

  p := 1;                              {init S parse index}
  string_token_anyd (                  {extract year number field}
    s, p,                              {input string and parse index}
    '/', 1,                            {list of token delimiters}
    0,                                 {first N delimiters that may be repeated}
    [],                                {no special options}
    tk,                                {parsed token}
    pick,                              {index to terminating delimiter found}
    stat);
  if sys_error(stat) then goto syerr;
  if tk.len < 1 then goto syerr;       {year can't be the empty string}
  string_t_int (tk, date.year, stat);  {convert year string to integer}
  if sys_error(stat) then goto syerr;

  date.month := 0;                     {init remaining fields to their defaults}
  date.day := 0;
  date.hour := 0;
  date.minute := 0;
  date.second := 0;
  date.sec_frac := 0.0;
  date.hours_west := 0.0;
  date.tzone_id := sys_tzone_cut_k;
  date.daysave := sys_daysave_no_k;
  date.daysave_on := false;

  string_token_anyd (                  {extract month number field}
    s, p,                              {input string and parse index}
    '/', 1,                            {list of token delimiters}
    0,                                 {first N delimiters that may be repeated}
    [],                                {no special opions}
    tk,                                {parsed token}
    pick,                              {index to terminating delimiter found}
    stat);
  if string_eos(stat) then goto have_date;
  if sys_error(stat) then goto syerr;
  string_t_int (tk, date.month, stat);
  if sys_error(stat) then goto syerr;
  date.month := date.month - 1;

  string_token_anyd (                  {extract day number field}
    s, p,                              {input string and parse index}
    '.', 1,                            {list of token delimiters}
    0,                                 {first N delimiters that may be repeated}
    [],                                {no special opions}
    tk,                                {parsed token}
    pick,                              {index to terminating delimiter found}
    stat);
  if string_eos(stat) then goto have_date;
  if sys_error(stat) then goto syerr;
  string_t_int (tk, date.day, stat);
  if sys_error(stat) then goto syerr;
  date.day := date.day - 1;

  string_token_anyd (                  {extract hour number field}
    s, p,                              {input string and parse index}
    ':', 1,                            {list of token delimiters}
    0,                                 {first N delimiters that may be repeated}
    [],                                {no special opions}
    tk,                                {parsed token}
    pick,                              {index to terminating delimiter found}
    stat);
  if string_eos(stat) then goto have_date;
  if sys_error(stat) then goto syerr;
  string_t_int (tk, date.hour, stat);
  if sys_error(stat) then goto syerr;

  string_token_anyd (                  {extract minute number field}
    s, p,                              {input string and parse index}
    ':', 1,                            {list of token delimiters}
    0,                                 {first N delimiters that may be repeated}
    [],                                {no special opions}
    tk,                                {parsed token}
    pick,                              {index to terminating delimiter found}
    stat);
  if string_eos(stat) then goto have_date;
  if sys_error(stat) then goto syerr;
  string_t_int (tk, date.minute, stat);
  if sys_error(stat) then goto syerr;

  string_substr (s, p, s.len, tk);     {get remainder of input string into TK}
  if tk.len < 1 then goto have_date;
  string_t_fpm (tk, date.sec_frac, stat); {convert to floating point seconds}
  if sys_error(stat) then goto syerr;
  date.second := trunc(date.sec_frac); {extract whole seconds}
  date.sec_frac := date.sec_frac - date.second; {remove whole seconds from fraction}

have_date:                             {DATE is all filled in}
  time := sys_clock_from_date (date);  {make absolute time descripor}
  return;

syerr:                                 {syntax error}
  sys_stat_set (sys_subsys_k, sys_stat_timestr_bad_k, stat);
  sys_stat_parm_vstr (s, stat);
  end;
