MODULE XF86VMode; (** AUTHOR "fnecati"; PURPOSE "unix <X/xf86vmode.h>"; *)

IMPORT
  X11 , Unix, SYSTEM, Modules, KernelLog;

CONST
  libXxf86vm = 'libXxf86vm.so.1';

TYPE

	PChar = POINTER TO ARRAY OF CHAR;
	cuchar = CHAR; (* int8 *)
	Pcushort = POINTER TO ARRAY OF INTEGER;

	Bool = X11.Bool;

	DisplayPtr = X11.DisplayPtr;
	Time = X11.Time;
	Window = X11.Window;

CONST
	X_XF86VidModeQueryVersion*     = 0;
	X_XF86VidModeGetModeLine*      = 1;
	X_XF86VidModeModModeLine*      = 2;
	X_XF86VidModeSwitchMode*       = 3;
	X_XF86VidModeGetMonitor*       = 4;
	X_XF86VidModeLockModeSwitch*   = 5;
	X_XF86VidModeGetAllModeLines*  = 6;
	X_XF86VidModeAddModeLine*      = 7;
	X_XF86VidModeDeleteModeLine*   = 8;
	X_XF86VidModeValidateModeLine* = 9;
	X_XF86VidModeSwitchToMode*     = 10;
	X_XF86VidModeGetViewPort*      = 11;
	X_XF86VidModeSetViewPort*      = 12;
	(* new for version 2.x of this extension *)
	X_XF86VidModeGetDotClocks*     = 13;
	X_XF86VidModeSetClientVersion* = 14;
	X_XF86VidModeSetGamma*         = 15;
	X_XF86VidModeGetGamma*         = 16;
	X_XF86VidModeGetGammaRamp*     = 17;
	X_XF86VidModeSetGammaRamp*     = 18;
	X_XF86VidModeGetGammaRampSize* = 19;
	X_XF86VidModeGetPermissions*   = 20;

	CLKFLAG_PROGRAMABLE*           = 1;

	(*$IFDEF XF86VIDMODE_EVENTS*)
	XF86VidModeNotify*             = 0;
	XF86VidModeNumberEvents*       = (XF86VidModeNotify + 1);

	XF86VidModeNotifyMask*         = 00000001H;

	XF86VidModeNonEvent*           = 0;
	XF86VidModeModeChange*         = 1;
	(* (*$ELSE XF86VIDMODE_EVENTS*)
	XF86VidModeNumberEvents*       = 0;
	(*$ENDIF XF86VIDMODE_EVENTS*)
	*)
	XF86VidModeBadClock*           = 0;
	XF86VidModeBadHTimings*        = 1;
	XF86VidModeBadVTimings*        = 2;
	XF86VidModeModeUnsuitable*     = 3;
	XF86VidModeExtensionDisabled*  = 4;
	XF86VidModeClientNotLocal*     = 5;
	XF86VidModeZoomLocked*         = 6;
	XF86VidModeNumberErrors*       = (XF86VidModeZoomLocked + 1);

	XF86VM_READ_PERMISSION*  = 1;
	XF86VM_WRITE_PERMISSION* = 2;

	(* Video Mode Settings: *)
TYPE
 	 	 XF86VidModeModeLine* = RECORD
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


	PPXF86VidModeModeInfo* = POINTER TO ARRAY OF PXF86VidModeModeInfo;
	PXF86VidModeModeInfo* = POINTER TO XF86VidModeModeInfo;
	XF86VidModeModeInfo* = RECORD
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
	XF86VidModeSyncRange* = RECORD
		hi* : REAL; (* Top of range *)
		lo* : REAL; (* Bottom of range *)
	END;

	XF86VidModeMonitor* = RECORD
		vendor * : PChar;  (* Name of manufacturer *)
		model * : PChar; (* Model name *)
		empty * : REAL; (* Monitor bandwidth *)
		nhsync * : cuchar; (* Number of horiz sync ranges *)
		hsync * : XF86VidModeSyncRange; (* Horizontal sync ranges *)
		nvsync * : cuchar; (* Number of vert sync ranges *)
		vsync * : XF86VidModeSyncRange; (* Vertical sync ranges *)
	END;

	XF86VidModeNotifyEvent* = RECORD
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

	XF86VidModeGamma* = RECORD
		red * : REAL;   (* Red Gamma value *)
		green * : REAL; (* Green Gamma value *)
		blue * : REAL;  (* Blue Gamma value *)
	END;


