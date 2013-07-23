MODULE XNXLRender;
IMPORT SYSTEM, Kernel, Modules, WMWindowManager, Graphics:=WMGraphics, Raster, Objects, Random, XNXLMarsh,
Rectangles:= WMRectangles,  Scale:= WMRasterScale, Out := KernelLog, Math, XNXLBase,  XNXLMath,  XNXLRetina,Heaps,
	XNXLGL,  X11,  Api := X11Api, GL:=OpenGL, GLC := OpenGLConst, Inputs, KS := X11KeySymDef, V := XF86VMode, 
	XNXLAudio;

CONST S=3; (* image size multiplier *)
	ML = 0;  MM = 1;  MR = 2;
	Button1Bit = 8; Button2Bit = 9; Button3Bit =10;
	ShiftKeyBit = 0;  ShiftLokBit = 1;  ControlKeyBit = 2;  Mod1KeyBit = 3;
	Mod2KeyBit = 4;  Mod3KeyBit = 5;  Mod4KeyBit = 6;  Mod5KeyBit = 7;	  
	rad2deg=360/6.28318;
	
TYPE Aperture = XNXLBase.Aperture;
TYPE Ray = XNXLBase.Ray;
TYPE Voxel = XNXLBase.Voxel; 
TYPE PT = XNXLBase.PT;
TYPE Hints = RECORD
	flags: SET;
	functions: LONGINT;
	decorations: LONGINT;
	inputMode: LONGINT;
	status: LONGINT
END;
TYPE SNAP = RECORD
	lookphi, looktheta : REAL;
	aperture: Aperture;
	x,y,z,cdroll: REAL;		
	lookdxyz:PT;
END;	

TYPE keyevent=RECORD
	ucs : LONGINT; 
	flags : SET; 
	keysym : LONGINT
END;

TYPE VoxWindow = OBJECT(WMWindowManager.DoubleBufferWindow)
VAR
	camera: Camera;
	pointerlastx, pointerlasty, pointercenterx, pointercentery: LONGINT;
	pi: WMWindowManager.PointerInfo;
	focus, voxconnect,FISHEYE: BOOLEAN;
	connectvox: Voxel;
	Key: CHAR;
	movemode: CHAR;
	raysperframe: LONGINT;
	selfislarge: BOOLEAN;
	Forward,Backward,invertmouse:BOOLEAN;
	cameralock: BOOLEAN;
	wheelmi:INTEGER;
	msense: REAL;
	wheelplus, wheelminus: ARRAY 4 OF PROCEDURE;
	 
PROCEDURE & New(W,H, i,j: INTEGER);
BEGIN
	Init(W*S, H*S, TRUE); 
	raysperframe:=W*H;
	pointercenterx:= (W*S) DIV 2; 
	pointercentery:= (H*S) DIV 2; 	
	manager := WMWindowManager.GetDefaultManager();
	manager.Add(i,j, SELF, { WMWindowManager.FlagFrame, WMWindowManager.FlagStayOnTop});
    	WMWindowManager.LoadCursor("XNXL.Recticle.png", 3,3, pi);	
	SetPointerInfo(pi);
	NEW(camera, W, H);
	movemode := 'p';
	SetIcon(Graphics.LoadImage("WMIcons.tar://WMFileManager.png", TRUE));
	filtor:=TRUE;
	wheelplus[0]:=speedup;
	wheelminus[0]:=slowdown;
	wheelplus[1]:=cursorpush;
	wheelminus[1]:=cursorpull;			
	wheelplus[2]:=cursorsizeplus;
	wheelminus[2]:=cursorsizeminus;		
	wheelplus[3]:=vlnext;
	wheelminus[3]:=vllast;	
	msense:=25;  (*lower is skittisher*)
END New;

PROCEDURE FocusGot*;
BEGIN
	focus := TRUE;
	XNXLBase.STOP:=FALSE;
	PAUSE:=FALSE;
	camera.returntohorizon:=FALSE;
END FocusGot;

PROCEDURE FocusLost*;
BEGIN
	focus := FALSE;
	XNXLBase.STOP:=TRUE;
	PAUSE:=TRUE;
END FocusLost;

PROCEDURE Close;
BEGIN
	XNXLBase.worldalive := FALSE;
	Close^;
END Close;


