MODULE X11Api; (** AUTHOR "fnecati"; PURPOSE "some missing types, const and functions in Unix.X11.Mod"; *)

IMPORT
	X11, Unix, Modules, Trace, SYSTEM;

(*! New XEvet types *)

TYPE 
	ADDRESS*= SYSTEM.ADDRESS;
	PChar* = POINTER TO ARRAY OF CHAR;
	Buffer = X11.Buffer;
	VisualPtr = X11.VisualPtr;
	VisualInfoPtr*  = POINTER TO X11.VisualInfo; 
	DisplayPtr* = X11.DisplayPtr;
	Window * = X11.Window;
	Time* = X11.Time;
	Pixmap = X11.Pixmap;
	Cursor* = X11.Cursor;
	Atom* = X11.Atom;
	XID* = LONGINT;
	Drawable* = X11.Drawable;
	Colormap* = X11.Colormap;
	ComposeStatus = X11.ComposeStatus;
	KeySym* = X11.KeySym;
	
	(* Cursor control & motion *)
	(* X11/keysymdef.h *)
CONST

	XK_Home* = 	0FF50H;
	XK_Left* = 	0FF51H;  (* Move left, left arrow *)
	XK_Up* = 	0FF52H;  (* Move up, up arrow *)
	XK_Right* = 	0FF53H;  (* Move right, right arrow *)
	XK_Down* = 	0FF54H;  (* Move down, down arrow *)
	XK_Prior* = 	0FF55H;  (* Prior, previous *)
	XK_Page_Up* = 	0FF55H;
	XK_Next* = 	0FF56H;  (* Next *)
	XK_Page_Down* = 0FF56H;
	XK_End* = 	0FF57H;  (* EOL *)
	XK_Begin* = 	0FF58H;  (* BOL *)

	XK_Escape* = 0FF1BH;
	XK_F1* =0FFBEH;
	
	(*  X11/X.h *)
(* ****************************************************************
                       RESERVED RESOURCE AND CONSTANT DEFINITIONS
**************************************************************** *)
 
	None* = 0;	(* universal null resource or null atom *)
	ParentRelative* = 1;	(* background pixmap in CreateWindow
					    and ChangeWindowAttributes *)
	CopyFromParent* = 0;	(* border pixmap in CreateWindow
					       and ChangeWindowAttributes
					   special VisualID and special window
					       class passed to CreateWindow *)
	PointerWindow* = 0;	(* destination window in SendEvent *)
	InputFocus* = 1;	(* destination window in SendEvent *)
	PointerRoot* = 1;	(* focus window in SetInputFocus *)
	AnyPropertyType* = 0;	(* special Atom, passed to GetProperty *)
	AnyKey* = 0;	(* special Key Code, passed to GrabKey *)
	AnyButton* = 0;	(* special Button Code, passed to GrabButton *)
	AllTemporary* = 0;	(* special Resource ID passed to KillClient *)
	CurrentTime* = 0;	(* special Time *)
	NoSymbol* = 0;	(* special KeySym *)


	(* EVENT DEFINITIONS
	    similar to Unix.X11.Mod but changed types to SET for easy usage 
	*)
 
	(*  Input Event Masks. Used as event-mask window attribute and as arguments
	   to Grab requests.  Not to be confused with event names. *)

CONST
	NoEventMask* = 0;  KeyPressMask* = 0; KeyReleaseMask* = 1;
	ButtonPressMask* = 2;  ButtonReleaseMask* = 3;  EnterWindowMask* = 4;  
	LeaveWindowMask* = 5;  PointerMotionMask* = 6;  PointerMotionHintMask* = 7;  
	Button1MotionMask* = 8; Button2MotionMask* = 9; Button3MotionMask* = 10; 
	Button4MotionMask* = 11;  Button5MotionMask* = 12;  ButtonMotionMask* = 13; 
	KeymapStateMask* = 14; ExposureMask* = 15; VisibilityChangeMask* = 16; 
	StructureNotifyMask* = 17; ResizeRedirectMask* = 18; SubstructureNotifyMask* = 19; 
	SubstructureRedirectMask* = 20; FocusChangeMask * = 21; PropertyChangeMask* = 22; 
	ColormapChangeMask* = 23; OwnerGrabButtonMask* = 24; 

	(* Event names.  Used in "type" field in XEvent structures.  Not to be
	confused with event masks above.  They start from 2 because 0 and 1
	are reserved in the protocol for errors and replies. *)