VAR

	XF86VidModeQueryVersion- : PROCEDURE {C} (dpy: DisplayPtr; VAR majorVersion : LONGINT; VAR minorVersion : LONGINT) : Bool;
	XF86VidModeQueryExtension- : PROCEDURE {C} (dpy : DisplayPtr; VAR eventBaseReturn : LONGINT; VAR errorBaseReturn : LONGINT ) : Bool;
	XF86VidModeSetClientVersion- : PROCEDURE {C} (dpy : DisplayPtr) : Bool;
	XF86VidModeGetModeLine- : PROCEDURE {C} ( dpy : DisplayPtr; screen : LONGINT; VAR dotclockReturn : LONGINT; VAR modeline :  XF86VidModeModeLine) : Bool;
	XF86VidModeGetAllModeLines- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT;  VAR modecountReturn : LONGINT; modelinesPtr : ADDRESS (*PPPXF86VidModeModeInfo*) ) : Bool;
	XF86VidModeAddModeLine- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR new_modeline : XF86VidModeModeInfo; VAR after_modeline : XF86VidModeModeInfo ) : Bool;
	XF86VidModeDeleteModeLine- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR modeline : XF86VidModeModeInfo ) : Bool;
	XF86VidModeModModeLine- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR modeline : XF86VidModeModeLine) : Bool;
	XF86VidModeValidateModeLine- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR modeline : XF86VidModeModeInfo ) : LONGINT (* Api.Status *);
	XF86VidModeSwitchMode- : PROCEDURE {C} ( dpy : DisplayPtr; screen : LONGINT; zoom : LONGINT ) : Bool;
	XF86VidModeSwitchToMode- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR modeline : XF86VidModeModeInfo ) : Bool;
	XF86VidModeLockModeSwitch- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; lock : LONGINT) : Bool;
	XF86VidModeGetMonitor- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR monitor : XF86VidModeMonitor) : Bool;
	XF86VidModeGetViewPort- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR xreturn : LONGINT; VAR yreturn : LONGINT ) : Bool;
	XF86VidModeSetViewPort- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; x : LONGINT; y : LONGINT ) : Bool;
	XF86VidModeGetDotClocks- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR flagsReturn : SET; VAR numberOffClocksReturn : LONGINT;  VAR maxDotClockReturn : LONGINT;
	    clocksReturn : ADDRESS (*Xlib.PPcint *) ) : Bool;
	XF86VidModeGetGamma- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR gamma : XF86VidModeGamma ) : Bool;
	XF86VidModeSetGamma- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR gamma : XF86VidModeGamma ) : Bool;
	XF86VidModeSetGammaRamp-: PROCEDURE {C} ( dpy : DisplayPtr; screen : LONGINT; asize : LONGINT; redarray : Pcushort; greenarray : Pcushort; bluearray : Pcushort ) : Bool;
	XF86VidModeGetGammaRamp- : PROCEDURE {C} ( dpy : DisplayPtr; screen : LONGINT; asize : LONGINT; redarray : Pcushort;  greenarray : Pcushort; bluearray : Pcushort ) : Bool;
	XF86VidModeGetGammaRampSize- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR asize : LONGINT ) : Bool;
	XF86VidModeGetPermissions- : PROCEDURE {C} (dpy : DisplayPtr; screen : LONGINT; VAR permissions : LONGINT ) : Bool;


xlib: LONGINT;

(* *********** Wrapper macros ************* *)

PROCEDURE XF86VidModeSelectNextMode*(disp : DisplayPtr; scr : LONGINT) : Bool;
BEGIN
    RETURN XF86VidModeSwitchMode(disp, scr, 1);
END XF86VidModeSelectNextMode;

PROCEDURE XF86VidModeSelectPrevMode*(disp : DisplayPtr; scr : LONGINT) : Bool;
BEGIN
    RETURN XF86VidModeSwitchMode(disp, scr, -1);
END XF86VidModeSelectPrevMode;

PROCEDURE VidModeGetAllModeLines*(display: DisplayPtr; screen: LONGINT; VAR vidlines: PPXF86VidModeModeInfo): LONGINT;
VAR
      mlines1: PPXF86VidModeModeInfo;
      mlinesadr: ADDRESS;
      mcount: LONGINT;
      res: LONGINT;
      i: LONGINT;
BEGIN

