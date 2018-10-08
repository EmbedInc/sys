{   Private system-dependent include file for implementing the SYS library
*   routines.
*
*   This version is for the Microsoft Win32 API.
}
type
  win_word_t = int16u_t;               {Windows WORD data type}
  win_dword_t = int32u_t;              {Windows DWORD data type}
  win_short_t = integer16;             {Windows SHORT data type}
  win_ushort_t = int16u_t;             {Windows U_SHORT data type}
  win_long_t = integer32;              {Windows LONG data type}
  win_wchar_t = int16u_t;              {Windows WCHAR (Unicode character) data type}
  win_uint_t = int32u_t;               {Windows UINT data type}
  win_handle_t = int32u_t;             {Windows HANDLE data type}
  win_atom_t = win_word_t;             {ID of string in global atom table}
{
*   Windows BOOL data type.  This changed at version 5.0 of the Microsoft
*   Visual C/C++ compiler.  It used to be a 32 bit integer, now its an
*   8 bit integer, and essentially equivalent to our built in "boolean"
*   type.  We declare it as an enumerated type for compatibility with the
*   code that was written prior to version 5 of the compiler.
}
  win_bool_t = int8u_t (               {Windows BOOL data type}
    win_bool_false_k = 0,              {FALSE}
    win_bool_true_k = 1);              {example only, any non-zero value is TRUE}

  win_word_p_t = ^win_word_t;          {pointers to the basic Windows data types}
  win_dword_p_t = ^win_dword_t;
  win_short_p_t = ^win_short_t;
  win_ushort_p_t = ^win_ushort_t;
  win_long_p_t = ^win_long_t;
  win_wchar_p_t = ^win_wchar_t;
  win_uint_p_t = ^win_uint_t;
  win_handle_p_t = ^win_handle_t;
  win_bool_p_t = ^win_bool_t;
  win_atom_p_t = ^win_atom_t;

  win_iocode_t = win_dword_t;          {I/O control code for DeviceIoControl}

