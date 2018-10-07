{   Subroutine SYS_BEEP (SEC_BEEP, SEC_WAIT, N)
*
*   Cause a beep or tone to be made, if possible with current hardware.
*
*   SEC_BEEP - Seconds duration for the beep.  This is not intended to be accurate,
*     and may even be ignored on some hardware.
*
*   SEC_WAIT - Seconds wait after all but the last beep.
*
*   N - Total number of beeps to produce.  This subroutine will loop indefinately
*     if N is set to SYS_BEEP_FOREVER.
*
*   This version is for the Microsoft Win32s API.
}
module sys_beep;
define sys_beep;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';

procedure sys_beep (                   {ring bell or make tone, if possible}
  in      sec_beep: real;              {seconds duration of tone}
  in      sec_wait: real;              {seconds to wait after tone}
  in      n: sys_int_machine_t);       {N times for tone/wait, or SYS_BEEP_FOREVER}
  val_param;

const
  freq = 440;                          {37-32767 frequency in Herz}

var
  msec_beep: win_dword_t;              {milliseconds duration for each beep}
  msec_wait: win_dword_t;              {milliseconds to wait between beeps}
  i: sys_int_machine_t;                {loop counter}

label
  forever;

begin
  msec_beep := round(max(0.0, 1000.0 * sec_beep)); {make integer mS time values}
  msec_wait := round(max(0.0, 1000.0 * sec_wait));

  if n = sys_beep_forever
    then begin                         {supposed to beep in infinite loop}
forever:
      discard( Beep (freq, msec_beep) ); {do the last beep}
      Sleep (msec_wait);               {do wait after this beep}
      goto forever;
      end
    else begin                         {beep specified number of times}
      if n <= 0 then return;           {nothing to do ?}
      for i := 1 to n-1 do begin       {loop once for all but last beep}
        discard( Beep (freq, msec_beep) ); {do this beep}
        Sleep (msec_wait);             {do wait after this beep}
        end;                           {back for next beep and wait}
      discard( Beep (freq, msec_beep) ); {do the last beep}
      end
    ;
  end;
