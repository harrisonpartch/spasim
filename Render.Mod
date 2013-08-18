MODULE Render;
IMPORT SYSTEM, Kernel, Modules,Objects, Random, Marsh, 
 Out := KernelLog, Math,XNXLMath, Base,  Retina,Heaps,
	 X11,  Api := X11Api, GL:=OpenGL, GLC := OpenGLConst,  GLSL:= GLShaderUtils,
	 Inputs, KS := X11KeySymDef, V := XF86VMode, Raster, Graphics:=WMGraphics, Commands,Strings,Streams;

CONST PX=3; (* image size multiplier -- must be 3 for correct foveation! *)
	ML = 0;  MM = 1;  MR = 2;
	Button1Bit = 8; Button2Bit = 9; Button3Bit =10;
	ShiftKeyBit = 0;  ShiftLokBit = 1;  ControlKeyBit = 2;  Mod1KeyBit = 3;
	Mod2KeyBit = 4;  Mod3KeyBit = 5;  Mod4KeyBit = 6;  Mod5KeyBit = 7;	  
	rad2deg=360/6.28318;

TYPE 
	Aperture = Base.Aperture;
	Ray = Base.Ray;
	Voxel = Base.Voxel; 
	PT = Base.PT;
	Float = GL.Float;
	Uint = GL.Uint;
    	Int = GL.Int;
    	Ushort = GL.Ushort;
TYPE SNAP = RECORD
	lookphi, looktheta : REAL;
	aperture: Aperture;
	x,y,z,cdroll: REAL;		
	lookdxyz:PT;
END;	

TYPE Camera = OBJECT
VAR
	random: Random.Generator;
	rayschanged, ang1,filter: BOOLEAN;
	fovealeft, fovearight, foveabottom, foveatop: LONGINT;
	fovea: BOOLEAN;
	cam,worldcenter: PT; 
	d2c:REAL;
	W,H,pointerx,pointery:LONGINT;
	aperture: Aperture;
	iamalargecamera: BOOLEAN;
	lookdxyz:PT;
	cx, cy, cz, cvx, cvy, cvz, cvl, cvu: REAL;   
	xaxis,yaxis,zaxis,UP,down:PT; 
	croll: REAL;
	cdroll: REAL;
	cameratheta,cameraphi: REAL;
	world:Voxel;	
	positionlock, orientationlock, returntohorizon: BOOLEAN;	
	fisheye: REAL;	
	gravity: REAL;

PROCEDURE & init (width, height: INTEGER);
BEGIN
	W := width; H := height;
	filter:=FALSE;
	cameratheta := 0;
	cameraphi := 0;
	aperture.width :=1.5;
	aperture.height :=1.5;
	aperjust(1,1);
	Base.setPT(xaxis, 1,0,0);	
	Base.setPT(yaxis,0,1,0);	
	Base.setPT(zaxis,0,0,-1);	
	Base.setPT(worldcenter,1/2,1/2,1/2);	
	fisheye:=1;
	GLIDE:=0.98;
	hop; 
END init;

PROCEDURE aperjust(w,h: INTEGER);
BEGIN
	aperture.width :=aperture.width*(w/h);
END aperjust;

PROCEDURE hop;
BEGIN
	stop;
	cx :=1/2+Base.rand.Uniform()/2; cy:=1/2+Base.rand.Uniform()/2; cz := 1/2+Base.rand.Uniform()/2;
END hop;

PROCEDURE move;
VAR
	face: INTEGER;
	x,y,z,d: REAL;
	v, target: Voxel;
	p,q,normal: PT;
	proberay: Ray;
	pass,slower: BOOLEAN;

PROCEDURE normalize(VAR x,y,z,d: REAL);
BEGIN
	d := Math.sqrt(x*x + y*y+z*z);
	x := x/d; y := y/d; z:=z/d
END normalize;	

PROCEDURE denormalize(VAR x,y,z,d: REAL);
BEGIN
	x := x*d; y := y*d; z:=z*d
END denormalize;	

PROCEDURE reflect(VAR x,y,z: REAL; nx,ny,nz:REAL);
VAR 
	dot: REAL;
BEGIN
	dot := x*nx+y*ny+z*nz;
	nx := 2*nx*dot; ny := 2*ny*dot; nz := 2*nz*dot;
	x := x-nx; y := y-ny; z := z-nz; 
END reflect;

BEGIN

	x := cx + cvx; y := cy + cvy; z := cz + cvz;
	p:=Base.mkPT(x,y,z);
	v := Base.world.probe(p,200);
	pass := Base.world.passprobe(p);

	IF ~pass THEN
		x := cx + cvx; y := cy + cvy; z := cz;	
		q:=Base.mkPT(x,y,z);
		pass := Base.world.passprobe(q);
		IF pass THEN 
			cvz:=-cvz/2
		ELSE
			x := cx + cvx; y := cy; z := cz+cvz;	
			q:=Base.mkPT(x,y,z);
			pass := Base.world.passprobe(q);
			IF pass THEN 
				cvy:=0
			ELSE			
				x := cx; y := cy + cvy; z := cz+cvz;	
				q:=Base.mkPT(x,y,z);
				pass := Base.world.passprobe(q);
				IF pass THEN 
					cvx:=0 
				END
			END
		END
	END;
	IF  pass THEN 
		cx:=x; cy:=y; cz:=z 
	ELSE
		Base.world.Shade(proberay);
		normalize(cvx,cvy,cvz,d);
		reflect(cvx, cvy, cvz, proberay.normal.x, proberay.normal.y, proberay.normal.z);
		denormalize(cvx,cvy,cvz,d);	
		cvx:=cvx/2; cvy:=cvy/2; cvz:=cvz/2; 
	END;
	IF cx<0 THEN cx:=cx+1
	ELSIF cx>1 THEN cx:=cx-1
	END;
	IF cy<0 THEN cy:=cy+1
	ELSIF cy>1 THEN cy:=cy-1
	END;
	IF cz<0 THEN cz:=cz+1
	ELSIF cz>1 THEN cz:=cz-1
	END;	
