{   Subroutine SYS_READ_ENV_GLOBAL
*
*   Read all the information in the GLOBAL.ENV environment files into the
*   private common block for the SYS library.
}
module sys_read_env_global;
define sys_read_env_global;
%include 'sys2.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';

var
  lock: sys_sys_threadlock_t;          {single thread lock for reading global ENV}
  havelock: boolean := false;          {LOCK has been created}

const
{
*   Hard wired defaults set before reading the first enviroment file.
}
  env_fnam = 'global.env';             {leafname of environment files}
  max_tries = 8;                       {max number of times to read env file set}

procedure sys_read_env_global;

var
  conn: file_conn_t;                   {connection handle to environment files}
  mem_p: util_mem_context_p_t;         {mem handle for new env path}
  env_p: sys_name_ent_p_t;             {pointer to first dir of new env path}
  n_tries: sys_int_machine_t;          {number of times re-tried read env files}
  src_p, dst_p: sys_name_ent_p_t;      {source and destination directory name pntrs}
  prev_dst_p: sys_name_ent_p_t;        {points to previous dest directory name}
  fnam: string_leafname_t;             {leafname of our environment files}
  lang: string_var32_t;                {language name as read from env files}
  stat: sys_err_t;                     {completion status code}

label
  again, different;
{
************************************************************
*
*   Local subroutine DELETE_DIR (NAME)
*
*   Delete the directory of name NAME from the local env path directories list.
*   It is permissible for NAME to not be in the list.  In that case, this routine
*   has no effect.
}
procedure delete_dir (
  in      name: string_treename_t);    {name of directory to delete}

var
  dir_p: sys_name_ent_p_t;             {pointer to current directory entry}
  prev_dir_p: sys_name_ent_p_t;        {pointer to previous directory entry}

begin
  dir_p := env_p;                      {init current entry to first list entry}
  prev_dir_p := nil;                   {init to no previous entry exists}

  while dir_p <> nil do begin          {once for each entry in the list}
    if string_equal(dir_p^.name, name) then begin {found entry to delete ?}
      if prev_dir_p = nil
        then begin                     {entry was first in list}
          env_p := dir_p^.next_p;
          end
        else begin                     {entry was not first in list}
          prev_dir_p^.next_p := dir_p^.next_p; {update link in previous entry}
          end
        ;
      if dir_p^.next_p <> nil then begin {entry was not last in list}
        dir_p^.next_p^.prev_p := dir_p^.prev_p; {update link in next entry}
        end;
      util_mem_ungrab (dir_p, mem_p^); {deallocate memory for this entry}
      return;                          {all done deleting list entry}
      end;                             {done handling entry matches NAME}
    prev_dir_p := dir_p;               {advance to next entry in chain}
    dir_p := dir_p^.next_p;
    end;                               {back and try new chain entry}
  end;
{
************************************************************
*
*   Local subroutine READ_ENV_FILES
*
*   Read and process the environment file set.  The environment file set is
*   already open on the connection handle CONN.
}
procedure read_env_files;

var
  buf: string_var8192_t;               {one line input buffer}
  p: string_index_t;                   {input line parse index}
  cmd: string_var32_t;                 {command name}
  parm: string_treename_t;             {command parameter}
  pick: sys_int_machine_t;             {number of token picked from list}
  dir_p, prev_dir_p: sys_name_ent_p_t; {pointers to current and previous entries}
  stat: sys_err_t;                     {completion status code}

label
  next_line, missing, bad_parm, eof;
{
************************************************************
*
*   Local subroutine READ_ERROR
*   This subroutine is local to READ_ENV_FILES.
*
*   An error has occured while reading the environment files.  Print general
*   information about the error and bomb.  Specific information has already
*   been printed.
}
procedure read_error;
  options (noreturn);

var
  token: string_var16_t;               {scratch token for string conversion}
  msg: string_treename_t;              {output message buffer}

begin
  token.max := sizeof(token.str);      {init var strings}
  msg.max := sizeof(msg.str);

  writeln ('Error reading global.env environment file set.');

  msg.len := 0;
  string_appends (msg, 'Error on line');
  string_append1 (msg, ' ');
  string_f_int (token, conn.lnum);
  string_append (msg, token);
  string_appends (msg, ' of file');
  writeln (msg.str:msg.len);
  writeln (conn.tnam.str:conn.tnam.len);
  sys_bomb;
  end;
{
************************************************************
*
*   Start of READ_ENV_FILES.
}
begin
  buf.max := sizeof(buf.str);          {init var strings}
  cmd.max := sizeof(cmd.str);
  parm.max := sizeof(parm.str);