(* PROCEDURE KeyEvent (ucs : LONGINT; flags : SET; keysym : LONGINT);
(* We only want one event per frame!*)
BEGIN
	kevent.ucs:=ucs;
	kevent.flags:=flags;
	kevent.keysym:=keysym;
END KeyEvent ;
*)
PROCEDURE KeyEvent (ucs : LONGINT; flags : SET; keysym : LONGINT);
VAR
	done: BOOLEAN;
BEGIN
	Key := CHR(ucs);
	CASE CHR(ucs) OF
		|'4': 
		|'6': 
		|'2': 
		|'8':
		|'5': 
		|'0': 
		|'w': camera.forward
		|'s': camera.backward	
		|'a': camera.leftward	
		|'d': camera.rightward		
		|'e': camera.upstrafe	
		|'c': camera.downstrafe							
		|'&': multicore:=~multicore; IF multicore THEN Out.String("multicore") ELSE Out.String("singlecore")	END
		| ']': camera.aperture.width := camera.aperture.width * 101/99; camera.aperture.height := camera.aperture.height *101/99;
			camera.rayschanged  := TRUE; msense:=msense* 98/100;
		| '[': camera.aperture.width := camera.aperture.width * 99/101; camera.aperture.height := camera.aperture.height *99/101;
			camera.rayschanged  := TRUE; msense:=msense* 100/98;
		| 'q': Close; 
		| 'i': XNXLRetina.EDGE:=XNXLRetina.EDGE*2/3;
		| 'o': XNXLRetina.EDGE:=XNXLRetina.EDGE*3/2;
		| 'I': XNXLBase.DTL2:=XNXLBase.DTL2*1.5; 
		| 'O': XNXLBase.DTL2:=XNXLBase.DTL2/1.5
		| 'h': camera.hop;
		| ' ': 	INC(wheelmi);	
				wheelmi:= wheelmi MOD 4;
				CASE wheelmi OF
					|0: Out.String("SPEED ");
					|1:	Out.String("CDIST ");
					|2: Out.String("CSIZE ");
					|3:	Out.String("CVOX");					
				END;
				Out.Ln
		| '*': XNXLBase.STOPGO
		| 'x':  TRAILS:=~TRAILS
		| 'f': camera.filter:=~camera.filter
		| 'm': msense:=msense*90/100
		| 'n': msense:=msense*100/90
		| '(': camrotinertia:= camrotinertia*8/10	
		| ')': camrotinertia:= camrotinertia*10/8		
		| 'z': avtoggle:=~avtoggle	
		| '|': invertmouse:=~invertmouse		
		| 'Z': IF camera.fisheye > 1.0 THEN camera.fisheye:=1.5 ELSIF camera.fisheye < 1.5 THEN camera.fisheye:=1 END
		|'l': camera.positionlock:=~camera.positionlock
		|'r': R1:= R1*1.2; R2:=R1*1.5; Out.Int(ENTIER((R1+R2)/2),4); Out.String(" ms target"); Out.Ln;
		|'t': R1:= R1/1.2; R2:=R1*1.5; Out.Int(ENTIER((R1+R2)/2),4); Out.String(" ms target"); Out.Ln;
		|'U': camera.up(0.05)
		|'D': camera.up(-0.05)
		ELSE
	END;
END KeyEvent;

PROCEDURE PointerDown (x, y : LONGINT; keys : SET);
BEGIN
	pkeys:=keys;	
	IF MR IN keys THEN
		
	END;
END PointerDown;

PROCEDURE PointerUp (x, y : LONGINT; keys : SET);
BEGIN
	pkeys := keys;
END PointerUp;

PROCEDURE PointerMove (x, y : LONGINT; keys : SET);
VAR
	tx,ty: LONGINT;
BEGIN
	PAUSE:=FALSE;
	tx :=x; ty := y; pkeys := keys;
	pointerdx := pointerdx+pointerx - tx; pointerdy := pointerdy+pointery - ty;	
	IF invertmouse THEN pointerdx:=-pointerdx END;
	pointerx:=tx; pointery:=ty;
END PointerMove;

PROCEDURE PointerLeave;
BEGIN
	FocusLost;
END PointerLeave;

PROCEDURE WheelMove*(dz : LONGINT);
BEGIN
	IF dz<0 THEN wheelplus[wheelmi] ELSE wheelminus[wheelmi] END
END WheelMove;

PROCEDURE move;
VAR
	l,u:REAL;
BEGIN
	IF MR IN pkeys THEN
		TRAILS:=TRUE
	ELSE
		TRAILS:=FALSE
	END;
	l:=-pointerdx/msense;
	u:=pointerdy/msense;
	camera.left(l);
	camera.up(u);
	camera.tick;
	pointerdx:=0;
	pointerdy:=0
