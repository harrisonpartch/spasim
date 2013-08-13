MODULE OGLRender;
IMPORT Kernel, Objects, Random, Marsh, 
 Out := KernelLog, Math,XNXLMath, Base,  Retina, OGLWindow, 
	 GL:=OpenGL, GLC := OpenGLConst,  GLSL:= GLShaderUtils,
	 Inputs,  Raster, Strings,Streams;

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
	aperture.width :=2.3;
	aperture.height :=2.3;
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
	fward.x:=-fward.x;
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
	d:=-Retina.fward.x*0.0001; 	e:=-Retina.fward.y*0.0001;  	f:=-Retina.fward.z*0.0001; 
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


(*! ************* XLTL AMALGAMATION FOLLOWS *)

TYPE GLWindow=OBJECT(OGLWindow.Window)

PROCEDURE &openwincam(w,h: INTEGER);
BEGIN
	Init(w,h, 0,0, FALSE );
	NEW(camera,Base.W, Base.H); 
	camera.aperjust(w, h);
	SetTitle("SPASIM");
	SetGameMode(TRUE);
(*	HideMousePointer();	*)
	SetPrintFPS(TRUE);
END openwincam;

PROCEDURE OnLoad* ;
BEGIN
	IF ~InitGL() THEN Close; RETURN END; 	
	
	Raster.InitMode(copy, Raster.srcCopy);
	Display;	
	Marsh.dawn;
	
	NEW(rand);
	foveasize := 100;
	multicore:=TRUE;
	camrotinertia:=100;
	Base.DTL:=25000;
	Base.DTL2:=25000;
	Base.gravity:=0.0000001;
	Base.speed:=0.000001;
	Base.maxspeed:=0.0001;
	Base.cursordist:=0.01;
	R1:=100;
	R2:=150;
	avtoggle:=TRUE;
	

	mousex:=200;
	mousey:=200;
	centerx:=200;
	centery:=200;
	fogdensity:=0.11;
	leftsticky:=10.0;
	upsticky:=10.0;	
	Out.String('*line 1217!*');
	msd:=40;

	Base.worldalive := TRUE;

END OnLoad;

PROCEDURE Reshape(w, h: LONGINT);
BEGIN	
	GL.Viewport(0, 0, w, h);
	GL.ClearColor(0.0, 0.0, 0.0, 0.0);
	centerx:= w DIV 2; centery:= h DIV 2;
END Reshape;

PROCEDURE Close*;
BEGIN
	Base.worldalive:=FALSE;
	Out.String("Closing.."); Out.Ln;
	Close^;
END Close;
  
PROCEDURE KeyEvent* (ucs : LONGINT; flags : SET; keysym : LONGINT);

VAR
	v: Voxel;   
BEGIN
	CASE CHR(ucs) OF		
		   "s" : camera.backward(0.51)
		| "w" :camera.forward(0.51) 
		| "a" :camera.leftstrafe(0.5)	
		| "d" :camera.rightstrafe(0.5)
		| "e": camera.upstrafe(0.51)
		| "q": camera.downstrafe(0.51)	
		| "n": leftsticky:=leftsticky*1.3; upsticky:=upsticky*1.3;
		| "m": leftsticky:=leftsticky/1.3; upsticky:=upsticky/1.3;
		| "o":
		| "t": camera.glidetoggle 
		| "v":Marsh.engrain
		| "c":Marsh.sprout 
		| "x": Marsh.incVN
		| "z": Marsh.decVN		
		| "p":  camera.stop			
		| "2" : msd:= msd*10/9
		| "3" : 	msd:= msd*9/10
		| "4" : Base.gravity:= 1.5*Base.gravity		
		| "5" : Base.STOPGO	
		| "h" : camera.hop	
		| " " : 	
		| "]": camera.aperture.width := camera.aperture.width * 101/99; camera.aperture.height := camera.aperture.height *101/99
		| "[":  camera.aperture.width := camera.aperture.width * 99/101;  camera.aperture.height := camera.aperture.height *99/101
		| "9": IF Marsh.cursorsize<999999 THEN Marsh.cursorsize:=Marsh.cursorsize * 2; Base.cursordist:=Base.cursordist/2 END
		| "0": IF Marsh.cursorsize>1 THEN Marsh.cursorsize:=Marsh.cursorsize DIV 2; Base.cursordist:=Base.cursordist*2 END
		| "7": Base.cursordist:=Base.cursordist*1.3
		| "8": Base.cursordist:=Base.cursordist/1.3
		| "l": Marsh.lines:=~Marsh.lines
		| "b": Marsh.showcode;  IF CAPTUREMOUSE THEN CAPTUREMOUSE := FALSE; PAUSE:=TRUE END

	ELSE (* use keysm *)
		Out.String("ucs: "); Out.Hex(ucs,4); Out.Ln;
		CASE keysym OF
		| 1BH: IF CAPTUREMOUSE THEN 
							CAPTUREMOUSE := FALSE;
							PAUSE:=TRUE 
						ELSE
							(* alive:=FALSE *)
						END;
						Out.String("KsEscape.."); Out.Ln;
		|	Inputs.KsF1:
				Out.String("F1- Close"); Out.Ln;
				Marsh.engrain;
				Close();	
				
				
	(*	| Inputs.KsF11: ToggleFullWindow;*)
		| Inputs.KsF2: Base.gravity:= -Base.gravity;
		| Inputs.LeftCtrl: AVATAR:=~AVATAR; 	Out.String("LeftCtrl"); Out.Ln;
		| Inputs.RightCtrl: Marsh.SNIPEINTO:=~Marsh.SNIPEINTO;	 Out.String("RightCtrl"); Out.Ln;
		ELSE
			Out.String("keysym: "); Out.Hex(keysym,4); Out.Ln;
		END;
	END