END move; 

PROCEDURE stop;
BEGIN
	cvx:=0;
	cvy:=0;
	cvz:=0;
END stop;

PROCEDURE glidetoggle;
BEGIN
	IF GLIDE<1/2 THEN GLIDE:=0.95 ELSE GLIDE:=0.3 END;
END glidetoggle;

PROCEDURE forward(x:REAL);
VAR
	fward:PT;
BEGIN
	fward:=Retina.fward;
	cvx :=cvx+(x*fward.x * Base.speed); 
	cvy :=cvy+(x*fward.y * Base.speed); 	
	cvz :=cvz+(x*fward.z * Base.speed); 	
END forward;

PROCEDURE backward(x:REAL);
VAR	
	fward:PT;
BEGIN
	fward:=Retina.fward;	
	cvx :=cvx-(x*fward.x * Base.speed); 
	cvy :=cvy-(x*fward.y * Base.speed); 	
	cvz :=cvz-(x*fward.z * Base.speed); 	
END backward;

PROCEDURE rightstrafe(x:REAL);
VAR
	rward:PT;
	ray: Base.Ray;
BEGIN
	rward:=Retina.rward;
	rward:=Base.mulPT(rward,-1);
	cvx :=cvx+(x*rward.x * Base.speed); 
	cvy :=cvy+(x*rward.y * Base.speed); 	
	cvz :=cvz+(x*rward.z * Base.speed); 	
END rightstrafe;

PROCEDURE leftstrafe(x:REAL);
VAR
	lward:PT;
	ray: Base.Ray;
BEGIN
	lward:= Retina.rward;
	cvx :=cvx+(x*lward.x * Base.speed); 
	cvy :=cvy+(x*lward.y * Base.speed); 	
	cvz :=cvz+(x*lward.z * Base.speed); 	
END leftstrafe;

PROCEDURE upstrafe(x:REAL); (* strafe up perpendicular to look *)
VAR
	up:PT;
	ray: Base.Ray;
BEGIN
	up:=Retina.dward;
	up:=Base.mulPT(up,-1);
	cvx :=cvx+(x*up.x * Base.speed); 
	cvy :=cvy+(x*up.y * Base.speed); 	
	cvz :=cvz+(x*up.z * Base.speed); 	
END upstrafe;

PROCEDURE downstrafe(x:REAL);
VAR
	down:PT;
	ray: Base.Ray;
BEGIN
	down:=Retina.dward;
	cvx :=cvx+(x*down.x * Base.speed); 
	cvy :=cvy+(x*down.y * Base.speed); 	
	cvz :=cvz+(x*down.z * Base.speed); 	
END downstrafe;

PROCEDURE trace;
VAR
	t,p,h,w: REAL;
BEGIN
	Retina.go(cameratheta,cameraphi,aperture.width,aperture.height); 
END trace; 

PROCEDURE left (th: REAL);
BEGIN
	IF ~orientationlock THEN
		cvl:=cvl+th;
		cameratheta:=cameratheta+cvl;
		IF cameratheta> 6.28 THEN cameratheta := cameratheta-6.28 END;
		IF cameratheta< -6.28 THEN cameratheta := cameratheta+6.28 END
	END
END left;

PROCEDURE up (ph: REAL);
BEGIN
	cvu:=cvu+ph;
	cameraphi := cameraphi + cvu;
	IF cameraphi > 1.6 THEN cameraphi := 1.6 END;
	IF cameraphi < -1.6 THEN cameraphi := -1.6 END 	
END up;

PROCEDURE tick;
VAR
	oldcam:PT;
	a,b,c,d,e,f: REAL;
	gravityvector: PT;
	gravity: REAL;
BEGIN
	move;	
	cam.x := cx; cam.y := cy; cam.z := cz;
(*	gravityvector:=Base.subPT(worldcenter,cam);	*)
	gravityvector:=Base.mkPT(0,0,1);		
	gravity:=Base.gravity;
	gravityvector:=Base.mulPT(gravityvector,Base.gravity);
	a:=Retina.fward.x*Base.cursordist; b:=Retina.fward.y*Base.cursordist; c:=Retina.fward.z*Base.cursordist;
	d:=Retina.fward.x*0.0001; 	e:=Retina.fward.y*0.0001;  	f:=Retina.fward.z*0.0001; 
	Base.updatecamera(cx,cy,cz,a,b,c,d,e,f);	
(*	Marsh.drawavatar;  *)
	GLIDE:=0.975;	
	cvz := cvz*GLIDE+gravityvector.z; 
	cvx := cvx*GLIDE+gravityvector.x; cvy := cvy*GLIDE+gravityvector.y; 
	cvl :=cvl*0.0; cvu := cvu*0.0;
	IF AVATAR THEN Marsh.drawavatar END;
	IF MOUSEDOWN THEN
		IF MB=3 THEN 
			Marsh.drawcursor; 
		ELSIF MB=1 THEN Marsh.draw
		END;
	END;	
	trace; 
	Base.tick;