const
{
*   Bit sizes of several of the Windows data types.  These constants
*   are useful for constructing sets, below.
}
  bits_win_word_k = sizeof(win_word_t) * sys_bits_adr_k;
  bits_win_dword_k = sizeof(win_dword_t) * sys_bits_adr_k;
  bits_win_long_k = sizeof(win_long_t) * sys_bits_adr_k;
  bits_win_uint_k = sizeof(win_uint_t) * sys_bits_adr_k;
{
*   Additional process exit status codes that are not intended for use
*   in portable code.  The portable process exit status codes are defined
*   in SYS_SYS.INS.PAS.
}
  sys_sys_exstat_running_k = 16#103;   {process is still running}
{
*   General Windows system constants.
}
  func_fail_k = 16#FFFFFFFF;           {function value to indicate failure}
  handle_none_k = 0;                   {indicates handle to nothing}
  handle_invalid_k = 16#FFFFFFFF;      {handle returned on failure, etc}
  socket_invalid_k = handle_invalid_k; {socket ID returned on failure, etc}
  win_max_path_k = 260;                {max characters in standard pathname}
  end_of_line = 8#012;                 {end of line character value, CR stripped}
  socket_error_k = -1;                 {error flag returned by socket routines}
  still_running_k = 16#103;            {process or thread is still running}
  timeout_infinite_k = 16#FFFFFFFF;    {infinite timeout}
  commprop_init_k = 16#E73CF52E;       {indicates COMMPROP_T.PACKET_LEN is set}
{
*   Selected error codes.  The base error codes are listed in file WINERROR.H,
*   and codes for some subsystems are in separate include files, like RASERROR.H.
*   These error codes are the values returned by GetLastError.
}
  err_none_k = 0;                      {no error}
  err_file_not_found_k = 2;
  err_path_not_found_k = 3;
  err_access_denied_k = 5;             {no permission or object in use}
  err_handle_invalid_k = 6;            {invalid system handle given}
  err_no_more_files_k = 18;            {no more files for dir or wildcard search}
  err_inuse_k = 32;                    {file is in use}
  err_parm_invalid_k = 87;             {invalid parameter supplied}
  err_pipe_ended_k = 109;              {other end of pipe closed, no more data}
  err_more_data_k = 234;               {more data available than room to return it}
  err_net_gone_k = 520;                {network name no longer available (TCP EOF)}
  err_ras_already_conn_k = 602;        {RAS connection already established}
  err_ras_port_unav_inuse_k = 633;     {RAS port unavailable or already in use}
  err_io_inprogress_k = 996;           {I/O operation still in progress}
  err_io_pending_k = 997;              {I/O operation started but not completed yet}
  err_would_block = 10035;             {operation on non-blocking socket would block}
  err_host_unknown_k = 11001;          {unable to get IP address from host name}
{
*   Flags for describing virtual memory.  These are primarily used to specify
*   how to allocate new memory.  Flags can generally be ORed to produce
*   combinations.
}
  win_vmflag_moveable_k =    16#0002;  {memory block can be moved in virtual space}
  win_vmflag_nocompact_k =   16#0010;  {no compact or discard to alloc new memory}
  win_vmflag_nodiscard_k =   16#0020;  {no discard to alloc new memory}
  win_vmflag_zeroinit_k =    16#0040;  {initialize new memory to all zero}
  win_vmflag_discardable_k = 16#0F00;  {allow memory to be deallocated later}
{
*   IDs for the three standard system streams.  These must be re-typed to
*   WIN_DWORD_T before being passed to GetStdHandle or SetStdHandle.
}
  stdstream_in_k = -10;
  stdstream_out_k = -11;
  stdstream_err_k = -12;
{
*   Sizes and allocation limits.
}
  lan_user_max_k = 256;                {max chars in LAN user name}
  lan_password_max_k = 256;            {max chars in LAN password name}
  lan_computer_max_k = 15;             {max chars in LAN computer name}
  lan_domain_max_k = lan_computer_max_k; {max chars in LAN domain name}

  ras_phbook_ent_name_max_k = 20;      {max RAS phonebook entry name length}
  ras_phnum_max_k = 128;               {max RAS phone number length}
  ras_ph_callbacknum_max_k = 48;       {max RAS call back phone number length}
  ras_devtype_max_k = 16;              {max RAS device type length}
  ras_devname_max_k = 32;              {max RAS device name length}
{
*   Field width constants for the FLAGS parameter to FormatMessage.  These
*   constants are masked into the bits identified by FMSG_WIDTH_MASK_k.  The
*   remaining bits of FLAGS come from FMSG_FLAGS_T.
}
  fmsg_width_mask_k = 255;             {bit mask for width in FormatMessage FLAGS}
  fmsg_width_asis_k = 0;               {copies message with line breaks as written}
  fmsg_width_max_k = fmsg_width_mask_k; {copy only hard-coded line breaks from msg}
{
*   Natural language identifiers.  A complete natural language identifier is
*   made by merging the primary language ID into bits <9-0> and the sublanguage
*   identifier into bits <15-10>.
}
  win_lang_neutral_k = 0;              {language IDs for special operations}
  win_sublang_neutral_k = 0;
  win_sublang_default_k = 1;
  win_sublang_sys_default_k = 2;

  win_userlanguage_k =                 {ID for user's default language}
    win_lang_neutral_k ! lshft(win_sublang_default_k, 10);

type
  win_string_t = array[1..1] of char;  {standard system string for our config}
  win_string_p_t = ^win_string_t;      {pointer to arbitrary system string}
  unicode_str_t = array[1..1] of win_wchar_t; {arbitrary unicode string}

  win_handle_list_t = array[0..0] of win_handle_t; {arbitrary list of handle}
{
*   File data/time stamps use a different format than the native system time
*   descriptor.  The file date/time descriptor is the number of 100nS intervals
*   since the start of 1 January 1601.
}
  sys_sys_time_file_t = record         {time format used in file time stamps}
    low32: win_dword_t;                {low 32 bits of 100nS counter}
    high32: win_dword_t;               {high 32 bits of 100nS counter}
    end;

  time_zone_k_t = win_dword_t (        {time zone type IDs}
    time_zone_unk_k = 0,               {can't determine the time zone}
    time_zone_std_k = 1,               {within standard time of time zone}
    time_zone_day_k = 2);              {within daylight savings time of time zone}

  win_path_t =                         {standard max-size file system path name}
    array[1..win_max_path_k] of char;
  win_wpath_t =                        {max_size pathname using wide characters}
    array[1..win_max_path_k] of win_wchar_t;
{
*   Time zone information.  The TIME_STD and TIME_DAY fields are not what you
*   might expect.  These indicate when to switch to standard time (TIME_STD) and
*   when to switch to daylight savings time (TIME_DAY).  Either might be left
*   unspecified.  This is indicated when the MONTH field is zero.  If TIME_STD
*   is specified, then TIME_DAY must also be.  The BIAS_STD and BIAS_DAY fields
*   are not valid when the corresponding TIME_xxx fields are not specified.
*
*   These fields can have two formats, absolute and day-in-month.  The absolute
*   format is the UTC when to switch.  The time descriptor is interpreted in the
*   usual way.  For day-in-month format, the YEAR field is zero.  The DAY field
*   then indicates the Nth occurrance of the selected day of the week within the
*   month.  DAY = 5 indicates the last occurrance.  Therefore the first Sunday
*   in April is specified by YEAR = 0, MONTH = 4, DAY_WEEK = 0, DAY = 1.
}
  wname32_t = array[1..32] of win_wchar_t; {32 character Unicode name}

  time_zone_info_t = record            {info about a time zone}
    bias_curr: win_long_t;             {minutes to add to make coor univ time}
    name_std: wname32_t;               {name during standard time}
    time_std: sys_sys_time_t;          {when to switch to standard time, see above}
    bias_std: win_long_t;              {additional bias for standard time}
    name_day: wname32_t;               {name during daylight savings time}
    time_day: sys_sys_time_t;          {when to switch to day save time, see above}
    bias_day: win_long_t;              {additional bias for daylight savings time}
    end;

  faccess_k_t = (                      {file access modes}
    faccess_exec_k = 29,               {execute}
    faccess_write_k = 30,              {read}
    faccess_read_k = 31);              {write}
  faccess_t =                          {NULL set still allows attributes query}
    set of bitsize bits_win_dword_k eletype faccess_k_t;

  moaccess_k_t = win_dword_t (         {mapping object access modes}
    moaccess_read_k = 2,               {read only}
    moaccess_readwrite_k = 4,          {read and write}
    moaccess_writecopy_k = 8);         {copy on write}

  maccess_k_t = win_dword_t (          {access to mapped view of a file}
    maccess_writecopy_k = 1,           {copy on write}
    maccess_readwrite_k = 2,           {read and write access}
    maccess_read_k = 4);               {read only}

  fshare_k_t = (                       {file sharing modes}
    fshare_read_k = 0,                 {others may read file}
    fshare_write_k = 1);               {others may write to the file}
  fshare_t = set of bitsize bits_win_dword_k eletype fshare_k_t;

  secure_attr_p_t = ^secure_attr_t;    {pointer to security attributes structure}

  fcreate_k_t = win_dword_t (          {file creation behavior ID}
    fcreate_new_k = 1,                 {create new file, fails if already exist}
    fcreate_overwrite_k = 2,           {create new file, overwrites any old file}
    fcreate_existing_k = 3,            {open old file, fails if not already exist}
    fcreate_open_k = 4,                {opens existing file, creates if needed}
    fcreate_truncate_k = 5);           {open old file, truncates file to zero length}

  fattr_k_t = (                        {file attributes and mode flags}
    fattr_readonly_k = 0,              {apps can read but not write or delete file}
    fattr_hidden_k = 1,                {file not shown in ordinary directory listing}
    fattr_system_k = 2,                {file for exclusive OS use}
    fattr_dir_k = 4,                   {directory}
    fattr_archive_k = 5,               {file marked for backup or removal}
    fattr_normal_k = 7,                {no other attributes, must be used alone}
    fattr_temp_k = 8,                  {temporary, buffer in memory if possible}
    fattr_compressed_k = 11,           {compressed}
    fattr_posix_k = 24,                {Posix rules, case-sensitive names, etc.}
    fattr_backup_k = 25,               {open/create for backup or restore}
    fattr_del_close_k = 26,            {delete file on close}
    fattr_sequential_k = 27,           {optimize for sequentially accessing file}
    fattr_random_k = 28,               {optimize for randomly accessing file}
    fattr_nobuf_k = 29,                {data is not buffered or cached}
    fattr_overlap_k = 30,              {I/O calls just initiate operation and return}
    fattr_writethru_k = 31);           {immediately write data thru cache}
  fattr_t = set of bitsize bits_win_dword_k eletype fattr_k_t;

  dos_file_name_t =                    {8.3 char DOS file name, NULL terminated}
    array[1..14] of char;

  fdata_find_t = record                {data about file from FindNextFile, etc.}
    attr: fattr_t;                     {set of attribute flags}
    time_create: sys_sys_time_file_t;  {creation time, 0,0 for not supported}
    time_access: sys_sys_time_file_t;  {last access time, 0,0 for not supported}
    time_write: sys_sys_time_file_t;   {last write time, 0,0 for not supported}
    size_high: win_dword_t;            {file size in bytes, high word}
    size_low: win_dword_t;             {file size in bytes, low word}
    reserved0: win_dword_t;
    reserved1: win_dword_t;
    name: win_path_t;                  {true file name, NULL terminated}
    name_alt: dos_file_name_t;         {DOS alias file name, NULL terminated}
    end;

  fdata_handle_t = record              {data about file got from connection handle}
    attr: fattr_t;                     {set of attribute flags}
    time_create: sys_sys_time_file_t;  {creation time, 0,0 for not supported}
    time_access: sys_sys_time_file_t;  {last access time, 0,0 for not supported}
    time_write: sys_sys_time_file_t;   {last write time, 0,0 for not supported}
    volser: win_dword_t;               {volume serial number}
    size_high: win_dword_t;            {file size in bytes, high word}
    size_low: win_dword_t;             {file size in bytes, low word}
    n_links: win_dword_t;              {number of hard links to this file}
    id_high: win_dword_t;              {unique ID for file while open, high word}
    id_low: win_dword_t;               {unique ID for file while open, low word}
    end;

  overlap_t = record                   {for overlapped I/O and file position}
    internal: win_dword_t;             {for system use}
    internal_high: win_dword_t;        {for system use}
    offset: win_dword_t;               {file offset for start of I/O operation}
    offset_high: win_dword_t;          {high bytes of file offset}
    event_h: win_handle_t;             {handle to event for I/O complete}
    end;
  overlap_p_t = ^overlap_t;

  fmove_k_t = win_dword_t (            {file pos move distance interpretation}
    fmove_abs_k = 0,                   {distance is new absolute file offset}
    fmove_rel_k = 1,                   {distance is relative to current position}
    fmove_end_k = 2);                  {distance is relative to end of file}

  drivetype_k_t = win_uint_t (         {system drive type IDs}
    drivetype_unknown_k = 0,           {type can't be determined}
    drivetype_none_k = 1,              {no such drive exists}
    drivetype_remove_k = 2,            {medium is removable from the drive}
    drivetype_fixed_k = 3,             {medium can't be removed from drive}
    drivetype_remote_k = 4,            {network drive}
    drivetype_cdrom_k = 5,             {drive is a CDROM}
    drivetype_ram_k = 6);              {drive is a RAMDISK}

  filesys_k_t = (                      {flags about a particular file system}
    filesys_case_sens_k = 0,           {file name are case-sensitive}
    filesys_case_pres_k = 1,           {file name case is preserved}
    filesys_unicode_k = 3,             {unicode file names are stored}
    filesys_acls_k = 4);               {file system preserves and enforces ACLs}
  filesys_t = set of bitsize bits_win_dword_k eletype filesys_k_t;

  wsa_version_t = record               {Windows sockets version ID}
    major: int8u_t;                    {major version number}
    minor: int8u_t;                    {minor version number}
    end;

  wsa_info_t = record                  {info about Windows sockets implementation}
    version: wsa_version_t;            {version actually in use}
    version_max: wsa_version_t;        {max version the DLL can support}
    description: array[1..257] of char; {NULL terminated description string}
    status: array[1..129] of char;     {NULL terminated library status string}
    sock_max: int16u_t;                {max possible sockets this process can open}
    udp_maxsize: int16u_t;             {max UDP message size, 512 min, 0 = no max}
    vendor_p: univ_ptr;                {pointer to DLL vedor specific info}
    end;

  portid_t = int16u_t;                 {local communications port ID}

  socketid_t = win_handle_t;           {system network socket ID}

  inet_adr_p_t = ^sys_inet_adr_node_t; {pointer to internet node address}

  adrfam_k_t = sys_int_machine_t (     {network address families}
    adrfam_unspec_k = 0,               {not specified}
    adrfam_unix_k = 1,                 {UNIX, for pipes, etc. local to machine}
    adrfam_inet_k = 2);                {internet, UCP, TCP, etc.}

  socktype_k_t = sys_int_machine_t (   {socket type}
    socktype_stream_k = 1,             {reliable byte stream}
    socktype_dgram_k = 2,              {datagram, not reliable}
    socktype_raw_k = 3,                {raw interface, for root user only}
    socktype_rdm_k = 4,                {reliably delivered message}
    socktype_seqpacket_k = 5);         {sequenced packet stream}

  sockprot_k_t = sys_int_machine_t (   {socket protocol family}
    protfam_unspec_k = 0,              {not specified}
    protfam_unix_k = 1,                {UNIX, for pipes, etc. local to machine}
    protfam_inet_k = 2);               {internet, UCP, TCP, etc.}

  ipproto_k_t = sys_int_machine_t (    {IP Protocols}
    sol_socket_k = 16#ffff,            {level number to apply to socket itself}
    ipproto_ip_k = 0,                  {dummy for IP}
    ipproto_icmp_k = 1,                {control message protocol}
    ipproto_igmp_k = 2,                {group management protocol}
    ipproto_ggp_k = 3,                 {gateway^2 (deprecated)}
    ipproto_tcp_k = 6,                 {tcp}
    ipproto_pup_k = 12,                {pup}
    ipproto_udp_k = 17,                {user datagram protocol}
    ipproto_idp_k = 22,                {xns idp}
    ipproto_nd_k = 77,                 {UNOFFICIAL net disk proto}
    ipproto_raw_k = 255,               {raw IP packet}
    ipproto_max_k = 256);

  sockopt_k_t = sys_int_machine_t (    {socket option "names"}
    {option flags per-socket [i.e. level = sol_socket_k]}
    so_debug_k = 16#0001,              {turn on debugging info recording}
    so_acceptconn_k = 16#0002,         {socket has had listen()}
    so_reuseaddr_k = 16#0004,          {allow local address reuse}
    so_keepalive_k = 16#0008,          {keep connections alive}
    so_dontroute_k = 16#0010,          {just use interface addresses}
    so_broadcast_k = 16#0020,          {permit sending of broadcast msgs}
    so_useloopback_k = 16#0040,        {bypass hardware when possible}
    so_linger_k = 16#0080,             {linger on close if data present}
    so_oobinline_k = 16#0100,          {leave received OOB data in line}
    so_dontlinger_k = ~ord(so_linger_k), {turn off linger}
    so_exclusiveaddruse_k = ~ord(so_reuseaddr_k), {disallow local address reuse}
    {Additional options.}
    so_sndbuf_k = 16#1001,             {send buffer size}
    so_rcvbuf_k = 16#1002,             {receive buffer size}
    so_error_k = 16#1007,              {get error status and clear}
    so_type_k = 16#1008,               {get socket type}
    {WinSock 2 extension -- new options}
    so_group_id_k = 16#2001,           {ID of a socket group}
    so_group_priority_k = 16#2002,     {the relative priority within a group}
    so_max_msg_size_k = 16#2003,       {maximum message size}
    so_protocol_infoa_k = 16#2004,     {WSAPROTOCOL_INFOA structure}
    so_protocol_infow_k = 16#2005,     {WSAPROTOCOL_INFOW structure}
    pvd_config_k = 16#3001,            {configuration info for service provider}
    so_conditional_accept_k = 16#3002, {enable true conditional accept}
    {TCP options}
    tcp_nodelay_k = 16#0001);

  sendflag_k_t = sys_int_machine_t (   {sending socket data FLAGS parameter}
    sendflag_dontroute_k = 4);         {send without using routing tables}
  sendflag_t =                         {FLAGS parameter}
    set of bitsize bits_win_uint_k eletype sendflag_k_t;

  linger_t = record                    {structure used for so_linger_k optval}
    l_onoff: win_ushort_t;             {option on/off}
    l_linger: win_ushort_t;            {linger time in seconds}
    end;

  sockaddr_t = record                  {socket name or address}
    adrfam: win_ushort_t;              {address family, use ORD(ADRFAM_xxx_K)}
    case adrfam_k_t of                 {which address family is being used}
adrfam_inet_k: (                       {address family is INTERNET}
      inet_port: portid_t;             {port local to this machine, network order}
      inet_adr: sys_inet_adr_node_t;   {machine network address, network order}
      inet_pad: array[1..8] of int8u_t; {8 bytes of padding, don't touch}
      );
    end;

const
  sockaddr_len_inet_k =                {size of SOCKADDR_T with INTERNET addressing}
    offset(sockaddr_t.inet_pad) + sizeof(sockaddr_t.inet_pad);

type
  names_list_t =                       {list of pointers to names, NIL ends list}
    array[1..1] of ^string;
  name_list_p_t = ^name_list_t;

  inet_adr_list_t =                    {list of pointers to intenet adrs, NIL ends}
    array[1..1] of inet_adr_p_t;
  inet_adr_list_p_t = ^inet_adr_list_t;

  hostent_t = record                   {info about one host on the network}
    name_p: ^string;                   {pointer to official host name}
    names_list_p: name_list_p_t;       {pointer to list of other name string pntrs}
    adr_type: win_short_t;             {host address type, use ORD(ADRFAM_xxx_K)}
    adr_len: win_short_t;              {length of each address in list}
    adr_list_p: inet_adr_list_p_t;     {point to list of network address pointers}
    end;
  hostent_p_t = ^hostent_t;

  pcreate_k_t = (                      {individual process creation flags}
    pcreate_debug_k = 0,               {calling process is debugging new process}
    pcreate_ndebug_k = 1,              {don't inherit DEBUG flag}
    pcreate_suspend_k = 2,             {start thread suspended until ResumeThread}
    pcreate_noconsole_k = 3,           {don't inherit our console, don't make new}
    pcreate_newconsole_k = 4,          {create new console for new process}
    pcreate_prio_norm_k = 5,           {NORMAL scheduling priority}
    pcreate_prio_idle_k = 6,           {IDLE scheduling priority}
    pcreate_prio_high_k = 7,           {HIGH scheduling priority}
    pcreate_prio_real_k = 8,           {REAL TIME scheduling priority}
    pcreate_group_k = 9,               {new proc is root of new process group}
    pcreate_unicode_k = 10,            {environment string will be in unicode}
    pcreate_newdos_k = 11,             {run in new virtual DOS machine, 16 bit only}
    pcreate_deferr_k = 26,             {don't inherit error modes, use defaults}
    pcreate_nowind_k = 27);            {system value CREATE_NO_WINDOW}
  pcreate_t = set of bitsize bits_win_dword_k eletype pcreate_k_t;

  pstart_k_t = (                       {individual bits in PROCSTART_T.FLAGS}
    pstart_winshow_k = 0,              {WINSHOW field is valid}
    pstart_winsize_k = 1,              {DX and DY fields are valid}
    pstart_winpos_k = 2,               {X and Y fields are valid}
    pstart_charsize_k = 3,             {XCHARS and YCHARS fields are valid}
    pstart_fillattr_k = 4,             {FILL_ATTR field is valid}
    pstart_fullscreen_k = 5,           {system STARTF_RUNFULLSCREEN, x86 cpus only}
    pstart_fdback_on_k = 6,            {wake up with feedback cursor ON}
    pstart_fdback_off_k = 7,           {wake up with feedback cursor OFF}
    pstart_stdio_k = 8);               {STDIN, STDOUT, and STDERR fields are valid}
  pstart_t = set of bitsize bits_win_dword_k eletype pstart_k_t;

  winshow_k_t = sys_int_machine_t (    {window show state}
    winshow_hide_k = 0,                {hide window and activates another window}
    winshow_normal_k = 1,              {show and activate normally, use 1st time}
    winshow_minimize_k = 2,            {show and activate minimized}
    winshow_maximize_k = 3,            {show and activate maximized}
    winshow_noactivate_k = 4,          {show in most recent position, don't activate}
    winshow_show_k = 5,                {show and activate in current position}
    winshow_min_next_k = 6,            {show and minimize, activate next window}
    winshow_min_noactive_k = 7,        {show and minimize, don't change active wind}
    winshow_show_noactive_k = 8,       {show as is, don't change active window}
    winshow_restore_k = 9,             {show, activate, restore from min or max}
    winshow_default_k = 10);           {set as passed from invoking process}

  procstart_t = record                 {process startup info}
    size: win_dword_t;                 {byte size of this structure}
    reserved1_p: win_string_p_t;       {we must init this to NIL}
    desktop_p: win_string_p_t;         {for future use, init to NIL}
    title_p: win_string_p_t;           {console title, must be NIL if no console}
    x, y: win_dword_t;                 {upper left screen pixel of new window}
    dx, dy: win_dword_t;               {pixel size of new window}
    xchars, ychars: win_dword_t;       {size of new console window in characters}
    fill_attr: win_dword_t;            {sets text and bkgnd colors of new console}
    flags: pstart_t;                   {flags indicating valid fields, etc}
    winshow: win_word_t;               {WINSHOW_K_T ordinal value for initial state}
    reserved2: win_word_t;             {we must init this to 0}
    reserved3: univ_ptr;               {we must init this to NIL}
    stdin: win_handle_t;               {handle to standard input stream}
    stdout: win_handle_t;              {handle to standard output stream}
    stderr: win_handle_t;              {handle to standard error stream}
    end;

  procinfo_t = record                  {info about a system process}
    process_h: win_handle_t;           {handle to process}
    thread_h: win_handle_t;            {handle to primary thread of process}
    id_process: win_dword_t;           {process ID, valid only while process running}
    id_thread: win_dword_t;            {primary thread ID, valid only while running}
    end;

  dupflag_k_t = (                      {flags used with DuplicateHandle}
    dupflag_close_src_k = 0,           {close source handle, even on error}
    dupflag_access_same_k = 1);        {ignores ACCESS arg, copies from old handle}
  dupflags_t = set of bitsize bits_win_dword_k eletype dupflag_k_t;

  donewait_k_t = win_dword_t (         {reason WaitFor... routine returned}
    donewait_signaled_k = 0,           {object is in signalled state}
    donewait_abandoned_k = 16#80,      {mutex owner terminated, permission granted}
    donewait_timeout_k = 16#102,       {object never signalled, timout reached}
    donewait_failed_k = 16#FFFFFFFF);  {hard error, call GetLastError for more info}

  fmsg_flag_k_t = (                    {bits in FLAGS arg to FormatMessage}
    fmsg_flag_allocbuf_k = 8,          {alloc buffer, return BUF_P (LocalFree later)}
    fmsg_flag_nparms_k = 9,            {don't expand parms, copy parm refs directly}
    fmsg_flag_f_str_k = 10,            {SRC is pointer to explicit message string}
    fmsg_flag_f_mod_k = 11,            {SRC is msg module H, or NIL for curr proc}
    fmsg_flag_f_sys_k = 12,            {search system message tables for message}
    fmsg_flag_argar_k = 13);           {ARGS_P is array of 32 bit parameters}
  fmsg_flags_t = set of bitsize bits_win_dword_k eletype fmsg_flag_k_t;

  win_language_id_t = win_dword_t;     {primary language <9-0>, sublang <15-10>}

  shutdown_k_t = (                     {shutdown flags for ExitWindowsEx}
                                       {no flags means log off}
    shutdown_shut_k = 0,               {shut down the machine}
    shutdown_reboot_k = 1,             {shut down the machine and reboot}
    shutdown_force_k = 2,              {don't allow apps to abort shutdown}
    shutdown_poweroff_k = 3,           {shut down and turn off power}
    shutdown_forcehung_k = 4);         {force hung apps after a timeout}
  shutdown_t = set of bitsize bits_win_uint_k eletype shutdown_k_t;

  shutreas_k_t = (                     {shutdown reason flags}
    shutreas_user_k = 30,              {user defined}
    shutreas_planned_k = 31,           {planned shutdown}
    {
    *   Major reasons.
    }
    shutreas_hw_k = 16,                {hardware}
    shutreas_app_k = 18);              {application}
  shutreas_t = set of bitsize bits_win_dword_k eletype shutreas_k_t;
{
*   RAS data structures.
}
  rasdial_parms_t = record             {additional parameters for RasDial}
    size: win_dword_t;                 {size in bytes of whole RASDIAL_PARMS_T rec}
    phbook_entry:                      {phone book entry name, or NULL string}
      array [1 .. ras_phbook_ent_name_max_k+1] of char;
    phnum:                             {phone number override, or NULL string}
      array [1 .. ras_phnum_max_k+1] of char;
    phcallback:                        {call back phone number, "*" use phonebook}
      array [1 .. ras_ph_callbacknum_max_k+1] of char;
    user:                              {user name, NULL use curr user name}
      array [1 .. lan_user_max_k+1] of char;
    password:                          {password, NULL use curr user password}
      array [1 .. lan_password_max_k+1] of char;
    domain:                            {domain name, NULL default, "*" use phonebook}
      array [1 .. lan_domain_max_k+1] of char;
    end;

  ras_notify_k_t = win_dword_t (       {selects RasDial notification method}
    ras_notify_none_k = 0,             {use when no notification is requested}
    ras_notify_func_k = 0,             {call ras_notify_func_t type routine}
    ras_notify_func1_k = 1,            {call ras_notify_func1_t type routine}
    ras_notify_msg_k = 16#FFFFFFFF);   {send message to window, win handle supplied}

  ras_conn_t = record                  {info about one active RAS connection}
    size: win_dword_t;                 {size in bytes of whole RAS_CONN_T record}
    handle: win_handle_t;              {handle to this connection}
    phbook_entry:                      {phone book entry name, or NULL string}
      array [1 .. ras_phbook_ent_name_max_k+1] of char;
    end;
  ras_conn_ar_t =                      {list of RAS connection info structures}
    array[1..1] of ras_conn_t;

  ras_state_k_t = sys_int_machine_t (  {all the RAS connection states}
    ras_state_openport_k = 0,
    ras_state_portopened_k,
    ras_state_connectdevice_k,
    ras_state_deviceconnected_k,
    ras_state_alldevicesconnected_k,
    ras_state_authenticate_k,
    ras_state_authnotify_k,
    ras_state_authretry_k,
    ras_state_authcallback_k,
    ras_state_authchangepassword_k,
    ras_state_authproject_k,
    ras_state_authlinkspeed_k,
    ras_state_authack_k,
    ras_state_reauthenticate_k,
    ras_state_authenticated_k,
    ras_state_prepareforcallback_k,
    ras_state_waitformodemreset_k,
    ras_state_waitforcallback_k,
    ras_state_projected_k,

    ras_state_paused_k = 16#1000,      {all paused states have this bit set}
    ras_state_interactive_k = 16#1000,
    ras_state_retryauthentication_k,
    ras_state_callbacksetbycaller_k,
    ras_state_passwordexpired_k,

    ras_state_done_k = 16#2000,        {all done states have this bit set}
    ras_state_connected_k = 16#2000,
    ras_state_disconnected_k);

  ras_status_t = record                {current RAS connection progress status info}
    size: win_dword_t;                 {size in bytes of whole RAS_STATUS_T record}
    state: ras_state_k_t;              {current connection progress state}
    err: sys_sys_err_t;                {error status, 0 = no error}
    dev_type:                          {device type ("modem", "pad", "isdn", etc)}
      array [1 .. ras_devtype_max_k+1] of char;
    dev_name:                          {device name ("Hayes Smartmodem...", etc)}
      array [1 .. ras_devname_max_k+1] of char;
    end;

  winbaud_k_t = integer32 (            {serial line baud rate identifiers}
    winbaud_110_k = 110,
    winbaud_300_k = 300,
    winbaud_600_k = 600,
    winbaud_1200_k = 1200,
    winbaud_2400_k = 2400,
    winbaud_4800_k = 4800,
    winbaud_9600_k = 9600,
    winbaud_14400_k = 14400,
    winbaud_19200_k = 19200,
    winbaud_38400_k = 38400,
    winbaud_56000_k = 56000,
    winbaud_57600_k = 57600,
    winbaud_115200_k = 115200,
    winbaud_128000_k = 128000,
    winbaud_153600_k = 153600,
    winbaud_256000_k = 256000);

  dtrdrv_k_t = (                       {ID's for how DTR SIO line is driven}
    dtrdrv_off_k = 0,                  {DTR is de-asserted the whole time}
    dtrdrv_on_k = 1,                   {DTR is asserted the whole time}
    dtrdrv_handshake_k = 2);           {DTR is handshook}

  rtsdrv_k_t = (                       {ID's for how RTS SIO line is driven}
    rtsdrv_off_k = 0,                  {RTS is de-asserted the whole time}
    rtsdrv_on_k = 1,                   {RTS is asserted the whole time}
    rtsdrv_handshake_k = 2,            {RTS is handshook for flow control}
    rtsdrv_toggle_k = 3);

  parity_k_t = int8u_t (               {SIO line parity bit handling}
    parity_none_k = 0,                 {no parity bit used}
    parity_odd_k = 1,                  {odd parity}
    parity_even_k = 2,                 {even parity}
    parity_one_k = 3,                  {parity bit = 1}
    parity_zero_k = 4);                {parity bit = 0}

  stopbits_k_t = int8u_t (             {SIO line stop bits handling}
    stopbits_1_k = 0,                  {1 stop bit}
    stopbits_1_5_k = 1,                {1.5 stop bits}
    stopbits_2_k = 2);                 {2 stop bits}

  win_dcb_t = packed record            {Windows DCB structure for comm ports}
    size: integer32;                   {size of whole WIN_DCB_T structure}
    baud: winbaud_k_t;                 {baud rate identifier, WINBAUD_xxx_K}

    bin: boolean;                      {binary mode, no EOF check}
    parity_check: boolean;             {parity checking is enabled}
    cts_obey: boolean;                 {obey incoming CTS line for flow control}
    dsr_obey: boolean;                 {obey incoming DSR line for flow control}
    dtrdrv: dtrdrv_k_t;                {how DTR line is driven, DTRDRV_xxx_K}
    dsrrcv: boolean;                   {ignore incoming unless DSR is high}
    xoff_send_go: boolean;             {continue sending after sending XOFF}
    x_obey: boolean;                   {obey incoming XON/XOFF for flow control}
    x_send: boolean;                   {send XON/XOFF for flow control}
    parity_char_replace: boolean;      {replace with PARITY_CHAR on parity error}
    null_discard: boolean;             {discard incoming NULL bytes}
    rtsdrv: rtsdrv_k_t;                {how RTS line is driven, RTSDRV_xxx_K}
    err_abort: boolean;                {abort I/O operation on any error}
    unused1: 0..(2**17 - 1);           {remaining unused bits in 32 bit word}

    unused2: win_word_t;               {must be set to 0}
    xon_lim: win_word_t;               {min input buffer chars before XON sent}
    xoff_lim: win_word_t;              {max input buffer chars before XOFF sent}
    char_size: int8u_t;                {bits per character, 4-8}
    parity: parity_k_t;                {parity bit handling}
    stopbits: stopbits_k_t;            {ID for the number of stop bits}
    xon_char: int8u_t;                 {XON flow control character}
    xoff_char: int8u_t;                {XOFF flow control character}
    parity_char: int8u_t;              {replacement char on parity errors}
    eod_char: int8u_t;                 {character used to indicate end of data}
    event_char: int8u_t;               {received char to indicate special event}
    unused3: win_word_t;
    end;
  win_dcb_p_t = ^win_dcb_t;

  win_comstat_t = packed record        {Windows COMSTAT structure for comm ports}
    xmit_cts_wait: boolean;            {transmission waiting on CTS signal}
    xmit_dsr_wait: boolean;            {transmission waiting on DSR signal}
    xmit_rlsd_wait: boolean;           {transmission waiting on RLSD signal}
    xmit_xoff_hold: boolean;           {transmission held due to XOFF received}
    xmit_xoffsent_hold: boolean;       {transmission held dut to XOFF sent}
    eof: boolean;                      {end of file character was received}
    xcommchar: boolean;                {outgoing char queued by TransmitCommChar}
    unused1: 0..(2**25 - 1);           {remaining unused bits in 32 bit word}
    inqueue: win_dword_t;              {N unread characters in input queue}
    outqueue: win_dword_t;             {N unsent characters in output queue}
    end;

  commprop_t = record                  {communications port config properties}
    packet_len: win_word_t;            {length of entire packet, regardless of req}
    version: win_word_t;               {version number of this structure}
    serv_mask: win_dword_t;            {mask of bits indicating services provided}
    reserved1: win_dword_t;            {reserved, do not use}
    max_tx_queue: win_dword_t;         {max possible output buf size, 0 = no limit}
    max_rx_queue: win_dword_t;         {max possible input buf size, 0 = no limit}
    max_baud: winbaud_k_t;             {max possible baud rate}
    prov_type: win_dword_t;            {communications provider type}
    prov_cap: win_dword_t;             {bitmask for provider capabilities}
    settable_params: win_dword_t;      {bitmask indicating settable parameters}
    settable_baud: win_dword_t;        {bitmask for valid baud rates}
    settable_width: win_word_t;        {bitmask for valid data width}
    settable_stop: win_word_t;         {bitmask for valid stop bits and parit}
    tx_queue: win_dword_t;             {configured output buffer size}
    rx_queue: win_dword_t;             {configured input buffer size}
    prov_spec1: win_dword_t;           {set to COMMPROP_INIT_K if PAKET_LEN set}
    prov_spec2: win_dword_t;
    prov_arr: array[1..4] of int8u_t;  {additional provider info}
    end;

  commerr_k_t = (                      {comm line error codes}
    commerr_overflow_k = 0,            {software input buffer overflow}
    commerr_overrun_k = 1,             {hardware input char buffer overrun}
    commerr_parity_k = 2,              {hardware detected a parity error}
    commerr_framing_k = 3,             {hardware framing error}
    commerr_break_k = 4,               {hardware detected break condition}
    commerr_txfull_k = 8,              {app tried to xmit with output buffer full}
    commerr_parr_timeout_k = 9,        {timeout on parallel device}
    commerr_ioerr_k = 10,              {I/O error}
    commerr_parr_notsel_k = 11,        {parallel device not selected}
    commerr_parr_npaper_k = 12,        {parallel device signalled out of paper}
    commerr_mode_k = 15);              {mode not supported or bad handle}
  commerr_t = set of bitsize bits_win_dword_k eletype commerr_k_t;

  commpurge_k_t = (                    {actions IDs for PurgeComm}
    commpurge_txabort_k = 0,           {terminate outstanding write requests}
    commpurge_rxabort_k = 1,           {terminate outstanding read requests}
    commpurge_txclear_k = 2,           {discards output buffer contents}
    commpurge_rxclear_k = 3);          {discards input buffer contents}
  commpurge_t = set of bitsize bits_win_dword_k eletype commpurge_k_t;

  commevent_k_t = (                    {event IDs for comm ports}
    commevent_rxchar_k = 0,            {character received, read for read}
    commevent_rxflag_k = 1,            {EVENT_CHAR in DCB was received}
    commevent_txempty_k = 2,           {all pending output characters have been sent}
    commevent_cts_k = 3,               {CTS changed state}
    commevent_dsr_k = 4,               {DSR changed state}
    commevent_rlsd_k = 5,              {RLSD changed state}
    commevent_break_k = 6,             {BREAK received}
    commevent_err_k = 7,               {framing, overrun, or parity error occurred}
    commevent_ring_k = 8);             {ring indicator was detected}
  commevent_t = set of bitsize bits_win_dword_k eletype commevent_k_t;

  csidl_k_t = sys_int_machine_t (      {CSIDL_xxx constants, IDs for system directories}
    csidl_programs_k = 16#0002,        {programs menu for this user}
    csidl_desktopdirectory_k = 16#0010, {desktop of this user}
    csidl_common_programs_k = 16#0017, {programs menu for all users}
    csidl_common_desktopdirectory_k = 16#0019); {desktop visible to all users}

const
  commtimeout_max_k = 16#FFFFFFFF;     {special comm port timout value, see below}
{
*   Comm port timeout descriptor.  All values are in milliseconds.  In general,
*   a value of 0 disables the related timeout (never waits).  A special case
*   for READ timeouts exists.  To completely disable all read timeouts and
*   always return immediately with whatever is in the input buffer, set
*   READ_INTERVAL to COMMTIMEOUT_MAX_K, and READ_PER_CHAR and READ_FIXED to 0.
*
*   The total timeout value is the PER_CHAR value times the number of characters,
*   plus the associated FIXED value.
}
type
  commtimeout_t = record               {descriptor for comm device I/O timeouts}
    read_interval: win_dword_t;        {max allowed wait between input chars}
    read_per_char: win_dword_t;        {per character part of total read timeout}
    read_fixed: win_dword_t;           {fixed part of total read timeout}
    write_per_char: win_dword_t;       {per character part of total write timeout}
    write_fixed: win_dword_t;          {fixed part of total write timeout}
    end;
{
*   I/O control codes.  These codes are 32 bit values broken into four fields
*   as shown below.  See WINIOCTL.H.
*
*   <31:16>  -  Device Type.  0-32767 Microsoft reserved, 32768-65535 for
*     customers.  Use constants IOCTL_DEV_xxx_K.
*   <15:14>  -  Read/write access.  Use IOCTL_RW_xxx_K.
*   <13:2>   -  I/O control code.  0-2047 for Microsoft, 2048-4095 for others.
*   <1:0>    -  I/O method.  Use IOCTL_METH_xxx_K.
*
*   The constants IOCTL_<dev>_xxx_K are the full 32 bit values with all the
*   fields set appropriately for each of the individual I/O control operations.
}
const
  ioctl_dev_beep_k =    lshft(16#01, 16); {I/O control device codes}
  ioctl_dev_cdrom_k =   lshft(16#02, 16);
  ioctl_dev_null_k =    lshft(16#15, 16);
  ioctl_dev_cent_k =    lshft(16#16, 16);
  ioctl_dev_sio_k =     lshft(16#1B, 16);
  ioctl_dev_sound_k =   lshft(16#1D, 16);
  ioctl_dev_unknown_k = lshft(16#22, 16);

  ioctl_rw_any_k =       lshft(0, 14); {I/O control read/write access codes}
  ioctl_rw_read_k =      lshft(1, 14);
  ioctl_rw_write_k =     lshft(2, 14);
  ioctl_rw_readwrite_k = lshft(3, 14);

  ioctl_meth_buffered_k =   0;         {I/O control buffering method}
  ioctl_meth_in_direct_k =  1;
  ioctl_meth_out_direct_k = 2;
  ioctl_meth_neither_k =    3;
{
*   Registry manipulation.
}
const                                  {predefined registry keys}
  hkey_classes_root =     16#80000000;
  hkey_current_user =     16#80000001;
  hkey_local_machine =    16#80000002;
  hkey_users =            16#80000003;
  hkey_performance_data = 16#80000004;
  hkey_current_config =   16#80000005;
  hkey_dyn_data =         16#80000006;

type
  raccess_k_t = (                      {registry key access modes}
    raccess_query_k = 0,               {query subkey data}
    raccess_set_k = 1,                 {set subkey data}
    raccess_create_k = 2,              {create subkey}
    raccess_enum_k = 3,                {enumerate subkeys}
    raccess_notify_k = 4,              {get change notification}
    raccess_link_k = 5);               {create symbolic link}
  raccess_t = set of bitsize bits_win_dword_k eletype raccess_k_t;

  regopopt_k_t = (                     {option flags for opening registry key}
    regopopt_unused_k);                {placeholder, no options yet defined}
  regopopt_t = set of bitsize bits_win_dword_k eletype regopopt_k_t;

  regvol_k_t = win_dword_t (           {registry key volatility options}
    regvol_nvol_k = 0,                 {non volatile, saved accross shutdown/reboot}
    regvol_vol_k = 1,                  {volatile, goes away on shutdown}
    regvol_backup_k = 4);              {special flag for backup/restore use}

  reg_opstat_k_t = win_dword_t (       {status of open registry key operation}
    reg_opstat_new_k = 1,              {created new key}
    reg_opstat_old_k = 2);             {opened existing key}

  reg_dtype_k_t = win_dword_t (        {registry value data types}
    reg_dtype_none_k = 0,              {no defined type}
    reg_dtype_str_k = 1,               {null terminated string}
    reg_dtype_str_envvar_k = 2,        {string with unexpanded envvar references}
    reg_dtype_bin_k = 3,               {arbitrary binary data}
    reg_dtype_32_bkw_k = 4,            {32 bit value, backwards byte order}
    reg_dtype_32_fwd_k = 5,            {32 bit value, forwards byte order}
    reg_dtype_link_k = 6,              {symbolic link, unicode}
    reg_dtype_str_mult_k = 7,          {NULL term succession of NULL term strings}
    reg_dtype_resource_k = 8);         {device driver resource list}
{
*   Security.
}
const
  priv_attr_enable_k = 2;              {attribute mask bit for enable privilege}
{
*   Name strings for system privileges.  These strings can be passed to
*   LookupPrivilegeValue to get the corresponding LUID for the privilege.
}
  privnam_shutdown_k = 'SeShutdownPrivilege'(0); {shutdown system}

type
  win_luid_t = record                  {64 bit locally unique ID}
    i1, i2: int32u_t;
    end;

  win_tkacc_k_t = (                    {token access flags}
    win_tkacc_assign_primary_k,        {to attach primary token to process}
    win_tkacc_duplicate_k,             {to duplicate token}
    win_tkacc_impersonate_k,           {to attach impersonation token to process}
    win_tkacc_query_k,                 {to get contents of access token}
    win_tkacc_query_source_k,          {to find source of access token}
    win_tkacc_adjust_priv_k,           {to change priveledges in a token}
    win_tkacc_adjust_groups_k,         {to change groups in a token}
    win_tkacc_adjust_default_k);       {to change default ACL, prim group, owner}
  win_tkacc_t = set of bitsize bits_win_dword_k eletype win_tkacc_k_t;

  luid_and_attr_t = record             {locally unique identifier and it attributes}
    luid: win_luid_t;                  {locally unique identifier}
    attr: win_dword_t;                 {attribute mask bits}
    end;

  token_privileges_t = record          {info about privileges in an access token}
    n: win_dword_t;                    {number of entries in PRIV array}
    priv:                              {list of privileges and enable/disable flags}
      array [1..20] of luid_and_attr_t; {may be any length array at least N long}
    end;
  token_privileges_p_t = ^token_privileges_t;
{
*   DNS constants and structures.
}
  dns_rectype_k_t = win_word_t (
    dns_rectype_a_k = 1,               {A record, address of a host}
    dns_rectype_mx_k = 15);            {MX record, name of mail server for domain}

  dns_opt_k_t = win_dword_t (          {option flags to DnsQuery}
    dns_opt_nocache_k = 3,             {don't use cache}
    dns_opt_cache_k = 4);              {only use cache}
  dns_opts_t = set of bitsize bits_win_dword_k eletype dns_opt_k_t;

  dns_rec_p_t = ^dns_rec_t;
  dns_rec_t = record                   {one DNS record}
    next_p: dns_rec_p_t;               {pointer to next DNS record in list}
    name_p: win_string_p_t;            {name of host this record is for}
    rectype: dns_rectype_k_t;          {type of DNS record, A rec, MX rec, etc}
    len: win_word_t;                   {byte size of variable part of record}
    flags: win_dword_t;                {collection of 1-bit flags}
    ttl: win_dword_t;                  {time to live, seconds}
    unused: win_dword_t;
    case dns_rectype_k_t of
dns_rectype_a_k: (
      a_ipadr: win_dword_t;            {IP-4 address, low to high byte order}
      );
dns_rectype_mx_k: (
      mx_name_p: win_string_p_t;       {pointer to host name}
      mx_pref: win_word_t;             {preference distance, lower is more preferred}
      mx_unused: win_word_t;
      );
    end;

  dns_free_k_t = win_dword_t (         {options for dealocating DNS records}
    dns_free_list_k = 1);              {deallocate the whole list}

var (sys2)                             {defined in SYS_SYS_ERR.PAS}
  wsa_started: boolean := false;       {TRUE if WSAStartup already called}
  wsa_info: wsa_info_t;                {info returned from WSAStartup}
  instance_h: win_handle_t;            {handle to this instance of GUI program}
  instance_prev_h: win_handle_t;       {handle to previous instance of GUI program}
  show_state_initial: winshow_k_t;     {initial show state passed to WinMain}
{
*************************************************************************
*
*   Routine declarations.
}
{
********************
*
*   Error handling.
}
function FormatMessageA (              {get text of a message given it's ID}
  in      flags: win_dword_t;          {control flags and output width}
  in      src: univ_ptr;               {handle to msg module, or pnt to source str}
  in      id: win_dword_t;             {message ID, ignored if supplied explicitly}
  in      language: win_language_id_t; {natural language identifier}
  in out  buf_p: univ string_p_t;      {pointer to message text buffer}
  in      bufsize: win_dword_t;        {max chars in BUF_P^ if not automatic alloc}
  in      args_p: univ_ptr)            {pointer to arguments for message}
  :win_dword_t;                        {chars in BUF_P^ not counting NULL, 0 = err}
  val_param; extern;

function GetLastError                  {get last-set error code for this thread}
  :sys_sys_err_t;
  extern;
{
********************
*
*   File handling and I/O routines.
}
function AllocConsole                  {create console and attach to std streams}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  extern;

function ClearCommError (              {clear error on comm line and re-enable I/O}
  in      handle: win_handle_t;        {handle to open I/O connection}
  out     err: commerr_t;              {returned set of error flags}
  out     comstat: win_comstat_t)      {returned comm line current status}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function CloseHandle (                 {close object given its handle}
  in      handle: win_handle_t)        {open handle to close}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function CopyFileA (                   {copy existing file to a new file}
  in      name_old: univ win_path_t;   {existing file name, NULL term}
  in      name_new: univ win_path_t;   {new file name, NULL term}
  in      create_only: win_bool_t)     {don't overwrite old file when >0}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function CreateDirectoryA (            {create a file system directory}
  in      name: univ win_path_t;       {file name, NULL term}
  in      secur_p: secure_attr_p_t)    {pnt to security attributes, may be NIL}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function CreateFileMappingA (          {create handle to map views of file with}
  in      handle: win_handle_t;        {handle to regular file connection}
  in      secur_p: secure_attr_p_t;    {pnt to security attributes, may be NIL}
  in      access: moaccess_k_t;        {read, write, etc. access to allow}
  in      size_high: win_dword_t;      {object size, high 32 bits}
  in      size_low: win_dword_t;       {object size, low 32 bits}
  in      name: univ win_string_t)     {name for sharing, may be NIL pointer}
  :win_handle_t;                       {handle to file mapping object, 0 on err}
  val_param; extern;

function CreateFileA (                 {open a file}
  in      name: univ win_path_t;       {file name, NULL term}
  in      access: faccess_t;           {set of file access flags}
  in      share: fshare_t;             {set of file sharing flags}
  in      secur_p: secure_attr_p_t;    {pnt to security attributes, may be NIL}
  in      create: fcreate_k_t;         {file creating behaviour ID}
  in      attr: fattr_t;               {set of file attribute flags}
  in      attr_handle: win_handle_t)   {handle to attr template or HANDLE_NONE_K}
  :win_handle_t;                       {handle to file conn, HANDLE_INVALID_K on err}
  val_param; extern;

function CreatePipe (                  {create an unnamed local one-directional pipe}
  out     handle_read: win_handle_t;   {returned handle to pipe read I/O connection}
  out     handle_write: win_handle_t;  {returned handle to pipe write I/O connection}
  in      secur_p: secure_attr_p_t;    {pnt to security attributes, may be NIL}
  in      size: win_dword_t)           {buffer size suggestion, system default on 0}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function DeleteFileA (                 {delete file by name}
  in      name: univ win_path_t)       {file name, NULL term}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  extern;

function DeviceIoControl (             {perform I/O control operation}
  in      handle: win_handle_t;        {handle to open I/O connection}
  in      iocode: win_iocode_t;        {control code, use IOCTL_<dev>_xxx_K}
  in      ibuf: univ char;             {additional data used by this operation}
  in      ibuf_size: win_dword_t;      {number of bytes in IBUF}
  out     obuf: univ char;             {buffer to receive any returned data}
  in      obuf_size: win_dword_t;      {number of bytes allowed to write into OBUF}
  out     obuf_rsize: win_dword_t;     {number of bytes actually written into OBUF}
  in      overlap_p: overlap_p_t)      {pnt to overlap control info, may be NIL}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function FindFirstFileA (              {start directory or wildcard search}
  in      name: univ win_path_t;       {wildcard or directory name}
  out     find_data: fdata_find_t)     {returned info about first file}
  :win_handle_t;                       {handle for finding next, or HANDLE_INVALID_K}
  val_param; extern;

function FindNextFileA (               {continue search started with FindFirstFile}
  in      handle: win_handle_t;        {handle from last Find... call}
  in out  find_data: fdata_find_t)     {from last Find... call, will be updated}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function FindClose (                   {close directory or wildcard filename search}
  in      handle: win_handle_t)        {handle from last Find... call}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function FlushFileBuffers (            {write all buffered data to file}
  in      h: win_handle_t)             {handle to I/O connection}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function GetCommProperties (           {get communications port config properties}
  in      handle: win_handle_t;        {handle to open communications port}
  out     prop: commprop_t)            {returned communications port properties}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function GetCommState (                {get current comm device control state}
  in      h: win_handle_t;             {handle to I/O connection}
  out     dcb: win_dcb_t)              {returned structure with control settings}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function GetCurrentDirectoryA (        {get pathname of current directory}
  in      len: win_dword_t;            {max characters that NAME can hold}
  out     name: univ win_path_t)       {returned pathname}
  :win_dword_t;                        {N chars in NAME, not counting NULL, 0 = err}
  val_param; extern;

function GetDriveTypeA (               {get type of a file system drive}
  in      name: univ win_string_t)     {drive name, NIL for current drive}
  :drivetype_k_t;                      {returned drive type ID}
  val_param; extern;

function GetFileAttributesA (          {get attribute flags of file by name}
  in      name: univ win_path_t)       {name of file inquiring about}
  :fattr_t;                            {set of file attribute flags}
  extern;

function GetFileInformationByHandle (  {get info about file given connection handle}
  in      handle: win_handle_t;        {handle from CreateFile}
  out     data: fdata_handle_t)        {returned information}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function GetModuleFileNameA (          {get pathname of a loaded module}
  in      handle: win_handle_t;        {handle to module, NIL for process executable}
  out     name: univ win_string_t;     {returned module pathname}
  in      name_len: win_dword_t)       {max number of chars may write to NAME}
  :win_dword_t;                        {num chars returned, 0 on error}
  val_param; extern;

function GetOverlappedResult (         {get status of overlapped I/O operation}
  in      handle: win_handle_t;        {handle I/O operation is in progress on}
  in out  overlap: overlap_t;          {overlap descriptor supplied to original I/O}
  out     olen: win_dword_t;           {number of bytes actually transferred}
  in      wait: win_bool_t)            {wait for I/O complete on TRUE}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function GetStdHandle (                {get sys file conn handle to standard stream}
  in      id: win_dword_t)             {ID of standard stream}
  :win_handle_t;                       {handle to file conn, or HANDLE_INVALID_K}
  val_param; extern;

function GetVolumeInformationA (       {get info about a file system volume}
  in      root: univ win_string_t;     {file system root directory name}
  out     volname: univ win_string_t;  {name of volume}
  in      volname_max: win_dword_t;    {max characters allowed to write to VOLNAME}
  out     serial: win_dword_t;         {volume serial number}
  out     maxleaflen: win_dword_t;     {max length of file name component}
  out     flags: filesys_t;            {additional flags about this file system}
  out     fsname: univ win_string_t;   {file system type (FAT, NTFS, etc.)}
  in      fsname_max: win_dword_t)     {max characters allowed to write to FSNAME}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function MapViewOfFile (               {map part of file into our address space}
  in      handle: win_handle_t;        {handle to file mapping object}
  in      access: maccess_k_t;         {read/write access required}
  in      ofs_high: win_dword_t;       {starting file offset, high 32 bits}
  in      ofs_low: win_dword_t;        {starting file offset, low 32 bits}
  in      len: win_dword_t)            {size of region to map}
  :univ_ptr;                           {pointer to new mem, NIL on error}
  val_param; extern;

function MoveFileA (                   {rename a file}
  in      name_old: univ win_path_t;   {old file name}
  in      name_new: univ win_path_t)   {new file name}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function PurgeComm (                   {purge comm buffers and/or abort I/O}
  in      h: win_handle_t;             {handle to I/O connection}
  in      commpurge: commpurge_t)      {set of flags indicating what to do}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function ReadFile (                    {read data from an open file}
  in      handle: win_handle_t;        {file connection handle from CreateFile}
  out     buf: univ sys_size1_t;       {buffer to receive returned data}
  in      n: win_dword_t;              {number of bytes to read}
  out     nread: win_dword_t;          {number of bytes actually read}
  in      overlap_p: overlap_p_t)      {pnt to overlap and file pos info, may be NIL}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function RemoveDirectoryA (            {delete an empty directory}
  in      name: univ win_path_t)       {name of directory to delete}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function SetCommMask (                 {set what WaitCommEvent will wait for}
  in      h: win_handle_t;             {handle to I/O connection}
  in      commevent: commevent_t)      {set of event flags}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function SetCommTimeouts (             {set timeout behaviour for comm port I/O}
  in      h: win_handle_t;             {handle to I/O connection}
  in      timeout: commtimeout_t)      {describes timeout strategy and values}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function SetCommState (                {set new comm device control state}
  in      h: win_handle_t;             {handle to I/O connection}
  in      dcb: win_dcb_t)              {control modes structure}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function SetCurrentDirectoryA (        {set new current working directory}
  in      name: univ win_path_t)       {directory name}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function SetEndOfFile (                {set file end to current position}
  in      handle: win_handle_t)        {file connection handle from CreateFile}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function SetFilePointer (              {modify current file position without I/O}
  in      handle: win_handle_t;        {file connection handle from CreateFile}
  in      dmove: win_long_t;           {distance to move, pos forward, neg backward}
  in      dmove_high_p: win_long_p_t;  {pnt to high word distance, return location
                                        of high word pos, NIL = 32 bit offsets only}
  in      method: fmove_k_t)           {interpretation method for move distance}
  :win_dword_t;                        {new abs position low word, or FUNC_FAIL_K}
  val_param; extern;

function SetStdHandle (                {re-direct one of the standard streams}
  in      id: win_dword_t;             {ID of standard stream}
  in      h: win_handle_t)             {new system file conn handle for this stream}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function SetupComm (                   {request communications port buffer sizes}
  in      handle: win_handle_t;        {handle to open communications port}
  in      insize: win_dword_t;         {desired size of input buffer}
  in      outsize: win_dword_t)        {desired size of output buffer}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function UnmapViewOfFile (             {unmap region mapped with MapViewOfFile}
  in      p: univ_ptr)                 {pointer to start of mapped region}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function WaitCommEvent (               {wait for specified event on comm port}
  in      h: win_handle_t;             {handle to I/O connection}
  out     event: commevent_t;          {indicates which event occurred}
  in      overlap_p: overlap_p_t)      {points to overlap info, may be NIL}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function WriteFile (                   {write data to an open file}
  in      handle: win_handle_t;        {file connection handle from CreateFile}
  in      buf: univ sys_size1_t;       {buffer containing data to write}
  in      n: win_dword_t;              {number of bytes to write}
  out     nwrite: win_dword_t;         {number of bytes actually written}
  in      overlap_p: overlap_p_t)      {pnt to overlap and file pos info, may be NIL}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;
{
********************
*
*   Memory management.
}
function LocalAlloc (                  {allocate virtual memory for our process}
  in      flags: win_uint_t;           {use combinations of WIN_VMFLAG_xxx_K}
  in      size: sys_int_adr_t)         {number of bytes to allocate}
  :univ_ptr;                           {pnt to start of new mem, NIL on failure}
  val_param; extern;

function LocalFree (                   {release memory allocated with LocalAlloc}
  in      ptr: univ_ptr)               {pointer to start of memory block}
  :univ_ptr;                           {NIL on success, otherwise not NIL}
  val_param; extern;

function LocalSize (                   {size of chunk allocated with LocalAlloc}
  in      ptr: univ_ptr)               {pointer to start of chunk}
  :sys_int_adr_t;                      {number of bytes in chunk}
  val_param; extern;
{
********************
*
*   Network communication.
}
function accept (
  in      socket: socketid_t;          {ID of socket where listening for connects}
  out     name: sockaddr_t;            {name/address of socket initiating connection}
  in out  namelen: sys_int_adr_t)      {NAME max length in, NAME actual length out}
  :socketid_t;                         {ID of new socket, or SOCKET_INVALID_K}
  val_param; extern;

function bind (                        {bind a name to an existing socket}
  in      socket: socketid_t;          {ID of socket to name}
  in      name: sockaddr_t;            {socket name or address}
  in      namelen: sys_int_adr_t)      {number of bytes in NAME}
  :sys_int_machine_t;                  {0 on success, use WSAGetLastError on fail}
  val_param; extern;

procedure DnsFree (                    {deallocate records returned by DnsQuery}
  in val  rec_p: dns_rec_p_t;          {pointer to structure to deallocate}
  in val  free_type: dns_free_k_t);
  extern;

function DnsQuery_A (
  in      name: univ win_path_t;       {domain name, NULL terminated}
  in val  rectype: dns_rectype_k_t;    {type of record to look up}
  in val  options: dns_opts_t;         {option flags}
  in val  extra: univ_ptr;             {not used, set to NIL}
  out     rec_p: dns_rec_p_t;          {pointer to returned data}
  in val  res: univ_ptr)               {reserved, set to NIL}
  :sys_sys_err_t;                      {completion status code}
  extern;

function closesocket (                 {close connection to a network port}
  in      socket: socketid_t)          {ID of socket to close}
  :sys_int_machine_t;                  {0 on success, use WSAGetLastError on fail}
  val_param; extern;

function connect (                     {request connection to a remote socket}
  in      socket: socketid_t;          {ID of our socket}
  in      name: sockaddr_t;            {name or address of remote socket}
  in      namelen: sys_int_adr_t)      {number of bytes in NAME}
  :sys_int_machine_t;                  {0 on success, use WSAGetLastError on fail}
  val_param; extern;

function gethostbyaddr (               {get host network info given its address}
  in      adr: sys_inet_adr_node_t;    {internet address, network byte order}
  val     adr_len: sys_int_adr_t;      {length of ADR data structure}
  val     adrfam: adrfam_k_t)          {address family, must be ADRFAM_INET_K}
  :hostent_p_t;                        {pnt to host info, NIL on error}
  extern;                              {NOTE: argument ADR is passed by reference}

function gethostbyname (               {get host network info given its name}
  in      name: univ string)           {name inquiring about, null terminated}
  :hostent_p_t;                        {pnt to host info, NIL on error}
  val_param; extern;

function gethostname (                 {get network name of this machine}
  out     name: univ string;           {returned NULL terminated string}
  in      maxlen: sys_int_machine_t)   {max characters allowed to write into NAME}
  :sys_int_machine_t;                  {0 on success, use WSAGetLastError on fail}
  val_param; extern;

function getpeername (                 {get name/address of other end of stream}
  in      socket: socketid_t;          {ID of socket stream open on}
  out     name: sockaddr_t;            {name/adr of socket at other end of stream}
  in out  namelen: sys_int_adr_t)      {NAME max length in, NAME actual length out}
  :sys_int_machine_t;                  {0 on success, use WSAGetLastError on fail}
  val_param; extern;

function getsockname (                 {get internet address bound to a socket}
  in      socket: socketid_t;          {ID of socket inquiring about}
  out     name: sockaddr_t;            {returned address of the socket}
  in out  namelen: sys_int_adr_t)      {NAME max length in, NAME actual length out}
  :sys_int_machine_t;                  {0 on success, use WSAGetLastError on fail}
  val_param; extern;

function getsockopt (                  {get socket options}
  in      socket: socketid_t;          {ID of socket to change}
  in      level: ipproto_k_t;          {Level at which to apply changes}
  in      optname: sockopt_k_t;        {socket option to set}
  out     optval: univ char;           {pointer to the socket value to set}
  in out  optlen: sys_int_machine_t)   {the length of the optval buffer}
  :sys_int_machine_t;                  {0 on success, use WSAGetLastError on fail}
  val_param; extern;

function listen (                      {wait for client connection request}
  in      socket: socketid_t;          {ID of socket listening for connect requests}
  in      backlog: sys_int_machine_t)  {max allowed number of queued requests}
  :sys_int_machine_t;                  {0 on success, use WSAGetLastError on fail}
  val_param; extern;

function sendto (                      {send data to remote socket}
  in      socket: socketid_t;          {ID of socket to use for sending}
  in      buf: univ sys_size1_t;       {buffer containing data to write}
  in      len: sys_int_machine_t;      {number of bytes in BUF to send}
  in      flags: sendflag_t;           {option flags}
  in      name: sockaddr_t;            {socket name or address}
  in      namelen: sys_int_adr_t)      {number of bytes in NAME}
  :sys_int_machine_t;                  {number of bytes sent, or SOCKET_ERROR_K}
  val_param; extern;

function setsockopt (                  {change socket options}
  in      socket: socketid_t;          {ID of socket to change}
  in      level: ipproto_k_t;          {Level at which to apply changes}
  in      optname: sockopt_k_t;        {socket option to set}
  in      optval: univ char;           {pointer to the socket value to set}
  in      optlen: sys_int_machine_t)   {the length of the optval buffer}
  :sys_int_machine_t;                  {0 on success, use WSAGetLastError on fail}
  val_param; extern;

function socket (                      {create a new communications socket}
  in      adrfam: adrfam_k_t;          {address family (Unix, Internet, etc.)}
  in      socktype: socktype_k_t;      {socket type (stream, datagram, etc.)}
  in      prot: sockprot_k_t)          {protocol (Unix, Internet...)}
  :socketid_t;                         {ID of new socket, or SOCKET_INVALID_K}
  val_param; extern;

function WSACleanup                    {undo WSAStartup}
  :sys_int_machine_t;                  {0 on success, use WSAGetLastError on fail}
  extern;

function WSAGetLastError               {get last network-related error}
  :sys_sys_err_t;
  extern;

function WSAStartup (                  {*MUST* be first network call}
  in      version_max: wsa_version_t;  {max DLL version we can drive}
  out     wsa_info: wsa_info_t)        {returned implementation information}
  :sys_sys_err_t;                      {error code or 0 for no error}
  val_param; extern;
{
********************
*
*   Process Management.
}
function CreateEventA (                {create or re-use an event object}
  in      secur_p: secure_attr_p_t;    {pnt to security attributes, may be NIL}
  in      manual_reset: win_bool_t;    {system resets on successful wait when FALSE}
  in      initial: win_bool_t;         {initial state, TRUE for signaled}
  in      name: univ win_string_t)     {name for sharing, may be NIL}
  :win_handle_t;                       {handle to new event object or HANDLE_NONE_K}
  val_param; extern;

function CreateProcessA (              {create a new process and primary thread}
  in      module_p: univ_ptr;          {pnt to pathname of executable module, if NIL
                                        uses first token of CMLINE}
  in      cmline: univ win_string_t;   {command line}
  in      secur_proc_p: secure_attr_p_t; {security attr for process, may be NIL}
  in      secur_thread_p: secure_attr_p_t; {security attr for thread, may be NIL}
  in      inherit_handles: win_bool_t; {new process inherits handles on TRUE}
  in      create_flags: pcreate_t;     {set of additional creation flags}
  in      env_block_p: univ_ptr;       {new environment block pnt, inherit on NIL}
  in      init_dir_p: univ_ptr;        {pnt to initial working dir, inherit on NIL}
  in      procstart: procstart_t;      {initial state for main window, console, etc}
  out     procinfo: procinfo_t)        {returned handles and IDs for new process}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function CreateSemaphoreA (            {create a new semaphore}
  in      secur_p: secure_attr_p_t;    {security attributes, may be NIL}
  in      count_init: win_long_t;      {initial count value}
  in      count_max: win_long_t;       {maximum allowable count value}
  in      name: univ win_string_t)     {semaphore name, may be NIL}
  :win_handle_t;                       {handle to semaphore, HANDLE_NONE_K on err}
  val_param; extern;

function CreateThread (                {create a new thread within this process}
  in      secur_p: secure_attr_p_t;    {pointer to security attributes, may be NIL}
  in      stack_size: win_dword_t;     {initial thread stack size, 0 = default}
  in      routine_p: univ_ptr;         {pnt to thread func, i32 arg, i32 func val}
  in      arg: univ_ptr;               {argument passed to thread function}
  in      flags: pcreate_t;            {create flags, most not valid for threads}
  out     id: win_dword_t)             {ID of the new thread}
  :win_handle_t;                       {new thread handle, GetLastError on NONE}
  val_param; extern;

procedure DeleteCriticalSection (      {deallocate system resources for crit sect}
  in out  crit_sect: sys_sys_threadlock_t); {descriptor for critical section}
  extern;

function DuplicateHandle (             {create new handle to same object as old}
  in      proc_src_h: win_handle_t;    {handle to process owning original handle}
  in      handle_old: win_handle_t;    {handle to duplicate}
  in      proc_dest_h: win_handle_t;   {handle to process that will own new handle}
  out     handle_new: win_handle_t;    {newly created handle}
  in      access: win_dword_t;         {ignored if DUPFLAG_ACCESS_SAME_K used below}
  in      inherit: win_bool_t;         {TRUE allows new handle to be inherited}
  in      dupflags: dupflags_t)        {set of additional modifier flags}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

procedure EnterCriticalSection (       {enter mutual exclusion lock between threads}
  in out  crit_sect: sys_sys_threadlock_t); {descriptor for critical section}
  extern;

procedure ExitProcess (                {exit the current process}
  in      exstat: win_uint_t);         {exit status, use SYS_SYS_EXSTAT_xxx_K}
  val_param; extern;

procedure ExitThread (                 {exit the current thread}
  in      excode: win_dword_t);        {thread exit code}
  val_param; noreturn; extern;

function GetCommandLineA               {get pointer to command line string}
  :win_string_p_t;                     {points to NULL-term command line of process}
  extern;

function GetCurrentProcess             {get pseudo-handle to current process}
  :win_handle_t;                       {pseudo-handle, duplicate to make real handle}
  extern;

function GetCurrentProcessId           {get ID of the current process}
  :win_dword_t;
  extern;

function GetCurrentThread              {get pseudo-handle to current thread}
  :win_handle_t;                       {pseudo-handle, duplicate to make real handle}
  extern;

function GetCurrentThreadId            {get ID of the current thread}
  :win_dword_t;
  extern;

function GetExitCodeProcess (          {get exit status of terminated process}
  in      handle: win_handle_t;        {handle to process}
  out     exstat: win_dword_t)         {ExitProcess value, etc., or STILL_RUNNING_K}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function GetExitCodeThread (           {get exit status of terminated thread}
  in      handle: win_handle_t;        {handle to thread}
  out     exstat: win_dword_t)         {ExitThread value, etc., or STILL_RUNNING_K}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

procedure GetStartupInfoA (            {get info used to start this process}
  out     procstart: procstart_t);     {returned startup info buffer}
  extern;

procedure InitializeCriticalSection (  {init thread mutual exclusion lock}
  in out  crit_sect: sys_sys_threadlock_t); {descriptor for critical section}
  extern;

function SetCriticalSectionSpinCount ( {set the spin count value of a critical section}
  in out  crit_sect: sys_sys_threadlock_t; {the critical section to modify}
  in      spin_count: win_dword_t)     {number of times to spin before semiphore wait}
  :win_dword_t;                        {previous spin count value}
  val_param; extern;

procedure LeaveCriticalSection (       {release thread mutual exclusion lock}
  in out  crit_sect: sys_sys_threadlock_t); {descriptor for critical section}
  extern;

function ShellExecuteA (               {execute command thru shell}
  in      handle: win_handle_t;        {parent window for err messages, may be NULL}
  in      op: univ win_string_t;       {operation verb, may be NULL}
  in      file: univ win_string_t;     {name of system object to "execute"}
  in      parms: univ win_string_t;    {parameters to pass to executable object}
  in      dir: univ win_string_t;      {directory to execute in, NULL curr dir}
  in      show: win_uint_t)            {ID fow how to show executing object window}
  :win_uint_t;                         {err if <=32, >32 no error}
  val_param; extern;

function ReleaseSemaphore (            {increment semaphore value}
  in      handle: win_handle_t;        {handle to semaphore object}
  in      inc: win_long_t;             {amount to increment semaphore by}
  out     old: win_long_t)             {semaphore value before increment}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function ResetEvent (                  {reset an event from the signalled state}
  in      handle: win_handle_t)        {handle to event to reset from signalled}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function SetEvent (                    {explicitly set an event object to signalled}
  in      handle: win_handle_t)        {handle to event to set signalled}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function TerminateProcess (            {terminate a process given a handle to it}
  in      handle: win_handle_t;        {handle to process to terminate}
  in      exstat: win_uint_t)          {exit status for process and all its threads}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function WaitForSingleObject (         {wait for a particular event, or timeout}
  in      handle: win_handle_t;        {wait until this handle becomes signalled}
  in      timeout: win_dword_t)        {milliseconds timeout, or TIMEOUT_xxx_K}
  :donewait_k_t;                       {reason routine returned}
  val_param; extern;

function WaitForMultipleObjects (      {wait for any or all events from a list}
  in      n: win_dword_t;              {number of handles in HANDLES list}
  in      handles: univ win_handle_list_t; {list of handles to wait for signalled on}
  in      wait_all: win_bool_t;        {wait for all on TRUE, wait for any on FALSE}
  in      timeout: win_dword_t)        {milliseconds timeout, or TIMEOUT_xxx_K}
  :donewait_k_t;                       {reason routine returned}
  val_param; extern;
{
********************
*
*   RAS (Remote Access Services)
}
function RasDialA (                    {try to establish remote network connection}
  in      ext_p: univ_ptr;             {pnt to extension info, NIL for portability}
  in      phbook_p: univ_ptr;          {pnt to phone book file, NIL for portability}
  in      parms: rasdial_parms_t;      {additional parameters}
  in      notify_k: ras_notify_k_t;    {progress notification type request}
  in      notify_target: univ_ptr;     {NIL, pnt to func, or window handle}
  out     handle: win_handle_t)        {handle to this new RAS connection}
  :sys_sys_err_t;                      {0 on no error}
  val_param; extern;

function RasEnumConnectionsA (         {get list of current active RAS connections}
  in out  ras_list: univ ras_conn_ar_t; {connections list, first SIZE must be set}
  in out  size: win_dword_t;           {RAS_LIST byte size in,  used size on out}
  out     n: win_dword_t)              {number of RAS connections returned}
  :sys_sys_err_t;                      {0 on no error}
  val_param; extern;

function RasGetConnectStatusA (        {get status of current RAS connection}
  in      handle: win_handle_t;        {handle to RAS connection inquiring about}
  out     status: ras_status_t)        {returned current RAS connection status}
  :sys_sys_err_t;                      {0 on no error}
  val_param; extern;

function RasGetErrorStringA (          {get error message string from RAS err code}
  in      err_stat: sys_sys_err_t;     {error status code to get string for}
  out     str: univ string;            {returned string, 256 chars max}
  in      str_len: win_dword_t)        {number of chars available in STR}
  :sys_sys_err_t;                      {0 on no error}
  val_param; extern;

function RasHangUpA (                  {break a RAS connection}
  in      handle: win_handle_t)        {handle to RAS connection to terminate}
  :sys_sys_err_t;                      {0 on no error}
  val_param; extern;
{
********************
*
*   Registry manipulation.
}
function RegCloseKey (                 {close registry key we previously opened}
  in      key_h: win_handle_t)         {open handle to close}
  :sys_sys_err_t;                      {completion status code}
  val_param; extern;

function RegCreateKeyExA (             {create new registry key, re-open if existing}
  in      parent_h: win_handle_t;      {handle to parent key}
  in      name: univ string;           {name of key to create, NULL terminated}
  in      opts: regopopt_t;            {set of option flags}
  in      name_class: univ string;     {class (data type) name, NULL terminated}
  in      regvol: regvol_k_t;          {volatile attributes of new key}
  in      access: raccess_t;           {set of flags indicating access we need}
  in      secur_p: secure_attr_p_t;    {pnt to security attributes, may be NIL}
  out     key_h: win_handle_t;         {returned handle to newly opened registry key}
  out     opstat: reg_opstat_k_t)      {indicates new created or old opened}
  :sys_sys_err_t;                      {completion status code}
  val_param; extern;

function RegDeleteKeyA (               {delete key with no subkeys}
  in      parent_h: win_handle_t;      {handle to parent key}
  in      name: univ string)           {name of key to delete, NULL terminated}
  :sys_sys_err_t;                      {completion status code}
  val_param; extern;

function RegDeleteValueA (             {delete a value from a registry key}
  in      parent_h: win_handle_t;      {handle to key to delete a value of}
  in      name: univ string)           {name of value to delete, NULL terminated}
  :sys_sys_err_t;                      {completion status code}
  val_param; extern;

function RegFlushKey (                 {force cached registry changes to be written now}
  in      key_h: win_handle_t)         {handle to key to flush changes to}
  :sys_sys_err_t;                      {completion status code}
  val_param; extern;

function RegOpenKeyExA (               {open existing registry key}
  in      parent_h: win_handle_t;      {handle to parent key}
  in      name: univ string;           {name of key to open, NULL terminated}
  in      opts: regopopt_t;            {set of option flags}
  in      access: raccess_t;           {set of flags indicating access we need}
  out     key_h: win_handle_t)         {returned handle to newly opened registry key}
  :sys_sys_err_t;                      {completion status code}
  val_param; extern;

function RegQueryValueExA (            {get a registry value}
  in      key_h: win_handle_t;         {handle to key containing the value}
  in      name: univ string;           {name of value to get data from}
  in      reserved_p: univ_ptr;        {reserved, must be NIL}
  out     dtype: reg_dtype_k_t;        {identifies the value's data type}
  out     data: univ sys_size1_t;      {returned data, may be NIL to just get size}
  in out  size: win_dword_t)           {DATA size in, amount written to DATA out}
  :sys_sys_err_t;                      {completion status code}
  val_param; extern;

function RegSetValueExA (              {set a registry value}
  in      key_h: win_handle_t;         {handle to key to set the value in}
  in      name: univ string;           {name of value to set data of}
  in      reserved: win_dword_t;       {reserved, must be 0}
  in      dtype: reg_dtype_k_t;        {value data type}
  in      data: univ sys_size1_t;      {data to set the value to}
  in      size: win_dword_t)           {size of data in DATA}
  :sys_sys_err_t;                      {completion status code}
  val_param; extern;
{
********************
*
*   Time handling routines.
}
function FileTimeToSystemTime (        {convert file time stamp to regular time fmt}
  in      time_file: sys_sys_time_file_t; {time in file time stamp format}
  out     time_sys: sys_sys_time_t)    {returned system time descriptor}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  extern;

procedure GetLocalTime (               {get current time for local time zone}
  out     time: sys_sys_time_t);       {returned system time descriptor}
  extern;

procedure GetSystemTime (              {get current coordinated universal time}
  out     time: sys_sys_time_t);       {returned system time descriptor}
  extern;

function GetTimeZoneInformation (      {get information about our time zone}
  out     timezone: time_zone_info_t)  {returned info about current time zone}
  :time_zone_k_t;                      {indicates STD versus DAYSAVE, etc.}
  extern;

procedure Sleep (                      {suspend process for fixed amount of time}
  in      msec: win_dword_t);          {sleep time in mS, 0 = yield timeslice}
  val_param; extern;
{
********************
*
*   Security
}
function AdjustTokenPrivileges (       {enable/disable privileges in access token}
  in      token_h: win_handle_t;       {handle to token to adjust privileges of}
  in      disable_all: win_bool_t;     {disable all privileges on WIN_BOOL_TRUE_K}
  in      newpriv: univ token_privileges_t; {new state for selected privileges}
  in      prev_len: win_dword_t;       {size of PREVIOUS array}
  in      previous_p: univ token_privileges_p_t; {pnt to prev priv return ar, NIL OK}
  out     ret_len: win_dword_t)        {required size of PREVIOUS array}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function LookupPrivilegeValueA (       {get LUID from privilege name}
  in      name_sys: string;            {sys to look up for, NULL = local system}
  in      name_priv: string;           {name of privilege to look up}
  out     luid: win_luid_t)            {locally unique identifier for privilege}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function OpenProcessToken (            {open handle to token to a process}
  in      proc_h: win_handle_t;        {handle to process opening access token for}
  in      desired_access: win_tkacc_t; {access desired to the token}
  out     token_h: win_handle_t)       {returned handle to newly opened token}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function OpenThreadToken (             {get handle to access token for this thread}
  in      thread_h: win_handle_t;      {handle to the thread}
  in      desired_access: win_tkacc_t; {access desired to the token}
  in      self: win_bool_t;            {TRUE for proc rights, FALSE may use imperson}
  out     token_h: win_handle_t)       {returned handle to newly opened token}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;
{
********************
*
*   Miscellaneous system services.
}
function Beep (                        {sound tone on system speaker}
  in      freq: win_dword_t;           {frequency in herz, must be 37-32767}
  in      msec: win_dword_t)           {mS duration, or BEEP_ON_K for beep on and ret}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function ExitWindowsEx (               {log off the user}
  in      shutflags: shutdown_t;       {set of modifier flags}
  in      reserved: shutreas_t)        {reserved, set to 0}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function FreeLibrary (                 {release DLL or EXE loaded with LoadLibrary}
  in      h: win_handle_t)             {handle to loaded library from LoadLibrary}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function GetComputerNameA (            {get the name of this machine}
  out     name: univ string;           {returned name, NULL terminated}
  in out  nchar: win_dword_t)          {size of NAME in, chars returned on out}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  val_param; extern;

function GetEnvironmentVariableA (     {get environment variable value}
  in      name: univ win_string_t;     {variable name, NULL term}
  out     val: univ win_string_t;      {returned value string, NULL term}
  in      val_len: win_dword_t)        {max chars allowed to return in VAL}
  :win_dword_t;                        {chars in VAL, 0 = not fnd, desired length
                                        if > VAL_LEN}
  extern; val_param;

function GetProcAddress (              {get library entry point address}
  in      h: win_handle_t;             {handle to module from LoadLibrary, etc.}
  in      n: sys_int_adr_t)            {ordinal entry value or pointer to name str}
  :univ_ptr;                           {entry point address, NIL on error}
  val_param; extern;

function LoadLibraryA (                {load .DLL or .EXE file}
  in      name: univ win_string_t)     {library pathname}
  :win_handle_t;                       {handle to library, or HANDLE_NONE_K}
  val_param; extern;

function SetEnvironmentVariableA (     {set/create/delete environment variable}
  in      name: univ win_string_t;     {variable name, NULL term}
  in      val: univ win_string_t)      {new value, deleted if null string}
  :win_bool_t;                         {WIN_BOOL_FALSE_K with GetLastError on err}
  extern;
{
********************
*
*   Cognivision routines unique to this system.
}
procedure ascii_unicode (              {convert var string to system UNICODE}
  in      vstr: univ string_var_arg_t; {input Cognivision var string}
  out     ustr: univ unicode_str_t;    {output unicode string, NULL term}
  in      len: string_index_t);        {max characters to write into USTR}
  val_param; extern;

procedure sys_sys_error_bomb (         {system error occurred, bomb with explanation}
  in      subsys: string;              {name of subsystem containing error message}
  in      msg: string;                 {error message name within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param; extern;

procedure sys_sys_exit (               {exit process}
  in      exstat: sys_int_machine_t);  {process exit status code}
  val_param; extern;

procedure sys_sys_fault;               {create a fault}
  extern;

procedure sys_sys_get_stdpath (        {get the pathname of a special system directory}
  in      spid: csidl_k_t;             {ID of the special directory}
  in out  path: univ string_var_arg_t; {returned full treename}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure sys_sys_menu_entry_set (     {create or overwrite menu entry}
  in      tnam: univ unicode_str_t;    {treename of entry in file sys, path exists}
  in      prog: univ win_string_t;     {full treename of program to run from menu entry}
  in      args: univ win_string_t;     {command line parameters to target program}
  in      wdir: univ win_string_t;     {directory to run target program in}
  in      desc: univ win_string_t;     {menu entry description, may be empty}
  in      icon: univ win_string_t;     {icon BMP file, may be empty}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure sys_sys_netstart;            {init network SW, if not already done so}
  extern;

function sys_sys_run_gui (             {run GUI app with our std I/O and cmline}
  in      name: string;                {name of program to run}
  in      namelen: sys_int_machine_t)  {number of characters in NAME}
  :win_uint_t;                         {exit status code of subordinate process}
  val_param; extern;

procedure sys_sys_rootdir (            {get system name for machine root directory}
  in out  name: univ string_var_arg_t); {root directory (treename of /), like "C:\"}
  extern;

procedure sys_sys_stdout_fix;          {fix C runtime STDOUT to relfect Win32 state}
  extern;

procedure sys_sys_stdout_nobuf;        {disable C runtime STDOUT buffering}
  extern;

procedure sys_sys_stdio_gui;           {make sure GUI app has standard I/O}
  extern;

procedure unicode_ascii (              {convert system UNICODE string to var string}
  in out  vstr: univ string_var_arg_t; {returned Cognivision var string}
  in      ustr: univ unicode_str_t;    {input unicode string, may have NULL term}
  in      len: string_index_t);        {max characters in USTR}
  val_param; extern;
