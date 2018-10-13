{   Public include file to declare data types and entry points of the SYS
*   library.
*
*   This library contains routines that must be written in a system-dependent
*   way.  It is therefore expected that much of the source code in this
*   library will be re-written for each new operating system.
}
%natural_alignment;

type
  int8u_t = 0..255;                    {unsigned 8 bit integer}
  int16u_t = 0..65535;                 {unsigned 16 bit integer}
  int32u_t = 0..2147483647;            {unsigned 32 bit integer (only 31 declared)}

  string_p_t = ^string;

  sys_byte_order_k_t = (
    sys_byte_order_fwd_k,              {forwards, first byte is most significant}
    sys_byte_order_bkw_k);             {backwards, first byte is least significant}

  sys_os_k_t = (                       {ID of operating system running on}
    sys_os_unk_k,                      {unknown operating system}
    sys_os_domain_k,                   {Apollo Domain/OS}
    sys_os_hpux_k,                     {HP HP-UX version of Unix}
    sys_os_aix_k,                      {IBM AIX version of Unix}
    sys_os_irix_k,                     {SGI Irix version of Unix}
    sys_os_solaris_k,                  {SUN Solaris (SUNOS 5.0 or greater)}
    sys_os_sunos_k,                    {old SUN OS, (earlier than SUNOS 5.0)}
    sys_os_ultrix_k,                   {DEC Ultrix version of Unix}
    sys_os_win16_k,                    {16 bit interface to Windows}
    sys_os_win32_k,                    {32 bit interface to Windows and WindowsNT}
    sys_os_os2_k,                      {IBM OS2}
    sys_os_osf_k);                     {Open Software Foundation version of Unix}

  sys_threadmem_k_t = (                {different thread mem sharing schemes}
    sys_threadmem_share_k,             {all threads within proc share address space}
    sys_threadmem_copy_k);             {each thread gets copy of parent memory}

%include '(cog)lib/sys_sys.ins.pas';

const
  sys_err_t_max_parms = 4;             {max parameters stored in SYS_ERR_T}
  sys_beep_forever = 0;                {causes infinite number of beep repititions}
  sys_timeout_none_k = -1.0;           {no timeout, wait indefinately}
  sys_timeout_immed_k = 0.0;           {immediate timeout, never waits}

  sys_subsys_k = -1;                   {subsystem ID for this library}
  sys_stat_pgm_err_k = 1;              {program completed with other than T/F status}
  sys_stat_envvar_noexist_k = 2;       {environment variable does not exist}
  sys_stat_envvar_nodel_k = 3;         {unable to delete environment variable}
  sys_stat_envvar_noset_k = 4;         {unable to set environment var to new value}
  sys_stat_failed_k = 5;               {failed to perform requested operation}
  sys_stat_not_impl_k = 6;             {feature is not implemented}
  sys_stat_not_impl_name_k = 7;        {feature is not implemented, named in msg}
  sys_stat_event_not_bool_k = 8;       {operation requires a boolean event type}
  sys_stat_event_not_cnt_k = 9;        {operation requires a counted event type}
  sys_stat_not_impl_subr_k = 10;       {subr not implemented this OS, name in msg}
  sys_stat_timeout_k = 11;             {timeout occurred}
  sys_stat_timestr_bad_k = 12;         {bad time string}
  sys_stat_menuid_bad_k = 13;          {illegal or unexpected menu ID}
  sys_stat_no_mem_k = 14;              {memory not allocated}
  sys_stat_no_mxrec_k = 15;            {no MX records found}

type
{
*   Declare pointer data types to the machine-specific data types declared
*   in SYS_SYS.INS.PAS.
}
  sys_sys_err_p_t = ^sys_sys_err_t;
  sys_sys_time_p_t = ^sys_sys_time_t;
  sys_sys_threadlock_p_t = ^sys_sys_threadlock_t;
{
**********************************************************************
*
*   The data types in this section are really part of other libraries, but
*   are defined here because they are used by SYS data types or routines.
}
const
  string_fw_freeform_k = 0;            {field width to indicate free format}

type
  string_index_t = sys_int_min16_t;    {used for 1..n string chars index}

  string_leafname_t = record           {var string to hold max length leaf name}
    max: string_index_t;
    len: string_index_t;
    str: array[1..sys_leafname_maxlen_k] of char;
    end;

  string_treename_t = record           {var string to hold max length tree name}
    max: string_index_t;
    len: string_index_t;
    str: array[1..sys_treename_maxlen_k] of char;
    end;

  string_var32_t = record              {32 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..32] of char;
    end;

  string_var80_t = record              {80 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..80] of char;
    end;

  string_var_arg_t = record            {variable len string subroutine arg}
    max: string_index_t;               {maximum string length}
    len: string_index_t;               {current string length}
    str: array[1..80] of char;         {enough to print in debugger}
    end;

  string_var_p_t =                     {pointer to arbitrary variable length string}
    ^string_var_arg_t;

const
  util_mem_list_size_k = 15;           {number of mem blocks per list record}