next_line:                             {back here each new input line}
  file_read_env (conn, buf, stat);     {read next line from file set}
  if file_eof(stat) then goto eof;     {hit end of last file ?}
  if sys_error(stat) then read_error;
  p := 1;                              {init parse index into BUF}
  string_token (buf, p, cmd, stat);    {get command name}
  if sys_error(stat) then read_error;
  string_upcase (cmd);                 {make upper case for token matching}
  string_tkpick80 (cmd,
    'LANGUAGE ENV_PATH_DEL ENV_PATH_ADD',
    pick);
  case pick of
{
*   LANGUAGE <language name>
}
1: begin
  string_token (buf, p, parm, stat);
  if string_eos(stat) then goto missing;
  if sys_error(stat) then goto bad_parm;
  if parm.len <= 0 then goto bad_parm;
  string_copy (parm, lang);
  string_upcase (lang);
  end;
{
*   ENV_PATH_DEL <directory name>
}
2: begin
  string_token (buf, p, parm, stat);
  if string_eos(stat) then goto missing;
  if sys_error(stat) then goto bad_parm;
  if parm.len <= 0 then goto bad_parm;
  delete_dir (parm);
  end;
{
*   ENV_PATH_ADD <directory name>
}
3: begin
  string_token (buf, p, parm, stat);
  if string_eos(stat) then goto missing;
  if sys_error(stat) then goto bad_parm;
  if parm.len <= 0 then goto bad_parm;
  delete_dir (parm);                   {remove if already in list}
  dir_p := env_p;                      {init pointer to first directory in chain}
  prev_dir_p := nil;                   {init to no previous chain entry}
  while dir_p <> nil do begin          {loop until end of chain}
    prev_dir_p := dir_p;               {current entry becomes previous entry}
    dir_p := dir_p^.next_p;            {advance to next entry in chain}
    end;
  util_mem_grab (                      {grab memory for new list entry}
    sizeof(dir_p^),
    mem_p^,
    true,
    dir_p);
  dir_p^.name.max := sizeof(dir_p^.name.str); {init var string}
  string_copy (parm, dir_p^.name);     {set directory name}
  dir_p^.next_p := nil;                {this is last entry in list}
  if prev_dir_p = nil
    then begin                         {new entry is first in list}
      dir_p^.prev_p := nil;            {indicate there is no previous entry}
      env_p := dir_p;                  {set chain root pointer}
      end
    else begin                         {new entry is not first in list}
      dir_p^.prev_p := prev_dir_p;     {link after previous entry}
      prev_dir_p^.next_p := dir_p;
      end
    ;
  end;
{
*   Unrecognized command name.
}
otherwise
  writeln ('Unrecognized command "', cmd.str:cmd.len, '".');
  read_error;
  end;                                 {done with command name cases}

  string_token (buf, p, parm, stat);   {try to get another token}
  if not string_eos(stat) then begin   {there was another token ?}
    writeln ('Too many parameters for command "', cmd.str:cmd.len, '".');
    read_error;
    end;                               {done handling extraneous token found}
  goto next_line;                      {back and process next line from env files}

missing:                               {jump here on missing arguments}
  writeln ('Missing argument to command "', cmd.str:cmd.len, '".');
  read_error;

bad_parm:                              {jump here on bad command parameter}
  writeln ('Bad parameter "', parm.str:parm.len,
    '" to command "', cmd.str:cmd.len, '".');
  read_error;