END tick;
 
END Camera;

VAR
	FRAMERATE: REAL;
	rand: Random.Generator;
	wcount: INTEGER;
	frame, tickframe: LONGINT;
	movierecording, movieplaying: BOOLEAN; 
	frtrace, foveate: BOOLEAN;
	foveasize, fovealeft, fovearight, foveadown, foveaup: LONGINT;
	DEATH, wLOOK, MOUSEDOWN, PAUSE: BOOLEAN;
	tracetiled,avtoggle, capturethemouse: BOOLEAN;
	framecount: LONGINT;
	multicore,filtor,uplock,rollcam,suppressz: BOOLEAN;
	camrotinertia:REAL;
	framedt: REAL;
	pkeys: SET;	
	pointerx, pointerdx, pointery, pointerdy: LONGINT;
	R1,R2: REAL;
	xbuttons: SET;
	compstatus: X11.ComposeStatus;
	update: LONGINT;
	MMseen, MRseen: BOOLEAN;	
	noEventCount: LONGINT;
	display : X11.DisplayPtr;
	screen:LONGINT;
	win : X11.Window ;
	GLCtx : GL.GLXContext;  
	fullscreen, fullwindow, windecorations : BOOLEAN;	
	doubleBuffered: BOOLEAN;   	
	winAttr : Api.XSetWindowAttributes; (* set window attributes*)
	wmDelete: X11.Atom;	
	W,H, width, height, mousex, mousey : LONGINT; (* size of window *)
	desktopMode: V.XF86VidModeModeInfo;
	event: Api.XEvent;  
	keySymbol: ARRAY 256 OF LONGINT;
	currX, currY: LONGINT;
	alive, debug, debugevents : BOOLEAN; (* for main loop control *)	
	drawMode:LONGINT; (* fill, lines, points *)
	texture: ARRAY [3] OF GL.Int;  (* Storage For 3 Textures  *)
	LightAmbient, LightDiffuse, LightPosition: ARRAY [4] OF GL.Float;
	LightAmbient2, LightDiffuse2, LightPosition2: ARRAY [4] OF GL.Float;	
	red, green, blue, lightPos: ARRAY [4] OF GL.Float; 
	xrot, yrot, zrot: REAL;  (* X, Y  rotation *)
	axis: CHAR;
	z, zee : REAL; (* depth into the screen *)
	xspeed, yspeed: REAL;
	light, blend,raster: BOOLEAN; (* Whether or not lighting is on,  Whether or not blending is on *)
	filter: LONGINT; (* type of filter *)		
	ptlist: LONGINT;	
	CAPTUREMOUSE, GO,TRAIL,AVATAR,SCULL,METASLASH: BOOLEAN;	
	camera:Camera;
	fogdensity:REAL;
	leftsticky,upsticky: REAL;
	centerx,centery: LONGINT;
	MB:INTEGER;
	GLIDE:REAL;
	FR: LONGINT;
	positionLocation, texcoordsLocation: Uint;
	passthroughProgram, blurprogram,basetexture: GL.Uint;
	copy : Raster.Mode;
	visinfoptr : Api.VisualInfoPtr; (* pointer to X11 VisualInfo *)
	glctx : GL.GLXContext;  (* GL context *)
	gwa : Api.XWindowAttributes; (* get window attributes *)
	swa : Api.XSetWindowAttributes; (* set window attributes*)
	cmap : X11.Colormap; (* colormap for window *)
	context: Commands.Context; (* StdIO context *)
	curprogram: Uint; (* current active program *)
	progname: ARRAY 32 OF CHAR;
	image: Uint; (* image texture name *)		
	msd: REAL;	

PROCEDURE angletoray(VAR ray: Base.Ray; theta,phi: REAL);
VAR d: REAL;
BEGIN
	ray.dxyz.x := Math.cos(theta) * Math.cos(phi);
	ray.dxyz.y := Math.sin(theta) * Math.cos(phi);
	ray.dxyz.z := Math.sin(phi);
	d := Math.sqrt(ray.dxyz.x*ray.dxyz.x + ray.dxyz.y* ray.dxyz.y+ray.dxyz.z*ray.dxyz.z);  (* Norma! Liza! Ray! Front and center, oh dark thirty!*)
	ray.dxyz.x := ray.dxyz.x/d;
	ray.dxyz.y := ray.dxyz.y/d;
	ray.dxyz.z := ray.dxyz.z/d; 
END angletoray; 

PROCEDURE carttosph(VAR p: PT; theta, phi: REAL);
BEGIN
	p.x := Math.cos(theta) * Math.cos(phi);
	p.y := Math.sin(theta) * Math.cos(phi);
	p.z := Math.sin(phi);
END carttosph; 

PROCEDURE sphtocart( p: PT; VAR theta, phi: REAL);
VAR
	x,y, z: REAL;
BEGIN
	x := p.x; y := p.y; z := 0;
	Base.normalize(x,y,z);
	theta := XNXLMath.arccos(x);	
	phi := XNXLMath.arccos(1-p.z);
END sphtocart;

PROCEDURE ddray(VAR ray: Base.Ray); 
BEGIN
	ray.ddxyz.x := ray.dxyz.x/10000;
	ray.ddxyz.y := ray.dxyz.y/10000;
	ray.ddxyz.z := ray.dxyz.z/10000; 
END ddray; 

PROCEDURE gray(VAR ray: Ray);
VAR
	gray: REAL;
