MODULE XNXLRender;
IMPORT SYSTEM, Kernel, Random, XNXLMarsh,
 Out := KernelLog, Math, XNXLBase,  XNXLMath,  XNXLRetina,
	XNXLGL,  GL:=OpenGL, GLC := OpenGLConst, Inputs,
	OGLWindow;


CONST PX=2; (* image size multiplier *)

	rad2deg=360/6.28318;
	
TYPE Aperture = XNXLBase.Aperture;
TYPE Ray = XNXLBase.Ray;
TYPE Voxel = XNXLBase.Voxel; 
TYPE PT = XNXLBase.PT;

TYPE SNAP = RECORD
	lookphi, looktheta : REAL;
	aperture: Aperture;
	x,y,z,cdroll: REAL;		
	lookdxyz:PT;
END;	


TYPE Camera = OBJECT
VAR
	image,imj: XNXLBase.IMAGE;
	random: Random.Generator;
	rayschanged, ang1,filter: BOOLEAN;
	fovealeft, fovearight, foveabottom, foveatop: LONGINT;
	fovea: BOOLEAN;
	cam: PT; 
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
	proberay:= XNXLBase.rays[W DIV 2, H DIV 2];
	x := cx + cvx; y := cy + cvy; z := cz + cvz;
	pass := XNXLBase.world.passprobe(x,y,z);
	lookdxyz:=proberay.dxyz;
	IF ~pass THEN
		x := cx + cvx; y := cy + cvy; z := cz;	
		pass := XNXLBase.world.passprobe(x,y,z);
		IF pass THEN 
			cvz:=0
		ELSE
			x := cx + cvx; y := cy; z := cz+cvz;	
			pass := XNXLBase.world.passprobe(x,y,z);
			IF pass THEN 
				cvy:=0
			ELSE			
				x := cx; y := cy + cvy; z := cz+cvz;	
				pass := XNXLBase.world.passprobe(x,y,z);
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
	r, g, b: LONGINT;
	R,G,B:REAL;
	lr, lg,lb,nlr,nlg,nlb: LONGINT;
	fr,fg,fb: REAL;
BEGIN
	(* IF multicore THEN XNXLRetina.go ELSE XNXLRetina.gosinglecore END; *)
	XNXLRetina.go
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
	cvx := cvx*0.9; cvy := cvy*0.9; 
	cvl :=cvl*0.75; cvu := cvu*0.75;
	IF TRAILS THEN 
		XNXLMarsh.draw;
	END;
	initrays;
	trace;
	XNXLBase.tick;
END tick;

BEGIN 
END Camera;

