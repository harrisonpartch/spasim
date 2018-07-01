MODULE WinApi; (** AUTHOR "fnecati"; PURPOSE "missing WinApi functions"; *)

IMPORT
	 S:=SYSTEM, Kernel32, User32, GDI32, Modules;

VAR
	libgdi, libuser: Kernel32.HMODULE;

CONST
	NULL* = Kernel32.NULL;
	(*	const and types are adapted from BlackBox.WinApi.odc *)

	(* CreateWindow dwStyle values *)
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
	WM_NULL* = 0 (* {} *);
	WM_CREATE* = 1 (* {0} *);
	WM_DESTROY* = 2 (* {1} *);
	WM_MOVE* = 3 (* {0, 1} *);
	WM_SIZE* = 5 (* {0, 2} *);
	WM_ACTIVATE* = 6 (* {1, 2} *);
	WA_INACTIVE* = 0 (* {} *);
	WA_ACTIVE* = 1 (* {0} *);
	WA_CLICKACTIVE* = 2 (* {1} *);
	WM_SETFOCUS* = 7 (* {0..2} *);
	WM_KILLFOCUS* = 8 (* {3} *);
	WM_ENABLE* = 10 (* {1, 3} *);
	WM_SETREDRAW* = 11 (* {0, 1, 3} *);
	WM_SETTEXT* = 12 (* {2, 3} *);
	WM_GETTEXT* = 13 (* {0, 2, 3} *);
	WM_GETTEXTLENGTH* = 14 (* {1..3} *);
	WM_PAINT* = 15 (* {0..3} *);
	WM_CLOSE* = 16 (* {4} *);
	WM_QUERYENDSESSION* = 17 (* {0, 4} *);
	WM_QUIT* = 18 (* {1, 4} *);
	WM_QUERYOPEN* = 19 (* {0, 1, 4} *);
	WM_ERASEBKGND* = 20 (* {2, 4} *);
	WM_SYSCOLORCHANGE* = 21 (* {0, 2, 4} *);
	WM_ENDSESSION* = 22 (* {1, 2, 4} *);
	WM_SHOWWINDOW* = 24 (* {3, 4} *);
	WM_WININICHANGE* = 26 (* {1, 3, 4} *);
	WM_SETTINGCHANGE* = 26 (* {1, 3, 4} *);
	WM_DEVMODECHANGE* = 27 (* {0, 1, 3, 4} *);
	WM_ACTIVATEAPP* = 28 (* {2..4} *);
	WM_FONTCHANGE* = 29 (* {0, 2..4} *);
	WM_TIMECHANGE* = 30 (* {1..4} *);
	WM_CANCELMODE* = 31 (* {0..4} *);
	WM_SETCURSOR* = 32 (* {5} *);
	WM_MOUSEACTIVATE* = 33 (* {0, 5} *);
	WM_CHILDACTIVATE* = 34 (* {1, 5} *);
	WM_QUEUESYNC* = 35 (* {0, 1, 5} *);
	WM_GETMINMAXINFO* = 36 (* {2, 5} *);
	WM_PAINTICON* = 38 (* {1, 2, 5} *);
	WM_ICONERASEBKGND* = 39 (* {0..2, 5} *);
	WM_NEXTDLGCTL* = 40 (* {3, 5} *);
	WM_SPOOLERSTATUS* = 42 (* {1, 3, 5} *);
	WM_DRAWITEM* = 43 (* {0, 1, 3, 5} *);
	WM_MEASUREITEM* = 44 (* {2, 3, 5} *);
	WM_DELETEITEM* = 45 (* {0, 2, 3, 5} *);
	WM_VKEYTOITEM* = 46 (* {1..3, 5} *);
	WM_CHARTOITEM* = 47 (* {0..3, 5} *);
	WM_SETFONT* = 48 (* {4, 5} *);
	WM_GETFONT* = 49 (* {0, 4, 5} *);
	WM_SETHOTKEY* = 50 (* {1, 4, 5} *);
	WM_GETHOTKEY* = 51 (* {0, 1, 4, 5} *);
	WM_QUERYDRAGICON* = 55 (* {0..2, 4, 5} *);
	WM_COMPAREITEM* = 57 (* {0, 3..5} *);
	WM_COMPACTING* = 65 (* {0, 6} *);
	WM_COMMNOTIFY* = 68 (* {2, 6} *);
	WM_WINDOWPOSCHANGING* = 70 (* {1, 2, 6} *);
	WM_WINDOWPOSCHANGED* = 71 (* {0..2, 6} *);
	WM_POWER* = 72 (* {3, 6} *);
	PWR_OK* = 1 (* {0} *);
	PWR_FAIL* = -1 (* {0..31} *);
	PWR_SUSPENDREQUEST* = 1 (* {0} *);
	PWR_SUSPENDRESUME* = 2 (* {1} *);
	PWR_CRITICALRESUME* = 3 (* {0, 1} *);
	WM_COPYDATA* = 74 (* {1, 3, 6} *);
	WM_CANCELJOURNAL* = 75 (* {0, 1, 3, 6} *);
	WM_NOTIFY* = 78 (* {1..3, 6} *);
	WM_INPUTLANGCHANGEREQUEST* = 80 (* {4, 6} *);
	WM_INPUTLANGCHANGE* = 81 (* {0, 4, 6} *);
	WM_TCARD* = 82 (* {1, 4, 6} *);
	WM_HELP* = 83 (* {0, 1, 4, 6} *);
	WM_USERCHANGED* = 84 (* {2, 4, 6} *);
	WM_NOTIFYFORMAT* = 85 (* {0, 2, 4, 6} *);
	NFR_ANSI* = 1 (* {0} *);
	NFR_UNICODE* = 2 (* {1} *);
	NF_QUERY* = 3 (* {0, 1} *);
	NF_REQUERY* = 4 (* {2} *);
	WM_CONTEXTMENU* = 123 (* {0, 1, 3..6} *);
	WM_STYLECHANGING* = 124 (* {2..6} *);
	WM_STYLECHANGED* = 125 (* {0, 2..6} *);
	WM_DISPLAYCHANGE* = 126 (* {1..6} *);
	WM_GETICON* = 127 (* {0..6} *);
	WM_SETICON* = 128 (* {7} *);
	WM_NCCREATE* = 129 (* {0, 7} *);
	WM_NCDESTROY* = 130 (* {1, 7} *);
	WM_NCCALCSIZE* = 131 (* {0, 1, 7} *);
	WM_NCHITTEST* = 132 (* {2, 7} *);
	WM_NCPAINT* = 133 (* {0, 2, 7} *);
	WM_NCACTIVATE* = 134 (* {1, 2, 7} *);
	WM_GETDLGCODE* = 135 (* {0..2, 7} *);
	WM_NCMOUSEMOVE* = 160 (* {5, 7} *);
	WM_NCLBUTTONDOWN* = 161 (* {0, 5, 7} *);
	WM_NCLBUTTONUP* = 162 (* {1, 5, 7} *);
	WM_NCLBUTTONDBLCLK* = 163 (* {0, 1, 5, 7} *);
	WM_NCRBUTTONDOWN* = 164 (* {2, 5, 7} *);
	WM_NCRBUTTONUP* = 165 (* {0, 2, 5, 7} *);
	WM_NCRBUTTONDBLCLK* = 166 (* {1, 2, 5, 7} *);
	WM_NCMBUTTONDOWN* = 167 (* {0..2, 5, 7} *);
	WM_NCMBUTTONUP* = 168 (* {3, 5, 7} *);
	WM_NCMBUTTONDBLCLK* = 169 (* {0, 3, 5, 7} *);
	WM_KEYFIRST* = 256 (* {8} *);
	WM_KEYDOWN* = 256 (* {8} *);
	WM_KEYUP* = 257 (* {0, 8} *);
	WM_CHAR* = 258 (* {1, 8} *);
	WM_DEADCHAR* = 259 (* {0, 1, 8} *);
	WM_SYSKEYDOWN* = 260 (* {2, 8} *);
	WM_SYSKEYUP* = 261 (* {0, 2, 8} *);
	WM_SYSCHAR* = 262 (* {1, 2, 8} *);
	WM_SYSDEADCHAR* = 263 (* {0..2, 8} *);
	WM_UNICHAR* = 265;
	WM_KEYLAST* = 265;
	WM_IME_STARTCOMPOSITION* = 269 (* {0, 2, 3, 8} *);
	WM_IME_ENDCOMPOSITION* = 270 (* {1..3, 8} *);
	WM_IME_COMPOSITION* = 271 (* {0..3, 8} *);
	WM_IME_KEYLAST* = 271 (* {0..3, 8} *);
	WM_INITDIALOG* = 272 (* {4, 8} *);
	WM_COMMAND* = 273 (* {0, 4, 8} *);
	WM_SYSCOMMAND* = 274 (* {1, 4, 8} *);
	WM_TIMER* = 275 (* {0, 1, 4, 8} *);
	WM_HSCROLL* = 276 (* {2, 4, 8} *);
	WM_VSCROLL* = 277 (* {0, 2, 4, 8} *);
	WM_INITMENU* = 278 (* {1, 2, 4, 8} *);
	WM_INITMENUPOPUP* = 279 (* {0..2, 4, 8} *);
	WM_MENUSELECT* = 287 (* {0..4, 8} *);
	WM_MENUCHAR* = 288 (* {5, 8} *);
	WM_ENTERIDLE* = 289 (* {0, 5, 8} *);
	WM_CTLCOLORMSGBOX* = 306 (* {1, 4, 5, 8} *);
	WM_CTLCOLOREDIT* = 307 (* {0, 1, 4, 5, 8} *);
	WM_CTLCOLORLISTBOX* = 308 (* {2, 4, 5, 8} *);
	WM_CTLCOLORBTN* = 309 (* {0, 2, 4, 5, 8} *);
	WM_CTLCOLORDLG* = 310 (* {1, 2, 4, 5, 8} *);
	WM_CTLCOLORSCROLLBAR* = 311 (* {0..2, 4, 5, 8} *);
	WM_CTLCOLORSTATIC* = 312 (* {3..5, 8} *);
	WM_MOUSEFIRST* = 512 (* {9} *);
	WM_MOUSEMOVE* = 512 (* {9} *);
	WM_LBUTTONDOWN* = 513 (* {0, 9} *);
	WM_LBUTTONUP* = 514 (* {1, 9} *);
	WM_LBUTTONDBLCLK* = 515 (* {0, 1, 9} *);
	WM_RBUTTONDOWN* = 516 (* {2, 9} *);
	WM_RBUTTONUP* = 517 (* {0, 2, 9} *);
	WM_RBUTTONDBLCLK* = 518 (* {1, 2, 9} *);
	WM_MBUTTONDOWN* = 519 (* {0..2, 9} *);
	WM_MBUTTONUP* = 520 (* {3, 9} *);
	WM_MBUTTONDBLCLK* = 521 (* {0, 3, 9} *);
	WM_MOUSEWHEEL* = 522;
	WM_MOUSELAST* = 522 (* {1, 3, 9} *);

	WM_PARENTNOTIFY* = 528 (* {4, 9} *);
	MENULOOP_WINDOW* = 0 (* {} *);
	MENULOOP_POPUP* = 1 (* {0} *);
	WM_ENTERMENULOOP* = 529 (* {0, 4, 9} *);
	WM_EXITMENULOOP* = 530 (* {1, 4, 9} *);
	WM_NEXTMENU* = 531 (* {0, 1, 4, 9} *);
	WM_SIZING* = 532 (* {2, 4, 9} *);
	WM_CAPTURECHANGED* = 533 (* {0, 2, 4, 9} *);
	WM_MOVING* = 534 (* {1, 2, 4, 9} *);
	WM_POWERBROADCAST* = 536 (* {3, 4, 9} *);
	WM_DEVICECHANGE* = 537 (* {0, 3, 4, 9} *);
	WM_IME_SETCONTEXT* = 641 (* {0, 7, 9} *);
	WM_IME_NOTIFY* = 642 (* {1, 7, 9} *);
	WM_IME_CONTROL* = 643 (* {0, 1, 7, 9} *);
	WM_IME_COMPOSITIONFULL* = 644 (* {2, 7, 9} *);
	WM_IME_SELECT* = 645 (* {0, 2, 7, 9} *);
	WM_IME_CHAR* = 646 (* {1, 2, 7, 9} *);
	WM_IME_KEYDOWN* = 656 (* {4, 7, 9} *);
	WM_IME_KEYUP* = 657 (* {0, 4, 7, 9} *);
	WM_MDICREATE* = 544 (* {5, 9} *);
	WM_MDIDESTROY* = 545 (* {0, 5, 9} *);
	WM_MDIACTIVATE* = 546 (* {1, 5, 9} *);
	WM_MDIRESTORE* = 547 (* {0, 1, 5, 9} *);
	WM_MDINEXT* = 548 (* {2, 5, 9} *);
	WM_MDIMAXIMIZE* = 549 (* {0, 2, 5, 9} *);
	WM_MDITILE* = 550 (* {1, 2, 5, 9} *);
	WM_MDICASCADE* = 551 (* {0..2, 5, 9} *);
	WM_MDIICONARRANGE* = 552 (* {3, 5, 9} *);
	WM_MDIGETACTIVE* = 553 (* {0, 3, 5, 9} *);
	WM_MDISETMENU* = 560 (* {4, 5, 9} *);
	WM_ENTERSIZEMOVE* = 561 (* {0, 4, 5, 9} *);
	WM_EXITSIZEMOVE* = 562 (* {1, 4, 5, 9} *);
	WM_DROPFILES* = 563 (* {0, 1, 4, 5, 9} *);
	WM_MDIREFRESHMENU* = 564 (* {2, 4, 5, 9} *);
	WM_CUT* = 768 (* {8, 9} *);
	WM_COPY* = 769 (* {0, 8, 9} *);
	WM_PASTE* = 770 (* {1, 8, 9} *);
	WM_CLEAR* = 771 (* {0, 1, 8, 9} *);
	WM_UNDO* = 772 (* {2, 8, 9} *);
	WM_RENDERFORMAT* = 773 (* {0, 2, 8, 9} *);
	WM_RENDERALLFORMATS* = 774 (* {1, 2, 8, 9} *);
	WM_DESTROYCLIPBOARD* = 775 (* {0..2, 8, 9} *);
	WM_DRAWCLIPBOARD* = 776 (* {3, 8, 9} *);
	WM_PAINTCLIPBOARD* = 777 (* {0, 3, 8, 9} *);
	WM_VSCROLLCLIPBOARD* = 778 (* {1, 3, 8, 9} *);
	WM_SIZECLIPBOARD* = 779 (* {0, 1, 3, 8, 9} *);
	WM_ASKCBFORMATNAME* = 780 (* {2, 3, 8, 9} *);
	WM_CHANGECBCHAIN* = 781 (* {0, 2, 3, 8, 9} *);
	WM_HSCROLLCLIPBOARD* = 782 (* {1..3, 8, 9} *);
	WM_QUERYNEWPALETTE* = 783 (* {0..3, 8, 9} *);
	WM_PALETTEISCHANGING* = 784 (* {4, 8, 9} *);
	WM_PALETTECHANGED* = 785 (* {0, 4, 8, 9} *);
	WM_HOTKEY* = 786 (* {1, 4, 8, 9} *);
	WM_PRINT* = 791 (* {0..2, 4, 8, 9} *);
	WM_PRINTCLIENT* = 792 (* {3, 4, 8, 9} *);
	WM_HANDHELDFIRST* = 856 (* {3, 4, 6, 8, 9} *);
	WM_HANDHELDLAST* = 863 (* {0..4, 6, 8, 9} *);
	WM_AFXFIRST* = 864 (* {5, 6, 8, 9} *);
	WM_AFXLAST* = 895 (* {0..6, 8, 9} *);
	WM_PENWINFIRST* = 896 (* {7..9} *);
	WM_PENWINLAST* = 911 (* {0..3, 7..9} *);
	WM_APP* = 32768 (* {15} *);
	WM_USER* = 1024 (* {10} *);
	WMSZ_LEFT* = 1 (* {0} *);
	WMSZ_RIGHT* = 2 (* {1} *);
	WMSZ_TOP* = 3 (* {0, 1} *);
	WMSZ_TOPLEFT* = 4 (* {2} *);
	WMSZ_TOPRIGHT* = 5 (* {0, 2} *);
	WMSZ_BOTTOM* = 6 (* {1, 2} *);
	WMSZ_BOTTOMLEFT* = 7 (* {0..2} *);
	WMSZ_BOTTOMRIGHT* = 8 (* {3} *);

	(* Font system *)
	WGL_FONT_LINES* = 0 (* {} *);
	WGL_FONT_POLYGONS* = 1 (* {0} *);
	LPD_DOUBLEBUFFER* = {0};
	LPD_STEREO* = {1};
	LPD_SUPPORT_GDI* = {4};
	LPD_SUPPORT_OPENGL* = {5};
	LPD_SHARE_DEPTH* = {6};
	LPD_SHARE_STENCIL* = {7};
	LPD_SHARE_ACCUM* = {8};
	LPD_SWAP_EXCHANGE* = {9};
	LPD_SWAP_COPY* = {10};
	LPD_TRANSPARENT* = {12};
	LPD_TYPE_RGBA* = {};
	LPD_TYPE_COLORINDEX* = {0};
	WGL_SWAP_MAIN_PLANE* = {0};
	WGL_SWAP_OVERLAY1* = {1};
	WGL_SWAP_OVERLAY2* = {2};
	WGL_SWAP_OVERLAY3* = {3};
	WGL_SWAP_OVERLAY4* = {4};
	WGL_SWAP_OVERLAY5* = {5};
	WGL_SWAP_OVERLAY6* = {6};
	WGL_SWAP_OVERLAY7* = {7};
	WGL_SWAP_OVERLAY8* = {8};
	WGL_SWAP_OVERLAY9* = {9};
	WGL_SWAP_OVERLAY10* = {10};
	WGL_SWAP_OVERLAY11* = {11};
	WGL_SWAP_OVERLAY12* = {12};
	WGL_SWAP_OVERLAY13* = {13};
	WGL_SWAP_OVERLAY14* = {14};
	WGL_SWAP_OVERLAY15* = {15};
	WGL_SWAP_UNDERLAY1* = {16};
	WGL_SWAP_UNDERLAY2* = {17};
	WGL_SWAP_UNDERLAY3* = {18};
	WGL_SWAP_UNDERLAY4* = {19};
	WGL_SWAP_UNDERLAY5* = {20};
	WGL_SWAP_UNDERLAY6* = {21};
	WGL_SWAP_UNDERLAY7* = {22};
	WGL_SWAP_UNDERLAY8* = {23};
	WGL_SWAP_UNDERLAY9* = {24};
	WGL_SWAP_UNDERLAY10* = {25};
	WGL_SWAP_UNDERLAY11* = {26};
	WGL_SWAP_UNDERLAY12* = {27};
	WGL_SWAP_UNDERLAY13* = {28};
	WGL_SWAP_UNDERLAY14* = {29};
	WGL_SWAP_UNDERLAY15* = {30};


	TCI_SRCCHARSET* = 1 (* {0} *);
	TCI_SRCCODEPAGE* = 2 (* {1} *);
	TCI_SRCFONTSIG* = 3 (* {0, 1} *);
	TMPF_FIXED_PITCH* = 1 (* {0} *);
	TMPF_VECTOR* = 2 (* {1} *);
	TMPF_DEVICE* = 8 (* {3} *);
	TMPF_TRUETYPE* = 4 (* {2} *);
	NTM_REGULAR* = 64 (* {6} *);
	NTM_BOLD* = 32 (* {5} *);
	NTM_ITALIC* = 1 (* {0} *);
	LF_FACESIZE* = 32 (* {5} *);
	LF_FULLFACESIZE* = 64 (* {6} *);
	OUT_DEFAULT_PRECIS* = 0 (* {} *);
	OUT_STRING_PRECIS* = 1 (* {0} *);
	OUT_CHARACTER_PRECIS* = 2 (* {1} *);
	OUT_STROKE_PRECIS* = 3 (* {0, 1} *);
	OUT_TT_PRECIS* = 4 (* {2} *);
	OUT_DEVICE_PRECIS* = 5 (* {0, 2} *);
	OUT_RASTER_PRECIS* = 6 (* {1, 2} *);
	OUT_TT_ONLY_PRECIS* = 7 (* {0..2} *);
	OUT_OUTLINE_PRECIS* = 8 (* {3} *);

	CLIP_DEFAULT_PRECIS* = 0 (* {} *);
	CLIP_CHARACTER_PRECIS* = 1 (* {0} *);
	CLIP_STROKE_PRECIS* = 2 (* {1} *);
	CLIP_MASK* = 15 (* {0..3} *);
	CLIP_LH_ANGLES* = 16 (* {4} *);
	CLIP_TT_ALWAYS* = 32 (* {5} *);
	CLIP_EMBEDDED* = 128 (* {7} *);
	DEFAULT_QUALITY* = 0 (* {} *);
	DRAFT_QUALITY* = 1 (* {0} *);
	PROOF_QUALITY* = 2 (* {1} *);
	NONANTIALIASED_QUALITY* = 3 (* {0, 1} *);
	ANTIALIASED_QUALITY* = 4 (* {2} *);
	DEFAULT_PITCH* = 0 (* {} *);
	FIXED_PITCH* = 1 (* {0} *);
	VARIABLE_PITCH* = 2 (* {1} *);
	MONO_FONT* = 8 (* {3} *);
	ANSI_CHARSET* = 0 (* {} *);
	DEFAULT_CHARSET* = 1 (* {0} *);
	SYMBOL_CHARSET* = 2 (* {1} *);
	SHIFTJIS_CHARSET* = 128 (* {7} *);
	HANGEUL_CHARSET* = 129 (* {0, 7} *);
	GB2312_CHARSET* = 134 (* {1, 2, 7} *);
	CHINESEBIG5_CHARSET* = 136 (* {3, 7} *);
	OEM_CHARSET* = 255 (* {0..7} *);
	JOHAB_CHARSET* = 130 (* {1, 7} *);
	HEBREW_CHARSET* = 177 (* {0, 4, 5, 7} *);
	ARABIC_CHARSET* = 178 (* {1, 4, 5, 7} *);
	GREEK_CHARSET* = 161 (* {0, 5, 7} *);
	TURKISH_CHARSET* = 162 (* {1, 5, 7} *);
	THAI_CHARSET* = 222 (* {1..4, 6, 7} *);
	EASTEUROPE_CHARSET* = 238 (* {1..3, 5..7} *);
	RUSSIAN_CHARSET* = 204 (* {2, 3, 6, 7} *);
	MAC_CHARSET* = 77 (* {0, 2, 3, 6} *);
	BALTIC_CHARSET* = 186 (* {1, 3..5, 7} *);
	FS_LATIN1* = {0};
	FS_LATIN2* = {1};
	FS_CYRILLIC* = {2};
	FS_GREEK* = {3};
	FS_TURKISH* = {4};
	FS_HEBREW* = {5};
	FS_ARABIC* = {6};
	FS_BALTIC* = {7};
	FS_THAI* = {16};
	FS_JISJAPAN* = {17};
	FS_CHINESESIMP* = {18};
	FS_WANSUNG* = {19};
	FS_CHINESETRAD* = {20};
	FS_JOHAB* = {21};
	FS_SYMBOL* = {31};
	FF_DONTCARE* = 0 (* {} *);
	FF_ROMAN* = 16 (* {4} *);
	FF_SWISS* = 32 (* {5} *);
	FF_MODERN* = 48 (* {4, 5} *);
	FF_SCRIPT* = 64 (* {6} *);
	FF_DECORATIVE* = 80 (* {4, 6} *);
	FW_DONTCARE* = 0 (* {} *);
	FW_THIN* = 100 (* {2, 5, 6} *);
	FW_EXTRALIGHT* = 200 (* {3, 6, 7} *);
	FW_LIGHT* = 300 (* {2, 3, 5, 8} *);
	FW_NORMAL* = 400 (* {4, 7, 8} *);
	FW_MEDIUM* = 500 (* {2, 4..8} *);
	FW_SEMIBOLD* = 600 (* {3, 4, 6, 9} *);
	FW_BOLD* = 700 (* {2..5, 7, 9} *);
	FW_EXTRABOLD* = 800 (* {5, 8, 9} *);
	FW_HEAVY* = 900 (* {2, 7..9} *);
	FW_ULTRALIGHT* = 200 (* {3, 6, 7} *);
	FW_REGULAR* = 400 (* {4, 7, 8} *);
	FW_DEMIBOLD* = 600 (* {3, 4, 6, 9} *);
	FW_ULTRABOLD* = 800 (* {5, 8, 9} *);
	FW_BLACK* = 900 (* {2, 7..9} *);


	(*! Display Modes*)
	DM_SPECVERSION* = {0, 10};
	DM_ORIENTATION* = {0};
	DM_PAPERSIZE* = {1};
	DM_PAPERLENGTH* = {2};
	DM_PAPERWIDTH* = {3};
	DM_SCALE* = {4};
	DM_COPIES* = {8};
	DM_DEFAULTSOURCE* = {9};
	DM_PRINTQUALITY* = {10};
	DM_COLOR* = {11};
	DM_DUPLEX* = {12};
	DM_YRESOLUTION* = {13};
	DM_TTOPTION* = {14};
	DM_COLLATE* = {15};
	DM_FORMNAME* = {16};
	DM_LOGPIXELS* = {17};
	DM_BITSPERPEL* = {18};
	DM_PELSWIDTH* = {19};
	DM_PELSHEIGHT* = {20};
	DM_DISPLAYFLAGS* = {21};
	DM_DISPLAYFREQUENCY* = {22};
	DM_PANNINGWIDTH* = {23};
	DM_PANNINGHEIGHT* = {24};
	DM_ICMMETHOD* = {25};
	DM_ICMINTENT* = {26};
	DM_MEDIATYPE* = {27};
	DM_DITHERTYPE* = {28};
	DM_ICCMANUFACTURER* = {29};
	DM_ICCMODEL* = {30};

	CDS_UPDATEREGISTRY* = {0};
	CDS_TEST* = {1};
	CDS_FULLSCREEN* = {2};

	DISP_CHANGE_SUCCESSFUL* = 0 (* {} *);
	DISP_CHANGE_RESTART* = 1 (* {0} *);
	DISP_CHANGE_FAILED* = -1 (* {0..31} *);
	DISP_CHANGE_BADMODE* = -2 (* {1..31} *);
	DISP_CHANGE_NOTUPDATED* = -3 (* {0, 2..31} *);
	DISP_CHANGE_BADFLAGS* = -4 (* {2..31} *);

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
	HFONT* = HANDLE;