BEGIN
	gray := (ray.r + ray.g + ray.b)/3;
	ray.r := gray; ray.g := gray; ray.b := gray;
END gray;

PROCEDURE speedup;
BEGIN
	IF Base.speed < 	Base.maxspeed THEN Base.speed := Base.speed * 1.5 END
END speedup;

PROCEDURE slowdown;
BEGIN
	IF Base.speed > 0.00000000001 THEN Base.speed := Base.speed/1.5 END
END slowdown;

PROCEDURE cursorpush;
BEGIN
	Base.cursordist:=Base.cursordist*1.1
END cursorpush;

PROCEDURE cursorpull;
BEGIN
	Base.cursordist:=Base.cursordist*0.9 
END cursorpull;

PROCEDURE vlnext;
BEGIN
	Marsh.	incVN;
END vlnext;

PROCEDURE vllast;
BEGIN
	Marsh.	decVN;
END vllast;

PROCEDURE cursorsizeplus;
BEGIN
	Marsh.	cursorsize:=ENTIER(Marsh.cursorsize/1.5)
END cursorsizeplus;

PROCEDURE cursorsizeminus;
BEGIN
	Marsh.	cursorsize:=ENTIER(Marsh.cursorsize*1.5)
END cursorsizeminus;

(************** XLTL AMALGAMATION FOLLOWS *)

PROCEDURE Reshape(w, h: LONGINT);
BEGIN	
	GL.Viewport(0, 0, w, h);
	GL.ClearColor(0.0, 0.0, 0.0, 0.0);
	GL.MatrixMode(GLC.GL_PROJECTION);
	GL.LoadIdentity();
	GL.Frustum(-1,1,-1,1, 0.5, 60); 
	GL.MatrixMode(GLC.GL_MODELVIEW);
	GL.LoadIdentity(); 
	centerx:= w DIV 2; centery:= h DIV 2;
END Reshape;

PROCEDURE GLClose;
VAR res: LONGINT;
BEGIN
	(* do we have a rendering context *)
	IF GLCtx # 0 THEN
		(* Release the context *)
	    	res := GL.glXMakeCurrent(display, 0, 0);
	    	(* Delete the context *)
		GL.glXDestroyContext(display, GLCtx);
		GLCtx := 0;
	END;
	(* switch back to original desktop resolution if we were in fullscreen *)
	IF fullscreen THEN                                                                             
		res := V.XF86VidModeSwitchToMode(display, screen, desktopMode);
		res := V.XF86VidModeSetViewPort(display, screen, 0, 0); 
	END;                 	
	(* do we have a window *)
	IF win # 0 THEN
		(* Unmap the window*)
		Api.UnmapWindow(display, win);
		(* Destroy the window *)
		res:= Api.DestroyWindow(display, win);
		win := 0;
	END;	
	(* do we have a display *)
	IF display # 0 THEN	
		res := Api.CloseDisplay(display);
	END;
END GLClose;

PROCEDURE Close*;
VAR i: INTEGER;
BEGIN
	Base.worldalive:=FALSE;
	GLClose;
END Close;
	
PROCEDURE  CreateWindow(w, h: LONGINT; CONST title: ARRAY OF CHAR);
VAR
	res: LONGINT;
	masks: LONGINT;
	buf: X11.Buffer;
	attrib : ARRAY [*] OF GL.Int;  (* attributes of GL window *)

BEGIN
 display := X11.OpenDisplay(0);
 IF display =0 THEN
 	Out.String(" cannot connect to X server"); Out.Ln; ;
	Close;
     RETURN;
END;

(*  NEW(attrib, 7);
  attrib[0] := GLC.GLX_RGBA;
  attrib[1] := GLC.GLX_DEPTH_SIZE; attrib[2] := 24;
  attrib[3] := GLC.GLX_STENCIL_SIZE; attrib[4] := 8;
  attrib[5] := GLC.GLX_DOUBLEBUFFER; attrib[6] := 0 ;
*)
(*
 attrib := [GLC.GLX_RGBA, GLC.GLX_DOUBLEBUFFER, GLC.GLX_DEPTH_SIZE,  24, 0];
 *)
 NEW(attrib, 13);
 attrib[0] := GLC.GLX_RGBA;
  attrib[1] := GLC.GLX_DOUBLEBUFFER;
  attrib[2] := GLC.GLX_DEPTH_SIZE;	attrib[3] := 24;
  attrib[4] := GLC.GLX_STENCIL_SIZE;	attrib[5] := 8;
  attrib[6] := GLC.GLX_RED_SIZE;  	attrib[7] := 8;
  attrib[8] := GLC.GLX_GREEN_SIZE;	attrib[9] := 8;
  attrib[10] := GLC.GLX_RED_SIZE;	attrib[11] := 8;
  attrib[12] := 0 ;

 (* try to find a visual with this attribs *)
 visinfoptr := GL.glXChooseVisual(display, 0 , ADDRESSOF(attrib[0]));

 IF visinfoptr = NIL THEN
  	IF debug THEN Out.String(" NO appropriate visual found"); Out.Ln; END;
  	Close;
     RETURN;
 ELSE
	 IF debug THEN
		 Out.String("visinfoptr.depth= "); Out.Int(visinfoptr.depth,0); Out.Ln;
	 	Out.String("visinfoptr.visual ");  Out.Int(visinfoptr.visualID, 0); Out.Ln;
	 	
	END;