(* get  TXF86VidModeModeInfo*** info   C structure array  *)
res := XF86VidModeGetAllModeLines(display, screen, mcount, ADDRESSOF(mlinesadr));

mlines1 := SYSTEM.VAL(PPXF86VidModeModeInfo, mlinesadr-16); (*  ????  *)
 IF mlines1 = NIL THEN
	vidlines := NIL;
	RETURN res;
 END;

NEW(vidlines, mcount); (* create oberon friendly array, and copy to it*)
 FOR i:=0 TO mcount-1 DO vidlines[i] := mlines1[i];  END;

 X11.Free(mlinesadr);

 mlines1 := NIL;
 RETURN res;
END VidModeGetAllModeLines;


PROCEDURE LoadX11Functions;
BEGIN {EXCLUSIVE}
	xlib := Unix.Dlopen( libXxf86vm, 2 );
	ASSERT(xlib # 0, 301);

	Unix.Dlsym( xlib, "XF86VidModeQueryVersion", ADDRESSOF( XF86VidModeQueryVersion));
	Unix.Dlsym( xlib, "XF86VidModeQueryExtension", ADDRESSOF( XF86VidModeQueryExtension));
	Unix.Dlsym( xlib, "XF86VidModeSetClientVersion", ADDRESSOF( XF86VidModeSetClientVersion));
	Unix.Dlsym( xlib, "XF86VidModeGetModeLine", ADDRESSOF( XF86VidModeGetModeLine));
	Unix.Dlsym( xlib, "XF86VidModeGetAllModeLines", ADDRESSOF( XF86VidModeGetAllModeLines));
	Unix.Dlsym( xlib, "XF86VidModeAddModeLine", ADDRESSOF( XF86VidModeAddModeLine));
	Unix.Dlsym( xlib, "XF86VidModeDeleteModeLine", ADDRESSOF( XF86VidModeDeleteModeLine));
	Unix.Dlsym( xlib, "XF86VidModeModModeLine", ADDRESSOF( XF86VidModeModModeLine));
	Unix.Dlsym( xlib, "XF86VidModeValidateModeLine", ADDRESSOF( XF86VidModeValidateModeLine));
	Unix.Dlsym( xlib, "XF86VidModeSwitchMode", ADDRESSOF( XF86VidModeSwitchMode));
	Unix.Dlsym( xlib, "XF86VidModeSwitchToMode", ADDRESSOF( XF86VidModeSwitchToMode));
	Unix.Dlsym( xlib, "XF86VidModeLockModeSwitch", ADDRESSOF( XF86VidModeLockModeSwitch));
	Unix.Dlsym( xlib, "XF86VidModeGetMonitor", ADDRESSOF( XF86VidModeGetMonitor));
	Unix.Dlsym( xlib, "XF86VidModeGetViewPort", ADDRESSOF( XF86VidModeGetViewPort));
	Unix.Dlsym( xlib, "XF86VidModeSetViewPort", ADDRESSOF( XF86VidModeSetViewPort));
	Unix.Dlsym( xlib, "XF86VidModeGetDotClocks", ADDRESSOF( XF86VidModeGetDotClocks));
	Unix.Dlsym( xlib, "XF86VidModeGetGamma", ADDRESSOF( XF86VidModeGetGamma));
	Unix.Dlsym( xlib, "XF86VidModeSetGamma", ADDRESSOF( XF86VidModeSetGamma));
	Unix.Dlsym( xlib, "XF86VidModeSetGammaRamp", ADDRESSOF( XF86VidModeSetGammaRamp));
	Unix.Dlsym( xlib, "XF86VidModeGetGammaRamp", ADDRESSOF( XF86VidModeGetGammaRamp));
	Unix.Dlsym( xlib, "XF86VidModeGetGammaRampSize", ADDRESSOF( XF86VidModeGetGammaRampSize));
	Unix.Dlsym( xlib, "XF86VidModeGetPermissions", ADDRESSOF( XF86VidModeGetPermissions));

	KernelLog.String(libXxf86vm); KernelLog.String(' loaded.'); KernelLog.Ln; 
END LoadX11Functions;

PROCEDURE OnClose;
BEGIN {EXCLUSIVE}
 IF xlib # 0 THEN
       Unix.Dlclose(xlib);
       KernelLog.String(libXxf86vm); KernelLog.String(' unloaded.'); KernelLog.Ln; 
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