END move;

END VoxWindow;

TYPE Camera = OBJECT
VAR
	image,imj: XNXLBase.IMAGE;
	random: Random.Generator;
	rayschanged,   xdcdang1,filter: BOOLEAN;
	fovealeft, fovearight, foveabottom, foveatop: LONGINT;
	fovea: BOOLEAN;
	cam: PT; 
	mode : Raster.Mode;
	pixel: Raster.Pixel;
	W,H,pointerx,pointery:LONGINT;
	aperture: Aperture;
	iamalargecamera: BOOLEAN;
	lookdxyz:PT;
	cx, cy, cz, cvx, cvy, cvz, cvl, cvu: REAL;   
	fward,rward, down, down2, rward2, right,xaxis,yaxis,zaxis:PT; 
	croll: REAL;
	cdroll: REAL;
	cameratheta,cameraphi: REAL;
	world:Voxel;	
	positionlock, orientationlock, returntohorizon: BOOLEAN;	
	fisheye: REAL;	

PROCEDURE & init (width, height: INTEGER);
BEGIN
	NEW(image);
	NEW(imj); 
	W := width; H := height;
	Raster.InitMode(mode, Raster.srcCopy); 		
	filter:=FALSE;
	cameratheta := 0;
	cameraphi := 0;
	aperture.width := 5/3;
	aperture.height :=5/3;
	XNXLBase.setPT(xaxis, 1,0,0);	
	XNXLBase.setPT(yaxis,0,1,0);	
	XNXLBase.setPT(zaxis,0,0,-1);	
	fisheye:=1;
	hop;
END init;

PROCEDURE hop;
BEGIN
	stop;
	cx :=1/3+XNXLBase.rand.Uniform()/3; cy:=1/2+XNXLBase.rand.Uniform()/3; cz := 1/2+XNXLBase.rand.Uniform()/3;
END hop;

PROCEDURE move;
VAR
	face: INTEGER;
	x,y,z,d: REAL;
	v, target: Voxel;
	normal: PT;
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
	proberay:= XNXLBase.rays[(W DIV 2)-(W DIV 2)MOD 5, (H DIV 2)-(H DIV 2)MOD 5];
	x := cx + cvx; y := cy + cvy; z := cz + cvz;
	pass := XNXLBase.world.passprobe(x,y,z)&XNXLBase.world.passprobe(x,y,z-0.015);
	lookdxyz:=proberay.dxyz;
	IF ~pass THEN
		x := cx + cvx; y := cy + cvy; z := cz;	
		pass := XNXLBase.world.passprobe(x,y,z)&XNXLBase.world.passprobe(x,y,z-0.015);
		IF pass THEN 
			cvz:=0
		ELSE
			x := cx + cvx; y := cy; z := cz+cvz;	
			pass := XNXLBase.world.passprobe(x,y,z)&XNXLBase.world.passprobe(x,y,z-0.015);
			IF pass THEN 
				cvy:=0
			ELSE			
				x := cx; y := cy + cvy; z := cz+cvz;	
				pass := XNXLBase.world.passprobe(x,y,z)&XNXLBase.world.passprobe(x,y,z-0.015);
				IF pass THEN 
					cvx:=0 
				END
			END
		END
	END;
	IF  pass THEN 
		cx:=x; cy:=y; cz:=z (*  if movement forward restricted to xy plane *)
	ELSE
		XNXLBase.world.Shade(proberay);
		normalize(cvx,cvy,cvz,d);
		reflect(cvx, cvy, cvz, proberay.normal.x, proberay.normal.y, proberay.normal.z);
		denormalize(cvx,cvy,cvz,d);	
		cvx:=cvx/1.5; cvy:=cvy/1.5; cvz:=cvz/2; 
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
	XNXLBase.speed := XNXLBase.speed/1.05;
	cvx:=0;
	cvy:=0;
	cvz:=0;
END stop;

PROCEDURE splitprobe(x, y: LONGINT);
VAR
	v:Voxel;
	ray: Ray;
BEGIN
	x:=x- (x MOD 5); y:=y - (y MOD 5);
	x:= x DIV 2;
	y:= y DIV 2;
	ray:=XNXLBase.rays[x,y];
	NEW(v);
	v:=XNXLBase.world.proberay(ray); 
	v.split; 
END splitprobe;

PROCEDURE sniprobe;
VAR
	v:Voxel;
	ray: Ray;
	x,y: LONGINT;
