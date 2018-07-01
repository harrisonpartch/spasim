MODULE XF86VMode; (** AUTHOR "fnecati"; PURPOSE "unix <X/xf86vmode.h>"; *)

IMPORT
  X11 , Unix, Modules, KernelLog;

CONST
	libname = 'libXxf86vm.so.1';
VAR
	lib: ADDRESS;

TYPE

	PChar = POINTER {UNSAFE} TO ARRAY OF CHAR;
	cuchar = CHAR; (* int8 *)
	Pcushort = POINTER {UNSAFE} TO ARRAY OF INTEGER;

	Bool = X11.Bool;

	DisplayPtr = X11.DisplayPtr;
	Time = X11.Time;
	Window = X11.Window;

CONST
	XVidQueryVersion* = 0;
	XVidGetModeLine* = 1;
	XVidModModeLine* = 2;
	XVidSwitchMode* = 3;
	XVidGetMonitor* = 4;
	XVidLockModeSwitch* = 5;
	XVidGetAllModeLines*  = 6;
	XVidAddModeLine* = 7;
	XVidDeleteModeLine* = 8;
	XVidValidateModeLine* = 9;
	XVidSwitchToMode* = 10;
	XVidGetViewPort* = 11;
	XVidSetViewPort* = 12;
	(* new for version 2.x of this extension *)
	XVidGetDotClocks* = 13;
	XVidSetClientVersion* = 14;
	XVidSetGamma* = 15;
	XVidVidGetGamma* = 16;
	XVidetGammaRamp* = 17;
	XVidSetGammaRamp* = 18;
	XVidGetGammaRampSize* = 19;
	XVidGetPermissions* = 20;

	CLKFLAG_PROGRAMABLE* = 1;

	(*$IFDEF XF86VIDMODE_EVENTS*)
	XVidNotify*             = 0;
	XVidNumberEvents* = (XVidNotify + 1);

	XVidNotifyMask* = 00000001H;

	XVidNonEvent* = 0;
	XVidModeChange* = 1;
	(* (*$ELSE XF86VIDMODE_EVENTS*)
	XVidNumberEvents* = 0;
	(*$ENDIF XF86VIDMODE_EVENTS*)
	*)
	XVidBadClock* = 0;
	XVidBadHTimings* = 1;
	XVidBadVTimings* = 2;
	XVidModeUnsuitable* = 3;
	XVidExtensionDisabled*  = 4;
	XVidClientNotLocal* = 5;
	XVidZoomLocked* = 6;
	XVidNumberErrors* = (XVidZoomLocked + 1);

	XF86VM_READ_PERMISSION*  = 1;
	XF86VM_WRITE_PERMISSION* = 2;

	(* Video Mode Settings: *)
