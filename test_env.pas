{   Program TEST_ENV
*
*   Show information about the current environment, as defined by the
*   Cognivision environment files.
}
program test_env;
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';

var
  ent_p: sys_name_ent_p_t;             {pointer to current environment path entry}
  lang_p: sys_lang_p_t;                {pointer to descriptor for current language}
  tnam: string_treename_t;             {scratch treename}
  stat: sys_err_t;                     {completion status code}

begin
  tnam.max := sizeof(tnam.str);        {init local var string}

  string_cmline_init;                  {no command line arguments are allowed}
  string_cmline_end_abort;

  sys_cognivis_dir ('', tnam);         {get root software installation directory}
  writeln ('Software installation directory: ', tnam.str:tnam.len);

  sys_exec_tnam_get (tnam, stat);
  if sys_error(stat)
    then begin
      writeln ('Unable to get executable pathname.');
      end
    else begin
      writeln ('Executable pathname: ', tnam.str:tnam.len);
      end
    ;

  writeln;
  sys_env_path_get (ent_p);            {get pointer to first environment path entry}
  writeln ('Environment files search path:');
  while ent_p <> nil do begin          {once for each directory in path}
    string_treename (ent_p^.name, tnam); {fully resolve search directory name}
    write ('  ', ent_p^.name.str:ent_p^.name.len);
    if not string_equal (ent_p^.name, tnam) then begin
      write (' -> ', tnam.str:tnam.len);
      end;
    writeln;
    ent_p := ent_p^.next_p;            {advance to next entry in list}
    end;

  sys_langp_curr_get (lang_p);         {get pointer to current language info}
  writeln;
  writeln ('Default language info:');
  writeln ('  Name: ', lang_p^.name.str:lang_p^.name.len);
  writeln ('  Decimal char: ', lang_p^.decimal);
  writeln ('  Digits group char: ', lang_p^.digits_group_c);
  writeln ('  Digits group size: ', lang_p^.digits_group_n);
  writeln ('  Exponent string: ', lang_p^.exponent.str:lang_p^.exponent.len);
  end.
