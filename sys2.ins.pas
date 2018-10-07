{   Private include file for the SYS_ source code modules.
}
%include 'sys.ins.pas';
%include 'util.ins.pas';

type
  sys_lang_cache_p_t =                 {pointer to cached language data descriptor}
    ^sys_lang_cache_t;

  sys_lang_cache_t = record            {one cached language descriptor}
    next_p: sys_lang_cache_p_t;        {pointer to next descriptor in chain}
    lang: sys_lang_t;                  {data about this language}
    end;

var (sys_common)                       {private common block, not initialized}
  first_env_path_p: sys_name_ent_p_t;  {points to first environment file directory}
  env_path_mem_p: util_mem_context_p_t; {handle to memory for environment path}
  lang_curr_p: sys_lang_p_t;           {points to descriptor for current language}
  first_lang_cache_p: sys_lang_cache_p_t; {pnt to start of cached lang chain}
  threadlock: sys_sys_threadlock_t;    {thread interlock when THREADLOCK_CREATED TRUE}
  cognivis_dir: string_treename_t;     {COGNIVIS dir when COGNIVIS_DIR_SET TRUE}

var (sys_common2)                      {private common block, initialized}
  message_enter_level: sys_int_machine_t {number of times SYS_MESSAGE called}
    := 0;
  global_env_read: boolean             {TRUE after read GLOBAL.ENV environment file}
    := false;
  threadlock_created: boolean          {TRUE after THREADLOCK valid}
    := false;
  cognivis_dir_set: boolean            {TRUE if COGNIVIS dir explicitly set}
    := false;
{
*   Private routines for the SYS library.
}
procedure sys_read_env_global;         {read GLOBAL.ENV environment files}
  extern;

procedure sys_read_env_lang (          {read <language>.lan environment file set}
  in      lname: univ string_var_arg_t; {name of language to return info about}
  out     lang: sys_lang_t);           {language descriptor to fill in}
  extern;

function sys_sys_message (             {write message indicated by system err code}
  in      stat_sys: sys_sys_err_t)     {system error code}
  :boolean;                            {TRUE on error status, message printed}
  val_param; extern;

function sys_sys_message_get (         {return string for a system error code}
  in      stat_sys: sys_sys_err_t;     {system error status code}
  in out  emess: univ string_var_arg_t) {returned error message text, NULL on no err}
  :boolean;                            {TRUE on error status, message not empty}
  val_param; extern;