BEGIN
	x:=W DIV 2;
	y:=H DIV 2;
	ray:=XNXLBase.rays[x,y];
	NEW(v);
	v:=XNXLBase.world.proberay(ray); 
(*	XNXLBase.cursordist:=2*ray.length/3; *)
END sniprobe;


PROCEDURE deathray(x,y: LONGINT);
BEGIN
	initrays;
	XNXLBase.world.deathray(XNXLBase.rays[x,y]);
END deathray;

PROCEDURE forward;
VAR
	v: PT;
BEGIN
	v:=fward;
	cvx :=(v.x * XNXLBase.speed); 
	cvy := (v.y * XNXLBase.speed); 	
	cvz := (v.z * XNXLBase.speed); 	
END forward;

PROCEDURE backward;
VAR
	v: PT;
BEGIN
	v:=fward;
	cvx :=  -(v.x * XNXLBase.speed); 
	cvy :=  -(v.y * XNXLBase.speed); 	
	cvz :=  - (v.z * XNXLBase.speed); 	
END backward;

PROCEDURE rightward;
VAR
	v: PT;
BEGIN
	rward:=yaxis;
	XNXLMath.orrot(rward, zaxis, cameraphi);  
	v:=rward;
	cvx := (v.x * XNXLBase.speed); 
	cvy :=  (v.y * XNXLBase.speed); 	
	cvz := (v.z * XNXLBase.speed); 	
END rightward;

PROCEDURE leftward;
VAR
	v: PT;
BEGIN
	rward:=yaxis;
	XNXLMath.orrot(rward, zaxis, cameraphi);
  	v:=rward;
	cvx := -(v.x * XNXLBase.speed); 
	cvy := -(v.y * XNXLBase.speed); 	
	cvz := -(v.z * XNXLBase.speed); 	
END leftward;

PROCEDURE upstrafe; (* strafe up perpendicular to look *)
VAR
	v: PT;
BEGIN
	v:=down;
	cvx := -(v.x * XNXLBase.speed); 
	cvy := -(v.y * XNXLBase.speed); 	
	cvz := -(v.z * XNXLBase.speed); 	
END upstrafe;

PROCEDURE downstrafe;
VAR
	v: PT;
BEGIN
	v:=down;
	cvx :=  (v.x * XNXLBase.speed); 
	cvy :=  (v.y * XNXLBase.speed); 	
	cvz := (v.z * XNXLBase.speed); 	
END downstrafe;

PROCEDURE initrays;
VAR
	reversej, i, j: LONGINT;
	theta, phi, dtheta, dphi: REAL;
	lookperpray: Ray;
	lookvector:PT;
	look: XNXLBase.PT;
	camtweak: XNXLBase.PT;
	d1,d2,d3: REAL;
	w,h: REAL;
BEGIN
	fward:=xaxis;
	rward:=yaxis;
	down:=zaxis;
	XNXLMath.orrot(fward, zaxis, cameraphi);  
	XNXLMath.orrot(rward, zaxis, cameraphi);  
	XNXLMath.orrot(fward, rward, cameratheta);  
	XNXLMath.orrot(down, rward, cameratheta);  	
	w:= aperture.width;
	h:=aperture.height;
	w:=fisheye*w;
	h:= fisheye*h;
	dtheta := w / W;
	dphi := h/ H;
	theta := -w / 2;
	FOR i := 0 TO XNXLBase.W - 1  DO
		theta := theta + dtheta;
		phi :=  -aperture.height / 2; 	(*bottom*)
		FOR reversej := 0 TO XNXLBase.H - 1 DO
			j:= (XNXLBase.H -1)-reversej;
			phi := phi + dphi;
			XNXLBase.rays[i, j] := XNXLBase.blankray;			
			XNXLBase.rays[i, j].theta := theta;
			XNXLBase.rays[i, j].phi := phi;
			angletoray(XNXLBase.rays[i, j],theta,phi);
			XNXLMath.orrot(XNXLBase.rays[i, j].dxyz, zaxis, cameraphi);  	
		   	XNXLMath.orrot(XNXLBase.rays[i, j].dxyz, rward, cameratheta);  			  	  								  	  		
			IF XNXLBase.rays[i, j].dxyz.x < 0 THEN XNXLBase.rays[i, j].di := FALSE  ELSE XNXLBase.rays[i, j].di := TRUE END; 
			IF XNXLBase.rays[i, j].dxyz.y < 0 THEN XNXLBase.rays[i, j].dj := FALSE  ELSE XNXLBase.rays[i, j].dj := TRUE END;
			IF XNXLBase.rays[i, j].dxyz.z < 0 THEN XNXLBase.rays[i, j].dk := FALSE  ELSE XNXLBase.rays[i, j].dk := TRUE END;		
			XNXLBase.rays[i, j].lxyz := cam;
			XNXLBase.rays[i, j].xyz := cam;
			XNXLBase.rays[i, j].oxyz:=XNXLBase.rays[i, j].dxyz;
		END
	END;