END;
 cmap := X11.CreateColormap(display, X11.DefaultRootWindow(display), visinfoptr.visual, X11.AllocNone);
 IF cmap = 0 THEN
 	IF debug THEN
	 	Out.String(" cannot create colormap"); Out.Ln;
	 	X11.GetErrorText(display, cmap, buf, LEN(buf));
	 	Out.String("ERROR: CreateColormap = "); Out.String(buf); Out.Ln;
	 
 	END;
 END;

 (* window event masks *)
 masks :=  Api.KeyPressMask + Api.KeyReleaseMask + Api.ButtonPressMask + Api.ButtonReleaseMask + Api.PointerMotionMask +
 Api.ButtonMotionMask + Api.ExposureMask + Api.StructureNotifyMask + Api.FocusChangeMask;

  (* window attributes *)
 swa.backgroundPixel := 0;
 swa.borderPixel := 0;
 swa.colormap := cmap;
 swa.eventMask := masks;

 masks := Api.CWBackPixel + Api.CWBorderPixel + Api.CWColormap + Api.CWEventMask;

 win := Api.CreateWindow(display, X11.DefaultRootWindow(display), 0, 0, w, h,
		        0, visinfoptr.depth, Api.InputOutput,  visinfoptr.visual, masks, swa);

 (* show window *)
  Api.MapWindow(display, win);

 (* set title of window *)
 res := Api.StoreName(display, win, title);

(* create GL context *)
 (* GL_TRUE: Use direct rendering, GL_FLASE: use X server for rendering *)
 glctx := GL.glXCreateContext(display, visinfoptr, 0, GLC.GL_TRUE);
	 IF debug THEN Out.String("glXCreateContext glctx= "); Out.Int(glctx, 0); Out.Ln; END;

 res := GL.glXMakeCurrent(display, win, glctx);
	IF debug THEN  Out.String("glXMakeCurrent res= "); Out.Int(res, 0); Out.Ln; END;

SuppressX11Cursors(display,win);

END CreateWindow;

 PROCEDURE SuppressX11Cursors( disp: X11.DisplayPtr; win: X11.Window);
VAR
	fg : X11.Color;
	pixmap: X11.Pixmap;
	noCursor: X11.Cursor;
	data: ARRAY 8 OF CHAR;
	i : LONGINT;
	BEGIN
	fg.red := 0;  fg.green := 0;  fg.blue :=0;
	FOR i:=0 TO 7 DO data[i] := 0X  END;
	pixmap := X11.CreateBitmapFromData( disp, win, ADDRESSOF( data[0] ), 8, 8 );
	noCursor := X11.CreatePixmapCursor( disp, pixmap, pixmap, ADDRESSOF( fg ), ADDRESSOF( fg ), 0, 0 );
	X11.DefineCursor( disp, win, noCursor ); 
END SuppressX11Cursors;

PROCEDURE Wr(CONST str: ARRAY OF CHAR);
BEGIN
	IF debugevents THEN Out.String(str); Out.Ln END;
END Wr;

PROCEDURE CheckAlternateKeys( VAR mb: SET );
BEGIN
	IF ~MMseen & (ControlKeyBit IN xbuttons) THEN INCL( mb, MM ) END;
	IF ~MRseen & (Mod1KeyBit IN xbuttons) THEN INCL( mb, MR ) END
END CheckAlternateKeys;


PROCEDURE SendMouseMsg( x, y, dz: LONGINT; xbuttons: SET );
VAR mm: Inputs.AbsMouseMsg;
BEGIN
	mm.keys := {};
	mm.x := x;  mm.y := y;  mm.dz := dz;
	IF Button1Bit IN xbuttons THEN  INCL( mm.keys, ML )  END;
	IF Button2Bit IN xbuttons THEN  INCL( mm.keys, MM );  MMseen := TRUE  END;
	IF Button3Bit IN xbuttons THEN  INCL( mm.keys, MR );  MRseen := TRUE  END;
	IF ~(MMseen & MRseen) THEN  CheckAlternateKeys( mm.keys )  END;
(*	Inputs.mouse.Handle( mm );*)
	mousex := x; mousey:= y;
END SendMouseMsg;

PROCEDURE SendKeyboardMsg( km: Inputs.KeyboardMsg );
BEGIN
     IF km.ch='q' THEN alive := FALSE; END;
END SendKeyboardMsg;

PROCEDURE KeyState( ): SET;
VAR keys: SET;
BEGIN
	keys := {};
	IF ShiftKeyBit IN xbuttons THEN  INCL( keys, Inputs.LeftShift )  END;
	IF ControlKeyBit IN xbuttons THEN  INCL( keys, Inputs.LeftCtrl )  END;
	IF Mod1KeyBit IN xbuttons THEN  INCL( keys, Inputs.LeftAlt )  END;
	IF Mod4KeyBit IN xbuttons THEN  INCL( keys, Inputs.LeftMeta )  END;
	IF Mod5KeyBit IN xbuttons THEN  INCL( keys, Inputs.RightAlt )  END;
	RETURN keys
END KeyState;

PROCEDURE ToggleFullWindow;
VAR 
	cm: Api.XClientMessageEvent;
	xev: Api.XEvent;
	dl: Api.Data40l;
	wmstate, wmfullscreen: X11.Atom;
	res: LONGINT;