TYPE
	ModeLine* = POINTER {UNSAFE} TO RECORD
		hdisplay* : INTEGER; (* Number of display pixels horizontally *)
		hsyncstart* : INTEGER; (* Horizontal sync start *)
		hsyncend * : INTEGER;  (* Horizontal sync end *)
		htotal * : INTEGER;  (* Total horizontal pixels *)
		hskew * : INTEGER;
		vdisplay * : INTEGER; (* Number of display pixels vertically *)
		vsyncstart * : INTEGER; (* Vertical sync start *)
		vsyncend * : INTEGER;  (* Vertical sync start *)
		vtotal * : INTEGER; (* Total vertical pixels *)
		flags * : SET;  (* Mode flags *)
		privsize * : LONGINT; (* Size of private *)
		c_private-  : LONGINT; (* Server privates *)
	END;


	PModeInfo* = POINTER {UNSAFE} TO ARRAY OF ModeInfo;
	ModeInfo* = POINTER {UNSAFE} TO RECORD
		dotclock * : LONGINT; (* Pixel clock *)
		hdisplay * : INTEGER; (* Number of display pixels horizontally *)
		hsyncstart * : INTEGER; (* Horizontal sync start *)
		hsyncend * : INTEGER;  (* Horizontal sync end *)
		htotal * : INTEGER; (* Total horizontal pixels *)
		hskew * : INTEGER;
		vdisplay * : INTEGER; (* Number of display pixels vertically *)
		vsyncstart * : INTEGER;  (* Vertical sync start *)
		vsyncend * : INTEGER; (* Vertical sync start *)
		vtotal * : INTEGER;  (* Total vertical pixels *)
		flags * : SET; (* Mode flags *)
		privsize * : LONGINT; (* Size of private *)
		c_private*  : LONGINT;  (* Server privates *)
	END;

	(* Monitor information: *)
	SyncRange* = RECORD
		hi* : REAL; (* Top of range *)
		lo* : REAL; (* Bottom of range *)
	END;

	Monitor* = POINTER {UNSAFE} TO RECORD
		vendor * : PChar;  (* Name of manufacturer *)
		model * : PChar; (* Model name *)
		empty * : REAL; (* Monitor bandwidth *)
		nhsync * : cuchar; (* Number of horiz sync ranges *)
		hsync * : SyncRange; (* Horizontal sync ranges *)
		nvsync * : cuchar; (* Number of vert sync ranges *)
		vsync * : SyncRange; (* Vertical sync ranges *)
	END;

	NotifyEvent* = RECORD
		typ * : LONGINT;       (* of event *)
		serial * : LONGINT;    (* # of last request processed by server *)
		sendEvent * : Bool; (* true if this came from a SendEvent req *)
		display * : DisplayPtr; (* Display the event was read from *)
		root * : Window;     (* root window of event screen *)
		state * : LONGINT;       (* What happened *)
		kind * : LONGINT;        (* What happened *)
		forced * : Bool;     (* extents of new region *)
		time * : Time;       (* event timestamp *)
	END;

	Gamma* = RECORD
		red * : REAL;   (* Red Gamma value *)
		green * : REAL; (* Green Gamma value *)
		blue * : REAL;  (* Blue Gamma value *)
	END;


VAR

	QueryVersion- : PROCEDURE {PlatformCC} (dpy: DisplayPtr; VAR majorVersion : LONGINT; VAR minorVersion : LONGINT) : Bool;
	QueryExtension- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; VAR eventBaseReturn : LONGINT; VAR errorBaseReturn : LONGINT ) : Bool;
	SetClientVersion- : PROCEDURE {PlatformCC} (dpy : DisplayPtr) : Bool;
	GetModeLine- : PROCEDURE {PlatformCC} ( dpy : DisplayPtr; screen : LONGINT; VAR dotclockReturn : LONGINT; VAR modeline :  ModeLine) : Bool;
	GetAllModeLines- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT;  VAR modecountReturn : LONGINT; VAR modelinesr : PModeInfo ) : Bool;
	AddModeLine- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT;  new_modeline : ModeInfo;  VAR after_modeline : ModeInfo ) : Bool;
	DeleteModeLine- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; modeline : ModeInfo ) : Bool;
	ModModeLine- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; modeline : ModeLine) : Bool;
	ValidateModeLine- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; modeline : ModeInfo ) : LONGINT (* Api.Status *);
	SwitchMode- : PROCEDURE {PlatformCC} ( dpy : DisplayPtr; screen : LONGINT; zoom : LONGINT ) : Bool;
	SwitchToMode- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; modeline : ModeInfo ) : Bool;
	LockModeSwitch- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; lock : LONGINT) : Bool;
	GetMonitor- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT;  monitor : Monitor) : Bool;
	GetViewPort- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; VAR xreturn : LONGINT; VAR yreturn : LONGINT ) : Bool;
	SetViewPort- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; x : LONGINT; y : LONGINT ) : Bool;
	GetDotClocks- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; VAR flagsReturn : SET; VAR numberOffClocksReturn : LONGINT;  VAR maxDotClockReturn : LONGINT;
	    VAR clocksReturn : Pcushort ) : Bool;
	GetGamma- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; VAR gamma : Gamma ) : Bool;
	SetGamma- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; VAR gamma : Gamma ) : Bool;
	SetGammaRamp-: PROCEDURE {PlatformCC} ( dpy : DisplayPtr; screen : LONGINT; asize : LONGINT; redarray : Pcushort; greenarray : Pcushort; bluearray : Pcushort ) : Bool;
	GetGammaRamp- : PROCEDURE {PlatformCC} ( dpy : DisplayPtr; screen : LONGINT; asize : LONGINT; redarray : Pcushort;  greenarray : Pcushort; bluearray : Pcushort ) : Bool;
	GetGammaRampSize- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; VAR asize : LONGINT ) : Bool;
	GetPermissions- : PROCEDURE {PlatformCC} (dpy : DisplayPtr; screen : LONGINT; VAR permissions : LONGINT ) : Bool;

(* *********** Wrapper macros ************* *)

PROCEDURE SelectNextMode*(disp : DisplayPtr; scr : LONGINT) : Bool;
BEGIN
    RETURN SwitchMode(disp, scr, 1);