END initrays;

PROCEDURE trace;
VAR
	i, j, ii,jj,q,z: LONGINT;
	ry: XNXLBase.Ray;
	pixel : Raster.Pixel;
	r, g, b: LONGINT;
	R,G,B:REAL;
	lr, lg,lb,nlr,nlg,nlb: LONGINT;
	fr,fg,fb: REAL;
	rect,srect,clip: Rectangles.Rectangle;
BEGIN
	IF multicore THEN XNXLRetina.go ELSE XNXLRetina.gosinglecore END;
	FOR j:= 0 TO H-1 DO 
		FOR i := 0 TO W-1 DO
		XNXLBase.clamp3(XNXLBase.rays[i,j].r,XNXLBase.rays[i,j].g,XNXLBase.rays[i,j].b);	(* unneeded if shaders behave properly *)
			image[i,j].red:=XNXLBase.rays[i,j].r;
			image[i,j].green:=XNXLBase.rays[i,j].g;
			image[i,j].blue:=XNXLBase.rays[i,j].b;
		END
	END;	
	FOR j:= 0 TO H-1 DO 
		FOR i := 0 TO W-1 DO
			r:=ENTIER(image[i,j].red*255);
			g:=ENTIER(image[i,j].green*255);
			b:=ENTIER(image[i,j].blue*255);
			Raster.SetRGB(pixel,r,g,b);	
			Raster.Put(window.backImg,i,j,pixel,mode); 		
		END
	END;	
	rect:= Rectangles.MakeRect(0, 0, window.GetWidth(), window.GetHeight());
	srect:= Rectangles.MakeRect(0, 0, window.GetWidth() DIV S, window.GetHeight() DIV S);
	IF filter THEN
		Scale.Scale(window.backImg, srect, window.img, rect, rect, Scale. ModeCopy, Scale.ScaleBilinear);
	ELSE
		Scale.Scale(window.backImg, srect, window.img, rect, rect,  Scale.ModeSrcOverDst, Scale.ScaleBox);
	END;
	window.Invalidate(rect); 
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
	IF ~orientationlock THEN	
		cvu:=cvu+ph;
		cameraphi := cameraphi + cvu;
		IF cameraphi > 1.68 THEN cameraphi := 1.68 END;
		IF cameraphi < -1.68 THEN cameraphi := -1.68 END
	END
END up;

PROCEDURE tick;
VAR
	oldcam:PT;
	a,b,c: REAL;
BEGIN
	move;	
	cam.x := cx; cam.y := cy; cam.z := cz;
	a:=fward.x*XNXLBase.cursordist; b:=fward.y*XNXLBase.cursordist; c:=fward.z*XNXLBase.cursordist;
	XNXLBase.updatecameraPT(cx,cy,cz,a,b,c);	
	sniprobe;			
	cvz := cvz+XNXLBase.gravity/1000;
	cvx := cvx*0.97; cvy := cvy*0.97; cvz := cvz*0.97;
	cvl :=cvl*0.75; cvu := cvu*0.75;
	IF TRAILS THEN 
		XNXLMarsh.draw;
	END;
	initrays;
	trace
END tick;
 
END Camera;

VAR
	FRAMERATE: REAL;
	window: VoxWindow;
	rand: Random.Generator;
	wcount: INTEGER;
	frame, tickframe: LONGINT;
	frames: ARRAY 10000 OF SNAP;
	movierecording, movieplaying: BOOLEAN; 
	frtrace, foveate: BOOLEAN;
	foveasize, fovealeft, fovearight, foveadown, foveaup: LONGINT;
	DEATH, wLOOK, TRAILS, PAUSE: BOOLEAN;
	tracetiled,avtoggle, capturethemouse: BOOLEAN;
	framecount: LONGINT;
	multicore,filtor,uplock,rollcam,suppressz: BOOLEAN;
	camrotinertia:REAL;
	framedt: REAL;
	pkeys: SET;	
	kevent: keyevent;
	pointerx, pointerdx, pointery, pointerdy: LONGINT;
	R1,R2: REAL;
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
	
