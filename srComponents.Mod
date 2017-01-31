MODULE WMComponents;	(** AUTHOR "TF"; PURPOSE "Component Framework based on XML"; *)
(**

-- 	Events: --

	Each VisualComponent can produce keyboard and mouse events which can trigger A2 commands.
	The command string for a given event can by specified by the usage of XML attributes and component properties.
	The following attributes are defined:

	Keyboard:  	onReturn, onEscape, onKeyPressed, onKeyReleased
	Mouse: 		onLeftClick, onRightClick, onMiddleClick, onClick

	The command strings are processed (macro substitution) before the actual command is called.

-- 	Macro substitution: --

	General form: "^" [namespace ":"] macrostring

	A macro always start with MacroCharacter ("^"). The next occurence of a whitespace character determines the end of the macro.
	Two consequent MacroCharacter's ("^^") will be replaced by the MacroCharacter ("^") not triggering macro substitution at all.

	The user can install MacroHandlerProcedures for a given namespace. At most one handler per namespace can be installed.
	If the namespace is omitted, the default macro handler is triggered.

	The DefaultMacroHandler currently supports the following macro substitutions:

	^selection			is replaced by the last selection of the user
	^clipboard			is replaced by the content of the clipboard

	^attribute=[component "."] attribute
	^property=[component "."] property

	is replaced by the value of <attribute> or <property>. 
	If the component qualifier is omitted, <attribute> or <property> is supposed to be an attribute or property of the originator of the event.

	If no MacroHandlerProcedure is found for a given macro, no substitution takes place.
	Example:

	onLeftClick = SystemTools.Show ^attribute=generator
	onMiddleClick = SystemTools.Show ^property=FillColor

*)

(*PH 08/14: 
- avoid parallel call of FormWindow.SetContent, Component.AddContent, Form.InvalidateRect by different processes, through use of EXCLUSIVE sections.
- send an "invalidate content" message to a window after it appears on the display, which is handled after "form" field is ready
- restructure FormWindow.SetContent() to assure coherent displays and to assure FormWindow.content is consistent 
*)

IMPORT
	KernelLog, Inputs, Streams, Events, Files, Texts, TextUtilities,
	XML, XMLScanner, XMLParser, XMLObjects, Codecs, Localization, Repositories,
	Messages := WMMessages, Rectangles := WMRectangles,
	WMEvents, WMProperties, WMGraphics, Strings, WM := WMWindowManager, Raster,
	Commands, Modules, Kernel, Locks, Objects, WMDropTarget;

CONST
	Ok* = 0;
	DuplicateNamespace* = 1;

	AlignNone* = 0; AlignLeft* = 1; AlignTop* = 2; AlignRight* = 3; AlignBottom* = 4; AlignClient* = 5; AlignRelative*=6;

	None=0; Left=1; Right=2; Lower=3; Upper=4; LowerRight=5; UpperRight=6; LowerLeft=7; UpperLeft=8; Inside = 9;
	MaxRel = 16*1024;


	MaxComponentNameSize* = 64; (* including 0X *)

	TraceFocus = 0;
	TraceFinalize = 1;
	Trace = {};

	(* Enable event logging? *)
	Logging = TRUE;

	(* Macro handling *)

	(* General form of macro: MacroCharacter [Namespace + NamespaceCharacter] MacroName *)

	MacroCharacter = "^";
	NamespaceCharacter = ":";

	NoNamespace = "";

	(* Namespace used if no namespace is specified *)
	DefaultNamespace = "system";

	(* Macros names of default macro handler *)
	MacroSelection = "selection";
	MacroClipboard = "clipboard";
	MacroAttributePrefix = "attribute=";
	MacroPropertyPrefix = "property=";
	CanYield = TRUE;
	
	(*temporary - to be removed*)
	FlagDirty=13;

TYPE
	(** Installable event preview handlers. Are called by the components sequencer thread *)
	PointerHandler*  = PROCEDURE {DELEGATE} (x, y : LONGINT; keys : SET; VAR handled : BOOLEAN);
	PointerLeaveHandler* = PROCEDURE {DELEGATE} (VAR handled : BOOLEAN);
	DragDropHandler* = PROCEDURE {DELEGATE} (x, y : LONGINT; dragInfo : WM.DragInfo; VAR handled : BOOLEAN);
	DragResultHandler* = PROCEDURE {DELEGATE} (accepted : BOOLEAN; recipient : ANY; dragInfo : WM.DragInfo; VAR handled : BOOLEAN);
	DragAutoStartHandler* = PROCEDURE {DELEGATE} (VAR handled : BOOLEAN);
	FocusHandler* = PROCEDURE {DELEGATE} (hasFocus : BOOLEAN);
	ContextMenuHandler* = PROCEDURE {DELEGATE} (sender : ANY; x, y: LONGINT);
	KeyEventHandler* = PROCEDURE {DELEGATE} (ucs : LONGINT; flags : SET; VAR keySym : LONGINT; VAR handled : BOOLEAN);
	DrawHandler* = PROCEDURE {DELEGATE} (canvas : WMGraphics.Canvas);
	Recursion*= ENUM None*, FromComponent*, FromBottom* END;

