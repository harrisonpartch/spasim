(* ETH Oberon, Copyright 2000 ETH Zürich Institut für Computersysteme, ETH Zentrum, CH-8092 Zürich.
Refer to the general ETH Oberon System license contract available at: http://www.oberon.ethz.ch/ *)

MODULE KbdMouse;   (* g.f.	9.7.07 *)


(* replacement for the keyboard and mouse drivers in the Unix ports *)

IMPORT Machine, S := SYSTEM, Inputs, Plugins, X11, Displays, XDisplay, Api:=X11Api, Modules, Objects, Log := KernelLog;

CONST
	ML = 0;  MM = 1;  MR = 2;
	
	ModeSwitch = 13;
	
	MetaMask = { Api.Mod4Mask, ModeSwitch };


VAR
	event: Api.XEvent;  xbuttons: SET;
	compstatus: Api.ComposeStatus;

	disp: XDisplay.Display;

	MMseen, MRseen: BOOLEAN;
		
TYPE
	Poll = OBJECT 
		BEGIN {ACTIVE, SAFE,PRIORITY(Objects.High - 1)}
			LOOP
				Objects.Sleep( 15 );  PollXQueue;
			END 
		END Poll;

VAR
	poll: Poll; keySymbol: ARRAY 256 OF LONGINT;
	

	PROCEDURE CheckAlternateKeys( VAR mb: SET );
	BEGIN
		IF ~MMseen & (Api.ControlMask IN xbuttons) THEN INCL( mb, MM ) END;
		IF ~MRseen & (Api.Mod1Mask IN xbuttons) THEN INCL( mb, MR ) END
	END CheckAlternateKeys;


	PROCEDURE SendMouseMsg( x, y, dz: LONGINT; xbuttons: SET );
	VAR mm: Inputs.AbsMouseMsg;
	BEGIN
		Machine.Release( Machine.X11 ); 
		mm.keys := {};
		mm.x := x;  mm.y := y;  mm.dz := dz;
		IF Api.Button1Mask IN xbuttons THEN  INCL( mm.keys, ML )  END;
		IF Api.Button2Mask IN xbuttons THEN  INCL( mm.keys, MM );  MMseen := TRUE  END;
		IF Api.Button3Mask IN xbuttons THEN  INCL( mm.keys, MR );  MRseen := TRUE  END;
		IF ~(MMseen & MRseen) THEN  CheckAlternateKeys( mm.keys )  END;
		Inputs.mouse.Handle( mm );
		Machine.Acquire( Machine.X11 )
	END SendMouseMsg;


	PROCEDURE SendKeyboardMsg( km: Inputs.KeyboardMsg );
	BEGIN
		Machine.Release( Machine.X11 );
		Inputs.keyboard.Handle( km );
		Machine.Acquire( Machine.X11 ) 
	END SendKeyboardMsg;

	PROCEDURE PollXQueue;
	CONST bufsize = 20;
	VAR keycount, xr, yr, x, y, dz, i: LONGINT;
		rw, cw: X11.Window;   
		keysym: X11.KeySym;  xd: X11.DisplayPtr;
		newxbuttons, bdiff: SET;
		km: Inputs.KeyboardMsg;
		kp : Api.XKeyEvent;
		be : Api.XButtonPressedEvent;
		em: Api.XExposeEvent;
		cm : Api.XClientMessageEvent;
		datal: Api.Data40l;
		cn: Api.XConfigureEvent;
		res, events: LONGINT;
		buffer: ARRAY bufsize OF CHAR;
	BEGIN
		xd := disp.xdisp;
		Machine.Acquire( Machine.X11 );
		events := Api.Pending( xd );
		WHILE events > 0 DO 
			Api.NextEvent( xd, event );
			CASE event.typ OF
			| Api.KeyPress: kp := S.VAL(Api.XKeyEvent, event);
					X11.lastEventTime := kp.time;
					keycount := Api.LookupString( kp, buffer, bufsize, keysym, compstatus );
					X11.QueryPointer( xd, event.window, rw, cw, xr, yr, x, y, newxbuttons );
					IF keycount = 0 THEN
						bdiff := newxbuttons / xbuttons;  xbuttons := newxbuttons;
		Log.Bits( bdiff, 0, 32 ); Log.Ln;
						km.ch := 0X;						
						IF Api.ShiftMask IN bdiff THEN km.keysym := Inputs.KsShiftL
						ELSIF Api.ControlMask IN bdiff THEN 
							km.keysym := Inputs.KsControlL;
							IF ~MMseen THEN  SendMouseMsg( x, y, 0, xbuttons )  END
						ELSIF Api.Mod1Mask IN bdiff THEN 
							km.keysym := Inputs.KsAltL;
							IF ~MRseen THEN SendMouseMsg( x, y, 0, xbuttons )  END
						ELSIF MetaMask*bdiff # {} THEN km.keysym := Inputs.KsMetaL;
						ELSIF Api.Mod5Mask IN bdiff THEN km.keysym := Inputs.KsAltR
						END;
						km.flags := KeyState( );
						SendKeyboardMsg( km )
					ELSE
						xbuttons := newxbuttons;  i := 0;
						WHILE i < keycount DO
							km.ch := buffer[i];  km.flags := KeyState( );
							km.keysym := keySymbol[ORD( km.ch )];
							IF km.ch = 0F1X THEN  km.ch := 0A4X
							ELSIF km.ch = 0F2X THEN km.ch := 0A5X
							END;
							SendKeyboardMsg( km );
							INC( i )
						END
					END;
			| Api.KeyRelease: kp := S.VAL(Api.XKeyEvent, event);
					X11.lastEventTime := kp.time;
					X11.QueryPointer( xd, event.window, rw, cw, xr, yr, x, y, newxbuttons );
					bdiff := newxbuttons / xbuttons;  xbuttons := newxbuttons;
		Log.Bits( bdiff, 0, 32 ); Log.Ln;
					IF bdiff # {} THEN
						km.ch := 0X;
						IF Api.ShiftMask IN bdiff THEN km.keysym := Inputs.KsShiftL
						ELSIF Api.ControlMask IN bdiff THEN 
							km.keysym := Inputs.KsControlL;
							IF ~MMseen THEN  SendMouseMsg( x, y, 0, xbuttons )  END
						ELSIF Api.Mod1Mask IN bdiff THEN 
							km.keysym := Inputs.KsAltL;
							IF ~MRseen THEN SendMouseMsg( x, y, 0, xbuttons )  END
						ELSIF MetaMask*bdiff # {} THEN km.keysym := Inputs.KsMetaL
						ELSIF Api.Mod5Mask IN bdiff THEN km.keysym := Inputs.KsAltR
						END;
						km.flags := KeyState( ) + {Inputs.Release};
						SendKeyboardMsg( km )
					END
			| Api.ButtonPress: be := S.VAL(Api.XButtonPressedEvent, event);
					X11.lastEventTime := be.time;
					dz := 0;
					CASE be.button OF
					| Api.Button1:  INCL( xbuttons, Api.Button1Mask )
					| Api.Button2:  INCL( xbuttons, Api.Button2Mask )
					| Api.Button3:  INCL( xbuttons, Api.Button3Mask )
					| Api.Button4: dz := -1
					| Api.Button5: dz := +1
					ELSE  (* ignore *)
					END;
					SendMouseMsg( be.x, be.y, dz, xbuttons )
			| Api.ButtonRelease: be := S.VAL(Api.XButtonReleasedEvent, event);
					X11.lastEventTime := be.time;
					CASE be.button OF
					| Api.Button1:  EXCL( xbuttons, Api.Button1Mask )
					| Api.Button2:  EXCL( xbuttons, Api.Button2Mask )
					| Api.Button3:  EXCL( xbuttons, Api.Button3Mask )
					ELSE  (* ignore *)
					END;
					SendMouseMsg( be.x, be.y, 0, xbuttons )
			| Api.MotionNotify:
					X11.QueryPointer( xd, event.window, rw, cw, xr, yr, x, y, xbuttons );
					SendMouseMsg( x, y, 0, xbuttons )
			| Api.Expose, Api.GraphicsExpose: 
					(* hacking, clear all expoure events in queue *)
					REPEAT res := Api.CheckTypedEvent(xd, Api.Expose, event) UNTIL res # X11.True; 
					REPEAT 
						res := Api.CheckWindowEvent(xd, disp.primary, Api.ExposureMask, event) 
					UNTIL res # X11.True; 
					em := S.VAL( Api.XExposeEvent, event );
					IF em.count = 0 THEN  (* wait until last message*) 
						(* Let DisplayRefresher handle this *)						
						km.keysym := 0FFC6H;
						SendKeyboardMsg( km );
					END;
					(* clear all expoure events in queue, again *)
					REPEAT res := Api.CheckTypedEvent(xd, Api.Expose, event) UNTIL res # X11.True; 
			| Api.NoExpose:
			| Api.MappingNotify:
					X11.RefreshKeyboardMapping( ADDRESSOF( event ) )
			| Api.ClientMessage: 
					cm := S.VAL( Api.XClientMessageEvent, event );
					datal := S.VAL( Api.Data40l, cm.data );
					IF  S.VAL( X11.Atom,datal[0] ) = disp.wmDelete THEN									
						(* shutdown *)
						Machine.Release( Machine.X11 );
						Modules.Shutdown( Modules.Reboot );
					END; 
			| Api.UnmapNotify:
			| Api.MapNotify: 
			| Api.SelectionClear:
					IF Api.ClearSelection # NIL THEN Api.ClearSelection(); END
			| Api.SelectionNotify:
					IF Api.ReceiveSelection # NIL THEN
						Machine.Release( Machine.X11 );
							Api.ReceiveSelection( S.VAL( Api.XSelectionEvent, event ) );
						Machine.Acquire( Machine.X11 )
					END
			| Api.SelectionRequest:
					IF Api.SendSelection # NIL THEN
						Machine.Release( Machine.X11 );  
							Api.SendSelection( S.VAL( Api.XSelectionRequestEvent, event ) );
						Machine.Acquire( Machine.X11 )
					END
			| Api.ConfigureNotify:  cn := S.VAL(Api.XConfigureEvent, event);
			ELSE
				(* ignore *)
			END;
			events := Api.Pending( xd );
		END;
		Machine.Release( Machine.X11 );
	END PollXQueue;



	(* Returns wether key (SHIFT, CTRL or ALT) is pressed *)
	PROCEDURE KeyState( ): SET;
	VAR keys: SET;
	BEGIN
		keys := {};
		IF Api.ShiftMask IN xbuttons THEN  INCL( keys, Inputs.LeftShift )  END;
		IF Api.ControlMask IN xbuttons THEN  INCL( keys, Inputs.LeftCtrl )  END;
		IF Api.Mod1Mask IN xbuttons THEN  INCL( keys, Inputs.LeftAlt )  END;
		IF MetaMask*xbuttons # {} THEN  INCL( keys, Inputs.LeftMeta )  END;
		IF Api.Mod5Mask IN xbuttons THEN  INCL( keys, Inputs.RightAlt )  END;
		RETURN keys
	END KeyState;


	PROCEDURE Keysym( CONST str: ARRAY OF CHAR ): LONGINT;
	BEGIN
		RETURN X11.StringToKeysym( ADDRESSOF( str ) )
	END Keysym;

	PROCEDURE Init*;
	VAR FK: ARRAY 8 OF CHAR;
		n, i, k: LONGINT;  modifiers: X11.Modifiers;
		shift, control, meta, alt, capslock, numlock: LONGINT;   (* keysym's *)


		PROCEDURE Rebind( CONST keystr: ARRAY OF CHAR;  nofmod: LONGINT;  key: CHAR );
		VAR newkeystr: ARRAY 8 OF CHAR;
			oldkeysym: LONGINT;
		BEGIN
			Machine.Acquire( Machine.X11 );
			oldkeysym := Keysym( keystr );
			newkeystr[0] := key;  newkeystr[1] := 0X;
			X11.RebindKeysym( disp.xdisp, oldkeysym, modifiers, nofmod, ADDRESSOF( newkeystr ), 1 );
			Machine.Release( Machine.X11 )
		END Rebind;

		PROCEDURE Rebind4( CONST keyString: ARRAY OF CHAR;  n: LONGINT;  key: CHAR );
		BEGIN
			Rebind( keyString, n, key );
			modifiers[n] := shift;  Rebind( keyString, n + 1, key );
			modifiers[n] := control;  Rebind( keyString, n + 1, key );
			modifiers[n + 1] := shift;  Rebind( keyString, n + 2, key );
		END Rebind4;

	BEGIN
		MMseen := FALSE;  MRseen := FALSE;


		Machine.Acquire( Machine.X11 );
		X11.SelectInput( disp.xdisp, disp.primary,
						  X11.ExposureMask + X11.ButtonPressMask + X11.OwnerGrabButtonMask +
						  X11.ButtonReleaseMask + X11.PointerMotionHintMask + X11.PointerMotionMask +
						  X11.KeyPressMask + X11.KeyReleaseMask + X11.StructureNotifyMask );
		Machine.Release( Machine.X11 );

	 	shift := Keysym( "Shift_L" );  control := Keysym( "Control_L" );
		meta := Keysym( "Meta-L" );  alt := Keysym( "Alt_L" );
		capslock := Keysym( "Caps_Lock" );  numlock := Keysym( "Num_Lock" );

		modifiers[0] := shift;
		Rebind( "Pause", 1, 0ADX );   (* SHIFT-BREAK *)

		modifiers[0] := control;	Rebind( "Return", 1, 0AX );
		   modifiers[1] := numlock;	Rebind( "Return", 2, 0AX );
		   modifiers[1] := capslock;	Rebind( "Return", 2, 0AX );
			modifiers[2] := numlock;	Rebind( "Return", 3, 0AX );


		FOR k := 0 TO 4 DO
			CASE k OF
			| 0:   n := 0;
			| 1:   modifiers[0] := meta;  n := 1;
			| 2:   modifiers[0] := capslock;  n := 1
			| 3:   modifiers[0] := numlock;  n := 1
			| 4:   modifiers[0] := capslock;  modifiers[1] := numlock;  n := 2
			END;
			i := 0;  FK := "F0";
			WHILE i < 10 DO FK[1] := CHR( ORD( "0" ) + i );  Rebind4( FK, n, CHR( 0F0H + i ) );  INC( i ) END;
			i := 10;  FK := "F10";
			WHILE i <= 12 DO FK[2] := CHR( ORD( "0" ) + i - 10 );  Rebind4( FK, n, CHR( 0F0H + i ) );  INC( i ) END;

			Rebind4( "BackSpace", n, 7FX );
			Rebind4( "Delete", n, 0A1X );
			Rebind4( "Escape", n, 1BX );
			Rebind4( "Up", n, 0C1X );  Rebind4( "Down", n, 0C2X );
			Rebind4( "Left", n, 0C4X );  Rebind4( "Right", n, 0C3X );
			IF k < 3 THEN
				(* do not for NumLock on *)
				Rebind4( "KP_Up", n, 0C1X );  Rebind4( "KP_Down", n, 0C2X );
				Rebind4( "KP_Left", n, 0C4X );  Rebind4( "KP_Right", n, 0C3X );
			END;
			Rebind4( "Prior", n, 0A2X );  Rebind4( "KP_Prior", n, 0A2X );
			Rebind4( "Next", n, 0A3X );  Rebind4( "KP_Next", n, 0A3X );
			Rebind4( "Insert", n, 0A0X );
			Rebind4( "Home", n, 0A8X );  Rebind4( "KP_Home", n, 0A8X );
			Rebind4( "End", n, 0A9X );  Rebind4( "KP_End", n, 0A9X );
		END;
		
		
		(* special keyboard: *)
		modifiers[0] := shift; 
		(*a acute*)		Rebind( "aacute", 0, 094X );			Rebind( "aacute", 1, 094X );
		(*a grave*) 		Rebind( "agrave", 0, 08BX );			Rebind( "agrave", 1, 08BX );
		(*a diaeresis*)	Rebind( "adiaeresis", 0, 083X );		Rebind( "adiaeresis", 1, 083X );
		(*a circumflex*)	Rebind( "acircumflex", 0, 086X );		Rebind( "acircumflex", 1, 086X );
		(*e acute*) 		Rebind( "eacute", 0, 090X );			Rebind( "eacute", 1, 090X );
		(*e grave*)		Rebind( "egrave", 0, 08CX );			Rebind( "egrave", 1, 08CX );
		(*e diaeresis*)	Rebind( "ediaeresis", 0, 091X );		Rebind( "ediaeresis", 1, 091X );
		(*e circumflex*)	Rebind( "ecircumflex", 0, 087X );		Rebind( "ecircumflex", 1, 087X );
		(*i grave*)		Rebind( "igrave", 0, 08DX );			Rebind( "igrave", 1, 08DX );
		(*i diaeresis*)	Rebind( "idiaeresis", 0, 092X );		Rebind( "idiaeresis", 1, 092X );
		(*i circumflex*)	Rebind( "icircumflex", 0, 088X );		Rebind( "icircumflex", 1, 088X );
		(*o grave*)		Rebind( "ograve", 0, 08EX );			Rebind( "ograve", 1, 08EX );
		(*o diaeresis*)	Rebind( "odiaeresis", 0, 084X );		Rebind( "odiaeresis", 1, 084X );
		(*o circumflex*)	Rebind( "ocircumflex", 0, 089X );		Rebind( "ocircumflex", 1, 089X );
		(*u grave*)		Rebind( "ugrave", 0, 08FX );			Rebind( "ugrave", 1, 08FX );
		(*u diaeresis*)	Rebind( "udiaeresis", 0, 085X );		Rebind( "udiaeresis", 1, 085X );
		(*u circumflex*)	Rebind( "ucircumflex", 0, 08AX );		Rebind( "ucircumflex", 1, 08AX );
		(*c cedilla*)	Rebind( "ccedilla", 0, 093X );			Rebind( "ccedilla", 1, 093X );

		(*n tilde*)		Rebind( "ntilde", 0, 095X );
		(*s sharp*)		Rebind( "ssharp", 0, 096X );
		(*A diaeresis*)	Rebind( "Adiaeresis", 0, 080X );
		(*O diaeresis*)	Rebind( "Odiaeresis", 0, 081X );	
		(*U diaeresis*)	Rebind( "Udiaeresis", 0, 082X );
		 
		InitKeysym;

		NEW( poll );  
		
	END Init;

	PROCEDURE InitKeysym;
	VAR i: LONGINT;
	BEGIN
		FOR i := 0 TO 255 DO keySymbol[i] := i END;
		keySymbol[07FH] := Inputs.KsBackSpace;
		keySymbol[009H] := Inputs.KsTab;
		keySymbol[00AH] := Inputs.KsReturn;
		keySymbol[00DH] := Inputs.KsReturn;

		keySymbol[0C1H] := Inputs.KsUp;
		keySymbol[0C2H] := Inputs.KsDown;
		keySymbol[0C3H] := Inputs.KsRight;
		keySymbol[0C4H] := Inputs.KsLeft;

		keySymbol[0A0H] := Inputs.KsInsert;
		keySymbol[0A1H] := Inputs.KsDelete;
		keySymbol[0A2H] := Inputs.KsPageUp;
		keySymbol[0A3H] := Inputs.KsPageDown;
		keySymbol[0A8H] := Inputs.KsHome;
		keySymbol[0A9H] := Inputs.KsEnd;
		FOR i := 0F1H TO 0FCH DO keySymbol[i] := 0FFBEH + (i - 0F1H) END
	END InitKeysym;

	PROCEDURE GetXDisplay;
	VAR p: Plugins.Plugin;
	BEGIN
		p := Displays.registry.Await( "XDisplay" );  disp := p( XDisplay.Display )
	END GetXDisplay;

BEGIN
	ASSERT( S.VAL( LONGINT, {0} ) = 1 );
	GetXDisplay;  
END KbdMouse.


(** Remark:

1. Keyboard character codes correspond to the ASCII character set. Some other important codes are:

	SHIFT-BREAK	0ADX
	BREAK	0ACX
	F1 ... F12	0F1X ... 0FCX
	UP ARROW	0C1X
	RIGHT ARROW	0C3X
	DOWN ARROW	0C2X
	LEFT ARROW	0C4X
	INSERT	0A0X
	DELETE	0A1X
	PAGE-UP	0A2X
	PAGE-DOWN	0A3X
	ä, Ä	131, 128
	ö, Ö	132, 129
	ü, Ü	133, 130
	ß	150

The MODule EditKeys allows you to determine the keyboard code of any key pressed. For cross-platform portability, Oberon does not normally support all keys available on your keyboard.

2. On some platforms, SetMouseLimits may not influence the physical movement of the mouse cursor itself, only the magnitude of the coordinates returned by Mouse.
*)
