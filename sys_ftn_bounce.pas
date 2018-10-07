{
*  This module contains all the bounce routines used by FORTRAN for communicating
*  with the sys library.  It also contains some functions used to convert between
*  FORTRAN logical variables and PASCAL boolean variables.
}
module sys_ftn;
define sys_bomb_;
define sys_ftn_date_time1_;
define sys_ftn_mem_alloc_;
define sys_ftn_mem_dealloc_;
define sys_ftn_integer_adr_;
define sys_ftn_run_wait_stdio_;
define sys_ftn_width_stdout_;
define sys_message_;
define sys_wait_;
define sys_exit_;

define sys_ftn_logical_t_pas_boolean;
define sys_pas_boolean_t_ftn_logical;

%include 'sys2.ins.pas';
%include 'string.ins.pas';
%include 'sys_ftn.ins.pas';

procedure sys_bomb_;
  extern;

procedure sys_ftn_date_time1_ (        {return current local date/time in a string}
  out   date_str: univ sys_ftn_char_t; {25 chars, "YYYY MMM DD:MM:SS ZZZZ"}
  in    date_str_max: sys_ftn_integer_t); {dimensioned length of data_str}
  extern;

procedure sys_ftn_mem_alloc_ (         {allocate a block of virtual memory}
  in      size: sys_ftn_integer_adr_t; {size in machine address units}
  out     adr: sys_ftn_integer_adr_t); {start adr of region, NIL for unavailable}
  extern;

procedure sys_ftn_mem_dealloc_ (       {deallocate a block of virtual memory}
  in out  adr: sys_ftn_integer_adr_t); {starting address of block, returned NIL}
  extern;

function sys_ftn_integer_adr_ (        {return integer machine address for a variable}
  in      variable: univ sys_ftn_integer_t): {variable to get address for}
  sys_ftn_integer_adr_t;
  extern;

procedure sys_ftn_run_wait_stdio_ (    {run prog, wait for done, standard I/O conn}
  in      cmline: univ sys_ftn_char_t; {program pathname and program arguments}
  in      cmline_len: sys_ftn_integer_t; {length of command line}
  out     tf: sys_ftn_logical_t;       {TRUE/FALSE condition returned by program}
  out     failed: sys_ftn_logical_t);  {true if failed and writes appropriate message}
  extern;

function sys_ftn_width_stdout_         {return character width of standard output}
  :sys_ftn_integer_t;
  extern;

procedure sys_message_ (               {write message to stdout}
  in      subsys: univ sys_ftn_char_t; {name of subsystem, used to find message file}
  in      msg: univ sys_ftn_char_t;    {message name withing subsystem file}
  in      subsys_len: sys_ftn_char_len_t; {length of subsystem name - hidden argument}
  in      msg_len: sys_ftn_char_len_t); {length of message name - hidden argument}
  val_param; extern;

procedure sys_exit_ ;                  {exit program normally}
  extern;

procedure sys_wait_ (                  {suspend process for specified seconds}
  in      wait: sys_ftn_real_t);       {number of seconds to wait}
  extern;

{****************************************************}

procedure sys_bomb_;

begin
  sys_bomb;
  end;

{****************************************************}

procedure sys_ftn_date_time1_ (        {return current local date/time in a string}
  out   date_str: univ sys_ftn_char_t; {25 chars, "YYYY MMM DD:MM:SS ZZZZ"}
  in    date_str_max: sys_ftn_integer_t); {dimensioned length of data_str}

var
  idate_str: string_var80_t;
  i, len: string_index_t;

begin
  idate_str.max := sizeof(idate_str.str);
  sys_date_time1 (idate_str);
  len := min(idate_str.len, date_str_max);
  for i := 1 to len do begin           {copy date and time}
    date_str[i] := idate_str.str[i];
    end;
  for i := len + 1 to date_str_max do begin {pad end with spaces}
    date_str[i] := ' ';
    end;
  end;

{****************************************************}

procedure sys_ftn_mem_alloc_ (         {allocate a block of virtual memory}
  in      size: sys_ftn_integer_adr_t; {size in machine address units}
  out     adr: sys_ftn_integer_adr_t); {start adr of region, NIL for unavailable}

var
  p: sys_int_machine_p_t;              {pointer to new memory}
  ni: sys_int_machine_t;               {number of machine integers allocated}
  i: sys_int_machine_t;                {loop counter}

begin
  sys_mem_alloc (size, p);             {allocate memory}
  sys_mem_error (p, '', '', nil, 0);   {check allocation of memory}
  adr := sys_ftn_integer_adr_t(p);     {pass back starting address}

  ni := size div sizeof(p^);           {number of whole words allocated}
  for i := 1 to ni do begin            {once for each word allocated}
    p^ := 0;                           {init this word to zero}
    p := univ_ptr(sys_int_adr_t(p) + sizeof(p^)); {advance pointer to next word}
    end;                               {back to clear next new word}
  end;