PROCEDURE angletoray(VAR ray: XNXLBase.Ray; theta,phi: REAL);
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

PROCEDURE raytangle(VAR ray: XNXLBase.Ray);
VAR x,y, z: REAL;
BEGIN
	x := ray.xyz.x; y := ray.xyz.y; z := 0;
	XNXLBase.normalize(x,y,z);
	ray.theta := XNXLMath.arccos(x);	
	ray.phi := XNXLMath.arccos(1-ray.dxyz.z);
END raytangle; 

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
	XNXLBase.normalize(x,y,z);
	theta := XNXLMath.arccos(x);	
	phi := XNXLMath.arccos(1-p.z);
END sphtocart;

PROCEDURE ddray(VAR ray: XNXLBase.Ray); 
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
	IF XNXLBase.speed < 0.01 THEN XNXLBase.speed := XNXLBase.speed * 2 END
END speedup;

PROCEDURE slowdown;
BEGIN
	IF XNXLBase.speed > 0.0000001 THEN XNXLBase.speed := XNXLBase.speed/2 END
END slowdown;

PROCEDURE cursorpush;
BEGIN
	XNXLBase.cursordist:=XNXLBase.cursordist*1.1
END cursorpush;

PROCEDURE cursorpull;
BEGIN
	XNXLBase.cursordist:=XNXLBase.cursordist*0.9 
END cursorpull;

PROCEDURE vlnext;
BEGIN
	XNXLMarsh.	incVN;
END vlnext;

PROCEDURE vllast;
BEGIN
	XNXLMarsh.	decVN;
END vllast;

PROCEDURE cursorsizeplus;
BEGIN
	XNXLMarsh.	cursorsize:=ENTIER(XNXLMarsh.cursorsize/1.5)
END cursorsizeplus;

PROCEDURE cursorsizeminus;
BEGIN
	XNXLMarsh.	cursorsize:=ENTIER(XNXLMarsh.cursorsize*1.5)
END cursorsizeminus;

(************** XLTL AMALGAMATION FOLLOWS *)

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

PROCEDURE GLClose;
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
END GLClose;

PROCEDURE Close*;
VAR i: INTEGER;
BEGIN
	XNXLBase.worldalive:=FALSE;
	GLClose;
	IF window#NIL THEN window.Close; window:=NIL END;
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
 (* GL_TRUE: Use direct rendering, GL_FLSSE: use X server for rendering *)
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
					(*	CASE be.button OF
							  Api.Button1: camera.speedup;
							|Api.Button2: camera.mwheelmode:= (camera.mwheelmode+1)MOD 2			
							|Api.Button3: camera.slowdown;
							|Api.Button4: CASE camera.mwheelmode OF
												  0: camera.speedup	
												|1: XNXLBase.avdist:=XNXLBase.avdist*1.1
											ELSE
											END
							|Api.Button5: CASE camera.mwheelmode OF
												  0: camera.slowdown	
												|1: XNXLBase.avdist:=XNXLBase.avdist/1.1
											ELSE
											END
							ELSE
							END
	*)		| Api.ButtonRelease: be := SYSTEM.VAL(Api.XButtonReleasedEvent, event);
			(*		CASE be.button OF
					| Api.Button1:  camera.FUSETRAIL:=FALSE
					| Api.Button2:  
					| Api.Button3:  camera.TRAIL:=FALSE
					ELSE  (* ignore *)
					END;				
	*)		| Api.MotionNotify:  
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
		| KS.XK_w1 :camera.forward; Out.Char('*');
		| KS.XK_a1 :camera.leftward		
		| KS.XK_d1 :camera.rightward		
		| KS.XK_e1: camera.upstrafe
		| KS.XK_q1: camera.downstrafe	
		| KS.XK_l1: v:=XNXLBase.world.probe(XNXLBase.cursorPT.x, XNXLBase.cursorPT.y, XNXLBase.cursorPT.z) 	 
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
	(*	| KS.XK_o1:	glcamera.CCBUFFER:=~glcamera.CCBUFFER
		| KS.XK_t1: camera.TRAIL:=~camera.TRAIL; 
		| KS.XK_v1: camera.AVATAR:=~camera.AVATAR; 
		| KS.XK_z1: XLTLMarsh.marsh.draw;
		| KS.XK_x1: XLTLMarsh.marsh.cycleD;
		| KS.XK_1 : XNXLBase.DTL:= ENTIER(2*XNXLBase.DTL/3)		
		| KS.XK_2 : XNXLBase.DTL:= ENTIER(3*XNXLBase.DTL/2)		
		| KS.XK_3 : INC(XNXLBase.gravity);	
		| KS.XK_4: DEC(XNXLBase.gravity);					
		| KS.XK_h1 : camera.hop			
		| KS.XK_b1 : camera.AALIGN:=~camera.AALIGN	
		| KS.XK_m1 : XNXLBase.mtoggle:=~XNXLBase.mtoggle;
		| KS.XK_bracketright: camera.aperture.width := camera.aperture.width * 101/99; camera.aperture.height := camera.aperture.height *101/99
		| KS.XK_bracketleft: camera.aperture.width := camera.aperture.width * 99/101; camera.aperture.height := camera.aperture.height *99/101
		| KS.XK_plus: camera.speedup
		| KS.XK_minus: camera.slowdown
		| KS.XK_period: camera.stop
		| KS.XK_9: XNXLBase.avatarsize:=XNXLBase.avatarsize*2
		| KS.XK_0: IF XNXLBase.avatarsize>27 THEN XNXLBase.avatarsize:=ENTIER(XNXLBase.avatarsize/2) END
		| KS.XK_7: XNXLBase.avdist:=XNXLBase.avdist*1.3
		| KS.XK_8: XNXLBase.avdist:=XNXLBase.avdist/1.3	
		| KS.XK_5: leftsticky:=leftsticky*1.3; IF leftsticky>5 THEN leftsticky:=0.2  END;
		| KS.XK_6: upsticky:=upsticky*1.3; IF upsticky>5 THEN upsticky:=0.2  END; 
		| KS.XK_g1: camera.gravity:=~camera.gravity;
		| KS.XK_f1 : fogdensity:= fogdensity*1.1; 
				IF fogdensity>9.9 THEN fogdensity:=0.7 END		
*)	ELSE	
	END;	
