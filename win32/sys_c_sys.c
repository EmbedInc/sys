/*   Module of system-dependent routines that are only used on particular
**   platforms.
*/
#include <wtypes.h>
#include <winbase.h>
#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include <process.h>

/*******************************************************************************
**
**   Subroutine SYS_SYS_EXIT (EXSTAT)
**
**   Exit the process with EXSTAT as the exit status code.
*/
__declspec(dllexport) void sys_sys_exit (int exstat) {
/*
**   Executable code for function SYS_SYS_EXIT.
*/
  exit (exstat);
  }

/*******************************************************************************
**
**   Subroutine SYS_FLUSH_STDOUT
**
**   Flush all buffered data of the standard output streams (STDOUT, STDERR).
**   This causes the data to by physically written immediately.  This flushes
**   any buffered output data in both the C runtime library and any underlying
**   operating system buffer.
*/
__declspec(dllexport) void sys_flush_stdout (void) {

  fflush (stdout);
  fflush (stderr);
  }

/*******************************************************************************
**
**   Subroutine SYS_SYS_STDOUT_NOBUF
**
**   Try to disable buffering of the standard output streams.
*/
__declspec(dllexport) void sys_sys_stdout_nobuf (void) {
/*
**   Start of executable code.
*/
  setvbuf (stdout, 0, _IONBF, 0);      /* try to disable STDOUT buffering */
  setvbuf (stderr, 0, _IONBF, 0);      /* try to disable STDERR buffering */
  }

/*******************************************************************************
**
**   Subroutine SYS_SYS_STDOUT_FIX
**
**   Fix up the C runtime library STDOUT state to reflect whatever the Win32
**   standard output is set to.
*/
__declspec(dllexport) void sys_sys_stdout_fix (void) {

int fnum;                              /* C file number */
FILE *fp;                              /* C stream I/O file descriptor pointer */
/*
**   Start of executable code.
*/
  fnum = _open_osfhandle (             /* open C file number from Win32 handle */
    (long)GetStdHandle (STD_OUTPUT_HANDLE), /* Win32 handle for standard output */
    O_TEXT);                           /* open file with text translation */
  if (fnum == -1) return;              /* didn't open C file number ? */

  _dup2 (fnum, 1);                     /* set STDOUT filenum to new connection */
  _close (fnum);                       /* close temporary filenum */

  fp = _fdopen (1, "w");               /* create C stream file descriptor pointer */
  *stdout = *fp;                       /* stomp on STDOUT stream descriptor,
                                          see KB article Q105305 */
  sys_sys_stdout_nobuf ();             /* try to disable stream buffering */
  }
