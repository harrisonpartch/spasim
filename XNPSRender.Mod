MODULE XNPSRender;
IMPORT  Kernel, Modules, WMWindowManager, Graphics:=WMGraphics, Raster, Objects, Random, XNPSMarsh,
Rectangles:= WMRectangles,  Scale:= WMRasterScale, Out := KernelLog, Math, XNPSBase,  XNPSMath,  XNPSRetina,Heaps;

CONST S=2; (* image size multiplier *)
	ML = 0;  MM = 1;  MR = 2;
	
TYPE Aperture = XNPSBase.Aperture;
TYPE Ray = XNPSBase.Ray;
TYPE Voxel = XNPSBase.Voxel; 
TYPE PT = XNPSBase.PT;
	
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
    	WMWindowManager.LoadCursor("XNPS.Recticle.png", 3,3, pi);	
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
	msense:=50;  (*lower is skittisher*)
END New;

PROCEDURE FocusGot*;
BEGIN
	focus := TRUE;
	XNPSBase.STOP:=FALSE;
	PAUSE:=FALSE;
	camera.returntohorizon:=FALSE;
END FocusGot;

PROCEDURE FocusLost*;
BEGIN
	focus := FALSE;
	XNPSBase.STOP:=TRUE;
	PAUSE:=TRUE;
END FocusLost;

PROCEDURE Close;
BEGIN
	XNPSBase.worldalive := FALSE;
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
		| 'i': XNPSRetina.EDGE:=XNPSRetina.EDGE*2/3;
		| 'o': XNPSRetina.EDGE:=XNPSRetina.EDGE*3/2;
		| 'I': XNPSBase.DTL2:=XNPSBase.DTL2*1.5; 
		| 'O': XNPSBase.DTL2:=XNPSBase.DTL2/1.5
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
		| '*': XNPSBase.STOPGO
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
	image,imj: XNPSBase.IMAGE;
	random: Random.Generator;
	rayschanged, ang1,filter: BOOLEAN;
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
	filter:=TRUE;
	cameratheta := 0;
	cameraphi := 0;
	aperture.width := 5/3;
	aperture.height :=5/3;
	XNPSBase.setPT(xaxis, 1,0,0);	
	XNPSBase.setPT(yaxis,0,1,0);	
	XNPSBase.setPT(zaxis,0,0,-1);	
	fisheye:=1;
	hop;
END init;

PROCEDURE hop;
BEGIN
	stop;
	cx :=1/3+XNPSBase.rand.Uniform()/3; cy:=1/2+XNPSBase.rand.Uniform()/3; cz := 1/2+XNPSBase.rand.Uniform()/3;
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
	proberay:= XNPSBase.rays[(W DIV 2)-(W DIV 2)MOD 5, (H DIV 2)-(H DIV 2)MOD 5];
	x := cx + cvx; y := cy + cvy; z := cz + cvz;
	pass := XNPSBase.world.passprobe(x,y,z)&XNPSBase.world.passprobe(x,y,z-0.015);
	lookdxyz:=proberay.dxyz;
	IF ~pass THEN
		x := cx + cvx; y := cy + cvy; z := cz;	
		pass := XNPSBase.world.passprobe(x,y,z)&XNPSBase.world.passprobe(x,y,z-0.015);
		IF pass THEN 
			cvz:=0
		ELSE
			x := cx + cvx; y := cy; z := cz+cvz;	
			pass := XNPSBase.world.passprobe(x,y,z)&XNPSBase.world.passprobe(x,y,z-0.015);
			IF pass THEN 
				cvy:=0
			ELSE			
				x := cx; y := cy + cvy; z := cz+cvz;	
				pass := XNPSBase.world.passprobe(x,y,z)&XNPSBase.world.passprobe(x,y,z-0.015);
				IF pass THEN 
					cvx:=0 
				END
			END
		END
	END;
	IF  pass THEN 
		cx:=x; cy:=y; cz:=z (*  if movement forward restricted to xy plane *)
	ELSE
		XNPSBase.world.Shade(proberay);
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
	XNPSBase.speed := XNPSBase.speed/1.05;
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
	ray:=XNPSBase.rays[x,y];
	NEW(v);
	v:=XNPSBase.world.proberay(ray); 
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
	ray:=XNPSBase.rays[x,y];
	NEW(v);
	v:=XNPSBase.world.proberay(ray); 
(*	XNPSBase.cursordist:=2*ray.length/3; *)
END sniprobe;