TYPE
	SetStringProcedure = PROCEDURE {DELEGATE} (CONST string : ARRAY OF CHAR; x,y : LONGINT; VAR res : LONGINT);

	DropTarget = OBJECT(WMDropTarget.DropTarget)
	VAR
		originator : ANY;
		setString : SetStringProcedure;
		x,y : LONGINT;

		PROCEDURE &Init(originator : ANY; setString : SetStringProcedure; x,y : LONGINT);
		BEGIN
			ASSERT(setString # NIL);
			SELF.originator := originator;
			SELF.setString := setString;
			SELF.x := x;
			SELF.y := y;
		END Init;

		PROCEDURE GetInterface(type : LONGINT) : WMDropTarget.DropInterface;
		VAR sdi : DropString;
		BEGIN
			IF (type = WMDropTarget.TypeString) THEN
				NEW(sdi, originator, setString, x,y); RETURN sdi;
			ELSE
				RETURN NIL;
			END;
		END GetInterface;

	END DropTarget;

	DropString = OBJECT(WMDropTarget.DropString)
	VAR
		originator : ANY;
		setString : SetStringProcedure;
		x,y : LONGINT;

		PROCEDURE &Init(originator : ANY; setString : SetStringProcedure; x,y : LONGINT);
		BEGIN
			ASSERT(setString # NIL);
			SELF.originator := originator;
			SELF.setString := setString;
			SELF.x := x; SELF.y := y;
		END Init;

		PROCEDURE Set(CONST string : ARRAY OF CHAR; VAR res : LONGINT);
		BEGIN
			setString(string, x,y, res);
		END Set;

	END DropString;

	LanguageExtension* = POINTER TO RECORD(Messages.MessageExtension)
		languages* : Localization.Languages;
	END;

	ToggleEditMode* = POINTER TO RECORD
		recursion*: Recursion;
	END;

	Event* = RECORD
	END;

	KeyPressedEvent* = RECORD(Event)
		ucs- : LONGINT;
		flags- : SET;
		keysym- : LONGINT;
	END;

	PointerEvent* = RECORD(Event)
		x-, y-, z- : LONGINT;
		keys- : SET;
	END;

	EventContext* = OBJECT(Repositories.Context)
	VAR
		originator- : Component; (** {originator # NIL} *)
		command- : Strings.String; (** {command # NIL}, immutable *)
		timestamp- : LONGINT;

		PROCEDURE &New*(originator : Component; command : Strings.String; in, arg : Streams.Reader; out, error : Streams.Writer; caller : OBJECT);
		BEGIN
			ASSERT((originator # NIL) & (command # NIL));
			SELF.originator := originator;
			SELF.command := command;
			Init(in, arg, out, error, caller);
		END New;

	END EventContext;

	PointerContext* = OBJECT(EventContext)
	VAR
		pointer- : PointerEvent;
	END PointerContext;

	KeyContext* = OBJECT(EventContext)
	VAR
		key- : KeyPressedEvent;
	END KeyContext;

TYPE
	(** Basic component *)

	ComponentStyleChanged = OBJECT
	END ComponentStyleChanged;

	Component* = OBJECT(Repositories.Component)
	VAR
		sequencer- : Messages.MsgSequencer;
		initialized- : BOOLEAN;

		properties- : WMProperties.PropertyList;
		events- : WMEvents.EventSourceList;
		eventListeners- : WMEvents.EventListenerList;

		id-, uid- : WMProperties.StringProperty;
		enabled- : WMProperties.BooleanProperty;

		 (* discard property changes that come from a property change within the same component*)
		inPropertyUpdate, inLinkUpdate : BOOLEAN;

		(* If TRUE, this component is supposed to be created and managed by its parent. It is not externalized. *)
		internal- : BOOLEAN;

		(* after Init() , calling Reset() implicitely by insertion into FormWindow or explicitely, thereby triggering Initialize() is required to render component responsive to messages *)
		PROCEDURE &Init*;
		BEGIN
			Init^;
			SetNameAsString(StrComponent);
			sequencer := NIL;
			initialized := FALSE;
			NEW(properties); properties.onPropertyChanged.Add(SELF.InternalPropertyChanged); properties.onLinkChanged.Add(SELF.InternalLinkChanged);
			NEW(events);
			NEW(eventListeners);
			NEW(id, PrototypeID, NIL, NIL); properties.Add(id);
			NEW(uid, PrototypeUID, NIL, NIL); properties.Add(uid);
			NEW(enabled, PrototypeEnabled, NIL, NIL); properties.Add(enabled);
			inPropertyUpdate := FALSE;
			inLinkUpdate := FALSE;
			internal := FALSE;
			SetGenerator("WMComponents.N