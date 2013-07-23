MODULE XLTLNeoRender; (** AUTHOR "fnecati"; PURPOSE ""; *)
 (* axolotl-felix GL implemetation in Oberon
 	http://code.google.com/p/axolotl-felix/ *)
 
IMPORT
	XLTLBase, XLTLGL, Objects, Commands, X11,  
	Api := X11Api, GL:=OpenGL, GLC := OpenGLConst, Kernel, Inputs, KS := X11KeySymDef, V := XF86VMode, 
	Math, XLTLMath,  SYSTEM, Random,
	 Out:=KernelLog, XLTLRetina, XLTLMarsh, XLTLCellAutoVox, XLTLAudio;
	  
CONST
	ML = 0;  MM = 1;  MR = 2;
	Button1Bit = 8; Button2Bit = 9; Button3Bit =10;
	ShiftKeyBit = 0;  ShiftLokBit = 1;  ControlKeyBit = 2;  Mod1KeyBit = 3;
	Mod2KeyBit = 4;  Mod3KeyBit = 5;  Mod4KeyBit = 6;  Mod5KeyBit = 7;	  
	TR = XLTLBase.TR;
	rad2deg=360/6.28318;
TYPE PChar = POINTER TO ARRAY OF CHAR;
	
TYPE Hints = RECORD
		flags: SET;
		functions: LONGINT;
		decorations: LONGINT;
		inputMode: LONGINT;
		status: LONGINT
	END;
TYPE Ray = XLTLBase.Ray;
TYPE Voxel = XLTLBase.Voxel; 
TYPE PT = XLTLBase.PT;
TYPE Aperture = XLTLBase.Aperture;

VAR
	xbuttons: SET;
	timeStart: LONGINT;   (* milliseconds *)
	compstatus: X11.ComposeStatus;
	update: LONGINT;
	MMseen, MRseen: BOOLEAN;	
	noEventCount: LONGINT;
	display : X11.DisplayPtr;
	screen:LONGINT;
	win : X11.Window ;
	glctx : GL.GLXContext;  
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
	rand:Random.Generator;
	drawMode:LONGINT; (* fill, lines, points *)
	texture: ARRAY [3] OF GL.GLuint;  (* Storage For 3 Textures  *)
	LightAmbient, LightDiffuse, LightPosition: ARRAY [4] OF GL.GLfloat;
	LightAmbient2, LightDiffuse2, LightPosition2: ARRAY [4] OF GL.GLfloat;	
	red, green, blue, lightPos: ARRAY [4] OF GL.GLfloat; 
	xrot, yrot, zrot: REAL;  (* X, Y  rotation *)
	axis: CHAR;
	z, zee : REAL; (* depth into the screen *)
	xspeed, yspeed: REAL;
	light, blend: BOOLEAN; (* Whether or not lighting is on,  Whether or not blending is on *)
	filter: LONGINT; (* type of filter *)		
	ptlist: LONGINT;	
	CAPTUREMOUSE, GO: BOOLEAN;	
	camera:Camera;
	fogdensity:REAL;
	leftsticky,upsticky: REAL;
	centerx,centery: LONGINT;


TYPE Camera = OBJECT
VAR
	rayschanged, ang1,filter: BOOLEAN;
	fovealeft, fovearight, foveabottom, foveatop: LONGINT;
	aperture: Aperture;
	frame: LONGINT;
	fovea: BOOLEAN;
	cam: PT;
	lookdxyz:PT;
	cx, cy, cz, cvx, cvy, cvz, cvl, cvu: REAL;   
	fward,bward,rward,rward2, lward,upward, down, down2, right,xaxis,yaxis,zaxis:PT; 
	croll: REAL;
	cdroll: REAL;
	cameratheta,cameraphi: REAL;
	world:Voxel;	
	positionlock, orientationlock, returntohorizon, suppressz: BOOLEAN;		
	oldcam:PT;
	a,b,c: REAL;	
	tracing, Go:BOOLEAN;
	gravity, swimbladder: BOOLEAN;
	mwheelmode: INTEGER;
	TRAIL, FUSETRAIL, AVATAR, AALIGN,CCBUFFER: BOOLEAN;
		
PROCEDURE & init;
BEGIN
	W:=XLTLBase.W;
	H:=XLTLBase.H;
	filter:=TRUE;
	AVATAR:=TRUE;
	cam.x:=0.52;
	cam.y:=0.52;
	cam.z:=0.6;
	cameratheta := 0;
	cameraphi := 0;
	aperture.width :=1.6;
	aperture.height :=1.6;
	initrays;
	XLTLBase.setPT(xaxis,1,0,0);
	XLTLBase.setPT(yaxis,0,-1,0);	
	XLTLBase.setPT(zaxis,0,0,-1);
END init;

PROCEDURE hop;
BEGIN
	cam.x :=1/2+(rand.Uniform()-1/2)/7; 
	cam.y:=1/2+(rand.Uniform()-1/2)/7; 
	cam.z := 1/2+(rand.Uniform()-1/2)/7; 
END hop;

PROCEDURE stop;
BEGIN
	XLTLBase.speed := XLTLBase.speed/1.05;
	cvx:=0;
	cvy:=0;
	cvz:=0;
	cvl:=0;
	cvu:=0;
END stop;

PROCEDURE speedup;
BEGIN
	IF XLTLBase.speed < 0.01 THEN XLTLBase.speed := XLTLBase.speed * 1.3 END;
END speedup;

PROCEDURE slowdown;
BEGIN
	IF XLTLBase.speed > 0.0000001 THEN XLTLBase.speed := XLTLBase.speed/1.3 END;
END slowdown;

PROCEDURE deathray(x,y: LONGINT);
BEGIN
	initrays;
	XLTLBase.world.deathray(XLTLBase.rays[x,y]);
END deathray;

PROCEDURE forward;
VAR
	v: PT;
BEGIN
	IF AALIGN THEN v:=xaxis ELSE v:=fward END;
	cvx := v.x * XLTLBase.speed; 
	cvy := v.y * XLTLBase.speed; 	
	cvz := v.z * XLTLBase.speed; 	
END forward;

PROCEDURE backward;
VAR
	v: PT;
BEGIN
	IF AALIGN THEN v:=xaxis ELSE v:=fward END;
	cvx := -v.x * XLTLBase.speed; 
	cvy := -v.y * XLTLBase.speed; 	
	cvz := -v.z * XLTLBase.speed; 	
END backward;

PROCEDURE rightward;
VAR
	v: PT;
BEGIN
	IF AALIGN THEN v:=yaxis ELSE v:=rward2 END;
	cvx := v.x * XLTLBase.speed; 
	cvy := v.y * XLTLBase.speed; 	
	cvz := v.z * XLTLBase.speed; 	
END rightward;

PROCEDURE leftward;
VAR
	v: PT;
BEGIN
	IF AALIGN THEN v:=yaxis ELSE v:=rward2 END;
	cvx := -v.x * XLTLBase.speed; 
	cvy := -v.y * XLTLBase.speed; 	
	cvz := -v.z * XLTLBase.speed; 	
END leftward;

PROCEDURE upstrafe; (* strafe up perpendicular to look *)
VAR
	v: PT;
BEGIN
	IF AALIGN THEN v:=zaxis ELSE v:=down2 END;
	cvx := v.x * XLTLBase.speed; 
	cvy := v.y * XLTLBase.speed; 	
	cvz := v.z * XLTLBase.speed; 	
END upstrafe;

PROCEDURE downstrafe;
VAR
	v: PT;
BEGIN
	IF AALIGN THEN v:=zaxis ELSE v:=down2 END;
	cvx := -v.x * XLTLBase.speed; 
	cvy := -v.y * XLTLBase.speed; 	
	cvz := -v.z * XLTLBase.speed; 	
END downstrafe;

PROCEDURE xjet(jet: REAL);
BEGIN
	cvx:=cvx+(jet*XLTLBase.speed);
END xjet;

PROCEDURE fjet(jet: REAL);
BEGIN
	cvx :=cvx+fward.x * jet*XLTLBase.speed; 
	cvy :=cvy+fward.y * jet*XLTLBase.speed; 
END  fjet;

PROCEDURE yjet(jet: REAL);
BEGIN
	cvy:=cvy+(jet*XLTLBase.speed);
END yjet;

PROCEDURE zjet(jet: REAL);
BEGIN
	cvz:=cvz+(jet);
END zjet;

PROCEDURE ljet(jet: REAL);
BEGIN
	cvx:=cvx+lward.x*jet*XLTLBase.speed;
	cvy:=cvy+lward.y*jet*XLTLBase.speed;
END ljet;

PROCEDURE rjet;
VAR
	p: PT;
BEGIN
	p:=rward;
	cvx:=cvx+(p.x*XLTLBase.speed);
	cvy:=cvy+(p.y*XLTLBase.speed);
	cvz:=cvz+(p.z*XLTLBase.speed);
END  rjet;

PROCEDURE downjet;
VAR
	p: PT;
BEGIN
	p:= down;
	cvx:=cvx+(p.x*XLTLBase.speed);
	cvy:=cvy+(p.y*XLTLBase.speed);
	cvz:=cvz+(p.z*XLTLBase.speed);
END downjet;

PROCEDURE angletoray(VAR ray: XLTLBase.Ray; theta,phi: REAL);
VAR d: REAL;
BEGIN
	ray.dxyz.x := XLTLMath.cos(theta) * XLTLMath.cos(phi);
	ray.dxyz.y := XLTLMath.sin(theta) * XLTLMath.cos(phi);
	ray.dxyz.z := XLTLMath.sin(phi);
	d := Math.sqrt(ray.dxyz.x*ray.dxyz.x + ray.dxyz.y* ray.dxyz.y+ray.dxyz.z*ray.dxyz.z);  (* Norma! Liza! Ray! Front and center, oh dark thirty!*)
	ray.dxyz.x := ray.dxyz.x/d;
	ray.dxyz.y := ray.dxyz.y/d;
	ray.dxyz.z := ray.dxyz.z/d; 
END angletoray; 

PROCEDURE carttosph(VAR p: PT; theta, phi: REAL);
BEGIN
	p.x := XLTLMath.cos(theta) * XLTLMath.cos(phi);
	p.y := XLTLMath.sin(theta) * XLTLMath.cos(phi);
	p.z := XLTLMath.sin(phi);
END carttosph; 

PROCEDURE sphtocart( p: PT; VAR theta, phi: REAL);
VAR
	x,y, z: REAL;
BEGIN
	x := p.x; y := p.y; z := 0;
	XLTLBase.normalize(x,y,z);
	theta := XLTLMath.arccos(x);	
	phi := XLTLMath.arccos(1-p.z);
END sphtocart;

PROCEDURE ddray(VAR ray: XLTLBase.Ray); 
BEGIN
	ray.ddxyz.x := ray.dxyz.x/10000;
	ray.ddxyz.y := ray.dxyz.y/10000;
	ray.ddxyz.z := ray.dxyz.z/10000; 
END ddray; 

PROCEDURE aggle;
BEGIN
	XLTLBase.setPT(fward,1,0,0);		
	XLTLBase.setPT(rward, 0,0,1);	
	XLTLBase.setPT(rward2, 0,1,0);	
	XLTLBase.setPT(down,0,1,0);	
	XLTLBase.setPT(down2,0,0,1);	
	XLTLMath.orrot(fward, rward, cameraphi); 	
	XLTLMath.orrot(fward, down, cameratheta); 	
	XLTLMath.orrot(rward2, down, cameratheta); 	
	XLTLMath.orrot(down2, rward, cameraphi); 		
END aggle;

PROCEDURE initrays;
VAR
	i, j: LONGINT;
	theta, phi, dtheta, dphi: REAL;
	lookperpray: Ray;
	lookvector:PT;
	look: XLTLBase.PT;
	camtweak: XLTLBase.PT;
	d1,d2,d3: REAL;
	dt,dp: REAL;
BEGIN
	dt:= rand.Uniform()/73;
	dp := rand.Uniform()/37;
	dtheta := aperture.width/ W;
	dphi := aperture.height / H;
	theta := -aperture.width /2 + dt;
	FOR i := 0 TO XLTLBase.W - 1  DO
		theta := theta + dtheta;
		phi :=  -aperture.height /2 + dp; 	(*bottom*)
		FOR j := 0 TO XLTLBase.H - 1 DO
			phi := phi + dphi;
			XLTLBase.rays[i, j] := XLTLBase.blankray;	
			XLTLBase.rays[i, j].theta := theta;
			XLTLBase.rays[i, j].phi := phi;
			angletoray(XLTLBase.rays[i, j],theta,phi);
			XLTLMath.orrot(XLTLBase.rays[i, j].dxyz, rward, cameraphi);  	
		  	XLTLMath.orrot(XLTLBase.rays[i, j].dxyz, down, cameratheta);  								  	  		
			IF XLTLBase.rays[i, j].dxyz.x < 0 THEN XLTLBase.rays[i, j].di := FALSE  ELSE XLTLBase.rays[i, j].di := TRUE END; 
			IF XLTLBase.rays[i, j].dxyz.y < 0 THEN XLTLBase.rays[i, j].dj := FALSE  ELSE XLTLBase.rays[i, j].dj := TRUE END;
			IF XLTLBase.rays[i, j].dxyz.z < 0 THEN XLTLBase.rays[i, j].dk := FALSE  ELSE XLTLBase.rays[i, j].dk := TRUE END;	
			XLTLBase.rays[i, j].ddxyz.x:=XLTLBase.rays[i, j].dxyz.x/10000;
			XLTLBase.rays[i, j].ddxyz.y:=XLTLBase.rays[i, j].dxyz.y/10000;
			XLTLBase.rays[i, j].ddxyz.z:=XLTLBase.rays[i, j].dxyz.z/10000	
		END
	END;
END initrays;

PROCEDURE irays;
VAR
	i, j: LONGINT;
	theta, phi, dtheta, dphi: REAL;
	lookperpray: Ray;
	lookvector:PT;
	look: XLTLBase.PT;
	camtweak: XLTLBase.PT;
	d1,d2,d3: REAL;
BEGIN
	FOR i := 0 TO XLTLBase.W - 1  DO
		FOR j := 0 TO XLTLBase.H - 1 DO	
			XLTLBase.rays[i, j].origin := XLTLBase.camera;
			XLTLBase.rays[i, j].xyz := XLTLBase.camera;
			XLTLBase.rays[i, j].lxyz := XLTLBase.camera;
			XLTLBase.rays[i, j].terminate:=FALSE;
			XLTLBase.rays[i, j].scale:=1;
			XLTLBase.rays[i, j].dtl:=XLTLBase.DTL;
		END
	END;
(*	FOR i := (XLTLBase.W2-30) TO (XLTLBase.W2+29)  DO
		FOR j := (XLTLBase.H2-30) TO (XLTLBase.H2+29) DO	
			XLTLBase.rays[i, j].dtl:=XLTLBase.DTL2;
		END
	END; *)    (* overlapping coplanar polys *)
END irays;

PROCEDURE trace;
BEGIN
	 XLTLRetina.go;
END trace; 

PROCEDURE left (th: REAL);
BEGIN
	IF ~swimbladder THEN
		cvl:=cvl+th
	END
END left;

PROCEDURE up (ph: REAL);
BEGIN
	IF ~swimbladder THEN
		cvu:=cvu+ph;
	END
END up;

PROCEDURE bounce(VAR cam:PT; VAR x,y,z: REAL);
VAR
	ray: Ray;
BEGIN
	ray.origin := cam;
	ray.xyz := cam;
	ray.lxyz := cam;
	ray.dxyz.x:=x-cam.x;
	ray.dxyz.y:=y-cam.y;	
	ray.dxyz.z:=z-cam.z;	
	XLTLBase.world.Shade(ray);               (* correct only for cube face normals not arbitrary normals *)
	IF ray.normal.x#0 THEN cvx:=-cvx 
	ELSIF ray.normal.y#0 THEN cvy:=-cvy 
	ELSIF ray.normal.z#0 THEN cvz:=-cvz	
(*	ELSE cvx:=0; cvy:=0; cvz:=0 *)
	END;
END bounce; 

PROCEDURE tick; 
VAR
	x,y,z: REAL;
	pass:BOOLEAN;
	timer : Kernel.MilliTimer; 	
	t: LONGINT;
	gz:REAL;
	v: Voxel;
BEGIN
	IF gravity THEN cvz := cvz+XLTLBase.gravity/10000 END;
	cameratheta:=cameratheta+cvl;
	cameraphi := cameraphi + cvu;
	IF cameraphi>1.6 THEN cameraphi:=1.6 END;
	IF cameraphi<-1.6 THEN cameraphi:=-1.6 END;
	cvl:=cvl*0.5; cvu:=cvu*0.5;
	x := cam.x + cvx; y := cam.y+cvy; z := cam.z+cvz;
	IF ~XLTLBase.world.passprobe(x,y,z) THEN bounce(cam,x,y,z) 
	ELSE cam.x := cam.x + cvx; cam.y := cam.y+cvy; cam.z:= cam.z+cvz
	END;
	LightPosition[0]:= cam.x; LightPosition[1]:= cam.y; LightPosition[2]:= cam.z; LightPosition[3]:= 0.0;
  	 GL.glLightfv(GLC.GL_LIGHT1, GLC.GL_POSITION, SYSTEM.ADR(LightPosition[0]) );
   	aggle;
 	a:=fward.x; b:=fward.y; c:=fward.z;	
	XLTLBase.updatecamera(cam.x,cam.y,cam.z,a*XLTLBase.avdist,b*XLTLBase.avdist,c*XLTLBase.avdist);	  
	cvx := cvx*0.9; cvy := cvy*0.9; cvz := cvz*0.9; 
	IF TRAIL THEN XLTLMarsh.marsh.draw; XLTLAudio.Play END;
	IF FUSETRAIL THEN XLTLMarsh.marsh.drawfuse END;
	IF AVATAR THEN XLTLMarsh.marsh.avatar END;	
	initrays;
	irays; 
	trace;	
END tick;
END Camera;

PROCEDURE Reshape(w, h: LONGINT);
BEGIN	
GL.SetFCR();
	GL.glViewport(0, 0, w, h);
	GL.glClearColor(0.0, 0.0, 0.0, 0.0);
	GL.glMatrixMode(GLC.GL_PROJECTION);
	GL.glLoadIdentity();
	GL.glFrustum(-1,1,-1,1, 0.5, 60); 
	GL.glMatrixMode(GLC.GL_MODELVIEW);
	GL.glLoadIdentity(); 
GL.DelFCR();
	centerx:= w DIV 2; centery:= h DIV 2;
END Reshape;

PROCEDURE Close;
VAR res: LONGINT;
BEGIN
	(* do we have a rendering context *)
	IF glctx # 0 THEN
		(* Release the context *)
	    	res := GL.glXMakeCurrent(display, 0, 0);
	    	(* Delete the context *)
		GL.glXDestroyContext(display, glctx);
		glctx := 0;
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
END Close;
	
PROCEDURE  InitWindow(w, h: LONGINT; CONST title: ARRAY OF CHAR);
VAR 
	res: LONGINT;
	masks: SET;
	buf: X11.Buffer;
	attrib : ARRAY [*] OF GL.GLint;  (* attributes of GL window *) 
	visinfoptr : Api.VisualInfoPtr;
	gwa : Api.XWindowAttributes; (* get window attributes *) 	
	swa : Api.XSetWindowAttributes; (* set window attributes*)
	cmap : X11.Colormap; (* colormap for window *)	
		
BEGIN
 display := X11.OpenDisplay(0);
 IF display =0 THEN
 	Out.String(" cannot connect to X server"); Out.Ln; 
	Close;
     RETURN;
END;  

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
 visinfoptr := GL.glXChooseVisual(display, 0 , SYSTEM.ADR(attrib[0]));
 
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
 masks :=  {Api.KeyPressMask,  Api.KeyReleaseMask, Api.ButtonPressMask,  Api.ButtonReleaseMask,  Api.PointerMotionMask,
   Api.ButtonMotionMask, Api.ExposureMask, Api.StructureNotifyMask, Api.FocusChangeMask};

  (* window attributes *)
 swa.backgroundPixel := 0;
 swa.borderPixel := 0;
 swa.colormap := cmap;
 swa.eventMask := masks;
 
 masks := { Api.CWBackPixel, Api.CWBorderPixel, Api.CWColormap, Api.CWEventMask};
 
 win := Api.CreateWindow(display, X11.DefaultRootWindow(display), 0, 0, w, h,
		        0, visinfoptr.depth, Api.InputOutput,  visinfoptr.visual, masks, SYSTEM.ADR(swa));

 (* show window *)	
  Api.MapWindow(display, win);

 (* set title of window *)	 
 res := Api.StoreName(display, win, title); 

(* create GL context *)
 (* GL_TRUE: Use direct rendering, GL_FLASE: use X server for rendering *)
 glctx := GL.glXCreateContext(display, visinfoptr, 0, GLC.GL_FALSE); 
	 IF debug THEN Out.String("glXCreateContext glctx= "); Out.Int(glctx, 0); Out.Ln; END;
 res := GL.glXMakeCurrent(display, win, glctx);
	IF debug THEN  Out.String("glXMakeCurrent res= "); Out.Int(res, 0); Out.Ln; END;

END InitWindow;

PROCEDURE ToggleDecorations;
VAR 	hints: Hints; 
	property: X11.Atom;
BEGIN
	IF  ~fullwindow OR  ~fullscreen THEN
		hints.flags := {1};
 		windecorations := ~windecorations;
 		IF windecorations THEN hints.decorations := 0; ELSE hints.decorations := 1; END;
 		X11.Lock;
		property := Api.InternAtom(display, "_MOTIF_WM_HINTS", Api.True); 
		X11.ChangeProperty(display, win, property, property, 32, Api.PropModeReplace, SYSTEM.ADR(hints), 5);
		X11.Unlock;
	END;	
END ToggleDecorations;

PROCEDURE Wr(CONST str: ARRAY OF CHAR);
BEGIN
	IF debugevents THEN Out.String(str); Out.Ln END;
END Wr;

PROCEDURE CheckAlternateKeys( VAR mb: SET );
BEGIN
	IF ~MMseen & (ControlKeyBit IN xbuttons) THEN INCL( mb, MM ) END;
	IF ~MRseen & (Mod1KeyBit IN xbuttons) THEN INCL( mb, MR ) END
END CheckAlternateKeys;

(*
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
*)
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
	res := Api.SendEvent(display, X11.DefaultRootWindow(display), Api.False, {Api.SubstructureNotifyMask}, SYSTEM.ADR(xev));	
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
						be := SYSTEM.VAL(Api.XButtonEvent, event);
						CASE be.button OF
							  Api.Button1: camera.speedup;
							|Api.Button2: camera.mwheelmode:= (camera.mwheelmode+1)MOD 2			
							|Api.Button3: camera.slowdown;
							|Api.Button4: CASE camera.mwheelmode OF
												  0: camera.speedup	
												|1: XLTLBase.avdist:=XLTLBase.avdist*1.1
											ELSE
											END
							|Api.Button5: CASE camera.mwheelmode OF
												  0: camera.slowdown	
												|1: XLTLBase.avdist:=XLTLBase.avdist/1.1
											ELSE
											END
							ELSE
							END
			| Api.ButtonRelease: be := SYSTEM.VAL(Api.XButtonReleasedEvent, event);
					CASE be.button OF
					| Api.Button1:  camera.FUSETRAIL:=FALSE
					| Api.Button2:  
					| Api.Button3:  camera.TRAIL:=FALSE
					ELSE  (* ignore *)
					END;				
			| Api.MotionNotify:  
			IF ~warpedthemouse THEN (* only once per frame *)
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
		   KS.XK_s1 : camera.backward
		| KS.XK_w1 :camera.forward
		| KS.XK_a1 :camera.leftward		
		| KS.XK_d1 :camera.rightward		
		| KS.XK_e1: camera.upstrafe
		| KS.XK_q1: camera.downstrafe	
		| KS.XK_l1: v:=XLTLBase.world.probe(XLTLBase.cursor.x, XLTLBase.cursor.y, XLTLBase.cursor.z) 	 
		| KS.XK_Escape: IF CAPTUREMOUSE THEN 
							CAPTUREMOUSE := FALSE
						ELSE
							alive:=FALSE
						END
		|	KS.XK_F1:
			Close;
			fullscreen := ~ fullscreen;
		| KS.XK_Up: Wr("K_Up"); 
		| KS.XK_Down: Wr("K_Down"); 
		| KS.XK_F11: ToggleFullWindow;
		| KS.XK_F12: ToggleDecorations;
		| KS.XK_p1: drawMode := (drawMode+1) MOD 2; DrawMode(drawMode); 
		| KS.XK_o1:	camera.CCBUFFER:=~camera.CCBUFFER
		| KS.XK_t1: camera.TRAIL:=~camera.TRAIL; 
		| KS.XK_v1: camera.AVATAR:=~camera.AVATAR; 
		| KS.XK_z1: XLTLMarsh.marsh.draw;
		| KS.XK_x1: XLTLMarsh.marsh.cycleD;
		| KS.XK_1 : XLTLBase.DTL:= ENTIER(2*XLTLBase.DTL/3)		
		| KS.XK_2 : XLTLBase.DTL:= ENTIER(3*XLTLBase.DTL/2)		
		| KS.XK_3 : INC(XLTLBase.gravity);	
		| KS.XK_4: DEC(XLTLBase.gravity);					
		| KS.XK_h1 : camera.hop			
		| KS.XK_b1 : camera.AALIGN:=~camera.AALIGN	
		| KS.XK_m1 : XLTLBase.mtoggle:=~XLTLBase.mtoggle;
		| KS.XK_bracketright: camera.aperture.width := camera.aperture.width * 101/99; camera.aperture.height := camera.aperture.height *101/99
		| KS.XK_bracketleft: camera.aperture.width := camera.aperture.width * 99/101; camera.aperture.height := camera.aperture.height *99/101
		| KS.XK_plus: camera.speedup
		| KS.XK_minus: camera.slowdown
		| KS.XK_period: camera.stop
		| KS.XK_9: XLTLBase.avatarsize:=XLTLBase.avatarsize*2
		| KS.XK_0: IF XLTLBase.avatarsize>27 THEN XLTLBase.avatarsize:=ENTIER(XLTLBase.avatarsize/2) END
		| KS.XK_7: XLTLBase.avdist:=XLTLBase.avdist*1.3
		| KS.XK_8: XLTLBase.avdist:=XLTLBase.avdist/1.3	
		| KS.XK_5: leftsticky:=leftsticky*1.3; IF leftsticky>5 THEN leftsticky:=0.2  END;
		| KS.XK_6: upsticky:=upsticky*1.3; IF upsticky>5 THEN upsticky:=0.2  END; 
		| KS.XK_g1: camera.gravity:=~camera.gravity;
		| KS.XK_f1 : fogdensity:= fogdensity*1.1; 
				IF fogdensity>9.9 THEN fogdensity:=0.7 END		
	ELSE	
	END;	
END KeyEvent;

PROCEDURE MouseVent(x,y: LONGINT);
BEGIN
	camera.left(x/(1000*leftsticky));
	camera.up(y/(1000*upsticky));	
END MouseVent;

PROCEDURE InitGL;
BEGIN
	light := FALSE; blend := FALSE;
	xrot := 30.0; yrot := 30.0; z := -10.0;	
	xspeed := 0.0; yspeed := 0.0;
	filter := 0;
		
LightAmbient[0] := 0.21; LightAmbient[1] := 0.21; LightAmbient[2] := 0.21; LightAmbient[3] :=1.0;
LightDiffuse[0] := 0.5; LightDiffuse[1] := 0.5; LightDiffuse[2] := 0.5; LightDiffuse[3] := 0.0;
LightPosition[0]:= 0.0; LightPosition[1]:= 1.0; LightPosition[2]:= 1; LightPosition[3]:= 1.0;
LightDiffuse2[0] := 0.7; LightDiffuse2[1] := 0.4; LightDiffuse2[2] := 0.2; LightDiffuse2[3] := 1.0;
red[0]:=0.62; red[1]:=0.42; red[2]:=0.9; red[3]:=0.0; 
blue[0]:=0.09; blue[1]:=0.09; blue[2]:=0.09; blue[3]:=1.0; 

(* context.MakeCurrent(); *)
GL.SetFCR();

  (* Enable Texture Mapping ( NEW ) *)
  GL.glEnable( GLC.GL_TEXTURE_2D );

  (* Enable smooth shading *)
  GL.glShadeModel( GLC.GL_SMOOTH );

  (* Set the background black *)
  GL.glClearColor(0.99,0.39,0.29 , 0.0 );

  (* Depth buffer setup *)
  GL.glClearDepth( 1.0 );

  (* Enables Depth Testing *)
  GL.glEnable( GLC.GL_DEPTH_TEST );

  (* The Type Of Depth Test To Do *)
  GL.glDepthFunc( GLC.GL_LEQUAL );

  (* Really Nice Perspective Calculations *)
  GL.glHint( GLC.GL_PERSPECTIVE_CORRECTION_HINT, GLC.GL_NICEST );

  (* Setup The Ambient Light *)
  GL.glLightfv( GLC.GL_LIGHT1, GLC.GL_AMBIENT, SYSTEM.ADR(LightAmbient[0]) );

  (* Setup The Diffuse Light *)
  GL.glLightfv( GLC.GL_LIGHT1, GLC.GL_DIFFUSE, SYSTEM.ADR(LightDiffuse[0]) );

  (* Position The Light *)
  GL.glLightfv( GLC.GL_LIGHT1, GLC.GL_POSITION, SYSTEM.ADR(LightPosition[0]) );

  (* Enable Light One *)
  GL.glEnable( GLC.GL_LIGHT1 );
 
  (* Setup The Ambient Light *)
  GL.glLightfv( GLC.GL_LIGHT2, GLC.GL_AMBIENT, SYSTEM.ADR(LightAmbient[0]) );

  (* Setup The Diffuse Light *)
  GL.glLightfv( GLC.GL_LIGHT2, GLC.GL_DIFFUSE, SYSTEM.ADR(LightDiffuse[0]) );
  
  LightPosition[0]:= -1.0; LightPosition[1]:= -1.0; LightPosition[2]:= 1; LightPosition[3]:= 0.0;
  LightPosition2[0]:= 0.0; LightPosition2[1]:= 1.0; LightPosition2[2]:= 0; LightPosition2[3]:= 0.0; 
  
   GL.glLightfv( GLC.GL_LIGHT1, GLC.GL_POSITION, SYSTEM.ADR(LightPosition[0]) );
   GL.glLightfv( GLC.GL_LIGHT2, GLC.GL_POSITION, SYSTEM.ADR(LightPosition2[0]) );
   
    GL.glEnable( GLC.GL_LIGHT1);
    GL.glEnable( GLC.GL_LIGHT2);
  
  GL.glColorMaterial(GLC.GL_FRONT_AND_BACK, GLC.GL_AMBIENT_AND_DIFFUSE);
  
   GL.glEnable(GLC.GL_LIGHTING);

  (* Full Brightness, 50% Alpha ( NEW ) *)
  GL.glColor4f( 1.0, 1.0, 1.0, 0.5);
  
  GL.glEnable(GLC.GL_FOG);
  GL.glEnable(GLC.GL_COLOR_MATERIAL);
    GL.glFogi(GLC.GL_FOG_MODE, GLC.GL_EXP);
  GL.glFogfv(GLC.GL_FOG_COLOR,SYSTEM.ADR(blue[0]));
  GL.glFogf(GLC.GL_FOG_DENSITY, 0.031);
  

GL.DelFCR();
 
END InitGL;

PROCEDURE LightTick(x,y,z:REAL);
BEGIN
	LightPosition[0]:=x ; LightPosition[1]:=y; LightPosition[2]:= z; LightPosition[3]:=0.0;	
	GL.glLightfv( GLC.GL_LIGHT1, GLC.GL_POSITION, SYSTEM.ADR(LightPosition[0]) );
	
	
(*	GL.glLightf( GLC.GL_LIGHT1, GLC.GL_CONSTANT_ATTENUATION, 2.1); *)
END LightTick;


PROCEDURE DrawMode(dm: LONGINT);
VAR drawMode: LONGINT;
BEGIN
	drawMode := dm;  	
        IF drawMode = 0 THEN       (* fill mode*)
            GL.glPolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_FILL);
            GL.glEnable(GLC.GL_DEPTH_TEST);
            GL.glEnable(GLC.GL_CULL_FACE);
        ELSIF drawMode = 1 THEN  (* wireframe mode *)
            GL.glPolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_LINE);
            GL.glDisable(GLC.GL_DEPTH_TEST);
            GL.glDisable(GLC.GL_CULL_FACE);
        ELSE                    (* point mode *)

            GL.glPolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_POINT);
            GL.glDisable(GLC.GL_DEPTH_TEST);
            GL.glDisable(GLC.GL_CULL_FACE);
	  END;
