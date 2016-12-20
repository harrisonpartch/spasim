MODULE Render;
IMPORT Kernel, Objects, Random, Marsh, Rectangles := WMRectangles, WM := WMWindowManager, WMMessages,
 Out := KernelLog, Math,SPSMMath, Base, Retina,  WarpMouse,
	 Inputs,  Raster, Strings, Streams, Debugging;

TYPE
	Aperture = Base.Aperture;
	Ray = Base.Ray;
	Voxel = Base.Voxel;
	PT = Base.PT;
	
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
	cx:=1/3; cy:=1/2; cz:=1/2;
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
	cx :=cx+Base.rand.Uniform()/50-1/100;
	cy :=cy+Base.rand.Uniform()/50-1/100;
	cz :=cz+Base.rand.Uniform()/50-1/100;
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
			cvz:=0 (* -cvz/2 *)
		ELSE
			x := cx + cvx; y := cy; z := cz+cvz;
			q:=Base.mkPT(x,y,z);
			pass := Base.world.passprobe(q);
			IF pass THEN
				cvy:=0
			ELSE
				x := cx; y := cy + cvy; z := cz+cvz+0.001;
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
	fward,dward,rward:PT;
BEGIN
	fward:=Retina.fward;
	cvx :=cvx+(x*fward.x);
	cvy :=cvy+(x*fward.y);
	cvz :=cvz+(x*fward.z);
END forward;

PROCEDURE rightstrafe(x:REAL);
VAR
	rward,dward:PT;
	ray: Base.Ray;
BEGIN
	rward:=Retina.fward;
	dward:=Base.mkPT(0,1,0);
	SPSMMath.orrot(rward, dward,3.14159/2);
	cvx :=cvx+(x*rward.x);
	cvy :=cvy+(x*rward.y);
	cvz :=cvz+(x*rward.z);
END rightstrafe;

PROCEDURE upstrafe(x:REAL);
VAR
	rward,dward,fward:PT;
	ray: Base.Ray;
BEGIN
	dward:=Base.mkPT(0,0,1);
	rward:=Base.mkPT(0,1,0);
	SPSMMath.orrot(rward, dward,cameratheta);
	SPSMMath.orrot(dward, rward,cameraphi);
	cvx :=cvx+(x*dward.x);
	cvy :=cvy+(x*dward.y);
	cvz :=cvz+(x*dward.z);
END upstrafe;

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
	IF cameraphi > 1.61 THEN cameraphi := 1.61 END;
	IF cameraphi < -1.61 THEN cameraphi := -1.61 END
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
	gravityvector:=Base.mkPT(0,0,1);
	gravity:=Base.gravity;
	gravityvector:=Base.mulPT(gravityvector,Base.gravity);
	a:=Retina.fward.x*Base.cursordist; b:=Retina.fward.y*Base.cursordist; c:=Retina.fward.z*Base.cursordist;
	d:=Retina.fward.x*0.0021; e:=Retina.fward.y*0.0021;  f:=Retina.fward.z*0.0021;
	Base.updatecamera(cx,cy,cz,a,b,c,d,e,f);
	IF avaTF THEN Marsh.drawavatar END;
	GLIDE:=0.90;
	cvz := cvz*GLIDE+gravityvector.z;
	cvx := cvx*GLIDE+gravityvector.x; cvy := cvy*GLIDE+gravityvector.y;
	cvl :=cvl*0.5; cvu := cvu*0.5; 
	IF 0 IN MB THEN Marsh.draw; Out.Char("*");
	ELSIF  1 IN MB THEN Marsh.snipeinto;
	ELSIF  2 IN MB THEN Marsh.snipeonto;
	END;
	trace;
	Base.tick
END tick;
  
END Camera;

PROCEDURE P(VAR message:WMMessages.Message; VAR discard: BOOLEAN);
BEGIN
	IF CAPTURE THEN 
		RW.Handle(message);
		discard:=TRUE;
		IF (message.msgType=WMMessages.MsgPointer) THEN
			MB:=message.flags;
	END
	END
END P;

(*! ************* XLTL AMALGAMATION FOLLOWS *)

TYPE RayWindow=OBJECT(WM.DoubleBufferWindow)
VAR
	alive: BOOLEAN;
	i, t1: LONGINT;
	mousepreviousx, mousepreviousy: LONGINT;
	pi: WM.PointerInfo;
	warpvent: BOOLEAN;
	saccade: BOOLEAN;
	mstarget: INTEGER;