(*! *************************** *)
(*! *************************** *)
TYPE OGLW = OBJECT(OGLWindow.Window)

	(** *)
	PROCEDURE &New*(w,h: LONGINT; tit: ARRAY OF CHAR);
	BEGIN
	Init(w,h,400,10, FALSE);
	
	SetTitle(tit); 
	(*SetIdleTime(10);*)
	SetGameMode(TRUE);
	cmdlinerun := TRUE;
	END New;

	(** *)
	PROCEDURE OnLoad*();
	BEGIN

	DrawMode(0);
	InitGL; 	
	XNXLMarsh.dawn;	

	NEW(rand);
	foveasize := 30;
	XNXLBase.speed:=0.00051;
	multicore:=TRUE;
	camrotinertia:=100;
	XNXLRetina.world:=XNXLBase.world;
	XNXLBase.DTL:=100000000.0;
	XNXLBase.DTL2:=100.0;
	XNXLBase.cursordist:=0.0051;
	R1:=100;
	R2:=150;
	avtoggle:=TRUE;
	XNXLBase.gravity:=-0.1;	
	XNXLBase.worldalive := TRUE;


	centerx:= width DIV 2;
	centery:= height DIV 2;
	fogdensity:=0.11;
	leftsticky:=1.0;
	upsticky:=1.0;	
	NEW(camera,XNXLBase.W, XNXLBase.H);
	
	NEW(rand);
	XNXLRetina.world:=XNXLBase.world;
	END OnLoad;
	
	PROCEDURE KeyEvent(ucs : LONGINT; flags : SET; keysym : LONGINT);	 
	VAR
		v: Voxel;   
	BEGIN
		
		CASE CHR(ucs) OF
			"s" : camera.backward
			| "w" :camera.forward; 
			| "a" :camera.leftward		
			| "d" :camera.rightward		
			| "e": camera.upstrafe
			| "q": camera.downstrafe	
			| "z": XNXLBase.RVR:=~XNXLBase.RVR
			| "l": v:=XNXLBase.world.probe(XNXLBase.cursorPT.x, XNXLBase.cursorPT.y, XNXLBase.cursorPT.z) 	 
			| "p": drawMode := (drawMode+1) MOD 2; DrawMode(drawMode); 
			| "n": leftsticky:=leftsticky*1.3; upsticky:=upsticky*1.3;
			| "m": leftsticky:=leftsticky/1.3; upsticky:=upsticky/1.3;
			| "t": TRAIL:=~TRAIL; 
			| "v":AVATAR:=~AVATAR; 
	
			| "x": XNXLMarsh.incVN;
			| "1" : XNXLBase.DTL:= ENTIER(2*XNXLBase.DTL/3)		
			| "2" : XNXLBase.DTL:= ENTIER(3*XNXLBase.DTL/2)		
			| "h" : camera.hop	
			| "3" : Close	
	
			| "]": camera.aperture.width := camera.aperture.width * 101/99; camera.aperture.height := camera.aperture.height *101/99
			| "[": camera.aperture.width := camera.aperture.width * 99/101; camera.aperture.height := camera.aperture.height *99/101
			| ".": camera.stop
			| "9": XNXLMarsh.cursorsize:=XNXLMarsh.cursorsize*2
			| "0": IF XNXLMarsh.cursorsize>27 THEN XNXLMarsh.cursorsize:=ENTIER(XNXLMarsh.cursorsize/2) END
			| "7": XNXLBase.cursordist:=XNXLBase.cursordist*1.3
			| "8": XNXLBase.cursordist:=XNXLBase.cursordist/1.3;
			| CHR(27): Out.String("ESCAPE"); Out.Ln;
			 					IF CAPTUREMOUSE THEN 
			 						CAPTUREMOUSE := FALSE
								ELSE
									Close;
								END
		ELSE
		END;

		CASE keysym OF
			 Inputs.KsEscape: Out.String("ESCAPE"); Out.Ln;
			 					IF CAPTUREMOUSE THEN 
			 						CAPTUREMOUSE := FALSE
								ELSE
									Close;
								END
			| Inputs.KsF1: Out.String("KsF1"); Out.Ln;
			| Inputs.KsUp: Out.String("KsUp"); Out.Ln;
			| Inputs.KsDown:  Out.String("KsDown"); Out.Ln;
			| Inputs.KsF11: (*ToggleFullWindow;*)
			| Inputs.KsF12: (* ToggleDecorations; *)
		
			ELSE
			END;
	END KeyEvent;

	PROCEDURE PointerMove* (x, y : LONGINT; keys : SET);
	VAR xr, yr: LONGINT;
	BEGIN
	(*	IF ~warpedthemouse THEN (* only once per frame *)*)
			xr := x-centerx; yr := y - centery;
			(*Out.String("xr= "); Out.Int(xr, 0); Out.String("  yr= "); Out.Int(yr, 0); Out.Ln;*)
			
			camera.left(xr/(7500*leftsticky));
			camera.up(-yr/(7500*upsticky));
	
			IF CAPTUREMOUSE & (ABS(xr)+ABS(yr)>5) THEN	
				(*Api.WarpPointer( display, 0,mne.window, 0,0, 1000,1000, centerx,centery);	*)
			END;
(*			warpedthemouse:=TRUE
		END*)
	END PointerMove;

	PROCEDURE PointerDown* (x, y : LONGINT; keys : SET);
	BEGIN
		CAPTUREMOUSE:=TRUE;
		IF OGLWindow.MR IN keys THEN TRAILS:=TRUE END;		
	END PointerDown;

	PROCEDURE PointerUp* (x, y : LONGINT; keys : SET);
	BEGIN
		IF OGLWindow.MR IN keys THEN TRAILS:=FALSE END;
	END PointerUp;
	
	(** *)
	PROCEDURE WheelMove*(dz: LONGINT);
	BEGIN
		IF dz < 0 THEN speedup ELSE slowdown END;
	END WheelMove;

PROCEDURE Reshape(w, h: LONGINT);
BEGIN	

	GL.glViewport(0, 0, w, h);
	GL.glClearColor(0.3, 0.1, 0.4, 0.0);
	GL.glMatrixMode(GLC.GL_PROJECTION);
	GL.glLoadIdentity();
	GL.SetFCR();
		GL.glFrustum(-1,1,-1,1, 0.5, 60); 
	GL.DelFCR();
	GL.glMatrixMode(GLC.GL_MODELVIEW);
	GL.glLoadIdentity(); 

	centerx:= w DIV 2; centery:= h DIV 2;
	
END Reshape;

PROCEDURE draw;
VAR
	i,j,ii,jj,k,i3,j3,ii3,jj3:LONGINT;
	a: REAL;