END DrawMode;

PROCEDURE genptlist;
VAR
	i,j,k: INTEGER;
BEGIN
	ptlist:=GL.glGenLists(1);
	GL.glNewList(ptlist, GLC.GL_COMPILE);  
	GL.glMaterialfv(GLC.GL_FRONT, GLC.GL_AMBIENT_AND_DIFFUSE, SYSTEM.ADR(red[0])); 
	GL.glBegin(GLC.GL_POINTS);
	FOR i:=-20 TO 20 DO FOR j:=-20 TO 20 DO FOR k:=-20 TO 20 DO
		GL.glVertex3f(i/10,j/10,k/10);
	END END END; 
	GL.glEnd;
	GL.glEndList();	
END genptlist;

PROCEDURE draw;
VAR
	i,j,k:LONGINT;
	a: REAL;
BEGIN
	InitGL;
	GL.SetFCR();
	GL.glMatrixMode(GLC.GL_PROJECTION);
	GL.glLoadIdentity();
	GL.glFrustum(-0.001,0.001,-0.001,0.001,0.001,150); 
	IF camera.CCBUFFER THEN
 		GL.glClear((GLC.GL_COLOR_BUFFER_BIT+GLC.GL_DEPTH_BUFFER_BIT))
 	ELSE
		GL.glClear((GLC.GL_DEPTH_BUFFER_BIT))
	END;	
	GL.glEnable( GLC.GL_TEXTURE_2D );
 	GL.glMatrixMode(GLC.GL_MODELVIEW);
	GL.glLoadIdentity(); 	
	GL.glScalef(TR,TR,TR);	
	GL.DelFCR();
	a:= camera.cameraphi*rad2deg;
	GL.SetFCR();	
	GL.glRotatef(a,1,0,0); 		
	GL.DelFCR();
	a:= 90+camera.cameratheta*rad2deg;
	GL.SetFCR();
	GL.glRotatef(a,0,1,0); 		
	GL.glTranslatef(-camera.cam.x, -camera.cam.z,-camera.cam.y); 	
		IF camera.cam.z>1/2 THEN 
		blue[0]:=0.0; blue[1]:=0.0; blue[2]:=0.29; blue[3]:=1.0; 
		GL.glFogf(GLC.GL_FOG_DENSITY, fogdensity);
		GL.glFogfv(GLC.GL_FOG_COLOR,SYSTEM.ADR(blue[0])); 
	ELSE
		GL.glFogf(GLC.GL_FOG_DENSITY, fogdensity/10);
		red[0]:=0.0; red[1]:=0.5; red[2]:=0.5; red[3]:=1.0; 
		GL.glFogfv(GLC.GL_FOG_COLOR,SYSTEM.ADR(red[0]));
	END;
	GL.glDisable(GLC.GL_CULL_FACE); 
	GL.glDisable( GLC.GL_TEXTURE_2D );	
	GL.glBegin( GLC.GL_QUADS);	
	GL.glNormal3f(0,-1,0);
	GL.glVertex3f(0,0.51,0);
	GL.glVertex3f(0.0,0.51,1);
	GL.glVertex3f(1.0,0.51,1);
	GL.glVertex3f(1.0,0.51,0);
	GL.glEnd;	
	GL.DelFCR();
	 GL.glEnable( GLC.GL_TEXTURE_2D);
	XLTLGL.draw; 
	GL.glXSwapBuffers(display, win);
