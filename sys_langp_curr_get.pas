{   Subroutine SYS_LANGP_CURR_GET (LANG_P)
*
*   Return the pointer to the descriptor for the currently selected language.
}
module sys_LANGP_CURR_GET;
define sys_langp_curr_get;
%include 'sys2.ins.pas';

procedure sys_langp_curr_get (         {get info about current language}
  out     lang_p: sys_lang_p_t);       {pointer to data about current language}

begin
  if not global_env_read then begin    {make sure environment files read}
    sys_read_env_global;
    end;
  lang_p := lang_curr_p;               {return pointer to language descriptor}
  end;