(*	WORD* = INTEGER;*)
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
		dwFlags*:WORDSET ;
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
		dwLayerMask*: WORDSET;
		dwVisibleMask*: WORDSET;
		dwDamageMask*: WORDSET;
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
		style*: DWORD;
		lpszName*: LONGINT;
		lpszClass*:LONGINT;
		dwExStyle*: WORDSET;
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
		style*: DWORD;
		lpszName*: LONGINT;
		lpszClass*: LONGINT;
		dwExStyle*: WORDSET;
	END;
	CREATESTRUCT* = CREATESTRUCTA;

	PGlyphMetricsFloat* = POINTER TO GlyphMetricsFloat;
	GlyphMetricsFloat* = RECORD
		gmfBlackBoxX*: REAL;
		gmfBlackBoxY*: REAL;
		gmfptGlyphOrigin*: User32.PointF;
		gmfCellIncX*: REAL;
		gmfCellIncY*: REAL;
	END;

	LayerPlaneDescriptor* = RECORD
		nSize*: INTEGER;
		nVersion*: INTEGER;
		dwFlags*: WORDSET;
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
		crTransparent*: LONGINT;
	END;

(*! Screen DeviceMode *)
	DEVMODEA* = RECORD
		dmDeviceName*: ARRAY  32 OF CHAR;
		dmSpecVersion*: INTEGER;
		dmDriverVersion*: INTEGER;
		dmSize*: INTEGER;
		dmDriverExtra*: INTEGER;
		dmFields*: SET;
		dmOrientation*: INTEGER;
		dmPaperSize*: INTEGER;
		dmPaperLength*: INTEGER;
		dmPaperWidth*: INTEGER;
		dmScale*: INTEGER;
		dmCopies*: INTEGER;
		dmDefaultSource*: INTEGER;
		dmPrintQuality*: INTEGER;
		dmColor*: INTEGER;
		dmDuplex*: INTEGER;
		dmYResolution*: INTEGER;
		dmTTOption*: INTEGER;
		dmCollate*: INTEGER;
		dmFormName*: ARRAY 32 OF CHAR;
		dmLogPixels*: INTEGER;
		dmBitsPerPel*: LONGINT;
		dmPelsWidth*: LONGINT;
		dmPelsHeight*: LONGINT;
		dmDisplayFlags*: SET;
		dmDisplayFrequency*: LONGINT;
		dmICMMethod*: LONGINT;
		dmICMIntent*: LONGINT;
		dmMediaType*: LONGINT;
		dmDitherType*: LONGINT;
		dmICCManufacturer*: LONGINT;
		dmICCModel*: LONGINT;
		dmPanningWidth*: LONGINT;
		dmPanningHeight*: LONGINT;
	END;
	PtrDEVMODEA* = POINTER TO DEVMODEA;

	DEVMODEW* = RECORD
		dmDeviceName*: ARRAY 32 OF CHAR16;
		dmSpecVersion*: INTEGER;
		dmDriverVersion*: INTEGER;
		dmSize*: INTEGER;
		dmDriverExtra*: INTEGER;
		dmFields*: SET;
		dmOrientation*: INTEGER;
		dmPaperSize*: INTEGER;
		dmPaperLength*: INTEGER;
		dmPaperWidth*: INTEGER;
		dmScale*: INTEGER;
		dmCopies*: INTEGER;
		dmDefaultSource*: INTEGER;
		dmPrintQuality*: INTEGER;
		dmColor*: INTEGER;
		dmDuplex*: INTEGER;
		dmYResolution*: INTEGER;
		dmTTOption*: INTEGER;
		dmCollate*: INTEGER;
		dmFormName*: ARRAY 32 OF CHAR16;
		dmLogPixels*: INTEGER;
		dmBitsPerPel*: LONGINT;
		dmPelsWidth*: LONGINT;
		dmPelsHeight*: LONGINT;
		dmDisplayFlags*: SET;
		dmDisplayFrequency*: LONGINT;
		dmICMMethod*: LONGINT;
		dmICMIntent*: LONGINT;
		dmMediaType*: LONGINT;
		dmDitherType*: LONGINT;
		dmICCManufacturer*: LONGINT;
		dmICCModel*: LONGINT;
		dmPanningWidth*: LONGINT;
		dmPanningHeight*: LONGINT;
	END;
	PtrDEVMODEW* = POINTER TO DEVMODEW;
	DEVMODE* = DEVMODEA;
	PtrDEVMODE* = PtrDEVMODEA;

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
	CreateFont-: PROCEDURE{WINAPI} (nHeight, nWidth, nEscapement, nOrientation, fnWeight,
					fdwItalic, fdwUnderline, fdwStrikeOut, fdwCharSet, fwOutputPrecision, fdwClipPrecision,
					fdwQuality, fdwPitchAndFamily: LONGINT; CONST lpszFace: ARRAY OF CHAR): HFONT;


	(* USER32.dll *)
	AdjustWindowRectEx-: PROCEDURE {WINAPI} (VAR lpRect: User32.Rect (* ADDRESS *); dwStyle: WORDSET; bMenu: BOOL; dwExStyle: WORDSET): BOOL;
	ClientToScreen- : PROCEDURE {WINAPI} (hWnd: HWND; VAR lpPoint: User32.Point): BOOL;
	FindWindow- : PROCEDURE {WINAPI} (CONST lpClassName: ARRAY OF CHAR; CONST lpWindowName: ARRAY OF CHAR): HWND;
	GetDesktopWindow-: PROCEDURE {WINAPI} (): HWND;
	GetWindowDC- : PROCEDURE {WINAPI} (hwin: HWND): HDC;