CONST
	KeyPress* = 2;  KeyRelease* =3;  ButtonPress* = 4;  ButtonRelease* = 5;  MotionNotify* =6;
	EnterNotify* = 7; LeaveNotify* =8;  FocusIn* = 9;  FocusOut* = 10;  KeymapNotify* = 11;
	Expose* = 12;  GraphicsExpose* = 13;  NoExpose* = 14;  VisibilityNotify* = 15;
	CreateNotify* = 16; DestroyNotify* = 17; UnmapNotify* = 18;  MapNotify* = 19;
	MapRequest* = 20;  ReparentNotify* = 21; ConfigureNotify* = 22; ConfigureRequest* = 23;
	GravityNotify* = 24; ResizeRequest* =	25; CirculateNotify* = 26; CirculateRequest* = 27;
	PropertyNotify* = 28; SelectionClear* = 29; SelectionRequest* =30; SelectionNotify* = 31;
	ColormapNotify* = 32;  ClientMessage* = 33;  MappingNotify* = 34;  GenericEvent* = 35;
	LASTEvent* =		36;	 (* must be bigger than any event # *)


	(* Key masks. Used as modifiers to GrabButton and GrùabKey, results of QueryPointer,
	state in various key-, mouse-, and button-related events. *)

	ShiftMask* = 1;  LockMask* = 2;  ControlMask* = 2;
	Mod1Mask* = 4;  Mod2Mask* = 5;  Mod3Mask* = 6;
	Mod4Mask* = 7;   Mod5Mask* = 8;

	(* modifier names.  Used to build a SetModifierMapping request or
	to read a GetModifierMapping request.  These correspond to the
	masks defined above. *)
	ShiftMapIndex* =	0;  LockMapIndex* = 1; ControlMapIndex* = 2;
	Mod1MapIndex* =	3; Mod2MapIndex* = 4; Mod3MapIndex* = 5;
	Mod4MapIndex* =	6; Mod5MapIndex* = 7;

	(* button masks.  Used in same manner as Key masks above. Not to be confused
	with button names below. *)
	Button1Mask* = 9; Button2Mask* = 10; Button3Mask* = 11;
	Button4Mask* = 12; Button5Mask* = 13;
  
	AnyModifier* = 16;  (* used in GrabButton, GrabKey *)

	(* button names. Used as arguments to GrabButton and as detail in ButtonPress
	and ButtonRelease events.  Not to be confused with button masks above.
	Note that 0 is already defined above as "AnyButton".  *)

	Button1* = 1; Button2* = 2; Button3* = 3;
	Button4* = 4; Button5* = 5;

	(* Notify modes *)
	NotifyNormal* = 0; NotifyGrab* = 1; NotifyUngrab* = 2; NotifyWhileGrabbed* =	3;

	NotifyHint* = 1; (* for MotionNotify events *)
		       
	(* Notify detail *)
	NotifyAncestor* = 0; NotifyVirtual* = 1; NotifyInferior* = 2; NotifyNonlinear* = 3;
	NotifyNonlinearVirtual* = 4; NotifyPointer* = 5; NotifyPointerRoot* = 6;
	NotifyDetailNone* = 7;

	(* Visibility notify *)
	VisibilityUnobscured* =  0; VisibilityPartiallyObscured* = 1; VisibilityFullyObscured* = 2;

	(* Circulation request *)
	PlaceOnTop* = 0; PlaceOnBottom* = 1;

	(* protocol families *)
	FamilyInternet* = 0; (* IPv4 *)  FamilyDECnet* = 1;  FamilyChaos* = 2; FamilyInternet6* = 6; (* IPv6 *)

	(* authentication families not tied to a specific protocol *)
	FamilyServerInterpreted* = 5;

	(* Property notification *)
	PropertyNewValue* = 0;  PropertyDelete* = 1;

	(* Color Map notification *)
	ColormapUninstalled* = 0; ColormapInstalled* = 1;

	(* GrabPointer, GrabButton, GrabKeyboard, GrabKey Modes *)
	GrabModeSync* = 0;  GrabModeAsync* = 1;

	(* GrabPointer, GrabKeyboard reply status *)
	GrabSuccess* = 0; AlreadyGrabbed* = 1; GrabInvalidTime* = 2; GrabNotViewable* = 3; GrabFrozen* = 4;

	(* AllowEvents modes *)
	AsyncPointer* = 0; SyncPointer* = 1; ReplayPointer* = 2; AsyncKeyboard* = 3;
	SyncKeyboard* = 4; ReplayKeyboard* = 5; AsyncBoth* = 6; SyncBoth* = 7;

	(* Used in SetInputFocus, GetInputFocus *)
	RevertToNone* = None;  RevertToPointerRoot* = PointerRoot; RevertToParent* = 2;
  


(* ****************************************************************
						 ERROR CODES  
 **************************************************************** *)

CONST
	Success* =	 0; (* everything's okay *)
	BadRequest* = 1; (* bad request code *)
	BadValue* =	   2;	(* int parameter out of range *)
	BadWindow* = 3; (* parameter not a Window *)
	BadPixmap* =	4; (* parameter not a Pixmap *)
	BadAtom* = 5; (* parameter not an Atom *)
	BadCursor* = 6; (* parameter not a Cursor *)
	BadFont* = 7; (* parameter not a Font *)
	BadMatch* = 8; (* parameter mismatch *)
	BadDrawable* = 9; (* parameter not a Pixmap or Window *)
	BadAccess* = 10; (* depending on context:
				 - key/button already grabbed
				 - attempt to free an illegal 
				   cmap entry 
				- attempt to store into a read-only 
				   color map entry.
 				- attempt to modify the access control
				   list from other than the local host.
				*)
	BadAlloc* = 11; (* insufficient resources *)
	BadColor* = 12; (* no such colormap *)
	BadGC* = 13; (* parameter not a GC *)
	BadIDChoice* = 14; (* choice not in range or already used *)
	BadName* = 15; (* font or color name doesn't exist *)
	BadLength* = 16;	(* Request length incorrect *)
	BadImplementation* = 17;	(* server is defective *)

	FirstExtensionError* = 128;
	LastExtensionError* = 255;
  

(* ****************************************************************
						 WINDOW DEFINITIONS 
 **************************************************************** *)
	
	(*  Window classes used by CreateWindow *)
	(* Note that CopyFromParent is already defined as 0 above *)
	InputOutput* = 1; InputOnly* = 2;

	(* Window attributes for CreateWindow and ChangeWindowAttributes *)
	CWBackPixmap* = 0; CWBackPixel* = 1; CWBorderPixmap* = 2; CWBorderPixel* = 3;
	CWBitGravity* = 4; CWWinGravity* = 5; CWBackingStore* = 6;  CWBackingPlanes* = 7;
	CWBackingPixel* = 8; CWOverrideRedirect* = 9; CWSaveUnder* =10; CWEventMask* =11;
	CWDontPropagate* =12; CWColormap* = 13; CWCursor* =14;

	(* ConfigureWindow structure *)
	CWX* = 0;  CWY* = 1; CWWidth* = 2; CWHeight* = 3; CWBorderWidth* = 4;
	CWSibling* = 5; CWStackMode* = 6;

	(* Bit Gravity *)
	ForgetGravity* = 0; NorthWestGravity* = 1; NorthGravity* = 2; NorthEastGravity* = 3;
	WestGravity* = 4; CenterGravity *= 5; EastGravity* = 6; SouthWestGravity* = 7;
	SouthGravity* = 8; SouthEastGravity* = 9; StaticGravity* = 10;

	(* Window gravity + bit gravity above *)
	UnmapGravity* = 0;

	(* Used in CreateWindow for backing-store hint *)
	NotUseful* = 0; WhenMapped* = 1; Always*= 2;

	(* Used in GetWindowAttributes reply *)
	IsUnmapped* = 0; IsUnviewable* = 1; IsViewable*= 2;

	(* Used in ChangeSaveSet *)
	SetModeInsert* = 0; SetModeDelete* = 1;

	(* Used in ChangeCloseDownMode *)
	DestroyAll* = 0; RetainPermanent* = 1; RetainTemporary* = 2;

	(* Window stacking method (in configureWindow) *)
	Above* =  0; Below* =1; TopIf* = 2; BottomIf* = 3; Opposite* = 4;

	(* Circulation direction *)
	RaiseLowest* = 0; LowerHighest* = 1;

	(* Property modes *)
	PropModeReplace* = 0; PropModePrepend* = 1; PropModeAppend * = 2;

(* ****************************************************************
                            GRAPHICS DEFINITIONS  not translated yet
 **************************************************************** *)



(* **************************************************************** 
                                             FONTS 
************************************************************* *)
(* used in QueryFont -- draw direction *)
	FontLeftToRight* = 0;
	FontRightToLeft* = 1;
	FontChange* = 255;

(* **************************************************************** 
                                            IMAGING 
 ************************************************************** *)
(* ImageFormat -- PutImage, GetImage *)
	XYBitmap* = 0; (* depth 1, XYFormat *)
	XYPixmap* = 1; (* depth == drawable depth *)
	ZPixmap* = 2; (* depth == drawable depth *)


(* **************************************************************** 
                                         COLOR MAP STUFF
***************************************************************** *)
(* For CreateColormap *)
	AllocNone* = 0;	(* create map with no entries *)
	AllocAll* = 1;	(* allocate entire map writeable *)

(* Flags used in StoreNamedColor, StoreColors *)
	DoRed* = 0; DoGreen* = 1; DoBlue* = 2;

(* **************************************************************** 
                                           CURSOR STUFF  
 **************************************************************** *)
(* QueryBestSize Class *)
	CursorShape* = 0; (* largest size that can be displayed *)
	TileShape* = 1; (* size tiled fastest *)
	StippleShape* = 2; (* size stippled fastest *)

(* **************************************************************** 
                                      KEYBOARD/POINTER STUFF
 **************************************************************** *)

	AutoRepeatModeOff*= 0; AutoRepeatModeOn* = 1; AutoRepeatModeDefault* = 2;
	
	LedModeOff* = 0; LedModeOn* = 1;

	(* masks for ChangeKeyboardControl *)
	KBKeyClickPercent* =  0;  KBBellPercent* =  1; KBBellPitch* =  2; 	KBBellDuration* =  3;
	KBLed* =  4; KBLedMode* =  5; KBKey* =  6; KBAutoRepeatMode* =  7;
	
	MappingSuccess* = 0; MappingBusy* = 1; MappingFailed* = 2;

	MappingModifier* = 0; MappingKeyboard* = 1; MappingPointer* = 2;

(* ****************************************************************
                                              SCREEN SAVER STUFF 
 **************************************************************** *)
  DontPreferBlanking* = 0; PreferBlanking* = 1; DefaultBlanking* = 2;

  DisableScreenSaver* = 0; DisableScreenInterval* = 0;

  DontAllowExposures* = 0; AllowExposures* = 1; DefaultExposures* =2;

(* for ForceScreenSaver *)
  ScreenSaverReset* = 0; ScreenSaverActive* = 1;

(* ****************************************************************
                             HOSTS AND CONNECTIONS
 **************************************************************** *)

	(* for ChangeHosts *)
 	HostInsert* = 0; HostDelete* = 1;

	(* for ChangeAccessControl *)
	EnableAccess* = 1; DisableAccess* = 0;

	(* Display classes  used in opening the connection 
	  Note that the statically allocated ones are even numbered and the
	  dynamically changeable ones are odd numbered *)

	StaticGray* = 0; GrayScale* = 1; StaticColor* = 2; PseudoColor* = 3;
	TrueColor* = 4;  DirectColor* = 5;

	(* Byte order  used in imageByteOrder and bitmapBitOrder *)
	LSBFirst* = 0; MSBFirst* = 1;


(* ****************************************************************
						ATOMS  <X11/Xatom.h> 
 **************************************************************** *)
	
	(* Do not change!  Changing this file implies a protocol change! *)
	XA_PRIMARY * = 1;  XA_SECONDARY * = 2;  XA_ARC * = 3;  XA_ATOM * = 4;  XA_BITMAP * = 5;
	XA_CARDINAL * = 6;  XA_COLORMAP * = 7;  XA_CURSOR * = 8;  XA_CUT_BUFFER0 * = 9;
	XA_CUT_BUFFER1 * = 10;  XA_CUT_BUFFER2 * = 11;  XA_CUT_BUFFER3 * = 12;  XA_CUT_BUFFER4 * = 13;
	XA_CUT_BUFFER5 * = 14;  XA_CUT_BUFFER6 * = 15;  XA_CUT_BUFFER7 * = 16;  XA_DRAWABLE * = 17;
	XA_FONT * = 18;  XA_INTEGER * = 19;  XA_PIXMAP * = 20;  XA_POINT * = 21;  XA_RECTANGLE * = 22;
	XA_RESOURCE_MANAGER * = 23;  XA_RGB_COLOR_MAP * = 24;  XA_RGB_BEST_MAP * = 25;
	XA_RGB_BLUE_MAP * = 26;  XA_RGB_DEFAULT_MAP * = 27;  XA_RGB_GRAY_MAP * = 28;
	XA_RGB_GREEN_MAP * = 29;  XA_RGB_RED_MAP * = 30;  XA_STRING * = 31;  XA_VISUALID * = 32;
	XA_WINDOW * = 33;  XA_WM_COMMAND * = 34;  XA_WM_HINTS * = 35;  XA_WM_CLIENT_MACHINE * = 36;
	XA_WM_ICON_NAME * = 37;  XA_WM_ICON_SIZE * = 38;  XA_WM_NAME * = 39;  XA_WM_NORMAL_HINTS * = 40;
	XA_WM_SIZE_HINTS * = 41;  XA_WM_ZOOM_HINTS * = 42;  XA_MIN_SPACE * = 43;  XA_NORM_SPACE * = 44;
	XA_MAX_SPACE * = 45;  XA_END_SPACE * = 46;  XA_SUPERSCRIPT_X * = 47;  XA_SUPERSCRIPT_Y * = 48;
	XA_SUBSCRIPT_X * = 49;  XA_SUBSCRIPT_Y * = 50;  XA_UNDERLINE_POSITION * = 51;  XA_UNDERLINE_THICKNESS * = 52;
	XA_STRIKEOUT_ASCENT * = 53;  XA_STRIKEOUT_DESCENT * = 54;  XA_ITALIC_ANGLE * = 55;
	XA_X_HEIGHT * = 56;  XA_QUAD_WIDTH * = 57;  XA_WEIGHT * = 58;  XA_POINT_SIZE * = 59;
	XA_RESOLUTION * = 60;  XA_COPYRIGHT * = 61;  XA_NOTICE * = 62;  XA_FONT_NAME * = 63;
	XA_FAMILY_NAME * = 64;  XA_FULL_NAME * = 65;  XA_CAP_HEIGHT * = 66;  XA_WM_CLASS * = 67;
	XA_WM_TRANSIENT_FOR * = 68;  XA_LAST_PREDEFINED * = 68;


(* *********************************************** *)
	(* X11/Xlib.h*) 	
(* *********************************************** *)
TYPE	
	Bool* = LONGINT;
	Status* = LONGINT;

CONST 
	True* = 1; False* = 0;
	QueuedAlready* = 0; QueuedAfterReading* = 1; QueuedAfterFlush* = 2;
	
TYPE 
	XSetWindowAttributes* = RECORD
		backgroundPixmap*: Pixmap; (* background, None, or ParentRelative *)
		backgroundPixel*: LONGINT;(* background pixel *)
		borderPixmap*: Pixmap;    (* border of the window or CopyFromParent *)
		borderPixel*: LONGINT;(* border pixel value *)
		bitGravity*: LONGINT;         (* one of bit gravity values *)
		winGravity*: LONGINT;         (* one of the window gravity values *)
		backingStore*: LONGINT;       (* NotUseful, WhenMapped, Always *)
		backingPlanes*: LONGINT;(* planes to be preserved if possible *)
		backingPixel*: LONGINT;(* value to use in restoring planes *)
		saveUnder*: BOOLEAN;         (* should bits under be saved? (popups) *)
		eventMask*:  SET;         (* set of events that should be saved *)
		doNotPropagateMask*: SET;(* set of events that should not propagate *)
		overrideRedirect*: BOOLEAN;  (* boolean value for override_redirect *)
		colormap*: Colormap;       (* color map to be associated with window *)
		cursor*: Cursor ;           (* cursor to be displayed (or None) *)
	END ;
    	   
	XWindowAttributes* = RECORD
		x*, y*: LONGINT;			(* location of window *)
		width*, height*: LONGINT;		(* width and height of window *)
		border_width*: LONGINT;			(* border width of window *)
		depth*: LONGINT;			(* depth of window *)
		visual* : VisualPtr;			(* the associated visual structure *)
		root* : Window;				(* root of screen containing window *)
		class*: LONGINT;			(* InputOutput, InputOnly*)
		bitGravity*: LONGINT;			(* one of the bit gravity values *)
		winGravity*: LONGINT;			(* one of the window gravity values *)
		backingStore*: LONGINT;		(* NotUseful, WhenMapped, Always *)
		backingPlanes*: LONGINT;		(* planes to be preserved if possible *)
		backingPixel*: LONGINT;		(* value to be used when restoring planes *)
		saveUnder*: BOOLEAN;			(* boolean, should bits under be saved? *)
		colormap*: Colormap;			(* color map to be associated with window *)
		mapInstalled*: BOOLEAN;		(* boolean, is color map currently installed*)
		mapState*: LONGINT;		(* IsUnmapped, IsUnviewable, IsViewable *)
		allEventMasks*: SET;		(* set of events all people have interest in*)
		yourEventMask*: SET;		(* my event mask *)
		doNotPropagateMask*: SET;	(* set of events that should not propagate *)
		overrideRedirect*: BOOLEAN;		(* boolean value for override-redirect *)
		screen*: LONGINT; (*X11.Screen;*)			(* back pointer to correct screen *)
	END;

	(* Data structure for host setting; getting routines. *)
	TYPE XHostAddress* = RECORD
			family* : LONGINT;		(* for example FamilyInternet *)
			length* : LONGINT;		(* length of address, in bytes *)
			address*: ADDRESS;		(* pointer to where to find the bytes *)
		END;

	(* Data structure for ServerFamilyInterpreted addresses in host routines *)
	TYPE XServerInterpretedAddress* = RECORD
			typelength*: LONGINT;		(* length of type string, in bytes *)
			valuelength*: LONGINT;	(* length of value string, in bytes *)
			type*: ADDRESS;		(* pointer to where to find the type string *)
			value*: ADDRESS;		(* pointer to where to find the address *)
		END;


	(* Data structure for XReconfigureWindow *)
	TYPE XWindowChanges * = RECORD
			x*, y*: LONGINT;
			width*, height* : LONGINT;
	 	   	border_width*: LONGINT;
			sibling* : Window;
	 	   	stack_mode*: LONGINT;
		END;

	(* ******************************************** *)
	(* ******************************************** *)
	 (* Definitions of specific events. from  X11lib.h *)	 

	(*! 
		 This union is defined so Xlib can always use the same sized
 		event structure internally, to avoid memory fragmentation.
	
		In C,  XEvent type is union of all event types with size of 192 bytes , 
		In Oberon, other event fields are padded with chars to prevent memory leaks. 
		Use type casting to obtain real event type.	
 *)

	TYPE XEvent* = RECORD   (* size of this event is 192 bytes *)  
			typ* : LONGINT;		(* of event, must bot be changed; first element *)
			serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
			sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
			display* : DisplayPtr;	(* Display the event was read from *)
			window* : Window;	        (* "event" window it is reported relative to *)			
			pad*: ARRAY 172 OF CHAR;  (* 192-SIZEOF(previoustypes),  type cast to corresponding event type*)
	END;

	TYPE XAnyEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;(* Display the event was read from *)
		window* : Window;	(* window on which event was requested in event mask *)
	END;
	
	TYPE XKeyEvent * = RECORD 
		typ* : LONGINT;		(* of event *)
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;	        (* "event" window it is reported relative to *)
		root* : Window;	        (* root window that the event occurred on *)
		subwindow* : Window;	(* child window *)
		time* : Time;		(* milliseconds *)
		x*, y* : LONGINT;		(* pointer x, y coordinates in event window *)
		xRoot*, yRoot* : LONGINT;	(* coordinates relative to root *)
		state* : LONGINT(*word*);	(* key or button mask *)
		keycode* : LONGINT(*word*);	(* detail *)
		sameScreen* : BOOLEAN;	(* same screen flag *)
	END;
	TYPE XKeyPressedEvent* = XKeyEvent;
	TYPE XKeyReleasedEvent* = XKeyEvent;
	
	TYPE XButtonEvent * = RECORD 
		typ* : LONGINT;		(* of event *)
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;	        (* "event" window it is reported relative to *)
		root* : Window;	        (* root window that the event occurred on *)
		subwindow* : Window;	(* child window *)
		time* : Time;		(* milliseconds *)
		x*, y* : LONGINT;		(* pointer x, y coordinates in event window *)
		xRoot*, yRoot* : LONGINT;	(* coordinates relative to root *)
		state* : LONGINT(*word*);	(* key or button mask *)
		button* : LONGINT(*word*);	(* detail *)
		sameScreen* : BOOLEAN;	(* same screen flag *)
	END;
	TYPE XButtonPressedEvent* = XButtonEvent;
	TYPE XButtonReleasedEvent* = XButtonEvent;
	
	TYPE XMotionEvent * = RECORD 
		typ* : LONGINT;		(* of event *)
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;	        (* "event" window reported relative to *)
		root* : Window;	        (* root window that the event occurred on *)
		subwindow* : Window;	(* child window *)
		time* : Time;		(* milliseconds *)
		x*, y* : LONGINT;		(* pointer x, y coordinates in event window *)
		xRoot*, yRoot* : LONGINT;	(* coordinates relative to root *)
		state* : LONGINT(*word*);	(* key or button mask *)
		isHint* : CHAR;		(* detail *)
		sameScreen* : BOOLEAN;	(* same screen flag *)
	END;
	TYPE PointerMovedEvent* = XMotionEvent;
	
	TYPE  XCrossingEvent * = RECORD 
		typ* : LONGINT;		(* of event *)
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;	        (* "event" window reported relative to *)
		root* : Window;	        (* root window that the event occurred on *)
		subwindow* : Window;	(* child window *)
		time* : Time;		(* milliseconds *)
		x*, y* : LONGINT;		(* pointer x, y coordinates in event window *)
		xRoot*, yRoot* : LONGINT;	(* coordinates relative to root *)
		mode* : LONGINT;		(* NotifyNormal, NotifyGrab, NotifyUngrab *)
		detail* : LONGINT;
		(*
		* NotifyAncestor, NotifyVirtual, NotifyInferior,
		* NotifyNonlinear,NotifyNonlinearVirtual
		*)
		sameScreen* : BOOLEAN;	(* same screen flag *)
		focus* : BOOLEAN;		(* boolean focus *)
		state* : LONGINT(*word*);	(* key or button mask *)
	END;
	TYPE XEnterWindowEvent* = XCrossingEvent;
	TYPE XLeaveWindowEvent* = XCrossingEvent;
	
	TYPE XFocusChangeEvent * = RECORD 
		typ* : LONGINT;		(* FocusIn or FocusOut *)
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;		(* window of event *)
		mode* : LONGINT;		(* NotifyNormal, NotifyWhileGrabbed, NotifyGrab, NotifyUngrab *)
		detail* : LONGINT;
		(*
		* NotifyAncestor, NotifyVirtual, NotifyInferior,
		* NotifyNonlinear,NotifyNonlinearVirtual, NotifyPointer,
		* NotifyPointerRoot, NotifyDetailNone
		*)
	END;
	TYPE XFocusInEvent* = XFocusChangeEvent;
	TYPE XFocusOutEvent* = XFocusChangeEvent;
	
	(* generated on EnterWindow and FocusIn  when KeyMapState selected *)
	TYPE XKeymapEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;
		keyVector* : ARRAY 32 OF CHAR;
	END;
	
	TYPE XExposeEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;
		x*, y* : LONGINT;
		width*, height* : LONGINT;
		count* : LONGINT;		(* if non-zero, at least this many more *)
	END;
	
	TYPE XGraphicsExposeEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		drawable* : Drawable;
		x*, y* : LONGINT;
		width*, height* : LONGINT;
		count* : LONGINT;		(* if non-zero, at least this many more *)
		majorCode* : LONGINT;		(* core is CopyArea or CopyPlane *)
		minorCode* : LONGINT;		(* not defined in the core *)
	END;
	
	TYPE XNoExposeEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		drawable* : Drawable;
		majorCode* : LONGINT;		(* core is CopyArea or CopyPlane *)
		minorCode* : LONGINT;		(* not defined in the core *)
	END;
	
	TYPE XVisibilityEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;
		state* : LONGINT;		(* Visibility state *)
	END;
	
	TYPE XCreateWindowEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		parent* : Window;		(* parent of the window *)
		window* : Window;		(* window id of window created *)
		x*, y* : LONGINT;		(* window location *)
		width*, height* : LONGINT;	(* size of window *)
		borderWidth* : LONGINT;	(* border width *)
		overrideRedirect* : BOOLEAN;	(* creation should be overridden *)
	END;
	
	TYPE XDestroyWindowEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		event* : Window;
		window* : Window;
	END;
	
	TYPE XUnmapEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		event* : Window;
		window* : Window;
		fromConfigure* : BOOLEAN;
	END;
	
	TYPE XMapEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		event* : Window;
		window* : Window;
		overrideRedirect* : BOOLEAN;	(* boolean, is override set... *)
	END;
	
	TYPE XMapRequestEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		parent* : Window;
		window* : Window;
	END;
	
	TYPE XReparentEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		event* : Window;
		window* : Window;
		parent* : Window;
		x*, y* : LONGINT;
		overrideRedirect* : BOOLEAN;
	END;
	
	TYPE XConfigureEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		event* : Window;
		window* : Window;
		x*, y* : LONGINT;
		width*, height* : LONGINT;
		borderWidth* : LONGINT;
		above* : Window;
		overrideRedirect* : BOOLEAN;
	END;
	
	TYPE XGravityEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		event* : Window;
		window* : Window;
		x*, y* : LONGINT;
	END;
	
	TYPE XResizeRequestEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;
		width*, height* : LONGINT;
	END;
	
	TYPE XConfigureRequestEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		parent* : Window;
		window* : Window;
		x*, y* : LONGINT;
		width*, height* : LONGINT;
		border_width* : LONGINT;
		above* : Window;
		detail* : LONGINT;		(* Above, Below, TopIf, BottomIf, Opposite *)
		valueMask* : LONGINT(*unsigned*);
	END;
	
	TYPE XCirculateEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		event* : Window;
		window* : Window;
		place* : LONGINT;		(* PlaceOnTop, PlaceOnBottom *)
	END;
	
	TYPE XCirculateRequestEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		parent* : Window;
		window* : Window;
		place* : LONGINT;		(* PlaceOnTop, PlaceOnBottom *)
	END;
	
	TYPE XPropertyEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;
		atom* : Atom;
		time* : Time;
		state* : LONGINT;		(* NewValue, Deleted *)
	END;
	
	TYPE XSelectionClearEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;
		selection* : Atom;
		time* : Time;
	END;
	
	TYPE XSelectionRequestEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		owner* : Window;
		requestor* : Window;
		selection* : Atom;
		target* : Atom;
		property* : Atom;
		time* : Time;
	END;
	
	TYPE XSelectionEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		requestor* : Window;
		selection* : Atom;
		target* : Atom;
		property* : Atom;		(* ATOM or None *)
		time* : Time;
	END;
	
	TYPE Data40 * = ARRAY 40 OF CHAR; (* max of these is 40 bytes*)
		 Data40b* = ARRAY 20 OF CHAR;
		 Data40s* = ARRAY 10 OF INTEGER;
		 Data40l* = ARRAY 5 OF HUGEINT;
	TYPE XClientMessageEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;
		messageType* : Atom;
		format* : LONGINT;
		data*: Data40;
			(* any of these, union 
			b* : ARRAY 20 OF CHAR;
			s* : ARRAY 10 OF INTEGER;
			l* : ARRAY 5 OF LONGINT;
			*)
	END; 
	
	TYPE XMappingEvent * = RECORD 
		typ* : LONGINT;
		serial* : LONGINT(*unsigned*);	(* # of last request processed by server *)
		sendEvent* : BOOLEAN;	(* true if this came from a SendEvent request *)
		display* : DisplayPtr;	(* Display the event was read from *)
		window* : Window;		(* unused *)
		request* : LONGINT;		(* one of MappingModifier, MappingKeyboard, MappingPointer *)
		firstKeycode* : LONGINT;	(* first keycode *)
		count* : LONGINT;		(* defines range of change w. firstKeycode*)
	END;
	
	TYPE XErrorEvent * = RECORD 
		typ* : LONGINT;
		display* : DisplayPtr;	(* Display the event was read from *)
		resourceid* : XID;		(* resource id *)
		serial* : LONGINT(*unsigned*);	(* serial number of failed request *)
		errorCode* : CHAR(*unsigned*);	(* error code of failed request *)
		requestCode* : CHAR(*unsigned*);	(* Major op-code of failed request *)
		minorCode* : CHAR(*unsigned*);	(* Minor op-code of failed request *)
	END;
	
	
	(* ************************************************************** *)	 
	(*  GenericEvent.  This event is the standard event for all newer extensions. *)
	
	TYPE XGenericEvent * = RECORD 
		typ* : LONGINT;         (* of event. Always GenericEvent *)
		serial* : LONGINT(*unsigned*);       (* # of last request processed *)
		sendEvent* : BOOLEAN;   (* true if from SendEvent request *)
		display* : DisplayPtr;     (* Display the event was read from *)
		extension* : LONGINT;    (* major opcode of extension that caused the event *)
		evtype* : LONGINT;       (* actual event type. *)
	END;
	
	TYPE XGenericEventCookie * = RECORD 
		typ* : LONGINT;         (* of event. Always GenericEvent *)
		serial* : LONGINT(*unsigned*);       (* # of last request processed *)
		sendEvent* : BOOLEAN;   (* true if from SendEvent request *)
		display* : DisplayPtr;     (* Display the event was read from *)
		extension* : LONGINT;    (* major opcode of extension that caused the event *)
		evtype* : LONGINT;       (* actual event type. *)
		cookie* : LONGINT(*word*);
		data* : ADDRESS;
	END;




CONST 
(* Action for EWMH client messages *)
	NET_WM_STATE_REMOVE* = 0;
	NET_WM_STATE_ADD* =1;
	NET_WM_STATE_TOGGLE* = 2;
VAR
	xlib: LONGINT;
	
	OpenDisplay- : PROCEDURE { C } (CONST name: ARRAY OF CHAR): DisplayPtr;
	CloseDisplay- : PROCEDURE { C } (display:DisplayPtr): LONGINT;
	CreateWindow- : PROCEDURE { C } (display: DisplayPtr; parent: Window;  x,  y: LONGINT;  width, height, border_width, depth, class: LONGINT; visual: VisualPtr; valuemask: SET;  attributes: ADDRESS (*XSetWindowAttributes*) ): Window;	
	DestroyWindow-: PROCEDURE { C }(display:DisplayPtr; win: Window): LONGINT;
	DisplayWidthMM-: PROCEDURE {C} ( d: DisplayPtr;  screen: LONGINT ): LONGINT;
	FreeColormap- : PROCEDURE { C } (display: DisplayPtr;  colormap: Colormap);
	XGetAtomName- : PROCEDURE { C } (display: DisplayPtr; atom: Atom): LONGINT;
	GetWindowAttributes- : PROCEDURE { C } (display: DisplayPtr; win: Window; attr: ADDRESS): LONGINT;
	
	GetWindowProperty-: PROCEDURE {C} ( d: DisplayPtr;  w: Window;  property: Atom;
											offset, length: LONGINT;  delete: Bool;  reqtype: Atom;  VAR typ: Atom;
											VAR format, nitems, bytesafter, prop: LONGINT ): LONGINT;

	GrabKeyboard-: PROCEDURE {C} (display: DisplayPtr; grabwindow: Window; ownerevents: Bool; pointermode, keyboardmode: LONGINT; time: Time): LONGINT;
	GrabPointer-: PROCEDURE {C} (display:DisplayPtr; grabwindow: Window; ownerevents: Bool; eventmask: SET; pointermode, keyboardmode: LONGINT; confineto: Window; cursor: Cursor; time: Time): LONGINT;
	InternAtom-: PROCEDURE {C} ( display: DisplayPtr;  CONST name: ARRAY OF CHAR;  onlyifexists: Bool ): Atom;
	LookupKeysym- : PROCEDURE { C } ( CONST event: XKeyEvent; index: LONGINT): KeySym;
	LookupString-:	PROCEDURE {C} ( VAR event: XKeyEvent;  VAR buf: Buffer;  bufsize: LONGINT;  VAR keysym: KeySym; VAR cstat: ComposeStatus ): LONGINT;
	MapWindow- : PROCEDURE { C } (display: DisplayPtr; win: Window);
	NextEvent-: PROCEDURE {C} ( d: DisplayPtr;  VAR event: XEvent );
	Pending- : PROCEDURE { C } (display: DisplayPtr): LONGINT;
	RaiseWindow-: PROCEDURE { C }(display: DisplayPtr; win: Window);
	RootWindow-: PROCEDURE { C }(display: DisplayPtr; screen: LONGINT): Window;	
	SendEvent-: PROCEDURE {C} ( d: DisplayPtr;  w: Window;  propagate: Bool;	eventmask: SET; event: ADDRESS ): Bool;

	SetStandardProperties-: PROCEDURE {C} (display: DisplayPtr; w: Window; CONST winName: ARRAY OF CHAR; 
							CONST iconName: ARRAY OF CHAR; iconpixmap: Pixmap;  argv: POINTER TO ARRAY OF CHAR; argc: LONGINT; hints: ADDRESS);
	SetWMProtocols-: PROCEDURE { C } (display: DisplayPtr; win: Window; protoclos: ADDRESS (* ARRAY OF Atoms *); count: LONGINT): LONGINT;
	StoreName- : PROCEDURE { C } (display: DisplayPtr; win: Window; CONST s: ARRAY OF CHAR): LONGINT;
	UnmapWindow- : PROCEDURE { C } (display: DisplayPtr; win: Window);	

	WarpPointer- : PROCEDURE {C} (display: DisplayPtr; srcwin, destwin: Window; srcx, srcy: LONGINT; srcwidth, srcheight: LONGINT; destx, desty: LONGINT);

	(* cut and paste *)
	SendSelection-:	 PROCEDURE {C } ( VAR event: XSelectionRequestEvent );
	ReceiveSelection-:  PROCEDURE { C } ( VAR event: XSelectionEvent );
	ClearSelection-: PROCEDURE { C } ;

			
	(* wrapper procedure for XGetAtomName  *)
	PROCEDURE GetAtomName*(display: DisplayPtr; atom: Atom): PChar;
	VAR adr, adr1: LONGINT;
		name: PChar;
		i, cnt: LONGINT;
		ch: CHAR;
	BEGIN
		adr := XGetAtomName(display, atom);
		cnt := 0;
		adr1 := adr;
		(* count # of characters *)
		SYSTEM.GET(adr1, ch); 
		WHILE ch # 0X DO
			INC(cnt); INC(adr1);
			SYSTEM.GET(adr1, ch);
		END;

		IF cnt = 0 THEN X11.Free(adr); RETURN NIL; END;
		
		(* copy characters to name *)
		adr1 := adr;
		NEW(name, cnt+1);
		FOR i :=0 TO cnt-1 DO
			SYSTEM.GET(adr1, ch); name[i] :=ch; INC(adr1);
		END;

		X11.Free(adr); (* free resulting string *)
		RETURN name;
	END GetAtomName;

	
PROCEDURE LoadX11Functions;
BEGIN {EXCLUSIVE}

		xlib := Unix.Dlopen( Unix.libX11name, 2 );
		Unix.Dlsym( xlib, "XOpenDisplay", SYSTEM.VAL( ADDRESS, OpenDisplay));
		Unix.Dlsym( xlib, "XCloseDisplay", SYSTEM.VAL( ADDRESS, CloseDisplay));
		Unix.Dlsym( xlib, "XCreateWindow", SYSTEM.VAL( ADDRESS, CreateWindow));
		Unix.Dlsym( xlib, "XDestroyWindow", SYSTEM.VAL( ADDRESS, DestroyWindow));
		Unix.Dlsym( xlib, "XDisplayWidthMM", SYSTEM.VAL( ADDRESS, DisplayWidthMM));
		Unix.Dlsym( xlib, "XFreeColormap", SYSTEM.VAL( ADDRESS, FreeColormap));
		Unix.Dlsym( xlib, "XGetAtomName", SYSTEM.VAL( ADDRESS, XGetAtomName));
		Unix.Dlsym( xlib, "XGetWindowAttributes", SYSTEM.VAL( ADDRESS, GetWindowAttributes));
		Unix.Dlsym( xlib, "XGetWindowProperty", SYSTEM.VAL( ADDRESS, GetWindowProperty));
		Unix.Dlsym( xlib, "XGrabKeyboard", SYSTEM.VAL( ADDRESS, GrabKeyboard));
		Unix.Dlsym( xlib, "XGrabPointer", SYSTEM.VAL( ADDRESS, GrabPointer));
		Unix.Dlsym( xlib, "XInternAtom", SYSTEM.VAL( ADDRESS, InternAtom));
		Unix.Dlsym( xlib, "XLookupKeysym", SYSTEM.VAL( ADDRESS, LookupKeysym));
		Unix.Dlsym( xlib, "XLookupString", SYSTEM.VAL( ADDRESS, LookupString));
		Unix.Dlsym( xlib, "XMapWindow", SYSTEM.VAL( ADDRESS, MapWindow));
		Unix.Dlsym( xlib, "XNextEvent", SYSTEM.VAL( ADDRESS, NextEvent));
		Unix.Dlsym( xlib, "XUnmapWindow", SYSTEM.VAL( ADDRESS, UnmapWindow));
		Unix.Dlsym( xlib, "XPending", SYSTEM.VAL( ADDRESS, Pending));
		Unix.Dlsym( xlib, "XRaiseWindow", SYSTEM.VAL( ADDRESS, RaiseWindow));
		Unix.Dlsym( xlib, "XRootWindow", SYSTEM.VAL( ADDRESS, RootWindow));
		Unix.Dlsym( xlib, "XSendEvent", SYSTEM.VAL( ADDRESS, SendEvent));
		Unix.Dlsym( xlib, "XSetStandardProperties", SYSTEM.VAL( ADDRESS, SetStandardProperties));
		Unix.Dlsym( xlib, "XSetWMProtocols", SYSTEM.VAL( ADDRESS, SetWMProtocols));
		Unix.Dlsym( xlib, "XStoreName", SYSTEM.VAL( ADDRESS, StoreName));
		Unix.Dlsym( xlib, "XWarpPointer", SYSTEM.VAL( ADDRESS, WarpPointer));
		
END LoadX11Functions;

PROCEDURE OnClose;
BEGIN {EXCLUSIVE}
	IF xlib # 0 THEN
     		Unix.Dlclose(xlib);
       	Trace.String(Unix.libX11name); Trace.StringLn(' unloaded.');
	END;
END OnClose;

	
BEGIN
	LoadX11Functions;
	Modules.InstallTermHandler(OnClose) ;
END X11Api.