END KeyEvent;

PROCEDURE MouseVent(x,y: LONGINT);
BEGIN
	camera.left(x/(1000*leftsticky));
	camera.up(y/(1000*upsticky));	
END MouseVent;

PROCEDURE InitGL;
BEGIN
	xrot := 30.0; yrot := 30.0; z := -10.0;	
	xspeed := 0.0; yspeed := 0.0;
	filter := 0;
	
		
LightAmbient[0] := 0.21; LightAmbient[1] := 0.21; LightAmbient[2] := 0.21; LightAmbient[3] :=1.0;
LightDiffuse[0] := 0.5; LightDiffuse[1] := 0.5; LightDiffuse[2] := 0.5; LightDiffuse[3] := 0.0;
LightPosition[0]:= 0.0; LightPosition[1]:= 1.0; LightPosition[2]:= 1; LightPosition[3]:= 1.0;
LightDiffuse2[0] := 0.7; LightDiffuse2[1] := 0.4; LightDiffuse2[2] := 0.2; LightDiffuse2[3] := 1.0;
red[0]:=0.62; red[1]:=0.42; red[2]:=0.9; red[3]:=0.0; 
blue[0]:=0.09; blue[1]:=0.09; blue[2]:=0.09; blue[3]:=1.0; 

 (*context.MakeCurrent(); *)
GL.SetFCR();

  (* Enable Texture Mapping ( NEW ) *)
 GL.glEnable( GLC.GL_TEXTURE_2D );

  (* Enable smooth shading *)
  GL.glShadeModel( GLC.GL_SMOOTH );

  (* Set the background black *)
  GL.glClearColor(0.33,0.39,0.29 , 0.0 );

  (* Depth buffer setup *)
  GL.glClearDepth( 1.0 );


  GL.glEnable( GLC.GL_DEPTH_TEST );
 GL.glDepthFunc(GLC.GL_LEQUAL );
  GL.glEnable(GLC.GL_ALPHA_TEST );

  GL.glBlendFunc(GLC.GL_SRC_ALPHA, GLC.GL_ONE_MINUS_SRC_ALPHA);
  

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
  GL.glColor4f(1,1,1,0.5);
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
	i,j,k,i3,j3:LONGINT;
	a: REAL;