PROCEDURE &openwincam(W,H: INTEGER);
BEGIN
	Init(W, H, TRUE);
	NEW(camera, Retina.W, Retina.H);
	camera.aperjust(W,H);
	manager := WM.GetDefaultManager();
	manager.Add(100,100, SELF, { WM.FlagFrame, WM.FlagClose, WM.FlagStayOnTop});
	RWcenterx:=100+(W DIV 2);
	RWcentery:=100+(H DIV 2);
     WM.LoadCursor("blankrecticle.png", 3,3, pi);
	SetPointerInfo(pi);
	mstarget:=30;
END openwincam;

PROCEDURE uncapture;
VAR 
	wmanager: WM.WindowManager;
BEGIN
	CAPTURE:= FALSE;
	wmanager:=WM.GetDefaultManager();
	wmanager.RemoveMessagePreview(P);
END uncapture;

PROCEDURE KeyEvent (ucs : LONGINT; flags : SET; keysym : LONGINT);
VAR
	v: Voxel;
	s: Strings.String;
	c: CHAR;
BEGIN
	CASE ucs OF
		   27: uncapture;
		| 164: uncapture; Close
		| 193: INC(mstarget);  INC(mstarget);  INC(mstarget);  INC(mstarget); 
		| 194: DEC(mstarget); DEC(mstarget); DEC(mstarget); DEC(mstarget); 
		| 195: camera.left(0.03)
		| 196: camera.left(-0.03)
	ELSE
		CASE CHR(ucs) OF
			   "s" : camera.forward(-0.51*Base.speed)
			| "w" :camera.forward(0.51*Base.speed)
			| "a" :camera.rightstrafe(-0.5*Base.speed)
			| "d" :camera.rightstrafe(0.5*Base.speed)
			| "e": camera.upstrafe(-0.51*Base.speed)
			| "q": camera.upstrafe(0.51*Base.speed)
			| "n": leftsticky:=leftsticky*1.3; upsticky:=upsticky*1.3;
			| "m": leftsticky:=leftsticky/1.3; upsticky:=upsticky/1.3;
			| "v":Marsh.engrain
			| "c": Marsh.sprout
			| "x": Marsh.incVN
			| "z": Marsh.decVN
			| "p":  camera.stop
			| "1": Marsh.lighten
			| "2" : Marsh.darken
			| "3" : Base.gravity:= Base.gravity/1.5
			| "4" : Base.gravity:= 1.5*Base.gravity
			| "5" : Base.STOPGO
			| "6" : avaTF:=~avaTF
			| "h" : camera.hop
			| "]": camera.aperture.width := camera.aperture.width * 101/99; camera.aperture.height := camera.aperture.height *101/99;
				(*    Out.String("] pressed"); Out.Ln; *)
			| "[":  camera.aperture.width := camera.aperture.width * 99/101;  camera.aperture.height := camera.aperture.height *99/101;
				(*Out.String("[ pressed"); Out.Ln;*)
			| "9": IF Marsh.cursorsize<999999 THEN Marsh.cursorsize:=Marsh.cursorsize * 2; Base.cursordist:=Base.cursordist/2 END
			| "0": IF Marsh.cursorsize>1 THEN Marsh.cursorsize:=Marsh.cursorsize DIV 2; Base.cursordist:=Base.cursordist*2 END
			| "7": Base.cursordist:=Base.cursordist*1.3
			| "8": Base.cursordist:=Base.cursordist/1.3
			| "l": Marsh.lines:=~Marsh.lines
			| "b": Marsh.showcode;
			| "=": uncapture;
			| "+": uncapture; Close;	
		ELSE
			Out.Int(ucs,5);
			Out.Ln;
		END
	END
END KeyEvent;

PROCEDURE PointerDown(x, y: LONGINT; keys: SET);
VAR 
	wmanager: WM.WindowManager;
BEGIN
	Out.Char("!");
	IF ~CAPTURE THEN
		CAPTURE:= TRUE;
		wmanager:=WM.GetDefaultManager();
		wmanager.InstallMessagePreview(P); 
	END; 
END PointerDown;
	
PROCEDURE PointerMove(x,y: LONGINT; keys: SET);
BEGIN
	IF CAPTURE THEN
			mousedx:=x-mousepreviousx;
			mousedy:=y-mousepreviousy;
			IF (mousedx+mousedy)>50 THEN saccade:=TRUE ELSE saccade:=FALSE END;
			camera.up(-mousedy*ABS(mousedy)/(10000*upsticky)); 
			camera.left(mousedx*ABS(mousedx)/(10000*leftsticky));	
			mousepreviousx:=x;
			mousepreviousy:=y;
	END
