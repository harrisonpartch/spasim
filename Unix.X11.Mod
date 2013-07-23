(* ETH Oberon, Copyright 2000 ETH Zürich Institut für Computersysteme, ETH Zentrum, CH-8092 Zürich.
Refer to the general ETH Oberon System license contract available at: http://www.oberon.ethz.ch/ *)

MODULE X11;   (* 1993-95 / rc *)

(* Oberon interface to X Window System Version 11 *)

(*	1998.06.24	g.f.	Linux PPC version	*)
(*	1999.04.03	g.f.	support for Threads added	*)
(*	1999.11.03	g,f,	Linux x86 version	 *)
(*	2001.01.05	g.f.	[C] - flag for new ompiler *)
(*	2001.08.04	g.f.	made this module a pure interface to xlib,
									  separated low level Display fumctionality into new module Displays  *)
(*	2006.07.31	g.f.	X11Ext added *)

IMPORT S := SYSTEM, Trace, Machine, Unix, Modules;

TYPE
	Address = S.ADDRESS;

	Pixmap* = Address;

	Pattern* = Address (* = PatternPtr *) ;
	PatternPtr* = POINTER TO PatternDesc;
	PatternDesc* = RECORD
				x*, y*: LONGINT;
				w*, h*: INTEGER;
				pixmap*: Pixmap
			END;

	MetricDesc* = RECORD
				dx*, x*, y*, filler: INTEGER;
				p*: PatternDesc
			END;

	Font* = POINTER TO Bytes;
	Bytes* = RECORD
				metrics*: ARRAY 256 OF MetricDesc;
				xid*: LONGINT
			END;

CONST
	BufferSize* = 512;

TYPE
	Buffer* = ARRAY BufferSize OF CHAR;
	ComposeStatus* = RECORD
					 	opaque: ARRAY 6 OF LONGINT
					   END;
	Modifiers* = ARRAY 8 OF LONGINT;

	DisplayPtr* = Address;
	Window* = LONGINT;
	Drawable* = LONGINT;
	GC* = LONGINT;
	Bool* = LONGINT;
	Colormap* = LONGINT;
	Time* = LONGINT;
	Atom* = LONGINT;

	VisualID* = LONGINT;
	Visual* = RECORD
				extData*: Address;
				visualid*: VisualID;
				class*: LONGINT;
				redMask*, greenMask*, blueMask*: LONGINT;
				bitsPerRgb*, mapEntries*: LONGINT
			END;
	VisualPtr* = POINTER TO Visual;
	VisualInfo* = RECORD
				visual*{UNTRACED}:  VisualPtr;
				visualID*: VisualID;
				screen*, depth*, class*: LONGINT;
				redmask*, greenmask*, bluemask*: LONGINT;
				colomapsize*, bitsperrgb*: LONGINT
			END;
	Color* = RECORD
				pixel*: LONGINT;
				red*, green*, blue*: INTEGER;
				flags*, pad*: CHAR
			END;
	Point* = RECORD
				x*, y*: INTEGER
			END;
	Rectangle* = RECORD
				x*, y*, w*, h*: INTEGER
			END;
	Cursor* = LONGINT;  KeySym* = LONGINT;  KeyCode* = LONGINT;
	Event* = RECORD
				typ*, serial*: LONGINT;
				sendEvent*: Bool;
				display*: DisplayPtr;
				window*, root*, subwindow*: Window;
				time*, x*, y*, xRoot*, yRoot*, state*, button*: LONGINT;
				sameScreen*, focus*: Bool;
				state2*: LONGINT;
				pad*: ARRAY 32 OF LONGINT
			END;
	SelectionEvent* = RECORD
				typ*, serial*: LONGINT;
				sendEvent*: Bool;
				display*: DisplayPtr;
				requestor*: Window;
				selection*, target*, property*: Atom;
				time*: Time
			END;
	SelectionRequestEvent* = RECORD
				typ*, serial*: LONGINT;
				sendEvent*: Bool;
				display*: DisplayPtr;
				owner*, requestor*: Window;
				selection*, target*, property*: Atom;
				time*: Time
			END;
	ExposeEvent* = RECORD
				typ*, serial*: LONGINT;
				sendEvent*: Bool;
				display*: DisplayPtr;
				window*: Window;
				x*, y*, width*, height*, count*: LONGINT;
			END;
	GraphicsExposeEvent* = RECORD
				typ*, serial*: LONGINT;
				sendEvent*: Bool;
				display*: DisplayPtr;
				drawable*: Drawable;
				x*, y*, width*, height*, count*, majorCode*, minorCode*: LONGINT;
			END;
	ButtonEvent* = RECORD
				typ*, serial*: LONGINT;
				sendEvent*: Bool;
				display*: DisplayPtr;
				window*, root*, subwindow*: Window;
				time*: Time;
				x*, y*, xRoot*, yRoot*, state*, button: LONGINT;
				sameScreen: Bool
			END;
	KeyEvent* = RECORD
				typ*, serial*: LONGINT;
				sendEvent*: Bool;
				display*: DisplayPtr;
				window*, root*, subwindow*: Window;
				time*: Time;
				x*, y*, xRoot*, yRoot*, state*, keycode*: LONGINT;
				sameScreen: Bool
			END;

	Image* = Address;
	ImagePtr* = POINTER TO ImageDesc;
	ImageDesc* = RECORD
				width*, height*: LONGINT;
				xoffset*, format*, data*: LONGINT;
				byteOrder*, bitmapUnit*, bitmapBitOrder*: LONGINT;
				bitmapPad*, depth*, bytesPerLine*, bitsPerPixel*: LONGINT;
				redmask*, greenmask*, bluemask*: LONGINT;
				obdata*, createImage*, destroyImage*, getPixel*, putPixel*, subImage*, addPixel*: LONGINT
			END;
	ErrorEvent* = RECORD
				typ*: LONGINT;
				display*: DisplayPtr;
				resourceid*, serial*: LONGINT;
				errorCode*, requestCode*, minorCode*: CHAR
			END;
	ErrorEventPtr* = POINTER TO ErrorEvent;
	ErrorHandler* = PROCEDURE ( d: DisplayPtr;  err: ErrorEventPtr; p3, p4: LONGINT ): LONGINT;
	IOErrorHandler = PROCEDURE ( d: DisplayPtr; p2, p3, p4: LONGINT ): LONGINT;

CONST
	(* X constants: <X11/X.h> *)
	False* = 0;  True* = 1;  None* = 0;
	(* line styles: *)
	LineSolid* = 0;  LineOnOffDash* = 1;  LineDoubleDash* = 2;
	(* cap styles: *)
	CapNotLast* = 0;  CapButt* = 1;  CapRound* = 2;  CapProjecting* = 3;
	(* join styles: *)
	JoinMiter* = 0;  JoinRound* = 1;  JoinBevel* = 2;
	(* fill styles: *)
	FillSolid* = 0;  FillTiled* = 1;  FillStippled* = 2;  FillOpaqueStippled* = 3;
	(* functions: *)
	GXand* = 1;  GXcopy* = 3;  GXxor* = 6;  GXor* = 7;  GXequiv* = 9;
	(* color flags: *)
	DoRed* = 1;  DoGreen* = 2;  DoBlue* = 4;  DoAll* = DoRed + DoGreen + DoBlue;
	(* for CreateColormap : *)
	AllocNone* = 0;  AllocAll* = 1;
	(* QueryBestSize Class: *)
	CursorShape* = 0;  TileShape* = 1;  StippleShape* = 2;
	(* visual classes: *)
	StaticGray* = 0;  GrayScale* = 1;  StaticColor* = 2;  PseudoColor* = 3;  TrueColor* = 4;  DirectColor* = 5;
	(* arc modes: *)
	ArcChord* = 0;  ArcPieSlice* = 1;
	(* polygone shape: *)
	Complex* = 0;  Nonconvex* = 1;  Convex* = 2;
	(* clip odering and origin: *)
	CoordModeOrigin* = 0;  CoordModePrevious* = 1;  Unsorted* = 0;  YSorted* = 1;  YXSorted* = 2;
	YXBanded* = 3;
	(* property modes: *)
	PropModeReplace* = 0;
	(* events types: *)
	KeyPress* = 2;  KeyRelease* = 3;  ButtonPress* = 4;  ButtonRelease* = 5;  MotionNotify* = 6;
	FocusIn* = 9;  FocusOut* = 10;
	Expose* = 12;  GraphicsExpose* = 13;  NoExpose* = 14;  UnmapNotify* = 18;
	MapNotify* = 19;  PropertyNotify* = 28;  SelectionClear* = 29;  SelectionRequest* = 30;
	SelectionNotify* = 31;  ClientMessage* = 33;  MappingNotify* = 34;
	(* event masks: *)
	KeyPressMask* = 1H;  KeyReleaseMask* = 2H;  ButtonPressMask* = 4H;  ButtonReleaseMask* = 8H;
	PointerMotionMask* = 40H;  PointerMotionHintMask* = 80H;  ButtonMotionMask* = 2000H;
	ExposureMask* = 8000H;  StructureNotifyMask* = 20000H;  FocusChangeMask* = 200000H;
	PropertyChangeMask* = 400000H;  OwnerGrabButtonMask* = 1000000H;
	(* event modes:  <X11/Xlib.h> *)
	QueuedAlready* = 0;  QueuedAfterReading* = 1;  QueuedAfterFlush* = 2;
	(* focus revert modes: <X11/X.h> *)
	RevertToParent* = 2;
	(* buttons: *)
	Button1* = 1;  Button2* = 2;  Button3* = 3;
	Button1Mask* = 100H;  Button2Mask* = 200H;  Button3Mask* = 400H;
	(* image format: *)
	XYBitmap* = 0;  XYPixmap* = 1;  ZPixmap* = 2;
	(* special keys: <X11/keysymdef.h> *)
	(* cursor shapes: <X11/cursorfont.h> *)
	XCleftptr* = 132;
	(* atoms: <X11/Xatom.h> *)
	XAPRIMARY* = 1;  XASTRING* = 31;

VAR
	ErrorText*: Buffer;
	ErrorFlag*: BOOLEAN;  lastEventTime*: Time;  ioErrors: INTEGER;

	(* cut and paste *)
	SendSelection*:			 PROCEDURE ( VAR event: SelectionRequestEvent );
	ReceiveSelection*:		 PROCEDURE ( VAR event: SelectionEvent );
	ClearSelection*:			 PROCEDURE;

VAR
	(* Xlib calls: *)
	OpenDisplay-:			PROCEDURE {C} ( name: Address ): DisplayPtr;
	DefaultScreen-:			PROCEDURE {C} ( d: DisplayPtr ): LONGINT;
	DisplayWidth-,
	DisplayHeight-,
	DisplayHeightMM-,
	DefaultDepth-,
	DisplayCells-,
	DisplayPlanes-,
	BlackPixel-,
	WhitePixel-:			PROCEDURE {C} ( d: DisplayPtr;  screen: LONGINT ): LONGINT;
	DefaultVisual-:			PROCEDURE {C} ( d: DisplayPtr;  screen: LONGINT ): LONGINT;
	DefaultColormap-:		PROCEDURE {C} ( d: DisplayPtr;  screen: LONGINT ): Colormap;
	DefaultRootWindow-:
							PROCEDURE {C} ( d: DisplayPtr ): Window;
	CreateSimpleWindow-:
							PROCEDURE {C} ( d: DisplayPtr;  parent: Window;
											x, y, width, height, borderWidth, border, background: LONGINT ): Window;
	TranslateCoordinates-:
							PROCEDURE {C} ( d: DisplayPtr;  sw, dw: Window;  srcx, srcy: LONGINT;
											VAR dstx, dsty: LONGINT;  VAR child: Window );
	MoveResizeWindow-:
							PROCEDURE {C} ( d: DisplayPtr;  w: Window;  x, y, width, height: LONGINT );
	StoreName-,
	SetIconName-:			PROCEDURE {C} ( d: DisplayPtr;  w: Window;  name: LONGINT );
	SetCommand-:			PROCEDURE {C} ( d: DisplayPtr;  w: Window;  argv, argc: LONGINT );
	MapRaised-,
	LowerWindow-,
	ClearWindow-:			PROCEDURE {C} ( d: DisplayPtr;  w: Window );
	Sync-:					PROCEDURE {C} ( d: DisplayPtr;  discard: LONGINT );
	Flush-:					PROCEDURE {C} ( d: DisplayPtr );
	StoreColor-:			PROCEDURE {C} ( d: DisplayPtr;  cmap: Colormap;  color: LONGINT );
	CreateBitmapFromData-:
							PROCEDURE {C} ( d: DisplayPtr;  drawable: Drawable;  data: Address;
											width, height: LONGINT ): Pixmap;
	CopyArea-:				PROCEDURE {C} ( d: DisplayPtr;  src, dest: Drawable;  gc: GC;
											srcX, srcY, width, height, destX, destY: LONGINT );
	CopyPlane-:				PROCEDURE {C} ( d: DisplayPtr;  src, dest: Drawable;  gc: GC;
											srcX, srcY, width, height, destX, destY, plane: LONGINT );
	SetStipple-:				PROCEDURE {C} ( d: DisplayPtr;  gc: GC;  stipple: Pixmap );
	SetTSOrigin-:			PROCEDURE {C} ( d: DisplayPtr;  gc: GC;  tsxorigin, tsyorigin: LONGINT );
	DrawPoint-:			PROCEDURE {C} ( d: DisplayPtr;  w: Drawable;  gc: GC;  x, y: LONGINT );
	FillRectangle-:			PROCEDURE {C} ( d: DisplayPtr;  w: Drawable;  gc: GC;  x, y, width, height: LONGINT );
	DrawString-:			PROCEDURE {C} ( d: DisplayPtr;  w: Drawable;  gc: GC;  x, y, string, length: LONGINT );
	CreateGC-:				PROCEDURE {C} ( d: DisplayPtr;  drawable: Drawable;  valueMask, values: LONGINT ): GC;
	SetForeground-,
	SetBackground-,
	SetFunction-,
	SetFont-,
	SetFillStyle-:			PROCEDURE {C} ( d: DisplayPtr;  gc: GC;  arg: LONGINT );
	SetPlaneMask-:			PROCEDURE {C} ( d: DisplayPtr;  gc: GC;  mask: LONGINT );
	SetGraphicsExposures-:
							PROCEDURE {C} ( d: DisplayPtr;  gc: GC;  graphicsExposures: Bool );
	SetLineAttributes-:		PROCEDURE {C} ( d: DisplayPtr;  gc: GC;  lineWidth, lineStyle, capStyle, joinStyle: LONGINT );
	AllocColorCells-:		PROCEDURE {C} ( d: DisplayPtr;  cmap: Colormap;  contig: Bool;  planeMasks: LONGINT;
											nplanes: LONGINT;  pixels: LONGINT;  ncolors: LONGINT ): LONGINT;
	SetWindowBackground-:
							PROCEDURE {C} ( d: DisplayPtr;  w: Window;  pixel: LONGINT );
	CreateFontCursor-:		PROCEDURE {C} ( d: DisplayPtr;  shape: LONGINT ): Cursor;
	CreatePixmapCursor-:	PROCEDURE {C} ( d: DisplayPtr;  csource, cmask: Pixmap;
											cfore, cback, xhot, yhot: LONGINT ): Cursor;
	RecolorCursor-:			PROCEDURE {C} ( d: DisplayPtr;  curs: Cursor;  cfore, cback: LONGINT );
	DefineCursor-:			PROCEDURE {C} ( d: DisplayPtr;  w: Window;  curs: Cursor );
	DrawLine-:				PROCEDURE {C} ( d: DisplayPtr;  w: Window;  gc: GC;  x1, y1, x2, y2: LONGINT );
	SetArcMode-:			PROCEDURE {C} ( d: DisplayPtr;  gc: GC;  arcmode: LONGINT );
	DrawArc-, FillArc-:		PROCEDURE {C} ( d: DisplayPtr;  w: Window;  gc: GC;
											x, y, width, height, angle1, angle2: LONGINT );
	FillPolygon-:			PROCEDURE {C} ( d: DisplayPtr;  w: Window;  gc: GC;
											points, npoints, shape, mode: LONGINT );
	SetClipMask-:			PROCEDURE {C} ( d: DisplayPtr;  gc: GC;  clipMask: Pixmap );
	SetClipRectangles-:		PROCEDURE {C} ( d: DisplayPtr;  gc: GC;
											clipxorigin, clipyorigin, rectangles, n, ordering: LONGINT );
	ListFonts-:				PROCEDURE {C} ( d: DisplayPtr;  pattern, maxnames: LONGINT;
											VAR count: LONGINT ): LONGINT;
	FreeFontNames-:		PROCEDURE {C} ( list: LONGINT );
	LoadFont-:				PROCEDURE {C} ( d: DisplayPtr;  name: Address ): LONGINT;
	SelectInput-:			PROCEDURE {C} ( d: DisplayPtr;  w: Window;  eventMask: LONGINT );
	NextEvent-:			PROCEDURE {C} ( d: DisplayPtr;  VAR event: Event );
	EventsQueued-:			PROCEDURE {C} ( d: DisplayPtr;  mode: LONGINT ): LONGINT;
	SetInputFocus-:			PROCEDURE {C} ( d: DisplayPtr;  focus: Window;  revertTo: LONGINT;  time: LONGINT );
	LookupString-:			PROCEDURE {C} ( VAR event: Event;  VAR buf: Buffer;  bufsize: LONGINT;  VAR keysym: KeySym;
											VAR cstat: ComposeStatus ): LONGINT;
	QueryPointer-:			PROCEDURE {C} ( d: DisplayPtr;  w: Window;  VAR rw, cw: Window;
											VAR xr, yr, xw, yw: LONGINT; VAR keysButtons: SET );
	RefreshKeyboardMapping-:
							PROCEDURE {C} ( event: LONGINT );
	Bell-:					PROCEDURE {C} ( d: DisplayPtr;  percent: LONGINT );
	RebindKeysym-:			PROCEDURE {C} ( d: DisplayPtr;  reboundsym: KeySym;  VAR modlist: Modifiers;
											modlength: LONGINT;  newstring: Address;  newlength: LONGINT );
	StringToKeysym-:		PROCEDURE {C} ( string: Address ): KeySym;
	CopyColormapAndFree-:
							PROCEDURE {C} ( d: DisplayPtr;  cmap: Colormap ): Colormap;
	CreateColormap-:		PROCEDURE {C} ( d: DisplayPtr;  w: Window;  vis: VisualPtr; alloc: LONGINT ): Colormap;
	MatchVisualInfo-:		PROCEDURE {C} ( d: DisplayPtr;  screen, depth, class: LONGINT; VAR vinfo: VisualInfo ): LONGINT;
	SetWindowColormap-:
							PROCEDURE {C} ( d: DisplayPtr;  w: Window;  cmap: Colormap );
	QueryBestSize-:			PROCEDURE {C} ( d: DisplayPtr;  class: LONGINT;
											screen: Drawable;  width, height: LONGINT;  VAR w, h: LONGINT );
	CreatePixmap-:			PROCEDURE {C} ( d: DisplayPtr;  drawable: Drawable;
											width, height, depth: LONGINT ): Pixmap;
	FreePixmap-:			PROCEDURE {C} ( d: DisplayPtr;  pixmap: Pixmap );
	CreateImage-:			PROCEDURE {C} ( d: DisplayPtr;  visual: VisualPtr;  depth, format, offset, data, width, height,
											bitmapPad, bytesPerLine: LONGINT ): Image;
	DestroyImage-:			PROCEDURE {C} ( image: Image );
	SubImage-:				PROCEDURE {C} ( image: Image;  x, y, width, height: LONGINT ): Image;
	GetImage-:				PROCEDURE {C} ( d: DisplayPtr;  drawable: Drawable;
											x, y, width, height, planeMask, format: LONGINT ): Image;
	GetSubImage-:			PROCEDURE {C} ( d: DisplayPtr;  drawable: Drawable;
												x, y, width, height, planeMask, format: LONGINT;  dstImage: Image;
											dstX, dstY: LONGINT ): Image;
	PutImage-:				PROCEDURE {C} ( d: DisplayPtr;  drawable: Drawable;  gc: GC;  image: Image;
											srcX, srcY, dstX, dstY, width, height: LONGINT );
	PutPixel-:				PROCEDURE {C} ( image: Image;  x, y, pixel: LONGINT ): LONGINT;
	GetPixel-:				PROCEDURE {C} ( image: Image;  x, y: LONGINT ): LONGINT;
	AddPixel-:				PROCEDURE {C} ( image: Image;  value: LONGINT );
	Free-:					PROCEDURE {C} ( data: LONGINT );
	(*SetErrorHandler-:	procedure {C} ( handler: ErrorHandler );*)
	GetErrorText-:			PROCEDURE {C} ( d: DisplayPtr;  errcode: LONGINT; VAR buf: Buffer; length: LONGINT );
	StoreBytes-:			PROCEDURE {C} ( d: DisplayPtr;  bytes, nbytes: LONGINT );
	FetchBytes-:			PROCEDURE {C} ( d: DisplayPtr;  VAR nbytes: LONGINT ): LONGINT;
	SetSelectionOwner-:	PROCEDURE {C} ( d: DisplayPtr;  selection: Atom;  owner: Window;  time: Time );
	GetSelectionOwner-:	PROCEDURE {C} ( d: DisplayPtr;  selection: Atom ): Window;
	InternAtom-:			PROCEDURE {C} ( d: DisplayPtr;  name: LONGINT;  onlyifexists: Bool ): Atom;
	SendEvent-:			PROCEDURE {C} ( d: DisplayPtr;  w: Window;  propagate: Bool;
											eventmask, event: LONGINT );
	ConvertSelection-:		PROCEDURE {C} ( d: DisplayPtr;  selection, target, property: Atom;
											requestor: Window;  timestamp: Time );
	ChangeProperty-:		PROCEDURE {C} ( d: DisplayPtr;  w: Window;  property, typ: Atom;
											format, mode, data, nelements: LONGINT );
	GetWindowProperty-:
							PROCEDURE {C} ( d: DisplayPtr;  w: Window;  property: Atom;
											offset, length: LONGINT;  delete: Bool;  reqtype: Atom;  VAR typ: Atom;
											VAR format, nitems, bytesafter, prop: LONGINT );
	DeleteProperty-:		PROCEDURE {C} ( d: DisplayPtr;  w: Window;  property: Atom );
	WarpPointer-:			PROCEDURE {C} ( d: DisplayPtr;  srcwin, dstwin: Window;
											srcx, srcy, srcw, srch, dstx, dsty: LONGINT );
	InstallColormap-:		PROCEDURE {C} ( d: DisplayPtr;  cmap: Colormap );
	GetGeometry-:			PROCEDURE {C} ( d: DisplayPtr;  drawable: Drawable;
											VAR root, x, y, width, height, orderWidth, Depth: LONGINT );
	ResizeWindow-:			PROCEDURE {C} ( d: DisplayPtr;  w: Window;  x, y: LONGINT );
	Synchronize-:			PROCEDURE {C} ( d: DisplayPtr;  onoff: LONGINT );
	AllocColor-:				PROCEDURE {C} ( d: DisplayPtr;  cmap: Colormap;  color: LONGINT ): LONGINT;
	(*SetIOErrorHandler-:	procedure {C} ( handler: IOErrorHandler ); *)

	(* X11Ext *)
	ShmQueryVersion-:		PROCEDURE {C} ( d: DisplayPtr;
											VAR major, minor: LONGINT;  VAR pixmaps: LONGINT ): LONGINT;
	ShmPixmapFormat-:	PROCEDURE {C} ( d: DisplayPtr ): LONGINT;
	ShmAttach-:			PROCEDURE {C} ( d: DisplayPtr;  xshmsegmentinfo: LONGINT ): LONGINT;
	ShmDetach-:			PROCEDURE {C} ( d: DisplayPtr;  xshmsegmentinfo: LONGINT ): LONGINT;
	ShmPutImage-:			PROCEDURE {C} ( d: DisplayPtr;  drawable,
											gc, image, srcX, srcY, dstX, dstY, width, height, event: LONGINT ): LONGINT;
	ShmGetImage-:			PROCEDURE {C} ( d: DisplayPtr;  drawable, image, x, y, planeMask: LONGINT ): LONGINT;
	ShmCreateImage-:		PROCEDURE {C} ( d: DisplayPtr;  visual, depth, format, data, shminfo, width, height: LONGINT ): LONGINT;
	ShmCreatePixmap-:		PROCEDURE {C} ( d: DisplayPtr;  drawable, data, shminfo, width, height, depth: LONGINT ): LONGINT;

	InitXErrorHandlers-:		PROCEDURE {C} ( eh: ErrorHandler; ioeh: IOErrorHandler );

	PROCEDURE Lock*;
	BEGIN
		Machine.Acquire( Machine.X11 )
	END Lock;


	PROCEDURE Unlock*;
	BEGIN
		Machine.Release( Machine.X11 )
	END Unlock;

	PROCEDURE LinkToX;
	VAR xlib: LONGINT;
	BEGIN
		xlib := Unix.Dlopen( Unix.libX11name, 2 );
		IF xlib = 0 THEN  (* try default version *)
		 xlib := Unix.Dlopen( "libX11.so", 2 )
		END;
		IF xlib = 0 THEN
			Trace.StringLn( "X11.LinkToX:  Unix.Dlopen( libX11.so ) failed " );  Unix.exit( 3 )
		END;

		Unix.Dlsym( xlib, "XOpenDisplay", S.VAL( Address, OpenDisplay ) );
		Unix.Dlsym( xlib, "XDefaultScreen", S.VAL( Address, DefaultScreen ) );
		Unix.Dlsym( xlib, "XDisplayWidth", S.VAL( Address, DisplayWidth ) );
		Unix.Dlsym( xlib, "XDisplayHeight", S.VAL( Address, DisplayHeight ) );
		Unix.Dlsym( xlib, "XDisplayHeightMM", S.VAL( Address, DisplayHeightMM ) );
		Unix.Dlsym( xlib, "XDefaultDepth", S.VAL( Address, DefaultDepth ) );
		Unix.Dlsym( xlib, "XDisplayCells", S.VAL( Address, DisplayCells ) );
		Unix.Dlsym( xlib, "XDisplayPlanes", S.VAL( Address, DisplayPlanes ) );
		Unix.Dlsym( xlib, "XBlackPixel", S.VAL( Address, BlackPixel ) );
		Unix.Dlsym( xlib, "XWhitePixel", S.VAL( Address, WhitePixel ) );
		Unix.Dlsym( xlib, "XDefaultVisual", S.VAL( Address, DefaultVisual ) );
		Unix.Dlsym( xlib, "XDefaultColormap", S.VAL( Address, DefaultColormap ) );
		Unix.Dlsym( xlib, "XDefaultRootWindow", S.VAL( Address, DefaultRootWindow ) );
		Unix.Dlsym( xlib, "XCreateSimpleWindow", S.VAL( Address, CreateSimpleWindow ) );
		Unix.Dlsym( xlib, "XTranslateCoordinates", S.VAL( Address, TranslateCoordinates ) );
		Unix.Dlsym( xlib, "XMoveResizeWindow", S.VAL( Address, MoveResizeWindow ) );
		Unix.Dlsym( xlib, "XStoreName", S.VAL( Address, StoreName ) );
		Unix.Dlsym( xlib, "XSetIconName", S.VAL( Address, SetIconName ) );
		Unix.Dlsym( xlib, "XSetCommand", S.VAL( Address, SetCommand ) );
		Unix.Dlsym( xlib, "XMapRaised", S.VAL( Address, MapRaised ) );
		Unix.Dlsym( xlib, "XLowerWindow", S.VAL( Address, LowerWindow ) );
		Unix.Dlsym( xlib, "XClearWindow", S.VAL( Address, ClearWindow ) );
		Unix.Dlsym( xlib, "XSync", S.VAL( Address, Sync ) );  Unix.Dlsym( xlib, "XFlush", S.VAL( Address, Flush ) );
		Unix.Dlsym( xlib, "XStoreColor", S.VAL( Address, StoreColor ) );
		Unix.Dlsym( xlib, "XCreateBitmapFromData", S.VAL( Address, CreateBitmapFromData ) );
		Unix.Dlsym( xlib, "XCopyArea", S.VAL( Address, CopyArea ) );
		Unix.Dlsym( xlib, "XCopyPlane", S.VAL( Address, CopyPlane ) );
		Unix.Dlsym( xlib, "XSetStipple", S.VAL( Address, SetStipple ) );
		Unix.Dlsym( xlib, "XSetTSOrigin", S.VAL( Address, SetTSOrigin ) );
		Unix.Dlsym( xlib, "XFillRectangle", S.VAL( Address, FillRectangle ) );
		Unix.Dlsym( xlib, "XDrawPoint", S.VAL( Address, DrawPoint ) );
		Unix.Dlsym( xlib, "XDrawString", S.VAL( Address, DrawString ) );
		Unix.Dlsym( xlib, "XCreateGC", S.VAL( Address, CreateGC ) );
		Unix.Dlsym( xlib, "XSetForeground", S.VAL( Address, SetForeground ) );
		Unix.Dlsym( xlib, "XSetBackground", S.VAL( Address, SetBackground ) );
		Unix.Dlsym( xlib, "XSetPlaneMask", S.VAL( Address, SetPlaneMask ) );
		Unix.Dlsym( xlib, "XSetLineAttributes", S.VAL( Address, SetLineAttributes ) );
		Unix.Dlsym( xlib, "XSetFunction", S.VAL( Address, SetFunction ) );
		Unix.Dlsym( xlib, "XSetFont", S.VAL( Address, SetFont ) );
		Unix.Dlsym( xlib, "XSetFillStyle", S.VAL( Address, SetFillStyle ) );
		Unix.Dlsym( xlib, "XSetGraphicsExposures", S.VAL( Address, SetGraphicsExposures ) );
		Unix.Dlsym( xlib, "XAllocColorCells", S.VAL( Address, AllocColorCells ) );
		Unix.Dlsym( xlib, "XSetWindowBackground", S.VAL( Address, SetWindowBackground ) );
		Unix.Dlsym( xlib, "XCreateFontCursor", S.VAL( Address, CreateFontCursor ) );
		Unix.Dlsym( xlib, "XCreatePixmapCursor", S.VAL( Address, CreatePixmapCursor ) );
		Unix.Dlsym( xlib, "XRecolorCursor", S.VAL( Address, RecolorCursor ) );
		Unix.Dlsym( xlib, "XDefineCursor", S.VAL( Address, DefineCursor ) );
		Unix.Dlsym( xlib, "XDrawLine", S.VAL( Address, DrawLine ) );
		Unix.Dlsym( xlib, "XSetArcMode", S.VAL( Address, SetArcMode ) );
		Unix.Dlsym( xlib, "XDrawArc", S.VAL( Address, DrawArc ) );
		Unix.Dlsym( xlib, "XFillArc", S.VAL( Address, FillArc ) );
		Unix.Dlsym( xlib, "XFillPolygon", S.VAL( Address, FillPolygon ) );
		Unix.Dlsym( xlib, "XSetClipMask", S.VAL( Address, SetClipMask ) );
		Unix.Dlsym( xlib, "XSetClipRectangles", S.VAL( Address, SetClipRectangles ) );
		Unix.Dlsym( xlib, "XListFonts", S.VAL( Address, ListFonts ) );
		Unix.Dlsym( xlib, "XFreeFontNames", S.VAL( Address, FreeFontNames ) );
		Unix.Dlsym( xlib, "XLoadFont", S.VAL( Address, LoadFont ) );
		Unix.Dlsym( xlib, "XSelectInput", S.VAL( Address, SelectInput ) );
		Unix.Dlsym( xlib, "XSync", S.VAL( Address, Sync ) );
		Unix.Dlsym( xlib, "XNextEvent", S.VAL( Address, NextEvent ) );
		Unix.Dlsym( xlib, "XEventsQueued", S.VAL( Address, EventsQueued ) );
		Unix.Dlsym( xlib, "XSetInputFocus", S.VAL( Address, SetInputFocus ) );
		Unix.Dlsym( xlib, "XLookupString", S.VAL( Address, LookupString ) );
		Unix.Dlsym( xlib, "XQueryPointer", S.VAL( Address, QueryPointer ) );
		Unix.Dlsym( xlib, "XRefreshKeyboardMapping", S.VAL( Address, RefreshKeyboardMapping ) );
		Unix.Dlsym( xlib, "XBell", S.VAL( Address, Bell ) );
		Unix.Dlsym( xlib, "XRebindKeysym", S.VAL( Address, RebindKeysym ) );
		Unix.Dlsym( xlib, "XStringToKeysym", S.VAL( Address, StringToKeysym ) );
		Unix.Dlsym( xlib, "XCopyColormapAndFree", S.VAL( Address, CopyColormapAndFree ) );
		Unix.Dlsym( xlib, "XCreateColormap", S.VAL( Address, CreateColormap ) );
		Unix.Dlsym( xlib, "XMatchVisualInfo", S.VAL( Address, MatchVisualInfo ) );
		Unix.Dlsym( xlib, "XSetWindowColormap", S.VAL( Address, SetWindowColormap ) );
		Unix.Dlsym( xlib, "XQueryBestSize", S.VAL( Address, QueryBestSize ) );
		Unix.Dlsym( xlib, "XCreatePixmap", S.VAL( Address, CreatePixmap ) );
		Unix.Dlsym( xlib, "XFreePixmap", S.VAL( Address, FreePixmap ) );
		Unix.Dlsym( xlib, "XCreateImage", S.VAL( Address, CreateImage ) );
		Unix.Dlsym( xlib, "XDestroyImage", S.VAL( Address, DestroyImage ) );
		Unix.Dlsym( xlib, "XSubImage", S.VAL( Address, SubImage ) );
		Unix.Dlsym( xlib, "XGetImage", S.VAL( Address, GetImage ) );
		Unix.Dlsym( xlib, "XGetSubImage", S.VAL( Address, GetSubImage ) );
		Unix.Dlsym( xlib, "XPutImage", S.VAL( Address, PutImage ) );
		Unix.Dlsym( xlib, "XPutPixel", S.VAL( Address, PutPixel ) );
		Unix.Dlsym( xlib, "XGetPixel", S.VAL( Address, GetPixel ) );
		Unix.Dlsym( xlib, "XAddPixel", S.VAL( Address, AddPixel ) );
		Unix.Dlsym( xlib, "XFree", S.VAL( Address, Free ) );
		(*Unix.Dlsym( xlib, "XSetErrorHandler", S.VAL( Address, SetErrorHandler ) );*)
		(*Unix.Dlsym( xlib, "XSetIOErrorHandler", S.VAL( Address, SetIOErrorHandler ) );*)
		Unix.Dlsym( xlib, "XGetErrorText", S.VAL( Address, GetErrorText ) );
		Unix.Dlsym( xlib, "XStoreBytes", S.VAL( Address, StoreBytes ) );
		Unix.Dlsym( xlib, "XFetchBytes", S.VAL( Address, FetchBytes ) );
		Unix.Dlsym( xlib, "XSetSelectionOwner", S.VAL( Address, SetSelectionOwner ) );
		Unix.Dlsym( xlib, "XGetSelectionOwner", S.VAL( Address, GetSelectionOwner ) );
		Unix.Dlsym( xlib, "XInternAtom", S.VAL( Address, InternAtom ) );
		Unix.Dlsym( xlib, "XSendEvent", S.VAL( Address, SendEvent ) );
		Unix.Dlsym( xlib, "XConvertSelection", S.VAL( Address, ConvertSelection ) );
		Unix.Dlsym( xlib, "XChangeProperty", S.VAL( Address, ChangeProperty ) );
		Unix.Dlsym( xlib, "XGetWindowProperty", S.VAL( Address, GetWindowProperty ) );
		Unix.Dlsym( xlib, "XDeleteProperty", S.VAL( Address, DeleteProperty ) );
		Unix.Dlsym( xlib, "XWarpPointer", S.VAL( Address, WarpPointer ) );
		Unix.Dlsym( xlib, "XInstallColormap", S.VAL( Address, InstallColormap ) );
		Unix.Dlsym( xlib, "XGetGeometry", S.VAL( Address, GetGeometry ) );
		Unix.Dlsym( xlib, "XResizeWindow", S.VAL( Address, ResizeWindow ) );
		Unix.Dlsym( xlib, "XSynchronize", S.VAL( Address, Synchronize ) );
		Unix.Dlsym( xlib, "XAllocColor", S.VAL( Address, AllocColor ) );

		xlib := Unix.Dlopen( Unix.libXextname, 2 );
		IF xlib = 0 THEN  (* try default version *)
			xlib := Unix.Dlopen( "libXext.so", 2 )
		END;
		IF xlib = 0 THEN  Trace.StringLn( "X11.LinkToX:  Unix.Dlopen( libXext.so ) failed " )  END;

		Unix.Dlsym( xlib, "XShmQueryVersion", S.VAL( Address, ShmQueryVersion ) );
		Unix.Dlsym( xlib, "XShmPixmapFormat", S.VAL( Address, ShmPixmapFormat ) );
		Unix.Dlsym( xlib, "XShmAttach", S.VAL( Address, ShmAttach ) );
		Unix.Dlsym( xlib, "XShmDetach", S.VAL( Address, ShmDetach ) );
		Unix.Dlsym( xlib, "XShmPutImage", S.VAL( Address, ShmPutImage ) );
		Unix.Dlsym( xlib, "XShmGetImage", S.VAL( Address, ShmGetImage ) );
		Unix.Dlsym( xlib, "XShmCreateImage", S.VAL( Address, ShmCreateImage ) );
		Unix.Dlsym( xlib, "XShmCreatePixmap", S.VAL( Address, ShmCreatePixmap ) );
	END LinkToX;

	PROCEDURE MyErrorHandler( d: DisplayPtr;  err: ErrorEventPtr; p3, p4: LONGINT ): LONGINT;
	BEGIN
		ErrorFlag := TRUE;
		GetErrorText( d, ORD( err.errorCode ), ErrorText, BufferSize );
		Trace.StringLn(  ErrorText );
		RETURN 0
	END MyErrorHandler;

	PROCEDURE MyIOErrorHandler( d: DisplayPtr; p2, p3, p4: LONGINT ): LONGINT;
	BEGIN
		ErrorFlag := TRUE;  ErrorText := "X11 I/O Error";
		Trace.StringLn( ErrorText );
		INC( ioErrors );
		IF ioErrors > 100 THEN  Modules.Shutdown( 0 )  END  ;
		RETURN 0
	END MyIOErrorHandler;

BEGIN
	ioErrors := 0;  LinkToX;  ErrorFlag := FALSE;
	(*SetIOErrorHandler( MyIOErrorHandler );*)
	(*SetErrorHandler( MyErrorHandler );*)
			(* Oberon procedures cannot be used as callback procedures because of
				incompatibilities between the PPC Oberon ABI and the PPC SYSV ABI.
				PPC Oberon follows the old MAC and IBM AIX ABI *)
	Unix.Dlsym( 0, "InitXErrH", S.VAL( Address, InitXErrorHandlers ) );
	InitXErrorHandlers( MyErrorHandler, MyIOErrorHandler );
END X11.