PROCEDURE deathray(x,y: LONGINT);
BEGIN
	initrays;
	XNPSBase.world.deathray(XNPSBase.rays[x,y]);
END deathray;

PROCEDURE forward;
VAR
	v: PT;
BEGIN
	v:=fward;
	cvx :=(v.x * XNPSBase.speed); 
	cvy := (v.y * XNPSBase.speed); 	
	cvz := (v.z * XNPSBase.speed); 	
END forward;

PROCEDURE backward;
VAR
	v: PT;
BEGIN
	v:=fward;
	cvx :=  -(v.x * XNPSBase.speed); 
	cvy :=  -(v.y * XNPSBase.speed); 	
	cvz :=  - (v.z * XNPSBase.speed); 	
END backward;

PROCEDURE rightward;
VAR
	v: PT;
BEGIN
	rward:=yaxis;
	XNPSMath.orrot(rward, zaxis, cameraphi);  
	v:=rward;
	cvx := (v.x * XNPSBase.speed); 
	cvy :=  (v.y * XNPSBase.speed); 	
	cvz := (v.z * XNPSBase.speed); 	
END rightward;

PROCEDURE leftward;
VAR
	v: PT;
BEGIN
	rward:=yaxis;
	XNPSMath.orrot(rward, zaxis, cameraphi);
  	v:=rward;
	cvx := -(v.x * XNPSBase.speed); 
	cvy := -(v.y * XNPSBase.speed); 	
	cvz := -(v.z * XNPSBase.speed); 	
END leftward;

PROCEDURE upstrafe; (* strafe up perpendicular to look *)
VAR
	v: PT;
BEGIN
	v:=down;
	cvx := -(v.x * XNPSBase.speed); 
	cvy := -(v.y * XNPSBase.speed); 	
	cvz := -(v.z * XNPSBase.speed); 	
END upstrafe;

PROCEDURE downstrafe;
VAR
	v: PT;
BEGIN
	v:=down;
	cvx :=  (v.x * XNPSBase.speed); 
	cvy :=  (v.y * XNPSBase.speed); 	
	cvz := (v.z * XNPSBase.speed); 	
END downstrafe;

PROCEDURE initrays;
VAR
	reversej, i, j: LONGINT;
	theta, phi, dtheta, dphi: REAL;
	lookperpray: Ray;
	lookvector:PT;
	look: XNPSBase.PT;
	camtweak: XNPSBase.PT;
	d1,d2,d3: REAL;
	w,h: REAL;
BEGIN
	fward:=xaxis;
	rward:=yaxis;
	down:=zaxis;
	XNPSMath.orrot(fward, zaxis, cameraphi);  
	XNPSMath.orrot(rward, zaxis, cameraphi);  
	XNPSMath.orrot(fward, rward, cameratheta);  
	XNPSMath.orrot(down, rward, cameratheta);  	
	w:= aperture.width;
	h:=aperture.height;
	w:=fisheye*w;
	h:= fisheye*h;
	dtheta := w / W;
	dphi := h/ H;
	theta := -w / 2;
	FOR i := 0 TO XNPSBase.W - 1  DO
		theta := theta + dtheta;
		phi :=  -aperture.height / 2; 	(*bottom*)
		FOR reversej := 0 TO XNPSBase.H - 1 DO
			j:= (XNPSBase.H -1)-reversej;
			phi := phi + dphi;
			XNPSBase.rays[i, j] := XNPSBase.blankray;			
			XNPSBase.rays[i, j].theta := theta;
			XNPSBase.rays[i, j].phi := phi;
			angletoray(XNPSBase.rays[i, j],theta,phi);
			XNPSMath.orrot(XNPSBase.rays[i, j].dxyz, zaxis, cameraphi);  	
		   	XNPSMath.orrot(XNPSBase.rays[i, j].dxyz, rward, cameratheta);  			  	  								  	  		
			IF XNPSBase.rays[i, j].dxyz.x < 0 THEN XNPSBase.rays[i, j].di := FALSE  ELSE XNPSBase.rays[i, j].di := TRUE END; 
			IF XNPSBase.rays[i, j].dxyz.y < 0 THEN XNPSBase.rays[i, j].dj := FALSE  ELSE XNPSBase.rays[i, j].dj := TRUE END;
			IF XNPSBase.rays[i, j].dxyz.z < 0 THEN XNPSBase.rays[i, j].dk := FALSE  ELSE XNPSBase.rays[i, j].dk := TRUE END;		
			XNPSBase.rays[i, j].lxyz := cam;
			XNPSBase.rays[i, j].xyz := cam;
			XNPSBase.rays[i, j].oxyz:=XNPSBase.rays[i, j].dxyz;
		END
	END;
