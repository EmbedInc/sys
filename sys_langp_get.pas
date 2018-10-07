{   Subroutine SYS_LANGP_GET (NAME,LANG_P)
*
*   Return LANG_P as pointing to a language descriptor for the language whos name
*   is in NAME.
}
module sys_LANGP_GET;
define sys_langp_get;
%include 'sys2.ins.pas';
%include 'string.ins.pas';

procedure sys_langp_get (              {get info about a particular language}
  in      name: univ string_var_arg_t; {name of language to return info about}
  out     lang_p: sys_lang_p_t);       {returned pointer to language info}

var
  uname: string_var32_t;               {upper case language name}
  cache_p: sys_lang_cache_p_t;         {points to curr chain entry}
  cache_pp: ^sys_lang_cache_p_t;       {points to curr chain pointer}

begin
  uname.max := sizeof(uname.str);      {init var string}

  if not global_env_read               {need to init environment ?}
    then sys_read_env_global;

  string_copy (name, uname);           {make local copy of language name}
  string_upcase (uname);               {make upper case for matching}

  cache_p := first_lang_cache_p;       {init to first chain entry}
  cache_pp := addr(first_lang_cache_p);

  while cache_p <> nil do begin        {scan over existing chain entries}
    if string_equal(uname, cache_p^.lang.name) then begin {language already here ?}
      lang_p := addr(cache_p^.lang);   {return pointer to existing descriptor}
      return;
      end;
    cache_pp := addr(cache_p^.next_p); {update address of curr cache pointer}
    cache_p := cache_p^.next_p;        {update curr cache pointer}
    end;                               {back and check new entry}
{
*   The requested language is not currently in the chain.  CACHE_PP is pointing
*   to where the pointer to the new entry will go.
}
  sys_mem_alloc (sizeof(cache_p^), cache_p); {allocate memory for new descriptor}
  if cache_p = nil then begin
    writeln ('Unable to allocate more virtual memory.  The disk is full.');
    sys_bomb;
    end;
  sys_read_env_lang (uname, cache_p^.lang); {fill in new language descriptor}
  cache_p^.next_p := nil;              {indicate this will be end of chain}
  cache_pp^ := cache_p;                {link new descriptor to end of chain}
  lang_p := addr(cache_p^.lang);       {pass back pointer to new language descriptor}
  end;