BEGIN
	wmstate := Api.InternAtom(display, "_NET_WM_STATE", Api.False);
	wmfullscreen := Api.InternAtom(display, "_NET_WM_STATE_FULLSCREEN", Api.False);
	fullwindow := ~ fullwindow;
	cm.typ := Api.ClientMessage;
	cm.window := win;
	cm.messageType := wmstate;
	cm.format := 32;
	IF fullwindow THEN dl[0] := 1; ELSE dl[0] := 0; END;
	dl[1] := wmfullscreen;
	dl[2] := 0;
	cm.data:=SYSTEM.VAL(Api.Data40, dl);
	xev := SYSTEM.VAL(Api.XEvent, cm);
	res := Api.SendEvent(display, X11.DefaultRootWindow(display), Api.False, Api.SubstructureNotifyMask, ADDRESSOF(xev));
END ToggleFullWindow;

PROCEDURE PollXQueue;
VAR   
	 keysym: X11.KeySym;
	 cm: Api.XClientMessageEvent;
	 ke: Api.XKeyEvent;
	 be: Api.XButtonEvent;
	 cn : Api.XConfigureEvent;
	 ee : Api.XExposeEvent;
	 mne: Api.XMotionEvent;
	 datal: Api.Data40l;
	 atomName: Api.PChar;
	 x,y,xr,yr: LONGINT;
	 warpedthemouse: BOOLEAN;
