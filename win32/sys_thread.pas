{   Module of routines that deal with threads of execution within a process.
*
*   This version is for the Microsoft Win32 API.
}
module sys_thread;
define sys_thread_create;
define sys_thread_event_get;
define sys_thread_release;
define sys_thread_exit;
define sys_thread_lock_create;
define sys_thread_lock_delete;
define sys_thread_lock_enter;
define sys_thread_lock_leave;
define sys_thread_lock_enter_all;
define sys_thread_lock_leave_all;
define sys_thread_mem_release;
define sys_thread_mem_shareable;
define sys_thread_yield;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
{
********************************************************************************
*
*   Local subroutine MAKE_MASTER_INTERLOCK
*
*   Set up our private interlock used to synchronize serial access to critical
*   code.  This routine must be called before any new threads are created
*   because it is not multi-thread safe.
}
procedure make_master_interlock;

begin
  if threadlock_created then return;   {already created interlock ?}
  InitializeCriticalSection (threadlock); {make interlock for all our threads}
  threadlock_created := true;          {indicate interlock already been created}
  end;
{
********************************************************************************
}
procedure sys_thread_create (          {create a new thread in this process}
  in      threadproc_p: sys_threadproc_p_t; {pointer to root thread routine}
  in      arg: sys_int_adr_t;          {argument passed to thread routine}
  out     id: sys_sys_thread_id_t;     {ID of newly created thread}
  out     stat: sys_err_t);            {returned error status}
  val_param;

var
  thread_id: win_dword_t;              {Win32 thread ID, unused}

begin
  sys_error_none (stat);               {init to no error}

  if not threadlock_created then begin {master thread interlock not yet created ?}
    make_master_interlock;             {create our master thread interlock}
    end;

  id := CreateThread (                 {create the new thread}
    nil,                               {no security attributes supplied}
    0,                                 {use default initial stack size}
    threadproc_p,                      {pointer to thread routine}
    univ_ptr(arg),                     {argument passed to thread routine}
    [],                                {optional thread creation flags}
    thread_id);                        {returned thread ID, unused}
  if id = handle_none_k then begin     {error ?}
    stat.sys := GetLastError;          {return the system error code}
    end;
  end;
{
********************************************************************************
}
procedure sys_thread_event_get (       {get system event to wait on thread exit}
  in      thread: sys_sys_thread_id_t; {system handle to the thread}
  out     event: sys_sys_event_id_t;   {associated system event handle}
  out     stat: sys_err_t);            {returned error status}
  val_param;

begin
  sys_error_none (stat);               {no error}
  event := thread;                     {thread handle is also the event handle}
  end;
{
********************************************************************************
*
*   Subroutine SYS_THREAD_RELEASE (ID, STAT)
*
*   Release all lingering thread state for an exited thread, or cause all
*   lingering state to be released when the thread exits.
*
*   The thread ID will no longer be valid or useable.
}
procedure sys_thread_release (         {release thread state if/when thread exits}
  in out  id: sys_sys_thread_id_t;     {thread ID, will be returned invalid}
  out     stat: sys_err_t);            {returned error status}
  val_param;

var
  ok: win_bool_t;

begin
  sys_error_none (stat);

  ok := CloseHandle (id);              {close handle to this thread}
  if ok = win_bool_false_k then begin
    stat.sys := GetLastError;
    end;
  end;
{
********************************************************************************
}
procedure sys_thread_exit;             {exit this thread}
  options (noreturn);

begin
  ExitThread (0);                      {exit the thread, exit status = 0}
  end;
{
********************************************************************************
}
procedure sys_thread_lock_create (     {create an interlock for single threading}
  out     h: sys_sys_threadlock_t;     {handle to new thread interlock}
  out     stat: sys_err_t);            {returned error status}
  val_param;

begin
  sys_error_none (stat);
  InitializeCriticalSection (h);
{
*   Set the spin count.  If a thread doesn't immediately acquire the lock
*   because it was in use, it will normally wait on a semiphore.  This can be a
*   expensive operation and cause strange behavior on multi-processor systems.
*   The spin count is the number of times the thread will re-try acquiring the
*   lock in a busy-wait loop before giving up and waiting on the semiphore.
*   This value is only relevant on multi-processor systems.  The spin lock
*   setting is ignored on single processor systems.
}
  discard( SetCriticalSectionSpinCount (h, 1000) );
  end;
{
********************************************************************************
}
procedure sys_thread_lock_delete (     {delete a single thread interlock}
  in out  h: sys_sys_threadlock_t;     {handle from SYS_THREAD_LOCK_CREATE}
  out     stat: sys_err_t);            {returned error status}
  val_param;

begin
  sys_error_none (stat);
  DeleteCriticalSection (h);
  end;
{
********************************************************************************
}
procedure sys_thread_lock_enter (      {enter single threaded code segment}
  in out  h: sys_sys_threadlock_t);    {handle from SYS_THREAD_LOCK_CREATE}
  val_param;

begin
  EnterCriticalSection (h);
  end;
{
********************************************************************************
}
procedure sys_thread_lock_leave (      {leave single threaded code segment}
  in out  h: sys_sys_threadlock_t);    {handle from SYS_THREAD_LOCK_CREATE}
  val_param;

begin
  LeaveCriticalSection (h);
  end;
{
********************************************************************************
}
procedure sys_thread_lock_enter_all;   {enter single threaded code for all threads}
  val_param;

begin
  if not threadlock_created then begin {master thread interlock not yet created ?}
    make_master_interlock;             {create our master thread interlock}
    end;
  EnterCriticalSection (threadlock);   {wait on master thread interlock}
  end;
{
********************************************************************************
}
procedure sys_thread_lock_leave_all;   {leave single threaded code for all threads}
  val_param;

begin
  LeaveCriticalSection (threadlock);
  end;
{
********************************************************************************
}
procedure sys_thread_mem_release (     {release memory shared across threads}
  in out  h: sys_sys_threadmem_h_t);   {handle to the shared memory}
  val_param;

begin
  sys_mem_dealloc (univ_ptr(h));       {deallocate the memory}
  end;
{
********************************************************************************
*
*   The Win32 version of this routine does nothing, since all threads within a
*   process always share the same address space.
}
procedure sys_thread_mem_shareable (   {alloc mem to be shared with child threads}
  in      size: sys_int_adr_t;         {size in machine address units}
  out     adr: univ_ptr;               {start adr of new mem, NIL = unavailable}
  out     h: sys_sys_threadmem_h_t);   {handle to new memory}
  val_param;

begin
  sys_mem_alloc (size, adr);           {allocate a new dynamic memory region}
  h := sys_int_adr_t(adr);             {handle is mem start address}
  end;
{
********************************************************************************
}
procedure sys_thread_yield;            {give up remainder of time slice}

begin
  Sleep (0);
  end;