BEGIN
	InitGL;
	GL.SetFCR();
	GL.glMatrixMode(GLC.GL_PROJECTION);
	GL.glLoadIdentity();
	GL.glFrustum(-0.001,0.001,-0.001,0.001,0.001,150); 
	IF TRUE THEN
 		GL.glClear((GLC.GL_COLOR_BUFFER_BIT+GLC.GL_DEPTH_BUFFER_BIT))
 	ELSE
		GL.glClear((GLC.GL_DEPTH_BUFFER_BIT))
	END;	
	GL.glEnable( GLC.GL_TEXTURE_2D );
 	GL.glMatrixMode(GLC.GL_MODELVIEW);
	GL.glLoadIdentity(); 	
	GL.glScalef(100,100,100);
	GL.DelFCR();
	a:= -camera.cameraphi*rad2deg;
	GL.SetFCR();	
	GL.glRotatef(a,1,0,0); 		
	GL.DelFCR();
	a:= 90+camera.cameratheta*rad2deg;
	GL.SetFCR();
	GL.glRotatef(a,0,1,0); 		
	GL.glTranslatef(-camera.cam.x, -camera.cam.z, -camera.cam.y); 	
	GL.glPushMatrix;	
	IF camera.cam.z>1/2 THEN 
		blue[0]:=0.0; blue[1]:=0.0; blue[2]:=0.29; blue[3]:=1.0; 
		GL.glFogf(GLC.GL_FOG_DENSITY, fogdensity);
		GL.glFogfv(GLC.GL_FOG_COLOR,SYSTEM.ADR(blue[0])); 
	ELSE
		GL.glFogf(GLC.GL_FOG_DENSITY, fogdensity/10);
		red[0]:=0.0; red[1]:=0.5; red[2]:=0.5; red[3]:=1.0; 
		GL.glFogfv(GLC.GL_FOG_COLOR,SYSTEM.ADR(red[0]));
	END;	
	GL.DelFCR();
	InitGL;	
	XNXLGL.draw; 
	GL.glMatrixMode(GLC.GL_PROJECTION);
	GL.glLoadIdentity();
	GL.glDisable( GLC.GL_DEPTH_TEST );
	GL.glDisable( GLC.GL_TEXTURE_2D );
	 GL.glDisable(GLC.GL_ALPHA_TEST );
	i3:=0;
	GL.glBegin(GLC.GL_QUADS);	
	FOR j:= 0 TO XNXLBase.W-1 DO 
		j3:=0; 
		FOR i := 0 TO XNXLBase.H-1 DO	
(*			GL.glColor3f(XNXLBase.rays[i,j].r, XNXLBase.rays[i,j].g,XNXLBase.rays[i,j].b); *)
			GL.glColor3f(rand.Uniform(),rand.Uniform(),rand.Uniform());
			GL.glVertex2f(i3,j3);
			GL.glVertex2f(i3+3,j3);
			GL.glVertex2f(i3+3,j3+3);
			GL.glVertex2f(i3,j3+3);				
			j3:=j3+3
		END;
		i3:=i3+3
	END;	
	GL.glEnd;		 
	GL.glXSwapBuffers(display, win);
END draw;

PROCEDURE mainloop;
BEGIN
	alive:=TRUE;
	NEW(rand);
	XNXLRetina.world:=XNXLBase.world;
	WHILE alive DO	
		window.move;		
		window.camera.tick; 
		draw;
		PollXQueue; 
	END;
END mainloop;	

PROCEDURE Open* ;
BEGIN	
	InitWindow(400,400, 'XOLOTL-HYBRID' );	
	DrawMode(0);
	InitGL; 	
	XNXLMarsh.dawn;	
	alive:=TRUE;
	NEW(rand);
	foveasize := 30;
	XNXLBase.speed:=0.00051;
	multicore:=TRUE;
	camrotinertia:=100;
	XNXLRetina.world:=XNXLBase.world;
	XNXLBase.DTL:=100000000.0;
	XNXLBase.DTL2:=100.0;
	XNXLBase.cursordist:=0.001;
	R1:=100;
	R2:=150;
	avtoggle:=TRUE;
	XNXLBase.gravity:=-0.003;	
	XNXLBase.worldalive := TRUE;
	debugevents:=FALSE;
	mousex:=200;
	mousey:=200;
	centerx:=200;
	centery:=200;
	fogdensity:=0.11;
	leftsticky:=1.0;
	upsticky:=1.0;	
	

	NEW(window, XNXLBase.W, XNXLBase.H, 100, 100); 
	window.camera.world:=XNXLBase.world;
	camera:=window.camera;
	mainloop;
END Open;

BEGIN

END XNXLRender.Open


SystemTools.FreeDownTo  XNXLBase~