BEGIN
	WHILE Api.Pending(display) > 0 DO 
			warpedthemouse:=FALSE;
			Api.NextEvent( display, event );
			CASE event.typ OF
			| Api.Expose: 
				ee := SYSTEM.VAL(Api.XExposeEvent, event);
			| Api.ConfigureNotify: 
					cn := SYSTEM.VAL(Api.XConfigureEvent, event);
			                    (* call Reshape only if our window-size changed *)
					IF (cn.width # width) OR  (cn.height # height) THEN
							width := cn.width;
							height := cn.height;
							Reshape(width, height);
					END;				
			| Api.ButtonPress: 
						CAPTUREMOUSE:=TRUE;	
						MOUSEDOWN:=TRUE;
						PAUSE:=FALSE;	
						be := SYSTEM.VAL(Api.XButtonEvent, event);
						CASE be.button OF	
							    Api.Button1:  MB:=1; 
							| Api.Button2:    MB:=2; 
							|  Api.Button3:  MB:=3; 
						 	| Api.Button4: MB:=4; speedup;			
							|Api.Button5: MB:=5; slowdown;
						ELSE
						END
		| Api.ButtonRelease: 
				MOUSEDOWN:=FALSE;
				be := SYSTEM.VAL(Api.XButtonReleasedEvent, event);
				CASE be.button OF
					| Api.Button1:  
					| Api.Button2:  
					| Api.Button3:  
					ELSE  (* ignore *)
					END;				
			| Api.MotionNotify:  
			IF ~warpedthemouse OR TRUE THEN (* only once per frame *)
				mne := SYSTEM.VAL(Api.XMotionEvent, event);			
				x := mne.x; y := mne.y;
				xr := x-centerx; yr :=y-centery;
				MouseVent(xr,yr);	
				IF CAPTUREMOUSE & (ABS(xr)+ABS(yr)>5) THEN
					Api.WarpPointer( display, 0,mne.window, 0,0, 1000,1000, centerx,centery);	
				END;
				warpedthemouse:=TRUE
			END
			| Api.KeyPress: 
				ke := SYSTEM.VAL(Api.XKeyEvent, event);								
				keysym := Api.LookupKeysym(ke, 0);
				KeyEvent(keysym)
				ELSE		
				END;
		END;	
END PollXQueue;

PROCEDURE KeyEvent(keysym: X11.KeySym);	 
VAR
	v: Voxel;   
BEGIN
	CASE keysym OF
		   KS.XK_s1 : camera.backward(0.51)
		| KS.XK_w1 :camera.forward(0.51) 
		| KS.XK_a1 :camera.leftstrafe(0.5)	
		| KS.XK_d1 :camera.rightstrafe(0.5)
		| KS.XK_e1: camera.upstrafe(0.51)
		| KS.XK_q1: camera.downstrafe(0.51)	
		| KS.XK_Escape: IF CAPTUREMOUSE THEN 
							CAPTUREMOUSE := FALSE;
							PAUSE:=TRUE 
						ELSE
							(* alive:=FALSE *)
						END
		|	KS.XK_F1:
				Marsh.engrain;
				Close;
				fullscreen := ~ fullscreen;
		| KS.XK_Up: Wr("K_Up"); 
		| KS.XK_Down: Wr("K_Down"); 
		| KS.XK_F11: ToggleFullWindow;
		| KS.XK_n1: leftsticky:=leftsticky*1.3; upsticky:=upsticky*1.3;
		| KS.XK_m1: leftsticky:=leftsticky/1.3; upsticky:=upsticky/1.3;
		| KS.XK_o1:
		| KS.XK_t1: camera.glidetoggle 
		| KS.XK_v1:Marsh.engrain
		| KS.XK_c1:Marsh.sprout 
		| KS.XK_x1: Marsh.incVN
		| KS.XK_z1: Marsh.decVN		
		| KS.XK_p1:  camera.stop			
		| KS.XK_2 : msd:= msd*10/9
		| KS.XK_3 : 	msd:= msd*9/10
		| KS.XK_4 : Base.gravity:= 1.5*Base.gravity		
		| KS.XK_5 : Base.STOPGO	
		| KS.XK_h1 : camera.hop	
		| KS.XK_space : 	
		| KS.XK_F2: Base.gravity:= -Base.gravity;
		| KS.XK_bracketright: camera.aperture.width := camera.aperture.width * 101/99; camera.aperture.height := camera.aperture.height *101/99
		| KS.XK_bracketleft: camera.aperture.width := camera.aperture.width * 99/101;  camera.aperture.height := camera.aperture.height *99/101
		| KS.XK_9: IF Marsh.cursorsize<999999 THEN Marsh.cursorsize:=Marsh.cursorsize * 2; Base.cursordist:=Base.cursordist/2 END
		| KS.XK_0: IF Marsh.cursorsize>1 THEN Marsh.cursorsize:=Marsh.cursorsize DIV 2; Base.cursordist:=Base.cursordist*2 END
		| KS.XK_7: Base.cursordist:=Base.cursordist*1.3
		| KS.XK_8: Base.cursordist:=Base.cursordist/1.3
		| KS.XK_Control_L: AVATAR:=~AVATAR	
		| KS.XK_Control_R: Marsh.SNIPEINTO:=~Marsh.SNIPEINTO	
		| KS.XK_l1: Marsh.lines:=~Marsh.lines
		| KS.XK_b1: Marsh.showcode;  IF CAPTUREMOUSE THEN CAPTUREMOUSE := FALSE; PAUSE:=TRUE END
	
	ELSE	
	END
END KeyEvent;

PROCEDURE MouseVent(x,y: LONGINT);
VAR
	up,left: REAL;
BEGIN
	left:=ABS(x)*x;
	up:=-ABS(y)*y; 
	camera.up(up/(30000*leftsticky)); 
	camera.left(left/(30000*leftsticky));
END MouseVent;
 

PROCEDURE  InitGL(): BOOLEAN;
		VAR vs, fs: Strings.String;
	vertexPosition, vertexUVID: Uint;
	TextureID: Uint;	
			vertices, texcoords: ARRAY [*] OF Float;
			vertexbuffer, uvbuffer: Uint;			
	BEGIN		
		GL.ReadImplementationProperties;
 (*		IF ~GL.GL_VERSION_2_0 THEN
 			Out.String("Error: your graphic card does not support OpenGL 2.0"); 
 			Out.Ln; Out.Update;
		 	RETURN FALSE;
		 END;
	*)
	Out.String("one");
	Out.Ln;
		IF ~ (GL.GL_ARB_vertex_shader & GL.GL_ARB_fragment_shader) THEN
		Out.String("GL_ARB_vertex_shader and GL_ARB_fragment_shader are not supported"); 
			Out.Ln; 
			RETURN FALSE;
		END;
	Out.String("two");
	Out.Ln;
		(* GL.Read_GL_ARB_Shader_Objects();*)
		GL.ActiveTexture(GLC.GL_TEXTURE0);		


	NEW(Retina.image);
		Out.String("three");
	Out.Ln;
	Raster.Create(Retina.image,Retina.W,Retina.H,Raster.BGRA8888);
	Out.String("four");
	Out.Ln;
	(* create texture object for image *)
	GL.GenTextures(1, ADDRESSOF(image));
	GL.BindTexture(GLC.GL_TEXTURE_2D, image); 
	(* These determine how interpolation is made when image scaled down on up *)
	GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_NEAREST);
	GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_NEAREST);
	GL.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, Retina.image.width, Retina.image.height, 0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, ADDRESSOF(Retina.image.mem[0]));
	Out.String("five");
	Out.Ln;
	(*	passthroughProgram := InitShader("MyDemos/blur2/passthroughVS.glsl", "MyDemos/blur2/passthroughFS.glsl");*)
	vs := VertexSource();
	fs := FragmentSource();
	passthroughProgram := InitTheseShaders(vs, fs);

		
	Out.String("six");
	Out.Ln;
	(* Get a handle for our buffers *)
		vertexPosition := GL.GetAttribLocation(passthroughProgram,  "Position");
		vertexUVID := GL.GetAttribLocation(passthroughProgram, "Texcoords");	
		
		(* Get a handle for our "myTextureSampler" uniform *)
		TextureID  := GL.GetUniformLocation(passthroughProgram, "u_image");
		
		(* A2 Image origin is top-left, opengl's image left-bottom; so, flip it *)
	
		vertices := [-1.0, -1.0,   1.0, -1.0,   1.0, 1.0,
					 -1.0, -1.0,   1.0, 1.0, -1.0, 1.0  ];

		texcoords := [0.0, 1.0,   1.0, 1.0,   1.0, 0.0,
					 0.0, 1.0,    1.0, 0.0,   0.0, 0.0  ];
		
		(* create VBO handles *)
		GL.GenBuffers(1, ADDRESSOF(vertexbuffer));
		GL.BindBuffer(GLC.GL_ARRAY_BUFFER, vertexbuffer);
		GL.BufferData(GLC.GL_ARRAY_BUFFER, LEN(vertices,0)*SIZEOF(Float), ADDRESSOF(vertices[0]), GLC.GL_STATIC_DRAW);

		GL.GenBuffers(1, ADDRESSOF(uvbuffer));
		GL.BindBuffer(GLC.GL_ARRAY_BUFFER, uvbuffer);
		GL.BufferData(GLC.GL_ARRAY_BUFFER, LEN(texcoords,0)*SIZEOF(Float), ADDRESSOF(texcoords[0]), GLC.GL_STATIC_DRAW);

		(* 1rst attribute buffer : vertices *)
	Out.String("seven");
	Out.Ln;
	GL.EnableVertexAttribArray(0);
		GL.BindBuffer(GLC.GL_ARRAY_BUFFER, vertexbuffer);
		GL.VertexAttribPointer(
			vertexPosition, (* The attribute we want to configure *)
			2, (*size *)
			 GLC.GL_FLOAT, (* type *)
			 GLC.GL_FALSE,  (* normalized ? *)
			 0, (* stride *)
			 0); (* array buffer offset *)

		(* 2nd attribute buffer : UVs *)
		GL.EnableVertexAttribArray(1);
		GL.BindBuffer(GLC.GL_ARRAY_BUFFER, uvbuffer);
		
		GL.VertexAttribPointer(
			vertexUVID, (* The attribute we want to configure *)
			2, (* size : U+V => 2 *)
			 GLC.GL_FLOAT, (* type *)
			 GLC.GL_FALSE,  (* normalized ? *)
			 0, (* stride *)
			  0); (* array buffer offset *)

	RETURN TRUE;
END InitGL;

PROCEDURE VertexSource():Strings.String;
VAR sw: Streams.StringWriter;
      buf: Strings.String;
BEGIN
	NEW(sw,256);

	sw.String("attribute vec2 Position;"); sw.Ln;
	sw.String("attribute vec2 Texcoords;"); 	sw.Ln;
	sw.String("varying vec2 v_Texcoords;"); 	sw.Ln;
	
	sw.String("void main(void) {"); 		sw.Ln;
	sw.String("  v_Texcoords = Texcoords;"); 	sw.Ln;
	sw.String("  gl_Position = vec4(Position,0,1);"); 		sw.Ln;
	sw.String("}"); sw.Ln;
	
	NEW(buf, sw.Pos());
	sw.Get(buf^);
	RETURN buf;
END VertexSource;

PROCEDURE FragmentSource():Strings.String;
VAR sw: Streams.StringWriter;
      buf: Strings.String;
BEGIN
	NEW(sw,256);

	sw.String("varying vec2 v_Texcoords;"); sw.Ln;
	sw.String("uniform sampler2D u_image;"); 	sw.Ln;

	sw.String("void main(void) { "); 	sw.Ln;
	sw.String("  gl_FragColor = texture2D(u_image, v_Texcoords);"); sw.Ln;	
	sw.String("} "); 	sw.Ln;
	NEW(buf, sw.Pos());
	sw.Get(buf^);
	RETURN buf;
END FragmentSource;


PROCEDURE InitTheseShaders(vertexShader, fragmentShader: Strings.String): Uint;
	VAR program: Uint;
		location: Int;

	BEGIN
		IF  ~GLSL.LoadTheseShaders(vertexShader, fragmentShader, program) THEN RETURN 0 END;
		GL.UseProgram(program);

		location := GL.GetUniformLocation(program, "u_image");
		IF location # -1 THEN GL.Uniform1i(location, 0); END;

		RETURN program;
END InitTheseShaders;

PROCEDURE Display();
BEGIN
	GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT) ;
	GL.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, Retina.image.width, Retina.image.height,  0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, Retina.image.adr);
	GL.DrawArrays(GLC.GL_TRIANGLES, 0, 2*3);  (* 2*3 indices starting at 0 -> 2 triangles *)	     		
	GL.glXSwapBuffers(display, win);