END initrays;

PROCEDURE trace;
VAR
	i, j, ii,jj,q,z: LONGINT;
	ry: XNPSBase.Ray;
	pixel : Raster.Pixel;
	r, g, b: LONGINT;
	R,G,B:REAL;
	lr, lg,lb,nlr,nlg,nlb: LONGINT;
	fr,fg,fb: REAL;
	rect,srect,clip: Rectangles.Rectangle;
BEGIN
	IF multicore THEN XNPSRetina.go ELSE XNPSRetina.gosinglecore END;
	FOR j:= 0 TO H-1 DO 
		FOR i := 0 TO W-1 DO
		XNPSBase.clamp3(XNPSBase.rays[i,j].r,XNPSBase.rays[i,j].g,XNPSBase.rays[i,j].b);	(* unneeded if shaders behave properly *)
			image[i,j].red:=XNPSBase.rays[i,j].r;
			image[i,j].green:=XNPSBase.rays[i,j].g;
			image[i,j].blue:=XNPSBase.rays[i,j].b;
			r:=ENTIER(XNPSBase.rays[i,j].r*255);
			g:=ENTIER(XNPSBase.rays[i,j].g*255);
			b:=ENTIER(XNPSBase.rays[i,j].b*255);
			Raster.SetRGB(pixel,r,g,b);	
			Raster.Put(activewindow.backImg,i,j,pixel,mode); 		
		END
	END;	
	rect:= Rectangles.MakeRect(0, 0, activewindow.GetWidth(), activewindow.GetHeight());
	srect:= Rectangles.MakeRect(0, 0, activewindow.GetWidth() DIV S, activewindow.GetHeight() DIV S);
	IF filter THEN
		Scale.Scale(activewindow.backImg, srect, activewindow.img, rect, rect, Scale. ModeCopy, Scale.ScaleBilinear);
	ELSE
		Scale.Scale(activewindow.backImg, srect, activewindow.img, rect, rect,  Scale.ModeSrcOverDst, Scale.ScaleBox);
	END;
	activewindow.Invalidate(rect); 
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
	a:=fward.x; b:=fward.y; c:=fward.z;
	XNPSBase.updatecameraPT(cx,cy,cz);	
	sniprobe;	
	XNPSBase.updatecursorPT(cx+a*XNPSBase.cursordist,cy+b*XNPSBase.cursordist,cz+c*XNPSBase.cursordist);		
	XNPSBase.normalize(a,b,c); (*should be normalized already *)
	XNPSBase.updateavatarPT(cx+a/1000,cy+b/1000,cz+c/1000);		
	cvz := cvz+XNPSBase.gravity/1000;
	cvx := cvx*0.97; cvy := cvy*0.97; cvz := cvz*0.97;
	cvl :=cvl*0.75; cvu := cvu*0.75;
	IF TRAILS THEN 
		XNPSMarsh.draw;
	END;
END tick;
 
END Camera;

TYPE cpbrowser=OBJECT(Camera)

PROCEDURE tick;   (* still same behavior as Camera. *)
VAR
	oldcam:PT;

BEGIN
	oldcam:=cam;
	cam.x := cx; cam.y := cy; cam.z := cz;
	cameratheta:=cameratheta+cvl;
	cameraphi:=cameraphi+cvu;
	IF TRAILS THEN XNPSMarsh.draw END;
	cvz := cvz+XNPSBase.gravity/100;
	cvx := cvx*0.959; cvy := cvy*0.959; cvz := cvz*0.859; cvl := cvl*0.1; cvu := cvu*0.31;
	IF ~(2 IN pkeys) THEN 
		cameraphi:=cameraphi*0.81 
	ELSE
		forward
	END;
	move;
	up(cvu);
	left(cvl); 
END tick;

END cpbrowser;

TYPE MainLoop=OBJECT
VAR
	dt,f,tf: LONGINT;
	fr: REAL;
	timer:Kernel.MilliTimer;
	timethisframe: BOOLEAN;
	framerate, lastframerate: LONGINT;