END SelectNextMode;

PROCEDURE SelectPrevMode*(disp : DisplayPtr; scr : LONGINT) : Bool;
BEGIN
    RETURN SwitchMode(disp, scr, -1);
END SelectPrevMode;

PROCEDURE LoadX11Functions;
BEGIN
	lib := Unix.Dlopen( libname, 2 );
	ASSERT(lib # 0, 301);

	Unix.Dlsym( lib, "XF86VidModeQueryVersion", ADDRESSOF( QueryVersion));
	Unix.Dlsym( lib, "XF86VidModeQueryExtension", ADDRESSOF( QueryExtension));
	Unix.Dlsym( lib, "XF86VidModeSetClientVersion", ADDRESSOF( SetClientVersion));
	Unix.Dlsym( lib, "XF86VidModeGetModeLine", ADDRESSOF( GetModeLine));
	Unix.Dlsym( lib, "XF86VidModeGetAllModeLines", ADDRESSOF( GetAllModeLines));
	Unix.Dlsym( lib, "XF86VidModeAddModeLine", ADDRESSOF( AddModeLine));
	Unix.Dlsym( lib, "XF86VidModeDeleteModeLine", ADDRESSOF( DeleteModeLine));
	Unix.Dlsym( lib, "XF86VidModeModModeLine", ADDRESSOF( ModModeLine));
	Unix.Dlsym( lib, "XF86VidModeValidateModeLine", ADDRESSOF( ValidateModeLine));
	Unix.Dlsym( lib, "XF86VidModeSwitchMode", ADDRESSOF( SwitchMode));
	Unix.Dlsym( lib, "XF86VidModeSwitchToMode", ADDRESSOF( SwitchToMode));
	Unix.Dlsym( lib, "XF86VidModeLockModeSwitch", ADDRESSOF( LockModeSwitch));
	Unix.Dlsym( lib, "XF86VidModeGetMonitor", ADDRESSOF( GetMonitor));
	Unix.Dlsym( lib, "XF86VidModeGetViewPort", ADDRESSOF( GetViewPort));
	Unix.Dlsym( lib, "XF86VidModeSetViewPort", ADDRESSOF( SetViewPort));
	Unix.Dlsym( lib, "XF86VidModeGetDotClocks", ADDRESSOF( GetDotClocks));
	Unix.Dlsym( lib, "XF86VidModeGetGamma", ADDRESSOF( GetGamma));
	Unix.Dlsym( lib, "XF86VidModeSetGamma", ADDRESSOF( SetGamma));
	Unix.Dlsym( lib, "XF86VidModeSetGammaRamp", ADDRESSOF( SetGammaRamp));
	Unix.Dlsym( lib, "XF86VidModeGetGammaRamp", ADDRESSOF( GetGammaRamp));
	Unix.Dlsym( lib, "XF86VidModeGetGammaRampSize", ADDRESSOF( GetGammaRampSize));
	Unix.Dlsym( lib, "XF86VidModeGetPermissions", ADDRESSOF( GetPermissions));

	KernelLog.String(libname); KernelLog.String(' loaded.'); KernelLog.Ln;
END LoadX11Functions;

PROCEDURE OnClose;
BEGIN
 IF lib # 0 THEN
       Unix.Dlclose(lib);
       KernelLog.String(libname); KernelLog.String(' unloaded.'); KernelLog.Ln;
END;
END OnClose;

BEGIN
	LoadX11Functions;
	Modules.InstallTermHandler(OnClose) ;
END XF86VMode.


(**


Arguments:
display
    Specifies the connection to the X server.
screen
    Specifies which screen number the setting apply to.
event_base_return
    Returns the base event number for the extension.
error_base_return
    Returns the base error number for the extension.
major_version_return
    Returns the major version number of the extension.
minor_version_return
    Returns the minor version number of the extension.
dotclock_return
    Returns the clock for the mode line.
modecount_return
    Returns the number of video modes available in the server.
zoom
    If greater than zero, indicates that the server should switch to the next mode, otherwise switch to the previous mode.
lock
    Indicates that mode switching should be locked, if non-zero.
modeline
    Specifies or returns the timing values for a video mode.
modesinfo
    Returns the timing values and dotclocks for all of the available video modes.
monitor
    Returns information about the monitor.
x
    Specifies the desired X location for the viewport.
x_return
    Returns the current X location of the viewport.
y
    Specifies the desired Y location for the viewport.
y_return
    Returns the current Y location of the viewport.

*)

