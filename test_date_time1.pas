program test_date_time1;
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';

var
  clock: sys_clock_t;                  {Cognivision time descriptor for current time}
  date: sys_date_t;                    {expanded date descriptor}
  tzone: sys_tzone_k_t;                {our time zone ID}
  hours_west: real;                    {hours west of coor univ time}
  daysave: sys_daysave_k_t;            {daylight savings time strategy}
  str:                                 {scratch string}
    %include '(cog)lib/string80.ins.pas';
  stat: sys_err_t;

begin
  clock := sys_clock;                  {get system time}
  sys_timezone_here (tzone, hours_west, daysave); {get info about our time zone}
  sys_clock_to_date (                  {make expanded date in local time}
    clock,                             {universal time descriptor}
    tzone, hours_west, daysave,        {info about our time zone}
    date);                             {returned date descriptor}

  sys_date_time1 (str);                {get date in format YYYY MMM DD HH:MM:SS ZZZZ}
  writeln ('"', str.str:str.len, '"'); {show the it}

  sys_clock_str1 (clock, str);         {get date in format YYYY/MM/DD.MM:HH:SS}
  writeln ('"', str.str:str.len, '"'); {show the it}
{
*   Show all the string we can get from SYS_DATE_STRING.
}
  writeln;

  sys_date_string (date, sys_dstr_year_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('year "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_mon_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('mon "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_mon_name_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('mon_name "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_mon_abbr_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('mon_abbr "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_day_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('day "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_daywk_name_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('daywk_name "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_daywk_abbr_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('daywk_abbr "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_hour_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('hour "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_min_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('min "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_sec_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('sec "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_sec_frac_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('sec_frac "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_tz_name_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('tz_name "', str.str:str.len, '"');

  sys_date_string (date, sys_dstr_tz_abbr_k, 0, str, stat);
  sys_error_abort (stat, '', '', nil, 0);
  writeln ('tz_abbr "', str.str:str.len, '"');
{
*   Show output from some of the other date routines.
}
  writeln;

  writeln ('Day of week ID = ', sys_date_dayofweek(date));
  writeln ('Julian day = ', sys_date_dayofyear(date) + 1);
  end.