END KeyEvent;

PROCEDURE PointerMove* (x, y : LONGINT; keys : SET);
VAR
	up,left: REAL;
BEGIN
	left:=ABS(x)*x;
	up:=-ABS(y)*y; 
	camera.up(up/(30000*leftsticky)); 
	camera.left(left/(30000*leftsticky));

END PointerMove;
 
PROCEDURE WheelMove*(dz: LONGINT);
BEGIN
	IF dz < 0 THEN slowdown
	ELSE speedup
	END;
END WheelMove;


PROCEDURE  InitGL(): BOOLEAN;
VAR 	vs, fs: Strings.String;
		vertexPosition, vertexUVID: Uint;
		TextureID: Uint;	
		vertices, texcoords: ARRAY [*] OF Float;
		vertexbuffer, uvbuffer: Uint;			
BEGIN		
	GL.ReadImplementationProperties;
	IF ~ (GL.GL_ARB_vertex_shader & GL.GL_ARB_fragment_shader) THEN
	Out.String("GL_ARB_vertex_shader and GL_ARB_fragment_shader are not supported"); 
		Out.Ln; 
		RETURN FALSE;
	END;
	(* GL.Read_GL_ARB_Shader_Objects();*)
	GL.ActiveTexture(GLC.GL_TEXTURE0);		

	NEW(Retina.image);
	Raster.Create(Retina.image,Retina.W,Retina.H,Raster.BGRA8888);

	(* create texture object for image *)
	GL.GenTextures(1, ADDRESSOF(image));
	GL.BindTexture(GLC.GL_TEXTURE_2D, image); 
	(* These determine how interpolation is made when image scaled down on up *)
	GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_NEAREST);
	GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_NEAREST);
	GL.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, Retina.image.width, Retina.image.height, 0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, ADDRESSOF(Retina.image.mem[0]));

	vs := VertexSource();
	fs := FragmentSource();
	IF  ~GLSL.LoadTheseShaders(vs, fs, passthroughProgram) THEN RETURN FALSE END;
	GL.UseProgram(passthroughProgram);
		

	(* Get a handle for our buffers *)
		vertexPosition := GL.GetAttribLocation(passthroughProgram,  "Position");
		vertexUVID := GL.GetAttribLocation(passthroughProgram, "Texcoords");	
		
		(* Get a handle for our "myTextureSampler" uniform *)
		TextureID  := GL.GetUniformLocation(passthroughProgram, "u_image");
		GL.Uniform1i(TextureID, 0); 
		
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

	GLSL.PrintOpenGLError("InitGL: ");
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


PROCEDURE Display();
BEGIN
	camera.tick;
	GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT) ;
	GL.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, Retina.image.width, Retina.image.height,  0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, Retina.image.adr);
	GL.DrawArrays(GLC.GL_TRIANGLES, 0, 2*3);  (* 2*3 indices starting at 0 -> 2 triangles *)	     		
	SwapBuffers();
	
END Display;

(*
PROCEDURE mainloop;
VAR
	ftimer: Kernel.MilliTimer;
	fms,fmsum: LONGINT;
	ft: ARRAY 10 OF LONGINT;
	i,ii: LONGINT;
BEGIN
		MakeCurrent();
		Reshape(width, height);
 		OnLoad;
				
	active:=TRUE;
	
	WHILE active DO
		i:=(i+1)MOD 10;
		Base.rnf:=i/10;
		Kernel.SetTimer(ftimer,1000);
		LoopForEvents;
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
			(* Kernel.Sleep(300) *)
		 END;
	END;
	Out.String("MainLoop exiting.."); Out.Ln;
	CloseWindow();
END mainloop;	
*)

BEGIN
	MainLoop;
END GLWindow;


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
	update: LONGINT;
	MMseen, MRseen: BOOLEAN;	

	

		
	mousex, mousey : LONGINT; (* size of window *)	
	


	CAPTUREMOUSE, GO,TRAIL,AVATAR,SCULL,METASLASH: BOOLEAN;	
	camera:Camera;
	fogdensity:REAL;
	leftsticky,upsticky: REAL;
	centerx,centery: LONGINT;
	MB:INTEGER;
	GLIDE:REAL;
	FR: LONGINT;

	passthroughProgram: GL.Uint;
	copy : Raster.Mode;

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

PROCEDURE Open* ;
VAR w: GLWindow;

BEGIN
	NEW(w, 720,480);
END Open;

BEGIN

END OGLRender.

OGLRender.Open ~ 