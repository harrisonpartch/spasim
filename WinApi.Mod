MODULE WinApi; (** AUTHOR "fnecati"; PURPOSE "missing WinApi functions"; *)

IMPORT
	 S:=SYSTEM, Kernel32, User32, GDI32;

CONST
		NULL* = Kernel32.NULL;

	 (** CreateWindow dwStyle values *)
		WS_OVERLAPPED* = {};
		WS_POPUP* = {31};
		WS_CHILD* = {30};
		WS_MINIMIZE* = {29};
		WS_VISIBLE* = {28};
		WS_DISABLED* = {27};
		WS_CLIPSIBLINGS* = {26};
		WS_CLIPCHILDREN* = {25};
		WS_MAXIMIZE* = {24};
		WS_CAPTION* = {22, 23};
		WS_BORDER* = {23};
		WS_DLGFRAME* = {22};
		WS_VSCROLL* = {21};
		WS_HSCROLL* = {20};
		WS_SYSMENU* = {19};
		WS_THICKFRAME* = {18};
		WS_GROUP* = {17};
		WS_TABSTOP* = {16};
		WS_MINIMIZEBOX* = {17};
		WS_MAXIMIZEBOX* = {16};
		WS_TILED* = {};
		WS_ICONIC* = {29};
		WS_SIZEBOX* = {18};
		WS_TILEDWINDOW* = {16..19, 22, 23};
		WS_OVERLAPPEDWINDOW* = {16..19, 22, 23};
		WS_POPUPWINDOW* = {19, 23, 31};
		WS_CHILDWINDOW* = {30};

		(** CreateWindow dwExStyle values *)
		WS_EX_DLGMODALFRAME* = {0};
		WS_EX_NOPARENTNOTIFY* = {2};
		WS_EX_TOPMOST* = {3};
		WS_EX_ACCEPTFILES* = {4};
		WS_EX_TRANSPARENT* = {5};
		WS_EX_MDICHILD* = {6};
		WS_EX_TOOLWINDOW* = {7};
		WS_EX_WINDOWEDGE* = {8};
		WS_EX_CLIENTEDGE* = {9};
		WS_EX_CONTEXTHELP* = {10};
		WS_EX_RIGHT* = {12};
		WS_EX_LEFT* = {};
		WS_EX_RTLREADING* = {13};
		WS_EX_LTRREADING* = {};
		WS_EX_LEFTSCROLLBAR* = {14};
		WS_EX_RIGHTSCROLLBAR* = {};
		WS_EX_CONTROLPARENT* = {16};
		WS_EX_STATICEDGE* = {17};
		WS_EX_APPWINDOW* = {18};
		WS_EX_OVERLAPPEDWINDOW* = {8, 9};
		WS_EX_PALETTEWINDOW* = {3, 7, 8};

		(** window Class styles*)
		CS_VREDRAW* = {0};
		CS_HREDRAW* = {1};
		CS_KEYCVTWINDOW* = {2};
		CS_DBLCLKS* = {3};
		CS_OWNDC* = {5};
		CS_CLASSDC* = {6};
		CS_PARENTDC* = {7};
		CS_NOKEYCVT* = {8};
		CS_NOCLOSE* = {9};
		CS_SAVEBITS* = {11};
		CS_BYTEALIGNCLIENT* = {12};
		CS_BYTEALIGNWINDOW* = {13};
		CS_GLOBALCLASS* = {14};
		CS_IME* = {16};

		(* size messages?  *)
		SM_CXSCREEN* = 0 (* {} *);
		SM_CYSCREEN* = 1 (* {0} *);
		SM_CXVSCROLL* = 2 (* {1} *);
		SM_CYHSCROLL* = 3 (* {0, 1} *);
		SM_CYCAPTION* = 4 (* {2} *);
		SM_CXBORDER* = 5 (* {0, 2} *);
		SM_CYBORDER* = 6 (* {1, 2} *);
		SM_CXDLGFRAME* = 7 (* {0..2} *);
		SM_CYDLGFRAME* = 8 (* {3} *);
		SM_CYVTHUMB* = 9 (* {0, 3} *);
		SM_CXHTHUMB* = 10 (* {1, 3} *);
		SM_CXICON* = 11 (* {0, 1, 3} *);
		SM_CYICON* = 12 (* {2, 3} *);
		SM_CXCURSOR* = 13 (* {0, 2, 3} *);
		SM_CYCURSOR* = 14 (* {1..3} *);
		SM_CYMENU* = 15 (* {0..3} *);
		SM_CXFULLSCREEN* = 16 (* {4} *);
		SM_CYFULLSCREEN* = 17 (* {0, 4} *);
		SM_CYKANJIWINDOW* = 18 (* {1, 4} *);
		SM_MOUSEPRESENT* = 19 (* {0, 1, 4} *);
		SM_CYVSCROLL* = 20 (* {2, 4} *);
		SM_CXHSCROLL* = 21 (* {0, 2, 4} *);
		SM_DEBUG* = 22 (* {1, 2, 4} *);
		SM_SWAPBUTTON* = 23 (* {0..2, 4} *);
		SM_RESERVED1* = 24 (* {3, 4} *);
		SM_RESERVED2* = 25 (* {0, 3, 4} *);
		SM_RESERVED3* = 26 (* {1, 3, 4} *);
		SM_RESERVED4* = 27 (* {0, 1, 3, 4} *);
		SM_CXMIN* = 28 (* {2..4} *);
		SM_CYMIN* = 29 (* {0, 2..4} *);
		SM_CXSIZE* = 30 (* {1..4} *);
		SM_CYSIZE* = 31 (* {0..4} *);
		SM_CXFRAME* = 32 (* {5} *);
		SM_CYFRAME* = 33 (* {0, 5} *);
		SM_CXMINTRACK* = 34 (* {1, 5} *);
		SM_CYMINTRACK* = 35 (* {0, 1, 5} *);
		SM_CXDOUBLECLK* = 36 (* {2, 5} *);
		SM_CYDOUBLECLK* = 37 (* {0, 2, 5} *);
		SM_CXICONSPACING* = 38 (* {1, 2, 5} *);
		SM_CYICONSPACING* = 39 (* {0..2, 5} *);
		SM_MENUDROPALIGNMENT* = 40 (* {3, 5} *);
		SM_PENWINDOWS* = 41 (* {0, 3, 5} *);
		SM_DBCSENABLED* = 42 (* {1, 3, 5} *);
		SM_CMOUSEBUTTONS* = 43 (* {0, 1, 3, 5} *);
		SM_CXFIXEDFRAME* = 7 (* {0..2} *);
		SM_CYFIXEDFRAME* = 8 (* {3} *);
		SM_CXSIZEFRAME* = 32 (* {5} *);
		SM_CYSIZEFRAME* = 33 (* {0, 5} *);
		SM_SECURE* = 44 (* {2, 3, 5} *);
		SM_CXEDGE* = 45 (* {0, 2, 3, 5} *);
		SM_CYEDGE* = 46 (* {1..3, 5} *);
		SM_CXMINSPACING* = 47 (* {0..3, 5} *);
		SM_CYMINSPACING* = 48 (* {4, 5} *);
		SM_CXSMICON* = 49 (* {0, 4, 5} *);
		SM_CYSMICON* = 50 (* {1, 4, 5} *);
		SM_CYSMCAPTION* = 51 (* {0, 1, 4, 5} *);
		SM_CXSMSIZE* = 52 (* {2, 4, 5} *);
		SM_CYSMSIZE* = 53 (* {0, 2, 4, 5} *);
		SM_CXMENUSIZE* = 54 (* {1, 2, 4, 5} *);
		SM_CYMENUSIZE* = 55 (* {0..2, 4, 5} *);
		SM_ARRANGE* = 56 (* {3..5} *);
		SM_CXMINIMIZED* = 57 (* {0, 3..5} *);
		SM_CYMINIMIZED* = 58 (* {1, 3..5} *);
		SM_CXMAXTRACK* = 59 (* {0, 1, 3..5} *);
		SM_CYMAXTRACK* = 60 (* {2..5} *);
		SM_CXMAXIMIZED* = 61 (* {0, 2..5} *);
		SM_CYMAXIMIZED* = 62 (* {1..5} *);
		SM_NETWORK* = 63 (* {0..5} *);
		SM_CLEANBOOT* = 67 (* {0, 1, 6} *);
		SM_CXDRAG* = 68 (* {2, 6} *);
		SM_CYDRAG* = 69 (* {0, 2, 6} *);
		SM_SHOWSOUNDS* = 70 (* {1, 2, 6} *);
		SM_CXMENUCHECK* = 71 (* {0..2, 6} *);
		SM_CYMENUCHECK* = 72 (* {3, 6} *);
		SM_SLOWMACHINE* = 73 (* {0, 3, 6} *);
		SM_MIDEASTENABLED* = 74 (* {1, 3, 6} *);
		SM_CMETRICS* = 75  (* {0, 1, 3, 6} *);

		(* pixel format description values *)
		PFD_TYPE_RGBA* = 0 (* {} *);
		PFD_TYPE_COLORINDEX* = 1 (* {0} *);
		PFD_MAIN_PLANE* = 0 (* {} *);
		PFD_OVERLAY_PLANE* = 1 (* {0} *);
		PFD_UNDERLAY_PLANE* = -1 (* {0..31} *);
		PFD_DOUBLEBUFFER* = {0};
		PFD_STEREO* = {1};
		PFD_DRAW_TO_WINDOW* = {2};
		PFD_DRAW_TO_BITMAP* = {3};
		PFD_SUPPORT_GDI* = {4};
		PFD_SUPPORT_OPENGL* = {5};
		PFD_GENERIC_FORMAT* = {6};
		PFD_NEED_PALETTE* = {7};
		PFD_NEED_SYSTEM_PALETTE* = {8};
		PFD_SWAP_EXCHANGE* = {9};
		PFD_SWAP_COPY* = {10};
		PFD_SWAP_LAYER_BUFFERS* = {11};
		PFD_DOUBLEBUFFER_DONTCARE* = {30};
		PFD_STEREO_DONTCARE* = {31};



		(* HDC Types *)
		OBJ_BITMAP* = 7 (* {0..2} *);
		OBJ_MEMDC* = 10;
		OBJ_ENHMETADC* = 12;
		OBJ_METADC* = 4;

		DIB_RGB_COLORS* = 0 (* {} *);
		DIB_PAL_COLORS* = 1 (* {0} *);

		BIRGB* = GDI32.BIRGB;

		PM_NOREMOVE* = 0 (* {} *);
		PM_REMOVE* = 1 (* {0} *);
		PM_NOYIELD* = 2 (* {1} *);

		GWL_WNDPROC* = -4 (* {2..31} *);
		GWL_HINSTANCE* = -6 (* {1, 3..31} *);
		GWL_HWNDPARENT* = -8 (* {3..31} *);
		GWL_STYLE* = -16 (* {4..31} *);
		GWL_EXSTYLE* = -20 (* {2, 3, 5..31} *);
		GWL_USERDATA* = -21 (* {0, 1, 3, 5..31} *);
		GWL_ID* = -12 (* {2, 4..31} *);

		(* Messages *)
		WM_ERASEBKGND* = 20 (* {2, 4} *);
		WM_SIZING* = 532 (* {2, 4, 9} *);

  TYPE
  
		HANDLE* = Kernel32.HANDLE;
		HINSTANCE* = Kernel32.HINSTANCE;
		HMENU* = User32.HMenu;
		HDC* = HANDLE;
		HGLRC* = HANDLE;
		HPALETTE* = HANDLE;
		HGDIOBJ* = HANDLE;
		BOOL* = Kernel32.BOOL;
		HWND* = HANDLE;
		HBITMAP* = HANDLE;
		WORD* = INTEGER;
		DWORD* = LONGINT;

		RGBQUAD* = RECORD
			rgbBlur*, rgbGreen*, rgbRed*, rgbReserved*: CHAR;
		END;

		PALETTEENTRY* = RECORD
			peRed*: CHAR;
			peGreen*: CHAR;
			peBlue*: CHAR;
			peFlags*: CHAR;
		END;
		PtrPALETTEENTRY* = POINTER TO PALETTEENTRY;

		LOGPALETTE* = RECORD
			palVersion*: INTEGER;
			palNumEntries*: INTEGER;
			palPalEntry*: ARRAY 1 OF PALETTEENTRY;
		END;
		PtrLOGPALETTE* = POINTER TO LOGPALETTE;

		BITMAP* = RECORD
			bmType*: LONGINT;
			bmWidth*: LONGINT;
			bmHeight*: LONGINT;
			bmWidthBytes*: LONGINT;
			bmPlanes*: INTEGER;
			bmBitsPixel*: INTEGER;
			bmBits*: LONGINT;
		END;

		BITMAPINFOHEADER* = RECORD
			biSize*: LONGINT;
			biWidth*: LONGINT;
			biHeight*: LONGINT;
			biPlanes*: INTEGER;
			biBitCount*: INTEGER;
			biCompression*: LONGINT;
			biSizeImage*: LONGINT;
			biXPelsPerMeter*: LONGINT;
			biYPelsPerMeter*: LONGINT;
			biClrUsed*: LONGINT;
			biClrImportant*: LONGINT;
		END;

		BITMAPINFO* = RECORD
			bmiHeader*: BITMAPINFOHEADER;
			bmiColors*: ARRAY 1 OF RGBQUAD;
		END;


	PIXELFORMATDESCRIPTOR* = RECORD
		nSize*: INTEGER;
		nVersion*: INTEGER;
		dwFlags*: SET;
		iPixelType*: CHAR;
		cColorBits*: CHAR;
		cRedBits*: CHAR;
		cRedShift*: CHAR;
		cGreenBits*: CHAR;
		cGreenShift*: CHAR;
		cBlueBits*: CHAR;
		cBlueShift*: CHAR;
		cAlphaBits*: CHAR;
		cAlphaShift*: CHAR;
		cAccumBits*: CHAR;
		cAccumRedBits*: CHAR;
		cAccumGreenBits*: CHAR;
		cAccumBlueBits*: CHAR;
		cAccumAlphaBits*: CHAR;
		cDepthBits*: CHAR;
		cStencilBits*: CHAR;
		cAuxBuffers*: CHAR;
		iLayerType*: CHAR;
		bReserved*: CHAR;
		dwLayerMask*: SET;
		dwVisibleMask*: SET;
		dwDamageMask*: SET;
	END;


		CREATESTRUCTA* = RECORD
			lpCreateParams*: LONGINT;
			hInstance*: HINSTANCE;
			hMenu*: HMENU;
			hwndParent*: HWND;
			cy*: LONGINT;
			cx*: LONGINT;
			y*: LONGINT;
			x*: LONGINT;
			style*: SET;
			lpszName*: LONGINT;
			lpszClass*:LONGINT;
			dwExStyle*: SET;
		END;
		CREATESTRUCTW* = RECORD
			lpCreateParams*: LONGINT;
			hInstance*: HINSTANCE;
			hMenu*: HMENU;
			hwndParent*: HWND;
			cy*: LONGINT;
			cx*: LONGINT;
			y*: LONGINT;
			x*: LONGINT;
			style*: SET;
			lpszName*: LONGINT;
			lpszClass*: LONGINT;
			dwExStyle*: SET;
		END;
		CREATESTRUCT* = CREATESTRUCTA;


