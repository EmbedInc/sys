/*   This module is used as a template for building console mode initiator
**   programs for GUI applications.  For some (silly) reason, Win32 GUI
**   apps don't get their standard I/O connected right when launched from
**   a normal console.  This program launches the GUI app in such a way
**   that the standard I/O connections work.  In other words, the GUI app
**   has standard in, standard out, and standard error when run from a
**   console.  This program is customized with the real application name.
**   The GUI program that actually does all the work and is launched from
**   here has the same name with "_w" appended.  For example, if this
**   program is called xxx.exe, then the GUI program is called xxx_w.exe.
**
**   This source file is only a template, and needs to be customized with
**   the application name.  All strings of three lower case "q" letters in a
**   row must be replaced with the application name (with no path or suffix).
**
**   This version is specific to the Microsoft Win32 API.
*/
typedef int sys_int_machine_t;
typedef unsigned int int32u_t;
typedef int32u_t win_uint_t;

typedef unsigned char string_t[80];

extern win_uint_t sys_sys_run_gui (
  string_t,
  sys_int_machine_t);

extern void ExitProcess (
  win_uint_t);

extern void string_cmline_set (
  int,
  char *,
  char *);

/*****************************
**
**   Start of program.
*/
int main (
    int argc,
    char * argv) {
  /*
  **   Executable code for main program.
  */
  string_cmline_set (argc, argv, "qqq");
  return sys_sys_run_gui ("qqq_w", -1);
  }