eof:                                   {jump here on end of file}
  end;
{
************************************************************
*
*   Start of main routine.
}
begin
  fnam.max := sizeof(fnam.str);        {init var strings}
  lang.max := sizeof(lang.str);
{
*   Deal with possible multi-threading in use.
}
  sys_thread_lock_enter_all;           {start globally single-threaded section}
  if not havelock then begin           {our local thread lock not exist yet ?}
    sys_thread_lock_create (lock, stat); {create our local lock}
    havelock := true;                  {indicate local lock now exists}
    end;
  sys_thread_lock_leave_all;           {end of globally single-threaded section}
  sys_error_abort (stat, '', '', nil, 0);

  sys_thread_lock_enter (lock);
  if global_env_read then begin        {ENV has already been read ?}
    sys_thread_lock_leave (lock);
    return;
    end;

  global_env_read := true;             {prevent recursive calls}
  lang_curr_p := nil;                  {init to no current language}
  first_lang_cache_p := nil;           {init to no cached language descriptors}
{
*  Init memory for ENV files search path.
}
  util_mem_context_get (util_top_mem_context, env_path_mem_p);
  util_mem_grab (                      {allocate mem for initial env directory}
    sizeof(first_env_path_p^),         {amount of memory to allocate}
    env_path_mem_p^,                   {memory context to allocate under}
    true,                              {we will need to individually deallocate}
    first_env_path_p);                 {pointer to start of new memory}
{
*   Set hard wired defaults for initial environment files search path.
}
  first_env_path_p^.name.max :=        {initial env files search path}
    sizeof(first_env_path_p^.name.str);
  sys_cognivis_dir ('env'(0), first_env_path_p^.name);
  first_env_path_p^.next_p := nil;
  first_env_path_p^.prev_p := nil;
{
*  Init before top loop.
}
  string_vstring (lang, 'ENGLISH', 7); {init curr language to default}
  n_tries := 0;                        {init number times env file set read}
  mem_p := nil;                        {indicate no local context allocated yet}
  string_vstring (fnam, env_fnam, sizeof(env_fnam)); {make var string file name}
{
*   Top level re-try loop.  Come back here if the environment files search
*   path got changed by reading the set of environment files.  We can only be
*   sure the right files were read if the path didn't change as a result of
*   reading that set of files.  Since an infinite loop is possible, we bomb
*   if attempting to read more than MAX_TRIES times.
}
again:                                 {back here if env path changed}
  if n_tries >= max_tries then begin
    writeln ('ENV path not stable after', n_tries:3, ' reads.');
    sys_bomb;
    end;
  n_tries := n_tries + 1;              {log one more pass thru environment files}
{
*   Init new env search path from existing one.
}
  util_mem_context_get (               {get mem context for new search path}
    util_top_mem_context,
    mem_p);
  env_p := nil;                        {init new search path to empty}

  src_p := first_env_path_p;           {init source directory pointer}
  prev_dst_p := nil;                   {init dest list to empty}
  while src_p <> nil do begin          {back here each new source directory name}
    util_mem_grab (                    {allocate memory for this dir name}
      sizeof(dst_p^),
      mem_p^,
      true,
      dst_p);
    dst_p^.name.max := sizeof(dst_p^.name.str); {init new var string}
    string_copy (src_p^.name, dst_p^.name); {copy this directory name}
    dst_p^.next_p := nil;              {init to this is end of list}
    if prev_dst_p = nil
      then begin                       {this is first directory in list}
        env_p := dst_p;                {set start of chain pointer}
        dst_p^.prev_p := nil;          {indicate this is start of chain}
        end
      else begin                       {this is not first directory in list}
        prev_dst_p^.next_p := dst_p;   {set NEXT pointer in previous entry}
        dst_p^.prev_p := prev_dst_p;   {set PREVIOUS pointer in new entry}
        end
      ;
    prev_dst_p := dst_p;               {advance destination pointer}
    src_p := src_p^.next_p;            {advance source pointer}
    end;                               {back and copy next entry in chain}
{
*   The env search directory name chain starting at ENV_P is now an exact copy
*   of the current one.  We will be editing this local one as the environment
*   files are read.
}
  file_open_read_env (fnam, '', true, conn, stat); {open enviroment file set}
  if sys_error(stat) then begin
    writeln ('Unable to open global.env file set.');
    if not stat.err                    {system error code ?}
      then sys_error_print (stat, '', '', nil, 0);
    sys_bomb;
    end;
  read_env_files;                      {process the environment files data}
  file_close (conn);                   {close connection to environment files}
{
*   The environment files have just been read and processed.
*
*   Now compare the new env directory search list with the old one.  A branch
*   will be taken to DIFFERENT if the lists are different.
}
  src_p := first_env_path_p;           {init pointer to first old dir name}
  dst_p := env_p;                      {init pointer to first new dir name}
  while src_p <> nil do begin          {keep looping until end of old list}
    if dst_p = nil then goto different; {new list shorter than old list ?}
    if not string_equal(src_p^.name, dst_p^.name) {directory names don't match ?}
      then goto different;
    src_p := src_p^.next_p;            {advance old list pointer}
    dst_p := dst_p^.next_p;            {advance new list pointer}
    end;                               {back and compare new list entries}
  if dst_p <> nil then goto different; {new list longer than old list ?}
{
*   The old and new lists are the same.  Clean up our local memory and leave.
}
  util_mem_context_del (mem_p);        {deallocate our dynamic memory}
  sys_langp_get (lang, lang_curr_p);   {set pointer to current language}
  sys_thread_lock_leave (lock);        {exit single-threaded section}
  return;
{
*   The old and new lists were different.  Install the new list as the current
*   list and try again.
}
different:
  util_mem_context_del (env_path_mem_p); {deallocate memory for old list}
  env_path_mem_p := mem_p;             {save memory context of list}
  first_env_path_p := env_p;           {install new list as current list}
  goto again;                          {back to read new environment file set}
  end;