VAR

	(* GDI32.dll *)
	CreateDIBSection- : PROCEDURE {WINAPI}  (p0: HDC;   p1: ADDRESS (*BITMAPINFO*); p2: LONGINT;  p3: ADDRESS; p4: HANDLE; p5: LONGINT): HBITMAP;
	CreatePalette-: PROCEDURE {WINAPI} ( p0: ADDRESS (*LOGPALETTE*)): HPALETTE;
	GetCurrentObject-: PROCEDURE {WINAPI} (p0: HDC; p1: LONGINT): HGDIOBJ;
	GetObject-: PROCEDURE {WINAPI}  (p0: HGDIOBJ; p1: LONGINT; p2: ADDRESS): LONGINT;
	GetObjectType-: PROCEDURE  {WINAPI} (h: HGDIOBJ): LONGINT;
	PeekMessage-: PROCEDURE {WINAPI} (VAR  lpMsg: User32.Msg; hWnd: HWND; wMsgFilterMin: LONGINT; wMsgFilterMax: LONGINT; wRemoveMsg: LONGINT): BOOL;
	RealizePalette- : PROCEDURE  {WINAPI} (p0: HDC): LONGINT;
	SelectPalette-: PROCEDURE {WINAPI} (p0: HDC; p1: HPALETTE; p2: BOOL): HPALETTE;
	ChoosePixelFormat- :PROCEDURE  {WINAPI} (p0: HDC;   p1: ADDRESS (*PIXELFORMATDESCRIPTOR*)): LONGINT;
 	DescribePixelFormat-: PROCEDURE {WINAPI} (p0: HDC; p1: LONGINT; p2: LONGINT;  p3: ADDRESS(*PIXELFORMATDESCRIPTOR*)): LONGINT;
	GetPixelFormat-: PROCEDURE {WINAPI} (p0: HDC): LONGINT;
	SetPixelFormat- : PROCEDURE {WINAPI}  (p0: HDC; p1: LONGINT;  p2: ADDRESS (*PIXELFORMATDESCRIPTOR*)): BOOL;
	SwapBuffers- : PROCEDURE {WINAPI}  (p0: HDC): BOOL;

	(* USER32.dll *)
	AdjustWindowRectEx-: PROCEDURE {WINAPI} (VAR lpRect: User32.Rect (* ADDRESS *); dwStyle: SET; bMenu: BOOL; dwExStyle: SET): BOOL;
	ClientToScreen- : PROCEDURE {WINAPI} (hWnd: HWND; VAR lpPoint: User32.Point): BOOL;
	FindWindow- : PROCEDURE {WINAPI} (CONST lpClassName: ARRAY OF CHAR; CONST lpWindowName: ARRAY OF CHAR): HWND;
	GetDesktopWindow-: PROCEDURE {WINAPI} (): HWND;
	GetWindowDC- : PROCEDURE {WINAPI} (hwin: HWND): HDC;


	PROCEDURE GetDC*(hwn: HANDLE): HDC;
	BEGIN
		RETURN User32.GetDC(hwn);
	END GetDC;

	PROCEDURE DeleteDC*(hdc: HDC): LONGINT;
	BEGIN
		RETURN GDI32.DeleteDC(hdc);
	END DeleteDC;

	PROCEDURE ReleaseDC*(hwn: HWND; hdc: HDC): LONGINT;
	BEGIN
		RETURN User32.ReleaseDC(hwn, hdc);
	END ReleaseDC;

	PROCEDURE SelectObject*(hdc: HDC; hbm: HBITMAP): LONGINT;
	BEGIN
		RETURN GDI32.SelectObject(hdc, hbm);
	END SelectObject;

	PROCEDURE DeleteObject*(hnd: HANDLE): LONGINT;
	BEGIN
		RETURN GDI32.DeleteObject(hnd);
	END DeleteObject;


	PROCEDURE CreateCompatibleDC*(hdc: HDC): HDC;
	BEGIN
		RETURN GDI32.CreateCompatibleDC(hdc);
	END CreateCompatibleDC;

