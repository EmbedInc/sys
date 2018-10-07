{   Program TEST_DATE [options]
*
*   Test ability to convert between a date descriptor and a time in absolute
*   seconds from the zero reference time (start of the year 2000).
*
*   The command line arguments are used to describe a date.  The default date
*   is the zero reference time.  The command line options can modify this date.
*
*   Valid command line options are:
*
*   -Y <year>
*   -MO <month>
*   -D <day>
*   -H <hour>
*   -MIN <minute>
*   -S <integer seconds>
*   -SF <FP seconds>
*   -TZ <time zone>
*     Time zone names are: CUT, EST, CST, MST, PST
*     The default is the current time zone.
}
program test_date;
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';

const
  max_msg_parms = 11;                  {max parameters we can pass to a message}

var
  opt,                                 {command line option name}
  parm, parm2:                         {command line option parameters}
    %include '(cog)lib/string16.ins.pas';
  pick: sys_int_machine_t;             {number of token picked from list}
  date: sys_date_t;                    {date descriptor}
  sec: double;                         {seconds from reference time}
  fp2: double;                         {scratch FP2 number}
  i, j: sys_int_machine_t;             {sdratch integers}
  tzone: sys_tzone_k_t;                {saved time zone info}
  hours_west: real;
  daysave: sys_daysave_k_t;
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;
  stat: sys_err_t;

label
  next_opt, parm_err, done_opts;

begin
  date.year := 2000;                   {set default date values}
  date.month := 0;
  date.day := 0;
  date.hour := 0;
  date.minute := 0;
  date.second := 0;
  date.sec_frac := 0.0;
  sys_timezone_here (date.tzone_id, date.hours_west, date.daysave);
  date.daysave_on := false;

  string_cmline_init;                  {init for command line processing}

next_opt:                              {back here each new command line option}
  string_cmline_token (opt, stat);     {get next command line option name}
  if string_eos(stat) then goto done_opts; {hit end of command line ?}
  sys_error_abort (stat, 'string', 'cmline_opt_err', nil, 0);
  string_upcase (opt);                 {make upper case for token matching}
  string_tkpick80 (opt,
    '-Y -MO -D -H -MIN -S -SF -TZ',
    pick);
  case pick of                         {which command line option was it ?}
{
*   -Y year
}
1: begin
  string_cmline_token_int (date.year, stat);
  end;
{
*   -MO month
}
2: begin
  string_cmline_token_int (date.month, stat);
  date.month := date.month - 1;
  end;
{
*   -D day
}
3: begin
  string_cmline_token_int (date.day, stat);
  date.day := date.day - 1;
  end;
{
*   -H hour
}
4: begin
  string_cmline_token_int (date.hour, stat);
  end;
{
*   -MIN minute
}
5: begin
  string_cmline_token_int (date.minute, stat);
  end;
{
*   -S second
}
6: begin
  string_cmline_token_int (date.second, stat);
  end;
{
*   -SF seconds
}
7: begin
  string_cmline_token_fp2 (fp2, stat);
  date.sec_frac := fp2;
  end;
{
*   -TZ timezone
}
8: begin
  string_cmline_token (parm2, stat);   {get time zone name}
  string_cmline_parm_check (stat, opt);
  string_append1 (opt, ' ');
  string_append (opt, parm);
  string_upcase (parm2);               {make upper case for token matching}
  string_tkpick80 (parm2,
    'OTHER CUT EST CST MST PST',
    pick);
  date.daysave := sys_daysave_appl_k;  {init to daylight savings time used this zone}
  case pick of
1:  begin
      date.tzone_id := sys_tzone_other_k;
      date.daysave := sys_daysave_no_k;
      string_cmline_token_fp2 (fp2, stat);
      if sys_error(stat) then goto parm_err;
      date.hours_west := fp2;
      end;
2:  begin
      date.tzone_id := sys_tzone_cut_k;
      date.hours_west := 0.0;
      end;
