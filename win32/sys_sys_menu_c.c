//   Routines that are related to system menus.  These routines are implemented
//   in C to access the system include files directly.
//
//   This version is for the Microsoft Windows Win32 API.
//
#include <stdio.h>
#include <shlobj.h>
#include <objbase.h>
#include "sys.h"

//******************************************************************************
//
//   Subroutine SYS_SYS_GET_STDPATH (SPID, PATH, STAT)
//
//   Get the pathname of one of the special system directories.  SPID is the ID
//   of the special directory.
//
void __stdcall sys_sys_get_stdpath (   //get path of special system diretory
  int spid,                            //ID of the directory to get the path of
  string_var_arg_t* path,              //the returned path
  sys_err_t* stat) {                   //returned completion status

char str[MAX_PATH];                    //max length null-terminated pathname
BOOL succ;                             //system call success

  sys_error_none (stat);               //init to no error

  succ = SHGetSpecialFolderPath (      //get path to special system directory
    NULL,                              //no window for dialog box
    str,                               //returned pathname
    spid,                              //ID of the special directory
    TRUE);                             //create directory if not previously existed
  if (!succ) {
    stat->sys = GetLastError();
    }

  string_vstring (path, str, -1);      //return var string path
  }

//******************************************************************************
//
//   Subroutine SYS_SYS_MENU_ENTRY_SET (TNAM, PROG, ARGS, WDIR, DESC, ICON, STAT)
//
//   Low level routine to create or overwrite a system menu entry.  TNAM is the
//   unicode string of the .lnk file in the file system.  PROG is the executable
//   to invoke when the menu entry is activated, and ARGS are its command line
//   parameters.  WDIR is the full treename of the working directory to run the
//   program in.  DESC is the description string for the menu entry.  ICON is
//   the full pathname of the .bmp file that is the icon to use when displaying
//   the menu entry.
//
void __stdcall sys_sys_menu_entry_set ( //create or overwrite menu entry
  WCHAR* tnam,                         //unicode menu entry treename in file system
  char* prog,                          //executable pathname
  char* args,                          //command line parameters for executable
  char* wdir,                          //working directory to run program in
  char* desc,                          //menu entry description string, may be empty
  char* icon,                          //icon file .bmp treename, may be empty
  sys_err_t* stat) {                   //completion status

IShellLink* sl_p;                      //points to shell interface object
IPersistFile* pf_p;                    //points to IPersistFile interface object

//
//   Create the link.
//
//   LINK is the pathname of the link to create and TARG is the target for it to
//   point to.
//
  sys_error_none (stat);
  CoInitialize (NULL);                 //initialize for using COM from this thread

  stat->sys = CoCreateInstance (       //create shell interface object
    &CLSID_ShellLink,                  //ID of object to create
    NULL,                              //new object not part of aggregate
    CLSCTX_INPROC_SERVER,              //context ID
    &IID_IShellLink,                   //ID of interface to create
    &sl_p);                            //returned pointer to the new interface
  if (stat->sys) return;

  stat->sys = sl_p->lpVtbl->SetPath (sl_p, prog); //set link target pathname
  if (stat->sys) return;

  stat->sys = sl_p->lpVtbl->SetArguments (sl_p, args); //set command line parameters
  if (stat->sys) return;

  stat->sys = sl_p->lpVtbl->SetWorkingDirectory (sl_p, wdir); //set working directory
  if (stat->sys) return;

  stat->sys = sl_p->lpVtbl->SetDescription (sl_p, desc); //set description text
  if (stat->sys) return;

  stat->sys = sl_p->lpVtbl->SetIconLocation (sl_p, icon, 1); //set icon file pathname
  if (stat->sys) return;

  stat->sys = sl_p->lpVtbl->QueryInterface ( //get pointer to IPersistFile interface
    sl_p,
    &IID_IPersistFile,
    &pf_p);
  if (stat->sys) return;

  stat->sys = pf_p->lpVtbl->Save (pf_p, tnam, TRUE); //save temp link in link file
  if (stat->sys) return;

  pf_p->lpVtbl->Release (pf_p);        //release IPersistFile interface
  sl_p->lpVtbl->Release (sl_p);        //release shell interface
  CoUninitialize ();                   //done with COM, release resources
  return;
  }