END draw;

PROCEDURE MainLoop;
VAR	
	timer : Kernel.MilliTimer; 	
	t: LONGINT;
	frame: LONGINT;
BEGIN
	Kernel.SetTimer(timer,3000);	
	WHILE alive DO	
		INC(frame);
		IF frame=3000 THEN
			frame:=0;
			t:=Kernel.Elapsed(timer);
			Kernel.SetTimer(timer,3000);	
			Out.Int(t,4);
			Out.Ln
		END;
		camera.tick;
		XLTLBase.tick;
		XLTLCellAutoVox.Engine.tick;
		draw;
		PollXQueue; 	
	END;
END MainLoop;	

PROCEDURE Open*;
BEGIN
	alive:=TRUE;
	debugevents:=FALSE;
	XLTLBase.worldalive:=TRUE;
	XLTLBase.speed:=0.001;
	axis:="y";	
	mousex:=200;
	mousey:=200;
	centerx:=200;
	centery:=200;
	fogdensity:=0.11;
	leftsticky:=1.0;
	upsticky:=1.0;
	NEW(rand);
	InitWindow(400,400, 'XOLOTL-HYBRID' );	
	InitGL; 	
	DrawMode(0);
	XLTLMarsh.loadtextures;	
	XLTLMarsh.marsh.dawn;	
	NEW(camera);

	MainLoop;
	 XLTLBase.worldalive:=FALSE;
 	alive:=FALSE;
 	XLTLAudio.CloseDevice; 
	Close;	

END Open;

BEGIN
	
END XLTLNeoRender.Open

SystemTools.FreeDownTo  XLTLBase~



