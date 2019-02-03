{   System dependent part of SYS.INS.PAS.  This file is intended to have
*   a different version for each different target system.
*
*   This particular verion is for:
*
*     Source language:      Microsoft C, release Visual C++ 2.0 or later
*     OS:                   Microsoft Win32 API
}
const
  sys_leafname_maxlen_k = 256;         {max chars allowed in pathname component}
  sys_treename_maxlen_k = 1024;        {max chars allowed in full pathname}
  sys_arr_size_index_k = 2**16+1;      {used to dimension large arrays that are
                                        dynamically allocated, forcing compiler
                                        not to optimize array index to integer16}
  sys_byte_order_k = sys_byte_order_bkw_k; {this machine has backwards byte ordering}
  sys_os_k = sys_os_win32_k;           {operating system}
  sys_fp_ieee32_native_k = true;       {machine can directly express IEEE 32 bit FP}
  sys_fp_ieee64_native_k = true;       {machine can directly express IEEE 64 bit FP}
  sys_threadmem_k = sys_threadmem_share_k; {our thread memory handling scheme}
{
*   Constants for the IDs of the standard streams.
}
  sys_sys_iounit_stdin_k = 0;          {stream ID for standard input}
  sys_sys_iounit_stdout_k = 1;         {stream ID for standard output}
  sys_sys_iounit_errout_k = 2;         {stream ID for error output}

  sys_sys_inetport_unspec_k = 0;       {no internet port specified}
  sys_sys_inetnode_any_k = 0;          {all applicable internet node addresses}

  sys_sys_exstat_ok_k = 0;             {process stopped with no errors}
  sys_sys_exstat_true_k = 0;           {no errors, process indicated TRUE}
  sys_sys_exstat_false_k = 1;          {no errors, process indicated FALSE}
  sys_sys_exstat_warn_k = 2;           {task completed, something unexpected found}
  sys_sys_exstat_err_k = 3;            {a hard error occurred}
  sys_sys_exstat_abort_k = 127;        {process was stopped abnormally}
  sys_sys_exstat_wekill_k = 16#FFFFFFFF; {we explicitly killed the process}

type
  sys_size1_t = int8u_t;               {data type that takes up one machine adr}

  sys_sys_err_t = integer32;           {format of system's error status code}

  sys_sys_iounit_t = int32u_t;         {native system I/O unit identifier (handle)}
  sys_sys_iounit_p_t = ^sys_sys_iounit_t;
  sys_sys_file_conn_t = int32u_t;      {native file connection handle}
  sys_sys_file_conn_p_t = ^sys_sys_file_conn_t;
  sys_sys_proc_id_t = int32u_t;        {system process ID (handle)}
  sys_sys_thread_id_t = int32u_t;      {thread handle}
  sys_sys_event_id_t = int32u_t;       {handle to event we can wait on (handle)}

  sys_sys_stream_pos_t = int32u_t;     {native system I/O stream position handle}

  sys_sys_inetsock_id_t = int32u_t;    {ID of internet socket on this machine}

  sys_sys_exstat_t = int32u_t;         {process exit status value}

  sys_sys_window_id_t = int32u_t;      {handle to identify a system window}

  sys_sys_screen_id_t = int32u_t;      {handle to identify a workstation screen}

  sys_sys_fpmode_t = univ_ptr;         {FP exception handling modes}

  sys_fp_ieee32_t = single;            {format for IEEE 32 bit floating point number}

  sys_fp_ieee64_t = double;            {format for IEEE 64 bit floating point number}

  sys_sys_threadlock_t =               {critical section descriptor}
    array[0..31] of sys_size1_t;

  sys_sys_threadmem_h_t = sys_int_adr_t; {start adr of mem shared between threads}

  sys_sys_time_t = record              {native system time descriptor}
    year: int16u_t;                    {full year}
    month: int16u_t;                   {1-12 month within year}
    day_week: int16u_t;                {0-6 day of week, Sunday = 0, Monday = 1, etc}
    day: int16u_t;                     {1-31 day within month}
    hour: int16u_t;                    {0-23 hour within day}
    minute: int16u_t;                  {0-59 minute within hour}
    second: int16u_t;                  {0-59 second within minute}
    msec: int16u_t;                    {0-999 milliseconds within second}
    end;