END PointerMove;

PROCEDURE WheelMove(dz: LONGINT);
BEGIN
	IF TRUE  THEN
		IF dz > 0 THEN slowdown; Out.String("slowdown dz="); Out.Int(dz, 0); Out.Ln;
		ELSE speedup; Out.String("speedup dz="); Out.Int(dz, 0); Out.Ln;
		END;
	END;
END WheelMove;

PROCEDURE detail();
	BEGIN
		IF saccade THEN 
			Retina.saccade:=TRUE
		ELSE	
			Retina.saccade:=FALSE;
			IF framedt < mstarget THEN
				(* timer.Sleep(mstarget-framedt); *)
				Retina.moredetail;
			ELSIF framedt > (mstarget+10) THEN
				Retina.lessdetail;
			END
 END 
END detail;

	BEGIN {ACTIVE}
		NEW(rand);
		foveasize := 100;
		multicore:=TRUE;
		camrotinertia:=100;
		Base.DTL:=25000;
		Base.DTL2:=2500;
		Base.gravity:=0.000001;
		Base.speed:=0.001;
		Base.maxspeed:=0.0001;
		Base.cursordist:=0.01;
		R1:=100;
		R2:=150;
		Base.worldalive := TRUE;
		fogdensity:=0.11;
		leftsticky:=10.0;
		upsticky:=10.0;
		Out.String('*line 1217!*');
		msd:=30;		
		NEW(timer);
		REPEAT
			Retina.image := backImg;
			t1:=Kernel.GetTicks();
			camera.tick;
			framedt:=Kernel.GetTicks()-t1;	
			detail;
			Swap; 
			Invalidate(Rectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
			IF CAPTURE THEN 
				WarpMouse.warp(500+bounds.l,500+bounds.t);
				mousepreviousx:=500; 
				mousepreviousy:=500;
			END
		UNTIL FALSE
	END RayWindow;

VAR
	rand: Random.Generator;
	wcount: INTEGER;
	frame, tickframe: LONGINT;
	movierecording, movieplaying: BOOLEAN;
	frtrace, foveate: BOOLEAN;
	foveasize, fovealeft, fovearight, foveadown, foveaup: LONGINT;
	DEATH, wLOOK, PAUSE: BOOLEAN;
	tracetiled,avaTF, capturethemouse: BOOLEAN;
	framecount: LONGINT;
	multicore,filtor,uplock,rollcam,suppressz: BOOLEAN;
	camrotinertia:REAL;
	framedt: LONGINT;
	pkeys: SET;
	pointerx, pointerdx, pointery, pointerdy: LONGINT;
	R1,R2: REAL;
	update: LONGINT;
	MLseen, MMseen, MRseen: BOOLEAN;
	chatting: BOOLEAN;
	chatvoxel: Voxel;
	warpedthemouse: BOOLEAN;
	MB : SET;	(* 0, 1, 2 *)
	MOUSEDOWN, CAPTURE, GO,TRAIL,AVATAR,SCULL,METASLASH: BOOLEAN;
	camera:Camera;
	fogdensity:REAL;
	leftsticky,upsticky: REAL;
	centerx,centery: LONGINT;
	GLIDE:REAL;
	msd: REAL;
	RW:  RayWindow;
	RWcenterx, RWcentery,mousedx,mousedy: LONGINT;
	timer: Kernel.Timer;

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
	Marsh.incVN;
END vlnext;

PROCEDURE vllast;
BEGIN
	Marsh.decVN;
END vllast;

PROCEDURE cursorsizeplus;
BEGIN
	Marsh.cursorsize:=ENTIER(Marsh.cursorsize/1.5)
END cursorsizeplus;

PROCEDURE cursorsizeminus;
BEGIN
	Marsh.cursorsize:=ENTIER(Marsh.cursorsize*1.5)
END cursorsizeminus;

PROCEDURE Open* ;
BEGIN
	NEW(RW, Retina.W*4,Retina.H*4);
	Base.STOPGO
END Open;

PROCEDURE Close*;
BEGIN
	 IF RW# NIL THEN RW.uncapture; RW.Close; RW := NIL END;
END Close;

BEGIN

END Render.

Render.Open ~

SystemTools.Free Render ~