type
  util_mem_list_p_t = ^util_mem_list_t;
  util_mem_list_t = record             {one list on mem blocks lists chain}
    next_p: util_mem_list_p_t;         {pointer to next list in chain}
    list:                              {block start addresses}
      array[1..util_mem_list_size_k] of univ_ptr;
    end;

  util_mem_context_p_t = ^util_mem_context_t;
  util_mem_context_t = record          {data about one memory list context}
    lock: sys_sys_threadlock_t;        {single thread lock for this data structure}
    parent_p: util_mem_context_p_t;    {pointer to parent context}
    prev_sib_p: util_mem_context_p_t;  {pointer to previous sibling context}
    next_sib_p: util_mem_context_p_t;  {pointer to next sibling context}
    child_p: util_mem_context_p_t;     {pointer to first subordinate context}
    first_list_p: util_mem_list_p_t;   {pointer to start of mem blocks lists chain}
    n_in_first: sys_int_machine_t;     {number of blocks in first chain entry}
    pool_size: sys_int_adr_t;          {total size of each memory pool region}
    max_pool_chunk: sys_int_adr_t;     {max size for taking mem from pool}
    pool_p: univ_ptr;                  {start adr of available region in curr pool}
    pool_left: sys_int_adr_t;          {memory left in current pool}
    end;
{
**********************************************************************
*
*   Back to SYS library data types.
}
type
{
*   Mnemonics for the different data types of the parameters that can be
*   inserted in a message from a .msg file.
}
  sys_msg_dtype_k_t = (                {mnemonics for .msg file parm data types}
    sys_msg_dtype_vstr_k,              {var string}
    sys_msg_dtype_str_k,               {string}
    sys_msg_dtype_int_k,               {machine integer}
    sys_msg_dtype_fp1_k,               {single precision floating point}
    sys_msg_dtype_fp2_k);              {double precision floating point}
{
*   Mnemonics for each escaped command allowed in .msg
*   message files.  Each of the commands must be preceded by the escape string.
*   The strings that identify each of these commands are in the current language
*   descriptor in array MSG_ECMD.  The constants below also are the indicies for
*   this array.  The escape string value is in MSG_ESC in the language descriptor.
}
  sys_msg_ecmd_k_t = (                 {mnemonics for .msg file escape commands}
    sys_msg_ecmd_parm_k);              {substitute passed parameter}
{
*   Mnemonics for the all the subcommands to the PARM (substitute passed parameter)
*   escape command in .msg files.  The constants below also are the inidicies for
*   the MSG_ECMD_PARM array in a language descriptor.  This array defines the
*   keywords for each of the subcommands.
}
  sys_msg_parm_k_t = (                 {mnemonics for .msg file PARM subcommand}
    sys_msg_parm_str_k,                {substitute string}
    sys_msg_parm_int_k,                {substitute integer integer}
    sys_msg_parm_float_k);             {substitute floating point number}
{
*   Mnemonics for special flags that can modify the handle to a screen
*   somewhere on the network.
}
  sys_scrflag_k_t = (
    sys_scrflag_proc_k,                {MACHINE is machine running this process}
    sys_scrflag_servdef_k,             {use default server, if relavant at all}
    sys_scrflag_scrdef_k,              {use default screen for indicated server}
    sys_scrflag_stdout_k);             {SCREEN is the one containing STDOUT window,
                                        mutually exclusive with other flags}
  sys_scrflag_t = set of sys_scrflag_k_t;
{
*   Mnemonics for spcial flags that can modify the handle to a particular
*   window somewhere on the network.
}
  sys_winflag_k_t = (
    sys_winflag_stdout_k,              {window is the one showing STDOUT transcript}
    sys_winflag_dir_k,                 {force given window to be used directly}
    sys_winflag_indir_k,               {not allowed to use wind directly, make new}
    sys_winflag_nowm_k,                {don't allow wind man to mess with new wind}
    sys_winflag_pos_k,                 {position for new window is given}
    sys_winflag_size_k,                {size for new window is given}
    sys_winflag_name_k,                {window name is given}
    sys_winflag_icname_k);             {icon name is given}
  sys_winflag_t = set of sys_winflag_k_t;
{
*   End of mnemonic constants.
}
  sys_name_ent_p_t =                   {points to treename linked list entry}
    ^sys_name_ent_t;

  sys_name_ent_t = record              {one entry in linked list of treenames}
    next_p: sys_name_ent_p_t;          {points to next entry in chain, NIL if last}
    prev_p: sys_name_ent_p_t;          {points to previous entry, NIL if first}
    name: string_treename_t;           {treename for this entry}
    end;

  sys_lang_t = record                  {data about a particular language}
    name: string_var32_t;              {language name, always upper case}
    decimal: char;                     {decimal "point" character}
    digits_group_c: char;              {digits group separator (comma in english)}
    digits_group_n: sys_int_machine_t; {number of digits in a group}
    exponent: string_var32_t;          {"E" in "1.03E6"}
    msg_esc: string_var32_t;           {precedes in-line command in message file}
    msg_ecmd:                          {escaped command names in .msg files}
      array[firstof(sys_msg_ecmd_k_t)..lastof(sys_msg_ecmd_k_t)]
      of string_var32_t;
    msg_ecmd_parm:                     {subcommands for "parm substitute" .msg cmd}
      array[firstof(sys_msg_parm_k_t)..lastof(sys_msg_parm_k_t)]
      of string_var32_t;
    end;
  sys_lang_p_t = ^sys_lang_t;

  sys_parm_msg_t = record              {descriptor for a message parameter}
    dtype: sys_msg_dtype_k_t;          {data type of this parameter}
    case sys_msg_dtype_k_t of
sys_msg_dtype_vstr_k: (                {var string}
      vstr_p: string_var_p_t);
sys_msg_dtype_str_k: (                 {string}
      str_p: ^string;
      str_len: string_index_t);        {number of chars in string}
sys_msg_dtype_int_k: (                 {machine integer}
      int_p: sys_int_machine_p_t);
sys_msg_dtype_fp1_k: (                 {single precision floating point}
      fp1_p: ^single);
sys_msg_dtype_fp2_k: (                 {double precision floating point}
      fp2_p: ^double);
    end;

  sys_parm_msg_ar_t =                  {arbitrary array of message parm descriptors}
    array[1..1] of sys_parm_msg_t;
  sys_parm_msg_ar_p_t = ^sys_parm_msg_ar_t;

  sys_msg_any_parm_t = record case sys_msg_dtype_k_t of {msg parm of any type}
sys_msg_dtype_vstr_k: (                {var string}
    vstr: string_treename_t);
sys_msg_dtype_str_k: (                 {string}
    str: string);
sys_msg_dtype_int_k: (                 {machine integer}
    int: sys_int_machine_t);
sys_msg_dtype_fp2_k: (                 {double precision floating point}
    fp2: double);
    end;

  sys_fp_ieee32_p_t =                  {pointer to IEEE 32 bit FP number}
    ^sys_fp_ieee32_t;

  sys_fp_ieee64_p_t =                  {pointer to IEEE 64 bit FP number}
    ^sys_fp_ieee64_t;

  sys_size1_p_t =                      {pointer to minimum addressable size data}
    ^sys_size1_t;

  sys_arg_any_t =                      {arbitrary subroutine argument}
    array[0..0] of sys_size1_t;
  sys_arg_any_p_t = ^sys_arg_any_t;

  sys_inet_adr_node_t = int32u_t;      {arbitrary internet address of any node}
  sys_inet_port_id_t = int16u_t;       {internet port on a particular node}
  sys_macadr_t =                       {ethernet MAC address, low to high order}
    array [0 .. 5] of int8u_t;
{
*   The following data structures are private to the SYS routines.  Applications
*   may only reference them in whole, and should not reference individual fields.
}
  sys_err_t = record                   {system-independent error status code}
    err: boolean;                      {TRUE on non-system error}
    subsys: sys_int_machine_t;         {subsystem ID of non-system error}
    code: sys_int_machine_t;           {specific error code within SUBSYS}
    sys: sys_sys_err_t;                {system-specific error code}
    n_parms: sys_int_machine_t;        {number of parameters referenced here}
    parm_ind:                          {parameter pointers, first N_PARMS used}
      array[1..sys_err_t_max_parms] of sys_parm_msg_t;
    parm:                              {up to max parms of any data type}
      array[1..sys_err_t_max_parms] of sys_msg_any_parm_t;
    end;
  sys_err_p_t = ^sys_err_t;

  sys_compare_k_t = (                  {comparison between two arithmetic quantities}
    sys_compare_lt_k,                  {first value is less than second}
    sys_compare_eq_k,                  {both values are equal}
    sys_compare_gt_k);                 {first value is greater than second}
  sys_compare_t = set of sys_compare_k_t; {union of separate compare conditions}

  sys_timer_t = record                 {info about one stopwatch timer}
    sec: double;                       {elapsed seconds, except when running}
    sys: sys_sys_time_t;               {system time when timer started}
    on: boolean;                       {TRUE if time currently running}
    end;

  sys_fpmode_t = record                {info about modes for handling floating point}
    sys: sys_sys_fpmode_t;             {system-specific data structure}
    end;

  sys_screen_t = record                {uniquely identifies a screen on the network}
    machine: string_leafname_t;        {name of machine screen is connected to,
                                        null string means default}
    server: sys_int_machine_t;         {ID of server within machine}
    screen: sys_int_machine_t;         {ID of screen within server}
    flags: sys_scrflag_t;              {can modify above, set of SYS_SCRFLAG_xxx_K}
    end;

  sys_window_t = record                {uniquely identifies a window on the network}
    screen: sys_screen_t;              {handle to the screen containing window}
    window: sys_int_machine_t;         {ID of window within screen}
    pos_x, pos_y: sys_int_machine_t;   {optional position within parent window}
    size_x, size_y: sys_int_machine_t; {optional size of new window}
    name_wind: string_var80_t;         {name to display, if possible, in banner}
    name_icon: string_var80_t;         {name to use when iconified}
    flags: sys_winflag_t;              {can modify above, set of SYS_WINFLAG_xxx_K}
    end;

  sys_procio_k_t = (                   {how to handle standard I/O of new process}
    sys_procio_none_k,                 {no connection to parent process}
    sys_procio_same_k,                 {use same STDIO streams as parent}
    sys_procio_talk_k,                 {create conn so all I/O goes to parent}
    sys_procio_explicit_k);            {explicit STDIO handle provided by parent}

  sys_threadproc_p_t = ^procedure (    {root routine for a new thread}
    in    arg: sys_int_adr_t);         {arbitrary pointer passed when thread started}
    val_param;

  sys_event_list_t =                   {arbitrary list of system event triggers}
    array[1..1] of sys_sys_event_id_t;
{
*   Clock time descriptor.  This descriptor can hold either an absolute or
*   relative time value.  It is the low level portable time descriptor.
*   An absolute value of zero indicates the start of the year 2000.
*
*   The time descriptor is a 60.30 fixed point number, representing seconds.
*   Since 90 bit numbers are not generally available, 3 fields of 30 bits each
*   are used.  The time value is stored as a twos complement number.
*
*   The time descriptor therefore has a resolution of 2**(-30) seconds, or
*   about 931 pico seconds.  It has a maximum value of 2**59 seconds, or
*   about 18 billion years.  (Current scientific estimates put the age of
*   the universe at around 15 billion years, and Earth's age at 4.5 billion
*   years).
}
  sys_clock_t = record                 {portable absolute or relative clock values}
    high: 0..1073741823;               {2**30 seconds}
    sec: 0..1073741823;                {whole seconds}
    low: 0..1073741823;                {fractions of a second, units of 2**(-30) sec}
    rel: boolean;                      {TRUE for relative time value}
    end;
  sys_clock_p_t = ^sys_clock_t;

  sys_tzone_k_t = (                    {mnemonics to identify particular time zones}
    sys_tzone_cut_k,                   {coordinated universal time}
    sys_tzone_east_usa_k,              {USA eastern time zone}
    sys_tzone_cent_usa_k,              {USA central time zone}
    sys_tzone_mount_usa_k,             {USA mountain time zone}
    sys_tzone_pacif_usa_k,             {USA pacific time zone}
    sys_tzone_other_k);                {arbitrary tzone, offset given separately}

  sys_daysave_k_t = (                  {daylight savings time handling strategy}
    sys_daysave_no_k,                  {never apply daylight savings time}
    sys_daysave_appl_k);               {apply daylight savings time when appropriate}

  sys_date_t = record                  {expanded format for a date/time}
    year: sys_int_machine_t;           {full year number, such as 1992, 2001, etc}
    month: sys_int_machine_t;          {whole month offsets from start of year}
    day: sys_int_machine_t;            {whole day offsets from start of month}
    hour: sys_int_machine_t;           {whole hour offsets from start of day}
    minute: sys_int_machine_t;         {whole minute offsets from start of hour}
    second: sys_int_machine_t;         {whole second offsets from start of minute}
    sec_frac: real;                    {remaining time from start of second, in secs}
    hours_west: real;                  {tzone hours west of CUT, daysave included}
    tzone_id: sys_tzone_k_t;           {ID for this time zone, use SYS_TZONE_xxx_K}
    daysave: sys_daysave_k_t;          {daylight savings time strategy}
    daysave_on: boolean;               {TRUE if daylight savings time in effect}
    end;
  sys_date_p_t = ^sys_date_t;

  sys_dstr_k_t = (                     {ID of string that can be extracted from date}
    sys_dstr_year_k,                   {full year number, blank pad left}
    sys_dstr_mon_k,                    {month number, zero pad left}
    sys_dstr_mon_name_k,               {full month name, blank pad left}
    sys_dstr_mon_abbr_k,               {month abbreviation, blank pad left}
    sys_dstr_day_k,                    {day number within month, zero pad left}
    sys_dstr_daywk_name_k,             {day of week full name, blank pad left}
    sys_dstr_daywk_abbr_k,             {day of week name abbreviation, blank pad left}
    sys_dstr_hour_k,                   {hour of day, zero pad left}
    sys_dstr_min_k,                    {whole minutes within hour, zero pad left}
    sys_dstr_sec_k,                    {whole seconds within minute, zero pad left}
    sys_dstr_sec_frac_k,               {seconds with fraction, zero pad right}
    sys_dstr_tz_name_k,                {full time zone name, blank pad left}
    sys_dstr_tz_abbr_k);               {time zone name abbreviation, blank pad left}

  sys_envvar_k_t = (                   {option flags for environment variables}
    sys_envvar_noexp_k,                {environment variables in string not expanded}
    sys_envvar_expvar_k);              {environment variables in string are expanded}
  sys_envvar_t = set of sys_envvar_k_t;

  sys_menu_k_t = (                     {IDs for paticular system memu locations}
    sys_menu_none_k,                   {no menu specified}
    sys_menu_desk_all_k,               {on the "desktop" for all users}
    sys_menu_desk_user_k,              {on the "desktop" for the current user}
    sys_menu_progs_all_k,              {normal menu for programs visible to all users}
    sys_menu_progs_user_k);            {normal menu for programs visible to current user}

  sys_mxrec_p_t = ^sys_mxrec_t;
  sys_mxrec_t = record                 {info about one mail exchange server for a domain}
    prev_p: sys_mxrec_p_t;             {pointer to next more preferred server in list}
    next_p: sys_mxrec_p_t;             {pointer to next less preferred server in list}
    name_p: string_var_p_t;            {points to the machine name}
    pref: sys_int_conv16_t;            {preference, lower values more preferred}
    ttl: sys_int_conv32_t;             {remaining time for this record valid, seconds}
    end;

  sys_mxdom_t = record                 {mail exchange data for a domain}
    mem_p: util_mem_context_p_t;       {pointer to mem context all data allocated under}
    n: sys_int_machine_t;              {number of machine names in the list}
    list_p: sys_mxrec_p_t;             {pointer to chain of MX records, most to least preferred}
    end;
  sys_mxdom_p_t = ^sys_mxdom_t;
{
*   Entry points.
}
procedure sys_beep (                   {ring bell or make tone, if possible}
  in      sec_beep: real;              {seconds duration of tone}
  in      sec_wait: real;              {seconds to wait between successive tones}
  in      n: sys_int_machine_t);       {number of tones, or SYS_BEEP_FOREVER}
  val_param; extern;

procedure sys_bomb;                    {abort with err, leave traceback if possible}
  options (extern, noreturn);

procedure sys_bomb_no_tb;              {abort with err, no traceback if possible}
  options (extern, noreturn);

function sys_clock                     {get the current time}
  :sys_clock_t;                        {returned time descriptor for current time}
  val_param; extern;

function sys_clock_add (               {add two clock values}
  in      clock1, clock2: sys_clock_t) {two clock values to add, at least one rel}
  :sys_clock_t;                        {resulting clock value}
  val_param; extern;

function sys_clock_compare (           {compare two clock values}
  in      clock1: sys_clock_t;         {clock value to compare}
  in      clock2: sys_clock_t)         {reference time to compare against}
  :sys_compare_k_t;                    {less / equal / greater comparison result}
  val_param; extern;

function sys_clock_from_date (         {return absolute clock value from a date}
  in      date: sys_date_t)            {input date descriptor}
  :sys_clock_t;                        {clock value resulting from the input date}
  val_param; extern;

function sys_clock_from_fp_abs (       {convert FP seconds to absolute clock value}
  in      s: sys_fp2_t)                {input in seconds}
  :sys_clock_t;                        {returned clock descriptor}
  val_param; extern;

function sys_clock_from_fp_rel (       {convert FP seconds to relative clock value}
  in      s: sys_fp2_t)                {input in seconds}
  :sys_clock_t;                        {returned clock descriptor}
  val_param; extern;

procedure sys_clock_from_str (         {make clock value from date/time string}
  in      s: univ string_var_arg_t;    {date/time string YYYY/MM/DD.hh:mm:ss.ss}
  out     time: sys_clock_t;           {returned clock value, CUT}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

function sys_clock_from_sys_abs (      {make clock value from absolute system time}
  in      clock_sys: sys_sys_time_t)   {absolute system time descriptor}
  :sys_clock_t;                        {returned Cognivision time descriptor}
  val_param; extern;

function sys_clock_from_sys_rel (      {make clock value from relative system time}
  in      clock_sys: sys_sys_time_t)   {relative system time descriptor}
  :sys_clock_t;                        {returned Cognivision time descriptor}
  val_param; extern;

function sys_clock_sub (               {subtract one clock value from another}
  in      clock_start: sys_clock_t;    {starting clock value, may be absolute}
  in      clock_delta: sys_clock_t)    {time to subtract, absolute or relative}
  :sys_clock_t;                        {time value of CLOCK_START - CLOCK_DELTA}
  val_param; extern;

procedure sys_clock_str1 (             {make date string YYYY/MM/DD.hh:mm:ss}
  in      clock: sys_clock_t;          {clock time to convert to string}
  in out  str: univ string_var_arg_t); {returned date/time string}
  val_param; extern;

procedure sys_clock_str2 (             {make date string YYYY/MM/DD.hh:mm:ss.xxx}
  in      clock: sys_clock_t;          {clock time to convert to string}
  in      nsf: sys_int_machine_t;      {number of seconds fraction digits}
  in out  str: univ string_var_arg_t); {returned date/time string}
  val_param; extern;

procedure sys_clock_to_date (          {make expanded date from absolute clock value}
  in      clock: sys_clock_t;          {input clock value, must be absolute}
  in      tzone: sys_tzone_k_t;        {time zone to convert into}
  in      hours_west: real;            {for OTHER tz, hours west of CUT without DST}
  in      daysave: sys_daysave_k_t;    {daylight savings time strategy}
  out     date: sys_date_t);           {completely filled in date descriptor}
  val_param; extern;

function sys_clock_to_fp2 (            {convert clock to floating point seconds}
  in      clock: sys_clock_t)          {input clock descriptor}
  :sys_fp2_t;                          {output value in seconds}
  val_param; extern;

function sys_clock_to_sys (            {convert Cognivision to system clock time}
  in      clock: sys_clock_t)          {Cognivision time descriptor}
  :sys_sys_time_t;                     {returned system time descriptor}
  val_param; extern;

procedure sys_cognivis_dir (           {get full pathname of Cognivision directory}
  in      name: string;                {generic directory name, may be NULL term}
  in out  tnam: univ string_var_arg_t); {resulting full directory tree name}
  val_param; extern;

procedure sys_cognivis_dir_set (       {set pathname of root Cognivision directory}
  in      name: univ string_var_arg_t); {new root dir name, empty to restore default}
  val_param; extern;

procedure sys_date_clean (             {wrap over and underflowed fields in date desc}
  in      date_in: sys_date_t;         {input date that may have out of range fields}
  out     date_out: sys_date_t);       {fixed date, may be same variable as DATE_IN}
  val_param; extern;

function sys_date_dayofweek (          {return number of day within week}
  in      date: sys_date_t)            {descriptor of a complete date}
  :sys_int_machine_t;                  {0-6 day of week, Sunday = 0}
  val_param; extern;

function sys_date_dayofyear (          {return number of day within year}
  in      date: sys_date_t)            {descriptor of a complete date}
  :sys_int_machine_t;                  {0-365 day offset from year start}
  val_param; extern;

procedure sys_date_from_sec (          {make expanded date from absolute seconds}
  in      s: double;                   {input time in absolute seconds}
  in      tzone: sys_tzone_k_t;        {time zone to convert into}
  in      hours_west: real;            {for OTHER tz, hours west of CUT without DST}
  in      daysave: sys_daysave_k_t;    {daylight savings time strategy}
  out     date: sys_date_t);           {completely filled in date descriptor}
  val_param; extern;

procedure sys_date_string (            {make string for part of a complete date}
  in      date: sys_date_t;            {describes the complete date}
  in      string_id: sys_dstr_k_t;     {identifies which string, use SYS_DSTR_xxx_K}
  in      fw: sys_int_machine_t;       {fixed field width or use STRING_FW_xxx_K}
  in out  s: univ string_var_arg_t;    {returned string}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure sys_date_time1 (             {return current local date/time in a string}
  out     date_str: univ string_var_arg_t); {25 chars, "YYYY MMM DD HH:MM:SS ZZZZ"}
  val_param; extern;

procedure sys_date_time2 (             {return current local date/time in a string}
  out     date_str: univ string_var_arg_t); {19 chars, "YYYY/MM/DD.hh:mm:ss"}
  val_param; extern;

procedure sys_date_time3 (             {return current local date/time in a string}
  in      nsf: sys_int_machine_t;      {number of seconds fraction digits to create}
  out     date_str: univ string_var_arg_t); {YYYY/MM/DD.hh:mm:ss.xxx}
  val_param; extern;

function sys_date_to_sec (             {return absolute seconds from a date}
  in      date: sys_date_t)            {descriptor for the input date}
  :double;                             {returned absolute seconds value}
  val_param; extern;

procedure sys_dummy (                  {does nothing, but prevents compiler opts}
  in out  arg: univ char);             {argument is not altered}
  extern;

procedure sys_env_path_get (           {get list of environment file directories}
  out     first_p: sys_name_ent_p_t);  {pointer to first directory in linked list}
  extern;

procedure sys_envvar_del (             {delete environment variable}
  in      varname: univ string_var_arg_t; {name of environment variable to delete}
  out     stat: sys_err_t);
  val_param; extern;

procedure sys_envvar_get (             {get value of system "environment" variable}
  in      varname: univ string_var_arg_t; {name of environment variable}
  in out  varval: univ string_var_arg_t; {value of environment variable}
  out     stat: sys_err_t);
  val_param; extern;

procedure sys_envvar_set (             {set env variable value, created if needed}
  in      varname: univ string_var_arg_t; {name of environment variable}
  in      varval: univ string_var_arg_t; {value of environment variable}
  out     stat: sys_err_t);
  val_param; extern;

procedure sys_envvar_startup_del (     {delete environment variable startup value}
  in      varname: univ string_var_arg_t; {name of environment variable}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure sys_envvar_startup_get (     {get environment value startup value}
  in      varname: univ string_var_arg_t; {name of environment variable}
  in out  val: univ string_var_arg_t;  {returned startup value}
  out     flags: sys_envvar_t;         {set of indicator flags}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

function sys_envvar_startup_set (      {set environment variable to be created at startup}
  in      varname: univ string_var_arg_t; {name of environment variable}
  in      val: univ string_var_arg_t;  {value to set variable to at system startup}
  in      flags: sys_envvar_t;         {set of option flags}
  out     stat: sys_err_t)
  :boolean;                            {TRUE if any startup state was changed}
  val_param; extern;

function sys_error (                   {determine whether error code signals error}
  in      stat: sys_err_t)             {error code to check}
  :boolean;                            {TRUE if STATUS indicates error condition}
  val_param; extern;

procedure sys_error_abort (            {print message and abort only if error}
  in      stat: sys_err_t;             {error code}
  in      subsys_name: string;         {subsystem name of caller's message}
  in      msg_name: string;            {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param; extern;

function sys_error_check (             {print message and return TRUE on error}
  in      stat: sys_err_t;             {error code}
  in      subsys_name: string;         {subsystem name of caller's message}
  in      msg_name: string;            {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t)  {number of parameters in PARMS}
  :boolean;                            {TRUE if STAT indicates error condition}
  val_param; extern;

procedure sys_error_none (             {return NO ERROR error status code}
  out     stat: sys_err_t);            {returned error status code}
  extern;

procedure sys_error_print (            {print system error message}
  in      stat: sys_err_t;             {system error code to print message for}
  in      subsys_name: string;         {subsystem name of caller's message}
  in      msg_name: string;            {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param; extern;

procedure sys_error_string (           {return string associated with status code}
  in      stat: sys_err_t;             {status code to return string for}
  in out  mstr: univ string_var_arg_t); {returned string, empty on no error}
  val_param; extern;

procedure sys_event_create_bool (      {create a Boolean (on/off) system event}
  out     id: sys_sys_event_id_t);     {system event handle, initialized to OFF}
  val_param; extern;

procedure sys_event_create_cnt (       {create a counted event (semiphore)}
  out     id: sys_sys_event_id_t);     {system event handle, initialized to no event}
  val_param; extern;

procedure sys_event_del_bool (         {delete a Boolean system event}
  in out  id: sys_sys_event_id_t);     {handle to event to delete}
  val_param; extern;

procedure sys_event_del_cnt (          {delete a counted system event}
  in out  id: sys_sys_event_id_t);     {handle to event to delete}
  val_param; extern;

procedure sys_event_notify_bool (      {notify (trigger) a Boolean system event}
  in out  id: sys_sys_event_id_t);     {handle to event to trigger}
  val_param; extern;

procedure sys_event_notify_cnt (       {notify (trigger) a counted system event}
  in out  id: sys_sys_event_id_t;      {handle to event to trigger}
  in      n: sys_int_machine_t);       {number of times to notify the event}
  val_param; extern;

procedure sys_event_wait (             {wait indefinitely on a single event}
  in out  event: sys_sys_event_id_t;   {the event to wait on}
  out     stat: sys_err_t);            {returned error status}
  val_param; extern;

procedure sys_event_wait_any (         {wait for any event in list to trigger}
  in out  events: univ sys_event_list_t; {list of events to wait on}
  in      n_list: sys_int_machine_t;   {number of entries in EVENTS list}
  in      timeout: real;               {seconds timeout, or SYS_TIMEOUT_xxx_K}
  out     n: sys_int_machine_t;        {1-N triggered event, 0 = timeout, -1 = err}
  out     stat: sys_err_t);            {returned error status, N = -1 on error}
  val_param; extern;

function sys_event_wait_tout (         {wait for single event or timeout}
  in out  event: sys_sys_event_id_t;   {the event to wait on}
  in      timeout: real;               {seconds timeout, or SYS_TIMEOUT_xxx_K}
  out     stat: sys_err_t)             {returned error status}
  :boolean;                            {TRUE on timeout or error}
  val_param; extern;

procedure sys_exec_tnam_get (          {get the complete pathname of this executable}
  in out  tnam: univ string_var_arg_t; {executable file treename}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure sys_exit;                    {exit quietly, indicate everything normal}
  options (extern, noreturn);

procedure sys_exit_error;              {exit quietly, indicate ERROR condition}
  options (extern, noreturn);

procedure sys_exit_false;              {exit quietly, indicate FALSE condition}
  options (extern, noreturn);

procedure sys_exit_n (                 {exit quietly with specific exit status code}
  in      n: sys_int_machine_t);       {exit status code of program}
  options (extern, noreturn);

procedure sys_exit_true;               {exit quietly, indicate TRUE condition}
  options (extern, noreturn);

function sys_fp_from_ieee32 (          {convert from IEEE 32 bit FP number}
  in      ival: sys_fp_ieee32_t)       {IEEE 32 bit floating point input value}
  :sys_fp_max_t;                       {returned native floating point value}
  val_param; extern;

function sys_fp_from_ieee64 (          {convert from IEEE 64 bit FP number}
  in      ival: sys_fp_ieee64_t)       {IEEE 64 bit floating point input value}
  :sys_fp_max_t;                       {returned native floating point value}
  val_param; extern;

function sys_fp_to_ieee32 (            {convert to IEEE 32 bit FP number}
  in      ival: sys_fp_max_t)          {native floating point input value}
  :sys_fp_ieee32_t;                    {returned IEEE 32 bit floating point value}
  val_param; extern;

function sys_fp_to_ieee64 (            {convert to IEEE 64 bit FP number}
  in      ival: sys_fp_max_t)          {native floating point input value}
  :sys_fp_ieee64_t;                    {returned IEEE 64 bit floating point value}
  val_param; extern;

procedure sys_fpmode_get (             {get current FP handling modes state}
  out     fpmode: sys_fpmode_t);       {returned handle to FP handling modes}
  extern;

procedure sys_fpmode_set (             {set new FP handling modes}
  in      fpmode: sys_fpmode_t);       {descriptor for new modes}
  val_param; extern;

procedure sys_fpmode_traps_none;       {disable all FP exception traps}
  extern;

function sys_height_stdout             {return character height of standard output}
  :sys_int_machine_t;
  val_param; extern;

function sys_inetadr_local (           {determine whether network node address is local}
  in      adr: sys_inet_adr_node_t)    {the node address to test}
  :boolean;                            {TRUE for unroutable local, FALSE for remote}
  val_param; extern;

procedure sys_langp_curr_get (         {get info about current language}
  out     lang_p: sys_lang_p_t);       {pointer to data about current language}
  extern;

procedure sys_langp_get (              {get info about a particular language}
  in      name: univ string_var_arg_t; {name of language to return info about}
  out     lang_p: sys_lang_p_t);       {returned pointer to language info}
  extern;

procedure sys_logoff (                 {log off user running this process}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure sys_mem_alloc (              {allocate a block of virtual memory}
  in      size: sys_int_adr_t;         {size in machine address units}
  out     adr: univ_ptr);              {start adr of region, NIL for unavailable}
  val_param; extern;

procedure sys_mem_check (              {check for legal access to dynamic memory}
  in      m: univ sys_size1_t;         {start memory to be accessed}
  in      len: sys_int_adr_t);         {length of access starting at M}
  val_param; extern;

procedure sys_mem_dealloc (            {deallocate a block of virtual memory}
  in out  adr: univ_ptr);              {starting address of block, returned NIL}
  extern;

procedure sys_mem_error (              {print err message and bomb on no mem}
  in      adr: univ_ptr;               {adr of new mem, NIL triggers error}
  in      subsys_name: string;         {subsystem name of caller's message}
  in      msg_name: string;            {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param; extern;

procedure sys_menu_entry_set (         {add entry to system menu, system dependent}
  in      menuid: sys_menu_k_t;        {ID of the menu to add entry to}
  in      entpath: univ string_var_arg_t; {menu entry path relative to MENUID location}
  in      name: univ string_var_arg_t; {menu entry name}
  in      prog: univ string_var_arg_t; {program to run when menu entry chosen}
  in      parms: univ string_var_arg_t; {target program command line parameters}
  in      wdir: univ string_var_arg_t; {working directory to run program in}
  in      desc: univ string_var_arg_t; {optional description string}
  in      icon: univ string_var_arg_t; {optional pathname of menu entry icon}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure sys_menu_entry_del (         {delete system menu entry}
  in      menuid: sys_menu_k_t;        {ID of the menu to delete entry from}
  in      entpath: univ string_var_arg_t; {menu entry path relative to MENUID location}
  in      name: univ string_var_arg_t; {menu entry name}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure sys_message (                {write message to user}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string);                {message name withing subsystem file}
  extern;

procedure sys_message_bomb (           {write message and abort program with error}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string;                 {message name withing subsystem file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  options (val_param, extern, noreturn);

procedure sys_message_parms (          {write message with parameters from caller}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string;                 {message name withing subsystem file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param; extern;

procedure sys_msg_parm_vstr (          {add var string parameter to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      s: univ string_var_arg_t);   {data for parameter}
  extern;

procedure sys_msg_parm_str (           {add string parameter to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      s: string);                  {data for parameter}
  extern;

procedure sys_msg_parm_int (           {add integer parameter to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      i: sys_int_machine_t);       {data for parameter}
  extern;                              {no VAL_PARAM, needs address of I}

procedure sys_msg_parm_fp1 (           {add single prec floating parm to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      r: single);                  {data for parameter}
  extern;                              {no VAL_PARAM, needs address of R}

procedure sys_msg_parm_fp2 (           {add double prec floating parm to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      r: double);                  {data for parameter}
  extern;                              {no VAL_PARAM, needs address of R}

procedure sys_msg_parm_real (          {floating parameter to msg parms array}
  out     msg_parm: sys_parm_msg_t;    {message parameter array entry to fill in}
  in      r: real);                    {data for parameter}
  extern;                              {no VAL_PARAM, needs address of R}

procedure sys_mx_dealloc (             {deallocate result of MX lookup}
  in out  mxdom_p: sys_mxdom_p_t);     {pointer to MX lookup result, returned NIL}
  val_param; extern;

procedure sys_mx_lookup (              {find mail exchange servers for a domain}
  in out  mem: util_mem_context_t;     {parent mem context, will make subordinate context}
  in      domain: univ string_var_arg_t; {domain name}
  out     mxdom_p: sys_mxdom_p_t;      {pointer to returned data}
  out     stat: sys_err_t);            {completion status, no mem allocated on error}
  val_param; extern;

procedure sys_node_id (                {return unique ID string for this machine}
  in out  s: univ string_var_arg_t);   {returned node ID string}
  extern;

procedure sys_node_name (              {return network name of this machine}
  in out  s: univ string_var_arg_t);   {returned node name string}
  extern;

procedure sys_order_flip (             {flip "byte" order of data object}
  in out  arg: univ sys_arg_any_t;     {data object to flip order of}
  in      size: sys_int_adr_t);        {size of data object to flip}
  val_param; extern;

procedure sys_proc_release (           {let go of process, may deallocate resources}
  in      proc: sys_sys_proc_id_t;     {ID of process we launched}
  out     stat: sys_err_t);            {returned error status}
  val_param; extern;

function sys_proc_status (             {get info about a process on this system}
  in      proc: sys_sys_proc_id_t;     {ID of process to get status of}
  in      wait: boolean;               {wait for process to terminate on TRUE}
  out     exstat: sys_sys_exstat_t;    {child process exit status}
  out     stat: sys_err_t)             {completion status code}
  :boolean;                            {TRUE if child process stopped}
  val_param; extern;

procedure sys_proc_stop (              {stop a process on this system}
  in      proc: sys_sys_proc_id_t;     {ID of process to stop}
  out     stat: sys_err_t);            {returned error status}
  val_param; extern;

procedure sys_reboot (                 {reboot the machine}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure sys_run (                    {run program in separate process}
  in      cmline: univ string_var_arg_t; {prog pathname and command line arguments}
  in      stdio_method: sys_procio_k_t; {how to set up standard I/O of new process}
  in out  stdin, stdout, stderr: sys_sys_iounit_t; {system STDIO handles}
  out     proc: sys_sys_proc_id_t;     {system ID of new process}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure sys_run_shell (              {run command as if entered to shell}
  in      cmline: univ string_var_arg_t; {prog pathname and command line arguments}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure sys_run_stdtalk (            {run prog, get handles to standard streams}
  in      cmline: univ string_var_arg_t; {prog pathname and command line arguments}
  out     proc: sys_sys_proc_id_t;     {system ID of new process}
  out     stdin: sys_sys_iounit_t;     {program's standard input stream handle}
  out     stdout: sys_sys_iounit_t;    {program's standard output stream handle}
  out     stderr: sys_sys_iounit_t;    {program's standard error stream handle}
  out     stat: sys_err_t);            {returned error status}
  val_param; extern;

procedure sys_run_wait_stdnone (       {run program, wait until done, no I/O conn}
  in      cmline: univ string_var_arg_t; {prog pathname and command line arguments}
  out     tf: boolean;                 {TRUE/FALSE condition returned by program}
  out     exstat: sys_sys_exstat_t;    {exit status returned by program}
  out     stat: sys_err_t);            {program's completion status code}
  val_param; extern;

procedure sys_run_wait_stdsame (       {run prog, wait for done, standard I/O conn}
  in      cmline: univ string_var_arg_t; {prog pathname and command line arguments}
  out     tf: boolean;                 {TRUE/FALSE condition returned by program}
  out     exstat: sys_sys_exstat_t;    {exit status returned by program}
  out     stat: sys_err_t);            {program's completion status code}
  val_param; extern;

procedure sys_shutdown (               {shut down and power off to extent possible}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

function sys_stat_match (              {TRUE on specified STAT condition}
  in      subsys: sys_int_machine_t;   {subsystem ID to compare against}
  in      code: sys_int_machine_t;     {code within subsystem to compare against}
  in out  stat: sys_err_t)             {status to test, reset to no error if matched}
  :boolean;                            {TRUE if STAT matched specified conditions}
  val_param; extern;

procedure sys_stat_parm_char (         {add character parameter to STAT}
  in      c: char;                     {data for parameter}
  in out  stat: sys_err_t);            {status code to add parameter to}
  val_param; extern;

procedure sys_stat_parm_int (          {add integer parameter to STAT}
  in      i: sys_int_machine_t;        {data for parameter}
  in out  stat: sys_err_t);            {status code to add parameter to}
  val_param; extern;

procedure sys_stat_parm_real (         {add floating point parameter to STAT}
  in      r: double;                   {data for parameter}
  in out  stat: sys_err_t);            {status code to add parameter to}
  val_param; extern;

procedure sys_stat_parm_str (          {add string parameter to STAT}
  in      s: string;                   {data for parameter}
  in out  stat: sys_err_t);            {status code to add parameter to}
  val_param; extern;

procedure sys_stat_parm_vstr (         {add var string parameter to STAT}
  in      s: univ string_var_arg_t;    {data for parameter}
  in out  stat: sys_err_t);            {status code to add parameter to}
  val_param; extern;

procedure sys_stat_set (               {set status code to a non-system value}
  in      subsys: sys_int_machine_t;   {subsystem ID code}
  in      n: sys_int_machine_t;        {status ID within subsystem}
  out     stat: sys_err_t);            {returned properly set status code}
  val_param; extern;

procedure sys_thread_create (          {create a new thread in this process}
  in      threadproc_p: sys_threadproc_p_t; {pointer to root thread routine}
  in      arg: sys_int_adr_t;          {argument passed to thread routine}
  out     id: sys_sys_thread_id_t;     {ID of newly created thread}
  out     stat: sys_err_t);            {returned error status}
  val_param; extern;

procedure sys_thread_event_get (       {get system event to wait on thread exit}
  in      thread: sys_sys_thread_id_t; {system handle to the thread}
  out     event: sys_sys_event_id_t;   {associated system event handle}
  out     stat: sys_err_t);            {returned error status}
  val_param; extern;

procedure sys_thread_exit;             {exit this thread}
  options (extern, noreturn);

procedure sys_thread_lock_create (     {create an interlock for single threading}
  out     h: sys_sys_threadlock_t;     {handle to new thread interlock}
  out     stat: sys_err_t);            {returned error status}
  val_param; extern;

procedure sys_thread_lock_delete (     {delete a single thread interlock}
  in out  h: sys_sys_threadlock_t;     {handle from SYS_THREAD_LOCK_CREATE}
  out     stat: sys_err_t);            {returned error status}
  val_param; extern;

procedure sys_thread_lock_enter (      {enter single threaded code segment}
  in out  h: sys_sys_threadlock_t);    {handle from SYS_THREAD_LOCK_CREATE}
  val_param; extern;

procedure sys_thread_lock_enter_all;   {enter single threaded code for all threads}
  val_param; extern;

procedure sys_thread_lock_leave (      {leave single threaded code segment}
  in out  h: sys_sys_threadlock_t);    {handle from SYS_THREAD_LOCK_CREATE}
  val_param; extern;

procedure sys_thread_lock_leave_all;   {leave single threaded code for all threads}
  val_param; extern;

procedure sys_thread_mem_release (     {release memory shared across threads}
  in out  h: sys_sys_threadmem_h_t);   {handle to the shared memory}
  val_param; extern;

procedure sys_thread_mem_shareable (   {alloc mem to be shared with child threads}
  in      size: sys_int_adr_t;         {size in machine address units}
  out     adr: univ_ptr;               {start adr of new mem, NIL = unavailable}
  out     h: sys_sys_threadmem_h_t);   {handle to new memory}
  val_param; extern;

procedure sys_thread_release (         {release thread state if/when thread exits}
  in out  id: sys_sys_thread_id_t;     {thread ID, will be returned invalid}
  out     stat: sys_err_t);            {returned error status}
  val_param; extern;

procedure sys_thread_yield;            {give up remainder of time slice}
  extern;

procedure sys_timer_init (             {initialize a stopwatch timer}
  out     t: sys_timer_t);             {timer to initialize}
  extern;

function sys_timer_sec (               {return elapsed seconds currently on timer}
  in      t: sys_timer_t)              {timer to use}
  :double;
  extern;

procedure sys_timer_start (            {start accumulating elapsed time}
  in out  t: sys_timer_t);             {timer to use}
  extern;

procedure sys_timer_stop (             {stop accumulating elapsed time}
  in out  t: sys_timer_t);             {timer to use}
  extern;

procedure sys_timezone_here (          {get information about the current time zone}
  out     tzone: sys_tzone_k_t;        {time zone ID}
  out     hours_west: real;            {hours west of CUT without daylight save time}
  out     daysave: sys_daysave_k_t);   {daylight savings time strategy}
  val_param; extern;

function sys_width_stdout              {return character width of standard output}
  :sys_int_machine_t;
  val_param; extern;

procedure sys_wait (                   {suspend process for specified seconds}
  in      wait: real);                 {number of seconds to wait}
  val_param; extern;