PROCEDURE InitWinApiLibs;
VAR
	lib: Kernel32.HMODULE;
BEGIN

	lib := Kernel32.LoadLibrary("GDI32.DLL");

	Kernel32.GetProcAddress(lib, "CreateDIBSection", S.VAL(ADDRESS, CreateDIBSection ));
	Kernel32.GetProcAddress(lib, "CreatePalette", S.VAL(ADDRESS, CreatePalette ));
	Kernel32.GetProcAddress(lib, "GetCurrentObject", S.VAL(ADDRESS, GetCurrentObject ));

	Kernel32.GetProcAddress(lib, "GetObjectA", S.VAL(ADDRESS, GetObject ));
	Kernel32.GetProcAddress(lib, "GetObjectType", S.VAL(ADDRESS,GetObjectType ));

	Kernel32.GetProcAddress(lib, "RealizePalette", S.VAL(ADDRESS, RealizePalette ));
	Kernel32.GetProcAddress(lib, "SelectPalette", S.VAL(ADDRESS, SelectPalette ));

	Kernel32.GetProcAddress(lib, "ChoosePixelFormat", S.VAL(ADDRESS, ChoosePixelFormat ));
	Kernel32.GetProcAddress(lib, "DescribePixelFormat", S.VAL(ADDRESS, DescribePixelFormat ));
	Kernel32.GetProcAddress(lib, "GetPixelFormat", S.VAL(ADDRESS, GetPixelFormat ));
	Kernel32.GetProcAddress(lib, "SetPixelFormat", S.VAL(ADDRESS, SetPixelFormat ));
	Kernel32.GetProcAddress(lib, "SwapBuffers", S.VAL(ADDRESS, SwapBuffers ));


	lib := Kernel32.LoadLibrary("USER32.DLL");
	Kernel32.GetProcAddress(lib, "AdjustWindowRectEx", S.VAL(ADDRESS, AdjustWindowRectEx ));
	Kernel32.GetProcAddress(lib, "ClientToScreen", S.VAL(ADDRESS, ClientToScreen));
	Kernel32.GetProcAddress(lib, "FindWindowA", S.VAL(ADDRESS, FindWindow));
	Kernel32.GetProcAddress(lib, "GetDesktopWindow", S.VAL(ADDRESS,GetDesktopWindow ));
	Kernel32.GetProcAddress(lib, "GetWindowDC", S.VAL(ADDRESS, GetWindowDC ));
	Kernel32.GetProcAddress(lib, "PeekMessageA", S.VAL(ADDRESS, PeekMessage ));


END InitWinApiLibs;

BEGIN
	InitWinApiLibs;

END WinApi.
