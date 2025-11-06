/*
/*   Messages that have associated status codes.
/*
msg err1
  lan english -def
    Program stopped with other than TRUE or FALSE status.  Returned
    status code is %p1i.  Command line was "%p2s".
msg err2
  lan english -def
    No environment variable of name "%p1s" exists.
msg err3
  lan english -def
    Unable to delete environment variable "%p1s".
msg err4
  lan english -def
    Unable to set environment variable "%p1s" to a new value.
msg err5
  lan english -def
    Operation failed.
msg err6
  lan english -def
    Feature is not implemented.
msg err7
  lan english -def
    The feature "%p1s" is not implemented.
msg err8
  lan english -def
    The requested operation requires a boolean event type, but the supplied
    event is not a boolean event.
msg err9
  lan english -def
    The requested operation requires a counted event type, but the supplied
    event is not a counted event.
msg err10
  lan english -def
    The portable environment subroutine "%p1s" has not been implemented for
    this operating system.
msg err11
  lan english -def
    Timeout occurred on waiting for %p1s.
msg err12
  lan english -def
    Unable to convert string "%p1s" to a time.
msg err13
  lan english -def
    Menu ID of %p1i is not supported.
msg err14
  lan english -def
    Unable to allocate dynamic memory.
msg err15
  lan english -def
    No MX record found for domain %p1s.
/*
/*   The error status codes 100-132 are reserved to correspond to the 0-32
/*   return values of ShellExecute.
/*
msg err100
  lan english -def
    ShellExecute error: The operating system is out of memory or other
    resources.
msg err102
  lan english -def
    ShellExecute error: File not found
msg err103
  lan english -def
    ShellExecute error: Path not found
msg err105
  lan english -def
    ShellExecute error: Access denied
msg err108
  lan english -def
    ShellExecute error: Out of memory
msg err126
  lan english -def
    ShellExecute error: A sharing violation occurred.
msg err127
  lan english -def
    ShellExecute error: The file name association is incomplete or
    invalid.
msg err128
  lan english -def
    ShellExecute error: The DDE transaction could not be completed because
    the request timed out.
msg err129
  lan english -def
    ShellExecute error: The DDE transaction failed.
msg err130
  lan english -def
    ShellExecute error: The DDE transaction could not be completed because
    other DDE transactions were being processed.
msg err131
  lan english -def
    ShellExecute error: There is no application associated with the given
    file name extension, or an attempt was made to print a file that is
    not prinatable.
msg err132
  lan english -def
    ShellExecute error: The specified DLL was not found.
/*
/*   Messages used by the SYS library.
/*
msg cleanup_establish
  lan english -def
    Error on establish cleanup handler.
msg cleanup_release
  lan english -def
    Error on release cleanup handler.
msg clock_abs_both_add
  lan english -def
    Attempt was made to add two absolute clock values.
msg clock_abs_subtract
  lan english -def
    Attempt was made to subtract an absolute time from a relative
    time.
msg clock_compare_relabs
  lan english -def
    Attempt was made to compare a relative clock value with an
    absolute clock value.
msg date_conv_year
  lan english -def
    Unable to convert year %p1i to a string.
msg date_conv_month
  lan english -def
    Unable to convert month %p1i to a string.
msg date_conv_day
  lan english -def
    Unable to convert day %p1i to a string.
msg date_conv_hour
  lan english -def
    Unable to convert hour %p1i to a string.
msg date_conv_minute
  lan english -def
    Unable to convert minute %p1i to a string.
msg date_conv_isec
  lan english -def
    Unable to convert seconds %p1i to a string.
msg date_conv_fpsec
  lan english -def
    Unable to convert seconds %p1f to a string.
msg date_trig_unexp
  lan english -def
    INTERNAL ERROR: Unexpected trigger date/time type encountered in
    module SYS_DATE.
msg daysave_unexp
  lan english -def
    Unexpected daylight savings time strategy encountered.
msg dealloc_mem
  lan english -def
    On system call to deallocate dynamic memory.
msg dynlib_load
  lan english -def
    Error on system call to explicitly load external library.
msg dynlib_lookup
  lan english -def
    Error on system call to look up symbol name in external library.
msg envvar_val_bad
  lan english -def
    Unable to interpret value "%p1s" of environment variable %p2s.
msg err_netclose
  lan english -def
    Error reported by system call to close use of network interface software.
msg err_netstart
  lan english -def
    Error on system call to startup network interface software.
msg err_netversion
  lan english -def
    Unable to find suitable version of the system network interface software.
msg err_reboot
  lan english -def
    Error encountered on attempt to shut down and restart the machine.
msg event_create_bool
  lan enslish -def
    Error on attempt to create event in SYS_EVENT_CREATE_BOOL.
msg event_create_cnt
  lan enslish -def
    Error on attempt to create event in SYS_EVENT_CREATE_CNT.
msg event_notify_bool
  lan english -def
    Error on attempt to notify Boolean event object.
msg event_notify_cnt
  lan english -def
    Error on attempt to notify counted event object.
msg event_reset_bool
  lan english -def
    Error on attempt to reset Boolean event object.
msg event_reset_cnt
  lan english -def
    Error on attempt to reset counted event object.
msg fpmode_get
  lan english -def
    Error occurred on attempt to get current floating point handling
    modes.
msg fpmode_set
  lan english -def
    Error occurred on attempt to set new floating point handling modes.
msg mem_alloc_overlap
  lan english -def
    Dynamic memory allocation system corruption detected.
    A new region was allocated that overlapped a previously allocated
    memory region.
msg mem_dealloc_not_found
  lan english -def
    An attempt was made to dynamically deallocate a region of memory
    giving an address that was not the start of a currently allocated
    block.
msg mem_table_overflow
  lan english -def
    Internal SYS library error.  Overflow occurred in table that keeps
    track of dynamically allocated memory regions.  The size is set
    in SYS_MEM.INS.PAS.  This table only exists when SYS_MEM.PAS is
    compiled with debug source code option.
msg no_mem
  lan english -def
    Unable to dynamically allocate more virtual memory.
    The disk is probably full.
msg node_id_get
  lan english -def
    Error occurred on attempt to get unique ID for this machine.
msg node_name_get
  lan english -def
    Error occurred on attempt to get network name for this machine.
msg open_msg
  lan english -def
    Error occurred on trying to open .msg message file.
msg proc_release
  lan english -def
    Error occurred on trying to release connection to a child process.
msg proc_start_err
  lan english -def
    Error occurred on trying to create a separate process with
    the command line "%p1s".
msg proc_stdio_method_unknown
  lan english -def
    Unexpected process standard I/O method ID encountered.  ID value
    was %p1i.
msg read_msg
  lan english -def
    Error occurred on trying to read from a .msg message file.
msg run
  lan english -def
    Error on attempt to run separate program.  Command line was: %p1s
msg run_arg_get
  lan english -def
    Error on extracting argument number %p1i from whole command line
    string in a SYS_RUN_ routine.
msg run_args_too_many
  lan english -def
    Too many arguments found on command line in a SYS_RUN_ routine.
    Current maximum is set to %p1i.
msg run_progname_get
  lan english -def
    Error on extracting program pathname from whole command line string
    in a SYS_RUN_ routine.
msg run_talk
  lan english -def
    Error on attempt to run separate program with pipes to its standard
    I/O streams.  Command line was: %p1s
msg thread_start
  lan english -def
    Error on attempt to start new thread within this process.
msg time_get_err
  lan english -def
    Error occurred on attempt to get current time from system.
msg time_elapsed
  lan english -def
    Elapsed time was %p1f10.2 seconds.
msg timezone_get
  lan english -def
    Error on attempt to get current timezone info from system.
msg timezone_unrecognized
  lan english -def
    Illegal, or unimplemented time zone ID encountered.
    ID number is %p1i.
msg wait
  lan english -def
    On system call to wait specified amount of time.
/*
/*   Messages used by standard top level programs.
/*
msg node_info
  lan english -def
    Node name is "%p1s", node ID is "%p2s".
msg server_nocmline
  lan english -def
    No command line supplied for the new process.
/*
/*   Message used by the INSTALL program.
/*
msg install_ask_reboot
  lan english -def
    The machine must be shut down and restarted to complete the software
    installation.  Would you like to shut down and restart the machine
    right now?  Answer YES or NO below, or hit ENTER to choose the default
    shown in parenthesis.
msg install_command_bad
  lan english -def
    Unrecognized command "%p3s" encountered on line %p1i of
    installation descriptor file "%p2s".
msg install_command_get
  lan english -def
    Error on attempt to get command name from line %p1i of
    installation descriptor file "%p2s".
msg install_destination
  lan english -def
    Installing software to %p1s
msg install_execdir_err
  lan english -def
    Error encountered in trying to determine the directory containing the
    executable running this process.
msg install_file_open
  lan english -def
    Error on attempt to open installation descriptor file.
msg install_file_read
  lan english -def
    Error on attempt to read line %p1i from installation descriptor
    file "%p2s".
msg install_new
  lan english -def
    No previous installation of this software was detected.
msg install_no_source
  lan english -def
    No installation source directory declared.
    Error encountered on line %p1i of installation descriptor file "%p2s".
msg install_no_reboot
  lan english -def
    Please shut down and restart the machine at your earliest convenience.
    The new software will not function correctly until this is done.
msg install_parm_err
  lan english -def
    Error with parameter to command "%p3s"
    on line %p1i of installation descriptor file "%p2s".
msg install_previous
  lan english -def
    A previous installation of this or related software was found
    at %p1s.  We recommend that you take the default below and install
    the new software over the old.
msg install_prompt_exit
  lan english -def
    Hit ENTER to exit the install program.
msg install_run_empty
  lan english -def
    Missing parameter after RUN command on line %p1i of the installation
    descriptor file "%p2s".
msg install_run_error
  lan english -def
    Error on attempt to execute the program.
msg install_run_failed
  lan english -def
    Install program aborting due to error in subordinate program.
msg install_source
  lan english -def
    Software installation source directory is %p4s.
msg install_success
  lan english -def
    Software installation completed successfully.
msg install_token_extra
  lan english -def
    Illegal extra token "%p4s" found after command "%p3s"
    on line %p1i of installation descriptor file "%p2s".
msg install_where
  lan english -def
    Enter where you want the software installed, or hit ENTER to choose
    the default shown in parenthesis.
/*
/*  The following messages are for handling passwords/licenses.
/*
msg pw_bad_arg
  lan english -def
    Bad argument to "%P1S" keyword in password file block ending on
    line %P2I in file "/cognivision_links/passwords".
msg pw_bad_int_arg
  lan english -def
    Bad integer argument to "%P1S" keyword in password file block ending on
    line %P2I in file "/cognivision_links/passwords".
msg pw_bad_month_arg
  lan english -def
    Bad month name for "%P1S" keyword  in password file block
    ending on line %P2I in file "/cognivision_links/passwords".
msg pw_file_not_opened
  lan english -def
    On attempt to open password file "%P1S".
msg pw_file_read_error
  lan english -def
    On attempt to read from password file.
msg pw_incorrect
  lan english -def
    Password "%P1S" is incorrect.
msg pw_license_not_begun
  lan english -def
    The license for this program has not yet begun.
msg pw_license_expired
  lan english -def
    The license for this software has expired.
msg pw_license_full_grace
  lan english -def
    .nfill
    ***********************************************************************
      WARNING:  The license for this software has EXPIRED.  However,
         a grace period has been granted until %P1S.
    ***********************************************************************
msg pw_license_prov_grace
  lan english -def
    .nfill
    ***********************************************************************
      WARNING:  This software was running under a provisional license
         awaiting payment, which was not recieved.  This license has
         therefore EXPIRED.  However, a grace period has been granted
         until %P1S.
    ***********************************************************************
msg pw_license_temp
  lan english -def
    .nfill
    ***********************************************************************
      WARNING:  This software is running under a temporary license which
         will expire on %P1S.
    ***********************************************************************
msg pw_license_temp_grace
  lan english -def
    .nfill
    ***********************************************************************
      WARNING:  This software was running under a temporary license which
         has EXPIRED.  However, a grace period has been granted until
         %P1S.
    ***********************************************************************
msg pw_line_number
  lan english -def
    The block describing the software license for this program ends on
    line number %P1I in file "/cognivision_links/passwords".
msg pw_not_found
  lan english -def
    No valid password file entry found for program %P1S, version %P2S.
msg pw_too_many_data_lines
  lan english -def
    No more than %P1I lines are allowed in block. Block ends on line number
    %P2I in file "/cognivision_links/passwords".
/*
/*   Messages used by program TEST_RUN.
/*
msg test_run_bool_false
  lan english -def
    Program completed successfully and indicated FALSE.  Exit status was %p1i.
msg test_run_bool_true
  lan english -def
    Program completed successfully and indicated TRUE.  Exit status was %p1i.
msg test_run_program_error
  lan english -def
    Error on attempt to create a process with command line "%p1s".
/*
/*   Messages used by program TEST_COG.
/*
msg test_cog_dtm
  lan english -def
    Current date/time: %p1s
/*
/*   Messages used by program TEST_DATE.
/*
msg test_date_sec
  lan english -def
    Absolute time is %p1f20.2 seconds.
msg test_date1
  lan english -def
    Date/time is %p1i/%p2i/%p3i %p4i:%p5i:%p6i + %p7f20.2
msg test_date2
  lan english -def
    TZ = %p8s, Hours West = %p9f8.2, Daysave = %p10s %p11s
/*
/*   Messages used by applications manipulating menu entries.
/*
msg menu_delete_err
  lan english -def
    Error on attempt to delete the menu entry "%p1s" at "%p2s" within the %p3s menu.
msg menu_info
  lan english -def
    .nfill
    Entry "%p1s" in menu %p2s at "%p3s".
      Program: %p4s
      Parameters: %p5s
      Working dir: %p6s
      Icon: %p7s
      Desc: %p8s
msg menu_no_name
  lan english -def
    No menu entry name provided.
msg menu_no_prog
  lan english -def
    Target program for menu entry not provided.
msg menu_prog_nexist
  lan english -def
    Menu entry target program "%p1s" does not exist.
msg menu_set_err
  lan english -def
    Error on create menu entry "%p1s" in menu %p2s at "%p3s".  Program "%p4s",
    parameters "%p5s", working directory "%p6s", icon "%p7s", description "%p8s".