(*	ChangeDisplaySettingsA-: PROCEDURE {WINAPI} (lpDevMode: ADDRESS; (*DEVMODEA*) dwFlags: SET): LONGINT;
	ChangeDisplaySettingsW- : PROCEDURE {WINAPI} (lpDevMode: ADDRESS (*DEVMODEW*); dwFlags: SET): LONGINT;
*)
	ChangeDisplaySettings-: PROCEDURE{WINAPI} (lpDevMode: ADDRESS (*DEVMODEA*); dwFlags: WORDSET): LONGINT;

(*

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

PROCEDURE SelectObject*(hdc: HDC; hbm: HBITMAP): ;
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
*)

PROCEDURE InitWinApiLibs;
BEGIN
	libgdi := Kernel32.LoadLibrary("GDI32.DLL");

	Kernel32.GetProcAddress(libgdi, "CreateDIBSection", S.VAL(ADDRESS, CreateDIBSection ));
	Kernel32.GetProcAddress(libgdi, "CreatePalette", S.VAL(ADDRESS, CreatePalette ));
	Kernel32.GetProcAddress(libgdi, "GetCurrentObject", S.VAL(ADDRESS, GetCurrentObject ));

	Kernel32.GetProcAddress(libgdi, "GetObjectA", S.VAL(ADDRESS, GetObject ));
	Kernel32.GetProcAddress(libgdi, "GetObjectType", S.VAL(ADDRESS,GetObjectType ));

	Kernel32.GetProcAddress(libgdi, "RealizePalette", S.VAL(ADDRESS, RealizePalette ));
	Kernel32.GetProcAddress(libgdi, "SelectPalette", S.VAL(ADDRESS, SelectPalette ));

	Kernel32.GetProcAddress(libgdi, "ChoosePixelFormat", S.VAL(ADDRESS, ChoosePixelFormat ));
	Kernel32.GetProcAddress(libgdi, "DescribePixelFormat", S.VAL(ADDRESS, DescribePixelFormat ));
	Kernel32.GetProcAddress(libgdi, "GetPixelFormat", S.VAL(ADDRESS, GetPixelFormat ));
	Kernel32.GetProcAddress(libgdi, "SetPixelFormat", S.VAL(ADDRESS, SetPixelFormat ));
	Kernel32.GetProcAddress(libgdi, "SwapBuffers", S.VAL(ADDRESS, SwapBuffers ));
	Kernel32.GetProcAddress(libgdi, "CreateFontW", S.VAL(ADDRESS, CreateFont));


	libuser := Kernel32.LoadLibrary("USER32.DLL");
	Kernel32.GetProcAddress(libuser, "AdjustWindowRectEx", S.VAL(ADDRESS, AdjustWindowRectEx ));
	Kernel32.GetProcAddress(libuser, "ClientToScreen", S.VAL(ADDRESS, ClientToScreen));
	Kernel32.GetProcAddress(libuser, "FindWindowA", S.VAL(ADDRESS, FindWindow));
	Kernel32.GetProcAddress(libuser, "GetDesktopWindow", S.VAL(ADDRESS,GetDesktopWindow ));
	Kernel32.GetProcAddress(libuser, "GetWindowDC", S.VAL(ADDRESS, GetWindowDC ));
	Kernel32.GetProcAddress(libuser, "PeekMessageA", S.VAL(ADDRESS, PeekMessage ));

	Kernel32.GetProcAddress(libuser, "ChangeDisplaySettingsA", S.VAL(ADDRESS, ChangeDisplaySettings ));
(*	Kernel32.GetProcAddress(libuser, "ChangeDisplaySettingsW", S.VAL(ADDRESS, ChangeDisplaySettingsW ));*)

END InitWinApiLibs;

PROCEDURE OnClose;
VAR res: LONGINT;
BEGIN
	IF libuser # Kernel32.NULL THEN
		res := Kernel32.FreeLibrary(libuser);
	END;

	IF libgdi # Kernel32.NULL THEN
		res := Kernel32.FreeLibrary(libgdi);
	END;
END OnClose;

BEGIN
	InitWinApiLibs();
	Modules.InstallTermHandler(OnClose);
END WinApi.
