{   Subroutine SYS_ENV_PATH_GET (FIRST_P)
*
*   Return a pointer to the list of directories of where to look for environment
*   files.  The list will be in order such that environment files should be
*   read (if found) from the directories in the order given.  The directories are
*   in a linked list structure.  FIRST_P is returned pointing to the entry for
*   the first directory in the list.  FIRST_P will be NIL if there are no directories
*   in the list at all.
}
module sys_env_path_get;
define sys_env_path_get;
%include 'sys2.ins.pas';

procedure sys_env_path_get (           {get list of environment file directories}
  out     first_p: sys_name_ent_p_t);  {pointer to first directory in linked list}

begin
  if not global_env_read then begin    {need to read global environment file}
    sys_read_env_global;               {read global environment descriptors}
    end;
  first_p := first_env_path_p;
  end;