3:  begin
      date.tzone_id := sys_tzone_east_usa_k;
      date.hours_west := 5.0;
      end;
4:  begin
      date.tzone_id := sys_tzone_cent_usa_k;
      date.hours_west := 6.0;
      end;
5:  begin
      date.tzone_id := sys_tzone_mount_usa_k;
      date.hours_west := 7.0;
      end;
6:  begin
      date.tzone_id := sys_tzone_pacif_usa_k;
      date.hours_west := 8.0;
      end;
otherwise
    sys_msg_parm_vstr (msg_parm[1], parm2);
    sys_msg_parm_vstr (msg_parm[2], opt);
    sys_message_bomb ('string', 'cmline_parm_bad', msg_parm, 2);
    end;
  end;                                 {end of -TZ command line option case}
{
*   Unrecognized command line option.
}
otherwise
    string_cmline_opt_bad;
    end;                               {end of command line option cases}

parm_err:                              {jump here on error with parm, STAT set}
  string_cmline_parm_check (stat, opt); {check for error with option parameter}
  goto next_opt;                       {back for next command line option}
done_opts:                             {all done with command line options}
{
*   All done processing the command line options.
*
*   Convert the input date to absolute time and print the result.
}
  sec := sys_date_to_sec(date);        {convert input date to absolute seconds}
  sys_msg_parm_fp2 (msg_parm[1], sec);
  sys_message_parms ('sys', 'test_date_sec', msg_parm, 1);
{
*   Convert the absolute time to its date and print the results.
}
  tzone := date.tzone_id;              {save time zone parameters}
  hours_west := date.hours_west;
  daysave := date.daysave;
  sys_date_from_sec (sec, tzone, hours_west, daysave, date); {fill in date descriptor}

  sys_msg_parm_int (msg_parm[1], date.year);
  i := date.month + 1;
  sys_msg_parm_int (msg_parm[2], i);
  j := date.day + 1;
  sys_msg_parm_int (msg_parm[3], j);
  sys_msg_parm_int (msg_parm[4], date.hour);
  sys_msg_parm_int (msg_parm[5], date.minute);
  sys_msg_parm_int (msg_parm[6], date.second);
  sys_msg_parm_real (msg_parm[7], date.sec_frac);
  case date.tzone_id of
sys_tzone_cut_k: string_vstring (parm, 'CUT', 3);
sys_tzone_east_usa_k: string_vstring (parm, 'EST', 3);
sys_tzone_cent_usa_k: string_vstring (parm, 'CST', 3);
sys_tzone_mount_usa_k: string_vstring (parm, 'MST', 3);
sys_tzone_pacif_usa_k: string_vstring (parm, 'PST', 3);
sys_tzone_other_k: begin
      string_vstring (parm, 'UNSPEC', 6);
      end;
otherwise
    string_vstring (parm, '???', 3);
    end;
  sys_msg_parm_vstr (msg_parm[8], parm);
  sys_msg_parm_real (msg_parm[9], date.hours_west);
  case date.daysave of
sys_daysave_no_k: string_vstring (parm2, 'NO', 2);
sys_daysave_appl_k: string_vstring (parm2, 'APPL', 4);
otherwise string_vstring (parm2, '???', 3);
    end;
  sys_msg_parm_vstr (msg_parm[10], parm2);
  case date.daysave_on of
false: string_vstring (opt, 'OFF', 3);
otherwise string_vstring (opt, 'ON', 2);
    end;
  sys_msg_parm_vstr (msg_parm[11], opt);

  sys_message_parms ('sys', 'test_date1', msg_parm, 11);
  sys_message_parms ('sys', 'test_date2', msg_parm, 11);
{
*   Convert the date back to an abolute time and print the results to verify
*   that the time wasn't altered.
}
  sec := sys_date_to_sec(date);        {convert input date to absolute seconds}
  sys_msg_parm_fp2 (msg_parm[1], sec);
  sys_message_parms ('sys', 'test_date_sec', msg_parm, 1);
  end.