END Display;

PROCEDURE mainloop;
VAR
	timer: Kernel.Timer;
	ftimer: Kernel.MilliTimer;
	fms,fmsum: LONGINT;
	ft: ARRAY 10 OF LONGINT;
	i,ii: LONGINT;
BEGIN
	alive:=TRUE;
	NEW(timer);
	NEW(rand);
	WHILE alive DO
		i:=(i+1)MOD 10;
		Base.rnf:=i/10;
		Kernel.SetTimer(ftimer,1000);
		PollXQueue; 
		IF ~PAUSE THEN 
			camera.tick; 
			Display;
			ft[i]:=Kernel.Elapsed(ftimer);
			fmsum:=0;
			FOR ii:=0 TO 9 DO
				fmsum:=fmsum+ft[ii]
			END;
			fms:=fmsum DIV 10; 
			IF ft[i]<msd THEN Retina.moredetail ELSIF ft[i]>(msd+10) THEN Retina.lessdetail END;
			IF i=9 THEN 	
				fmsum:=0;
				Out.Int(fms, 6); 
				Out.Ln 
			END;
		ELSE
			Objects.Sleep(300)
		 END;
	END;
END mainloop;	

PROCEDURE openwincam(w,h: INTEGER);
BEGIN
	CreateWindow(w,h,"SPASIM" );
	NEW(camera,Retina.W, Retina.H); 
	camera.aperjust(w,h);
END openwincam;

PROCEDURE Open* ;
BEGIN
	openwincam(720,480);
	IF ~InitGL() THEN Close; RETURN END; 	
	Raster.InitMode(copy, Raster.srcCopy);
	Marsh.dawn;	
	alive:=TRUE;
	NEW(rand);
	foveasize := 100;
	multicore:=TRUE;
	camrotinertia:=100;
	Base.DTL:=2500;
	Base.DTL2:=2500;
	Base.gravity:=0.0000001;
	Base.speed:=0.000001;
	Base.maxspeed:=0.0001;
	Base.cursordist:=0.01;
	R1:=100;
	R2:=150;
	avtoggle:=TRUE;
	Base.worldalive := TRUE;
	debugevents:=FALSE;
	mousex:=200;
	mousey:=200;
	centerx:=200;
	centery:=200;
	fogdensity:=0.11;
	leftsticky:=10.0;
	upsticky:=10.0;	
	Out.String('*line 1043!*');
	msd:=40;
	mainloop; 
	FR:=1000;		
END Open;

BEGIN

END Render.