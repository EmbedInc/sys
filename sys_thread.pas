{   Module of routines that deal with threads of execution within a process.
*
*   This version is the main line of decent.  It assumes thread manipulation
*   routines have not been implemented, but that process memory is always
*   shared accross all threads.
*
*   Since thread creation is not implemented in this module, some of the
*   routines assume that there is only one thread in the process.  Obviously
*   these need to be fixed when thread creation is implemented.
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
**********************************************************************
*
*   Subroutine SYS_THREAD_CREATE (THREADPROC_P, ARG, ID, STAT)
*
*   Create a new thread within this process.  THREADPROC_P points to the
*   top subroutine for the new thread.  ARG is the single argument passed to
*   the subroutine.  The thread will automatically terminate when the
*   subroutine returns.  ID is returned as the unique ID for the new thread.
}
procedure sys_thread_create (          {create a new thread in this process}
  in      threadproc_p: sys_threadproc_p_t; {pointer to root thread routine}
  in      arg: sys_int_adr_t;          {argument passed to thread routine}
  out     id: sys_sys_thread_id_t;     {ID of newly created thread}
  out     stat: sys_err_t);            {returned error status}
  val_param;

begin
  sys_stat_set (sys_subsys_k, sys_stat_not_impl_k, stat);
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_EVENT_GET (THREAD, EVENT, STAT)
*
*   Returns the system event EVENT for the thread of ID THREAD.  The
*   returned event can be used to wait for the thread to exit.
}
procedure sys_thread_event_get (       {get system event to wait on thread exit}
  in      thread: sys_sys_thread_id_t; {system handle to the thread}
  out     event: sys_sys_event_id_t;   {associated system event handle}
  out     stat: sys_err_t);            {returned error status}
  val_param;

begin
  sys_stat_set (sys_subsys_k, sys_stat_not_impl_k, stat);
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_RELEASE (ID, STAT)
*
*   Release all lingering thread state for an exited thread, or cause
*   all lingering state to be released when the thread exits.
*
*   The thread ID will no longer be valid or useable.
}
procedure sys_thread_release (         {release thread state if/when thread exits}
  in out  id: sys_sys_thread_id_t;     {thread ID, will be returned invalid}
  out     stat: sys_err_t);            {returned error status}
  val_param;

begin
  sys_stat_set (sys_subsys_k, sys_stat_not_impl_k, stat);
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_EXIT
*
*   Exit the current thread.  Note that returning from the main thread
*   subroutine implicitly exits a thread.
*
*   *** WARNING ***
*   This version assumes there is only one thread per process.
}
procedure sys_thread_exit;             {exit this thread}
  options (noreturn);

begin
  sys_exit;                            {exit the process}
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_LOCK_CREATE (H, STAT)
*
*   Create a mutual exclusion interlock for threads within a process.
*   The interlock can then be used between cooperating threads to guarantee
*   that only one thread at a time executes a particular section of code.
*
*   *** WARNING ***
*   This version assumes there is only one thread per process.
}
procedure sys_thread_lock_create (     {create an interlock for single threading}
  out     h: sys_sys_threadlock_t;     {handle to new thread interlock}
  out     stat: sys_err_t);            {returned error status}
  val_param;

begin
  sys_error_none (stat);
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_LOCK_DELETE (H, STAT)
*
*   Delete the thread mutual exclusion interlock H.
*
*   *** WARNING ***
*   This version assumes there is only one thread per process.
}
procedure sys_thread_lock_delete (     {delete a single thread interlock}
  in out  h: sys_sys_threadlock_t;     {handle from SYS_THREAD_LOCK_CREATE}
  out     stat: sys_err_t);            {returned error status}
  val_param;

begin
  sys_error_none (stat);
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_LOCK_ENTER (H)
*
*   Enter the mutual exclusion thread interlock H.  Only one thread at
*   a time can enter a mutual exclusion interlock.  All other attempts
*   to enter the interlock are blocked until the interlock is released
*   by the thread that has it.
*
*   *** WARNING ***
*   This version assumes there is only one thread per process.
}
procedure sys_thread_lock_enter (      {enter single threaded code segment}
  in out  h: sys_sys_threadlock_t);    {handle from SYS_THREAD_LOCK_CREATE}
  val_param;

begin
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_LOCK_LEAVE (H)
*
*   Leave the mutual exclusion thread interlock H.  This will allow another
*   thread to enter the interlocked area.
*
*   *** WARNING ***
*   This version assumes there is only one thread per process.
}
procedure sys_thread_lock_leave (      {leave single threaded code segment}
  in out  h: sys_sys_threadlock_t);    {handle from SYS_THREAD_LOCK_CREATE}
  val_param;

begin
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_LOCK_ENTER_ALL
*
*   Enter the global thread interlock.  Only one thread at a time can
*   have this lock.
*
*   *** WARNING ***
*   This version assumes there is only one thread per process.
}
procedure sys_thread_lock_enter_all;   {enter single threaded code for all threads}
  val_param;

begin
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_LOCK_LEAVE_ALL
*
*   Exit the global thread interlock.  This makes it the interlock available
*   to be entered by another thread.
*
*   *** WARNING ***
*   This version assumes there is only one thread per process.
}
procedure sys_thread_lock_leave_all;   {leave single threaded code for all threads}
  val_param;

begin
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_MEM_RELEASE (H)
*
*   Release memory that was shared accross all threads.  H is the handle
*   to the particular shared memory.
*
*   *** WARNING ***
*   This version assumes process memory is always shared between threads.
}
procedure sys_thread_mem_release (     {release memory shared across threads}
  in out  h: sys_sys_threadmem_h_t);   {handle to the shared memory}
  val_param;

var
  p: univ_ptr;

begin
  p := univ_ptr(h);
  sys_mem_dealloc (p);
  h := sys_sys_threadmem_h_t(h);
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_MEM_SHAREABLE (SIZE, ADR, H)
*
*   Allocate dynamic memory that is to be shared accross all threads in this
*   process.  Note that all process memory is shared accross threads on
*   systems where SYS_THREADMEM_K is set to SYS_THREADMEM_SHARE_K.
*
*   *** WARNING ***
*   This version assumes process memory is always shared between threads.
}
procedure sys_thread_mem_shareable (   {alloc mem to be shared with child threads}
  in      size: sys_int_adr_t;         {size in machine address units}
  out     adr: univ_ptr;               {start adr of new mem, NIL = unavailable}
  out     h: sys_sys_threadmem_h_t);   {handle to new memory}
  val_param;

begin
  sys_mem_alloc (size, adr);
  h := sys_sys_threadmem_h_t(adr);
  end;
{
**********************************************************************
*
*   Subroutine SYS_THREAD_YIELD
*
*   Give up the remainder of this thread's time slice.  This routine will
*   return some indeterminate amount of time later, meanwhile giving other
*   threads on this system a chance to execute.
}
procedure sys_thread_yield;            {give up remainder of time slice}

begin
  end;