BEGIN {ACTIVE, PRIORITY(Objects.Low)}
	f:=0; tf:=0;
	REPEAT
	IF ~PAUSE THEN 
		IF ~XNPSBase.STOP THEN
			XNPSBase.tick; 
		END;
		IF ~TRAILS & avtoggle THEN XNPSMarsh.drawavatar END;
		activewindow.camera.initrays;
		activewindow.move;
		Kernel.SetTimer(timer,1000);
		activewindow.camera.trace;	
		dt:=Kernel.Elapsed(timer);
		Out.Int(dt,6);
		Out.Ln;
		IF dt<R1 THEN 
			XNPSRetina.lsu
		ELSIF dt>R2 THEN
			XNPSRetina.lsd
		END;

ELSE
		Objects.Sleep(1000); (*this must be commented away in winaos! else it will not compile!*)
	END;
	UNTIL ~XNPSBase.worldalive;
	Close;
END MainLoop;

VAR
	main: MainLoop;	
	lFRAMERATE: REAL;
	activewindow, mainwindow, copybrowser: VoxWindow;
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
	
PROCEDURE angletoray(VAR ray: XNPSBase.Ray; theta,phi: REAL);
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

PROCEDURE raytangle(VAR ray: XNPSBase.Ray);
VAR x,y, z: REAL;
BEGIN
	x := ray.xyz.x; y := ray.xyz.y; z := 0;
	XNPSBase.normalize(x,y,z);
	ray.theta := XNPSMath.arccos(x);	
	ray.phi := XNPSMath.arccos(1-ray.dxyz.z);
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
	XNPSBase.normalize(x,y,z);
	theta := XNPSMath.arccos(x);	
	phi := XNPSMath.arccos(1-p.z);
END sphtocart;

PROCEDURE ddray(VAR ray: XNPSBase.Ray); 
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
	IF XNPSBase.speed < 0.01 THEN XNPSBase.speed := XNPSBase.speed * 1.4 END
END speedup;

PROCEDURE slowdown;
BEGIN
	IF XNPSBase.speed > 0.0000001 THEN XNPSBase.speed := XNPSBase.speed/1.4 END
END slowdown;

PROCEDURE cursorpush;
BEGIN
	XNPSBase.cursordist:=XNPSBase.cursordist*1.1
END cursorpush;

PROCEDURE cursorpull;
BEGIN
	XNPSBase.cursordist:=XNPSBase.cursordist*0.9 
END cursorpull;

PROCEDURE vlnext;
BEGIN
	XNPSMarsh.	incVN;
END vlnext;

PROCEDURE vllast;
BEGIN
	XNPSMarsh.	decVN;
END vllast;

PROCEDURE cursorsizeplus;
BEGIN
	XNPSMarsh.	cursorsize:=ENTIER(XNPSMarsh.cursorsize/1.5)
END cursorsizeplus;

PROCEDURE cursorsizeminus;
BEGIN
	XNPSMarsh.	cursorsize:=ENTIER(XNPSMarsh.cursorsize*1.5)
END cursorsizeminus;

PROCEDURE Open* ;
BEGIN
	XNPSBase.worldalive := TRUE;
	NEW(mainwindow, XNPSBase.W, XNPSBase.H, 100, 100); 
	mainwindow.camera.world:=XNPSBase.world;
(*	NEW(copybrowser, XNPSBase.W, XNPSBase.H, 100, 300); 
	copybrowser.camera.world:=XNPSBase.copybrowserworld;
*)	activewindow:=mainwindow;
	NEW(main);
END Open;

PROCEDURE Close*;
VAR i: INTEGER;
BEGIN
	XNPSBase.worldalive:=FALSE;
	IF mainwindow#NIL THEN mainwindow.Close; mainwindow:=NIL END;
	IF copybrowser#NIL THEN copybrowser.Close; copybrowser:=NIL END;
END Close;

BEGIN
	framecount := 0;
(****************************************)	
	wcount := 0;
	NEW(rand);
	Modules.InstallTermHandler(Close);
	foveasize := 30;
	XNPSBase.speed:=0.00051;
	multicore:=TRUE;
	camrotinertia:=100;
	XNPSRetina.world:=XNPSBase.world;
	XNPSBase.DTL:=100000000.0;
	XNPSBase.DTL2:=100.0;
	XNPSBase.cursordist:=0.001;
	R1:=100;
	R2:=150;
	avtoggle:=TRUE;
	XNPSBase.gravity:=-0.3;
END XNPSRender.



