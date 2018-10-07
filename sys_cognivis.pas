{   Module of routines for dealing with Cognivision-specific system issues.
}
module sys_cognivis;
define sys_cognivis_dir;
define sys_cognivis_dir_set;
%include 'sys2.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
{
*********************************************************************
*
*   Subroutine SYS_COGNIVIS_DIR (NAME, TNAM)
*
*   Find the full pathname of the Cognivision directory NAME.  For example on
*   PCs, NAME of "com" would typically expand to "c:\embedinc\com".
*
*   The name of the root cognivision direction can be determined by several
*   means.  In order from first to last precedent, they are:
*
*   1  -  Explicit value previously set by the application, by a call
*         to SYS_COGNIVIS_DIR_SET.
*
*   2  -  EMBEDINC_<name> environment variable, if present.  This only
*         applies to the specific NAME subdirectory, not the top Cognivision
*         directory.
*
*   3  -  COGNIVIS_<name> environment variable, if present.  This only
*         applies to the specific NAME subdirectory, not the top Cognivision
*         directory.
*
*   4  -  EMBEDINC environment variable, if present.
*
*   5  -  COGNIVIS environment variable, if present.
*
*   6  -  The directory above where the executable file for this process is
*         stored, if the directory containing the executable file is named
*         "COM".  The COM match is not case sensitive.
*
*   7  -  /embedinc
*
*   Cognivision path names are always lower case on systems that allow a
*   choice.  Note that environment variable names must be upper case on
*   many systems.
}
procedure sys_cognivis_dir (           {get full pathname of Cognivision directory}
  in      name: string;                {generic directory name, may be NULL term}
  in out  tnam: univ string_var_arg_t); {resulting full directory tree name}
  val_param;

var
  envvar: string_var132_t;             {environment variable name}
  nameu: string_treename_t;            {upper case version of NAME}
  namel: string_treename_t;            {lower case version of NAME}
  path: string_treename_t;             {raw internal pathname}
  tnam2, tnam3: string_treename_t;     {scratch pathnames}
  fnam: string_leafname_t;             {scratch pathname component}
  stat: sys_err_t;

label
  got_root, got_path;

begin
  envvar.max := sizeof(envvar.str);    {init local var strings}
  nameu.max := sizeof(nameu.str);
  namel.max := sizeof(namel.str);
  path.max := sizeof(path.str);
  tnam2.max := sizeof(tnam2.str);
  tnam3.max := sizeof(tnam3.str);
  fnam.max := sizeof(fnam.str);
{
*   Save upcased and downcased versions of the input NAME.
}
  string_vstring (nameu, name, sizeof(name));
  string_copy (nameu, namel);
  string_upcase (nameu);
  string_downcase (namel);
{
*   Check for root cognivis directory explicitly overridden by the application.
}
  if cognivis_dir_set then begin       {dir explicitly overidden}
    string_copy (cognivis_dir, path);  {get root directory name}
    goto got_root;
    end;
{
*   Look for suitable environment variable for this specific directory.
}
  if nameu.len > 0 then begin          {a specific subdirectory was requested ?}
    string_vstring (envvar, 'EMBEDINC_', 9); {make envvar name for specific directory}
    string_append (envvar, nameu);
    sys_envvar_get (envvar, path, stat); {read specific envvar, if present}
    if not sys_error(stat) then goto got_path; {found environment variable ?}

    string_vstring (envvar, 'COGNIVIS_', 9); {make envvar name for specific directory}
    string_append (envvar, nameu);
    sys_envvar_get (envvar, path, stat); {read specific envvar, if present}
    if not sys_error(stat) then goto got_path; {found environment variable ?}
    end;
{
*   Look for suitable enironment variable for top level Cognivision directory.
}
  string_vstring (envvar, 'EMBEDINC'(0), -1);
  sys_envvar_get (envvar, path, stat); {read specific envvar, if present}
  if not sys_error(stat) then goto got_root; {found environment variable ?}

  string_vstring (envvar, 'COGNIVIS'(0), -1);
  sys_envvar_get (envvar, path, stat); {read specific envvar, if present}
  if not sys_error(stat) then goto got_root; {found environment variable ?}
{
*   Use the directory above where this executable is stored, if the executable
*   directory is named "com".
}
  sys_exec_tnam_get (tnam2, stat);     {try to get executable file pathname}
  if not sys_error(stat) then begin    {got executable file pathname ?}
    string_pathname_split (tnam2, tnam3, fnam); {get exec directory in TNAM3}
    string_pathname_split (tnam3, path, fnam); {get exec directory gnam in FNAM}
    string_upcase (fnam);              {COM name match is case-insensitive}
    if string_equal (string_v('COM'(0)), fnam) then begin {exec dir has right name ?}
      goto got_root;                   {Cognivis root directory is in PATH}
      end;
    end;
{
*   Default to /embedinc.
}
  string_vstring (path, '/embedinc'(0), -1);
{
*   The Cognivision root directory name is in PATH.
}
got_root:
  if namel.len > 0 then begin          {we have name within Cognivis directory ?}
    string_append1 (path, '/');        {append specific directory path}
    string_append (path, namel);
    end;

got_path:                              {raw pathname all set in PATH}
  string_treename (path, tnam);        {pass back final directory name}
  end;
{
*********************************************************************
*
*   Subroutine SYS_COGNIVIS_DIR_SET (NAME)
*
*   Set the new official COGNIVIS root directory name as used by routine
*   SYS_COGNIVIS_DIR.  This completely overrides any defaults used otherwise.
*   All Cognivision subdirectories are assumed to be directly within the
*   directory indicated by NAME.
*
*   NAME can be set to the empty string to restore the default COGNIVIS root
*   directory resolution.
}
procedure sys_cognivis_dir_set (       {set pathname of root Cognivision directory}
  in      name: univ string_var_arg_t); {new root dir name, empty to restore default}
  val_param;

begin
  if name.len <= 0 then begin          {restore to normal root dir resolution ?}
    cognivis_dir_set := false;
    return;
    end;

  cognivis_dir.max := sizeof(cognivis_dir.str); {init var string}
  string_copy (name, cognivis_dir);    {save new root directory name in common block}
  cognivis_dir_set := true;            {indicate COGNIVIS_DIR is now valid}
  end;