{****************************************************}

procedure sys_ftn_mem_dealloc_ (       {deallocate a block of virtual memory}
  in out  adr: sys_ftn_integer_adr_t); {starting address of block, returned NIL}

var
  iadr: univ_ptr;

begin
  iadr := univ_ptr(adr);               {convert to univ pointer}
  sys_mem_dealloc (iadr);              {deallocate memory}
  adr := sys_ftn_integer_adr_t(iadr);  {convert to fortran integer address}
  end;

{****************************************************}

function sys_ftn_integer_adr_ (        {return integer machine address for a variable}
  in      variable: univ sys_ftn_integer_t): {variable to get address for}
  sys_ftn_integer_adr_t;

begin
  sys_ftn_integer_adr_ := sys_ftn_integer_adr_t(addr(variable)); {return machine address of variable}
  end;

{****************************************************}

procedure sys_ftn_run_wait_stdio_ (    {run prog, wait for done, standard I/O conn}
  in      cmline: univ sys_ftn_char_t; {program pathname and program arguments}
  in      cmline_len: sys_ftn_integer_t; {length of command line}
  out     tf: sys_ftn_logical_t;       {TRUE/FALSE condition returned by program}
  out     failed: sys_ftn_logical_t);  {true if failed and writes appropriate message}

var
  cmd: string_var8192_t;               {command line}
  exstat: sys_sys_exstat_t;            {program exit status code}
  tf_local: boolean;                   {TRUE/FALSE returned by program}
  stat: sys_err_t;

begin
  cmd.max := sizeof(cmd.str);          {init local var string}

  string_vstring (cmd, cmline, cmline_len); {convert command line to var string}

  sys_run_wait_stdsame (               {run program in separate process}
    cmd,                               {command line to execute}
    tf_local,                          {TRUE/FALSE status returned by program}
    exstat,                            {program exit status}
    stat);
  if sys_error(stat) then begin        {attempt to run program failed ?}
    sys_error_print (stat, '', '', nil, 0);
    failed := sys_ftn_logical_true_k;
    return;
    end;

  failed := sys_ftn_logical_false_k;   {indicate everything went OK}
  if tf_local                          {pass back program's TRUE/FALSE status}
    then tf := sys_ftn_logical_true_k
    else tf := sys_ftn_logical_false_k;
  end;

{****************************************************}

function sys_ftn_width_stdout_         {return character width of standard output}
  :sys_ftn_integer_t;

begin
  sys_ftn_width_stdout_ := sys_width_stdout;
  end;

{****************************************************}

function sys_ftn_logical_t_pas_boolean ( {convert FORTRAN logical to PASCAL boolean}
  in      val: sys_ftn_logical_t):     {value of FORTRAN logical}
  boolean;
  val_param;

begin
  if val = sys_ftn_logical_false_k     {assume false is more reliable than true}
    then sys_ftn_logical_t_pas_boolean := false
    else sys_ftn_logical_t_pas_boolean := true;
  end;

{****************************************************}

function sys_pas_boolean_t_ftn_logical ( {convert PASCAL boolean to FORTRAN logical}
  in      val: boolean):               {value of PASCAL boolean}
  sys_ftn_logical_t;
  val_param;

begin
  if val
    then sys_pas_boolean_t_ftn_logical := sys_ftn_logical_true_k
    else sys_pas_boolean_t_ftn_logical := sys_ftn_logical_false_k;
  end;

{****************************************************}

procedure sys_message_ (               {write message to stdout}
  in      subsys: univ sys_ftn_char_t; {name of subsystem, used to find message file}
  in      msg: univ sys_ftn_char_t;    {message name withing subsystem file}
  in      subsys_len: sys_ftn_char_len_t; {length of subsystem name - hidden argument}
  in      msg_len: sys_ftn_char_len_t); {length of message name - hidden argument}
  val_param;

var
  ss: string_var80_t;
  m: string_var80_t;

begin
  ss.max := sizeof (ss.str);
  ss.len := 0;
  m.max := sizeof (m.str);
  m.len := 0;
  string_vstring (ss, subsys, subsys_len);
  string_fill (ss);
  string_vstring (m, msg, msg_len);
  string_fill (m);
  sys_message (ss.str, m.str);
  end;

{****************************************************}

procedure sys_wait_ (                  {suspend process for specified seconds}
  in      wait: sys_ftn_real_t);       {number of seconds to wait}

var
  i_wait: real;

begin
  i_wait := wait;
  sys_wait (i_wait);
  end;

{****************************************************}

procedure sys_exit_ ;                  {exit program normally}

begin
  sys_exit;
  end;