BEGIN
	IF XNXLBase.RVR THEN
		
		GL.glMatrixMode(GLC.GL_PROJECTION);
		GL.glLoadIdentity();
		GL.SetFCR();
			GL.glFrustum(-0.001,0.001,-0.001,0.001,0.001,150); 
		GL.DelFCR();
 		GL.glClear((GLC.GL_COLOR_BUFFER_BIT+GLC.GL_DEPTH_BUFFER_BIT));
	 		
		GL.glEnable( GLC.GL_TEXTURE_2D );
	 	GL.glMatrixMode(GLC.GL_MODELVIEW);
		GL.glLoadIdentity(); 	
		GL.glScalef(100,100,100);

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
	ELSE
		GL.glMatrixMode(GLC.GL_PROJECTION);
		GL.glLoadIdentity();
		GL.SetFCR();
		GL.glOrtho(0,XNXLBase.W*PX, XNXLBase.H*PX,0,0,1);
		GL.DelFCR();
		GL.glMatrixMode(GLC.GL_MODELVIEW);
		GL.glLoadIdentity();	GL.glDisable( GLC.GL_DEPTH_TEST );
		GL.glDisable( GLC.GL_TEXTURE_2D );
		GL.glDisable(GLC.GL_ALPHA_TEST );
		GL.glDisable(GLC.GL_CULL_FACE);
		GL.glTranslatef(0.375,0.375,0);
		i3:=0;
		FOR i:= 0 TO XNXLBase.W-1 DO 
			j3:=0; 
			FOR j := 0 TO XNXLBase.H-1 DO	
				GL.glBegin(GLC.GL_QUADS);	
				GL.glColor3f(XNXLBase.rays[i,j].r, XNXLBase.rays[i,j].g, XNXLBase.rays[i,j].b); 
				GL.glVertex2f(i3,j3);
				GL.glVertex2f(i3+PX,j3);
				GL.glVertex2f(i3+PX,j3+PX);
				GL.glVertex2f(i3,j3+PX);	
				GL.glEnd;	
				j3:=j3+PX
			END;
			i3:=i3+PX
		END	
	END;	
END draw;

(** *)
PROCEDURE Display*();
BEGIN
	camera.tick; 
	draw;
	SwapBuffers;
END Display;


PROCEDURE Close*;
VAR i: INTEGER;
BEGIN
	XNXLBase.worldalive:=FALSE;
	Close^;
END Close;

	
BEGIN
		MainLoop();
END OGLW;

(*! *************************** *)
(*! *************************** *)
	
VAR
	
	win : OGLW;
	
	rand: Random.Generator;


	foveasize: LONGINT;
	TRAILS : BOOLEAN;
	avtoggle: BOOLEAN;

	multicore: BOOLEAN;
	camrotinertia:REAL;

	R1,R2: REAL;

	drawMode:LONGINT; (* fill, lines, points *)

	LightAmbient, LightDiffuse, LightPosition: ARRAY [4] OF GL.GLfloat;
	LightDiffuse2, LightPosition2: ARRAY [4] OF GL.GLfloat;	
	red,  blue: ARRAY [4] OF GL.GLfloat; 
	xrot, yrot: REAL;  (* X, Y  rotation *)

	z : REAL; (* depth into the screen *)
	xspeed, yspeed: REAL;

	filter: LONGINT; (* type of filter *)		

	CAPTUREMOUSE, TRAIL,AVATAR: BOOLEAN;	
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
	XNXLMarsh.incVN;
END vlnext;

PROCEDURE vllast;
BEGIN
	XNXLMarsh.decVN;
END vllast;

PROCEDURE cursorsizeplus;
BEGIN
	XNXLMarsh.cursorsize:=ENTIER(XNXLMarsh.cursorsize/1.5)
END cursorsizeplus;

PROCEDURE cursorsizeminus;
BEGIN
	XNXLMarsh.cursorsize:=ENTIER(XNXLMarsh.cursorsize*1.5)
END cursorsizeminus;

(************** XLTL AMALGAMATION FOLLOWS *)

	
 
(*
PROCEDURE PollXQueue;
VAR   

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
							  Api.Button3:  TRAILS:=TRUE
						 	| Api.Button4: speedup;			
							|Api.Button5: slowdown;
						ELSE
						END
		| Api.ButtonRelease: be := SYSTEM.VAL(Api.XButtonReleasedEvent, event);
				CASE be.button OF
					| Api.Button1:  
					| Api.Button2:  
					| Api.Button3:  TRAILS:=FALSE
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
*)

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


PROCEDURE Open* ;

BEGIN	
	NEW(win, XNXLBase.W*PX, XNXLBase.H*PX, 'XENOXOLOTL -- Now With OGLWindow!' );
END Open;

BEGIN

END XNXLRender.Open


SystemTools.FreeDownTo  XNXLBase~

