MODULE Base;

IMPORT  Math:=Math, Random, Kernel, Out:=KernelLog (*DebugLog*), Objects, XNXL, 
Strings, Streams, WMFontManager, Raster, Graphics := WMGraphics, Commands(*, XNXLAudio*);

CONST
	W*=XNXL.W;
	H*=XNXL.H;
	BPS*=3; 
	NL*=24;
	
TYPE Name*=ARRAY NL OF CHAR;

TYPE Pixel*=Raster.Pixel;

TYPE PT*=RECORD
	x*,y*,z*: REAL
END;

TYPE SPT*=RECORD
	theta*,phi*,len*: REAL
END;

TYPE FRF*=PROCEDURE(p:PT):BOOLEAN;

TYPE IPT*=RECORD
	i*,j*,k*: INTEGER
END;

TYPE BOX*=RECORD
	p*,q*: PT
END;

TYPE Aperture* = RECORD
	width*, height*: REAL
END;

TYPE Color*=RECORD
	red*,green*,blue*,alpha*: REAL
END;

TYPE Colr*=RECORD
	r*,g*,b*: REAL
END;

TYPE NCube*=RECORD
	TF*:BOOLEAN;
	normal*: PT; 
	color*: Color;
	lightcube*:LightCube;
	mirrorTF*: BOOLEAN;
END;

TYPE Time*=RECORD
	seconds*:LONGINT; (*global from server*)
	s2cs*:LONGINT;
	centisecs*:LONGINT
END;

TYPE V*= OBJECT  (*abstract base type for voxel and texture and anything else that may animate *)
PROCEDURE tick*;
END tick;
PROCEDURE register*;
VAR i: INTEGER;
BEGIN
	i := 0;
	WHILE voxelist[i] # NIL DO INC(i) END;
	IF i < 99 THEN voxelist[i] := SELF END;
END register;

END V;

TYPE Texture*=OBJECT(V)
VAR
	img*: Raster.Image;
	imp*:ARRAY 10,10 OF Color;
	fmt: Raster.Format;
	W*,H*, bpr,adr: LONGINT;
	transparent*: BOOLEAN;

PROCEDURE & init*(n: ARRAY OF CHAR);
VAR
	i,j,ix,jy: LONGINT;
BEGIN
	Raster.InitMode(copy,Raster.srcCopy);
	img :=Graphics.LoadImage(n, TRUE); (* img format is BGRA8888 *)
	IF img#NIL THEN 
		W:=img.width-1; H:=img.height-1;
		ix:=W DIV 10;
		jy:=H DIV 10;
		FOR i:=0 TO 9 DO
			FOR j:=0 TO 9 DO
				imp[i,j]:=pixel(rand.Dice(W),rand.Dice(H))
			END
		END
	ELSE
		img := Graphics.LoadImage("grain.png", TRUE); 
		IF img=NIL THEN Out.String("NIL TEXTURE  FAULT") END;
		ASSERT(img#NIL);
		W:=img.width-1; H:=img.height-1;
	END;
END init;

PROCEDURE pixel*(x,y:REAL):Color;
VAR
	i,j: LONGINT;
	p: Raster.Pixel;
	c: Color;
BEGIN
	IF img#NIL THEN
		i:=ENTIER(x*W) MOD W; j:=ENTIER(y*H) MOD H;	
		Raster.Get(img,i,j,p,copy);
		c.red := ORD(p[2])/255; c.green := ORD(p[1])/255; c.blue := ORD(p[0])/255; c.alpha:= ORD(p[3])/255;	
	ELSE
		c.red:=1; c.blue:=1;
	END;
	RETURN c
END pixel;

PROCEDURE pixelT*(x,y:REAL; T: LONGINT):Color;
VAR
	i,j: LONGINT;
	p: Raster.Pixel;
	c: Color;
BEGIN
	IF T<1 THEN T:=1 END;
	IF img#NIL THEN
		i:=ENTIER(x*W) MOD W; j:=ENTIER(y*H) MOD H;	
		i:=T*(i DIV T); j:=T*(j DIV T); 
		Raster.Get(img,i,j,p,copy);
		c.red := ORD(p[2])/255; c.green := ORD(p[1])/255; c.blue := ORD(p[0])/255; c.alpha:= ORD(p[3])/255;	
	ELSE
		c.red:=1; c.blue:=1;
	END;
	RETURN c
END pixelT;

	
END Texture;

TYPE TexCube*=OBJECT(V)
VAR
	side*:ARRAY 6 OF Texture;
PROCEDURE & init*(CONST name: ARRAY OF CHAR; six:BOOLEAN);
VAR
	nstring: Strings.String;
BEGIN
	IF six THEN
		nstring:=Strings.ConcatToNew(name,".0.png");
		NEW(side[0],nstring^);
		nstring:=Strings.ConcatToNew(name,".1.png");
		NEW(side[1],nstring^);	
		nstring:=Strings.ConcatToNew(name,".2.png");
		NEW(side[2],nstring^);		
		nstring:=Strings.ConcatToNew(name,".3.png");
		NEW(side[3],nstring^);
		nstring:=Strings.ConcatToNew(name,".4.png");
		NEW(side[4],nstring^);	
		nstring:=Strings.ConcatToNew(name,".5.png");
		NEW(side[5],nstring^);	
	ELSE
		NEW(side[0],name);
		NEW(side[1],name);	
		NEW(side[2],name);		
		NEW(side[3],name);
		NEW(side[4],name);	
		NEW(side[5],name);			
	END
END init;	
END TexCube;

TYPE BPE*=RECORD
	red*,green*,blue*: REAL
END;

TYPE BPATCH*=ARRAY BPS,BPS OF BPE;

TYPE Ray* = RECORD
	xyz*, dxyz*, ddxyz*, lxyz*, txyz*, origin*, oxyz*, popdelta*, hitxyz*, hitdxyz*: PT;	
	theta*,phi*, dtheta*,dphi*: REAL;
	cellred*,cellgreen*,cellblue*,cellblack*: REAL;
	texcube*:TexCube;
	texcubeTF*:BOOLEAN;
	r*, g*, b*, ra*, ga*, ba*, bla*,ulfire*: REAL; (* ulfire is an invisible color *)
	rgb*: ARRAY 3,3 OF BPE;
	terminate*: BOOLEAN;
	scale*,tscale*: REAL;
	length*: REAL; 
	len*:PT;
	dxdi*,dydi*,dzdi*,dxdj*,dydj*,dzdj*: REAL;
	di*,dj*,dk*: BOOLEAN;
	changed*: BOOLEAN; 
	face*: INTEGER;
	mirrortf*:BOOLEAN;	
	normal*,fnormal*: PT;  
	normalTF*: BOOLEAN;
	corner*:PT;
	dtl*: REAL;	
	dtlTF*:BOOLEAN;
	hitmirrorTF*:BOOLEAN;
	justhitTF*:BOOLEAN;
	diositizeTF*:BOOLEAN;
	texdtl*:REAL;
END; 

TYPE RAYS*= POINTER TO ARRAY W, H OF Ray;
TYPE DTLRAYS*= POINTER TO ARRAY 3*W, 3*H OF Ray;

TYPE Voxel*=OBJECT(V)
VAR
	complex*, passable*: BOOLEAN;
	imposter*: Voxel;
	lockTF*,copymarker*,emptysplit*: BOOLEAN;
	DTL*: REAL;
	code*,ncode*:Name;  
	tscale*: PT;
	red*,green*,blue*,black*,alpha*: REAL;
	colored*,frozen*,probelock*,copyonstroke*:BOOLEAN;
	offset*:PT;
	lightcube*:LightCube;
PROCEDURE Shade*(VAR ray: Ray);
END Shade;
PROCEDURE proberay*(VAR ray: Ray):Voxel;
VAR v:Voxel;
BEGIN
	NEW(v);
	RETURN(v)
END proberay;
PROCEDURE probe*(p:PT; resolution: LONGINT):Voxel;
BEGIN
	RETURN(SELF);
END probe;
PROCEDURE passprobe*(p:PT):BOOLEAN;
BEGIN
	RETURN(passable);
END passprobe;
PROCEDURE setcolor* (r,g,b,bl,a: REAL); 
END setcolor;
PROCEDURE setcolorrec*(r,g,b,bl,a: REAL); 
END setcolorrec;
PROCEDURE erase*(p:PT; resolution:LONGINT);
END erase;
PROCEDURE deepcopy*():Voxel;
BEGIN
	RETURN(SELF)
END deepcopy;
PROCEDURE copyclear*;
END copyclear;
PROCEDURE fill*(v: Voxel);
END fill;
PROCEDURE line*(a,b: PT; level: LONGINT; v: Voxel);
END line;
PROCEDURE proberec*(p:PT; resolution,scale:LONGINT):Voxel;
END proberec;
PROCEDURE FRaster*( f: FR; resolution: LONGINT); 
END FRaster;
PROCEDURE FRasterrec*(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT); 
END FRasterrec;
PROCEDURE FRasterSolid*( f: FR; resolution: LONGINT); 
END FRasterSolid;
PROCEDURE FRasterrecSolid*(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT); 
END FRasterrecSolid;

PROCEDURE stroke*(p:PT; resolution: LONGINT; voxel,voxundo:Voxel);
END stroke;
PROCEDURE strokerec*(p:PT; resolution,scale: LONGINT; voxel,voxundo:Voxel);
END strokerec;
PROCEDURE nstroke*(p:PT; resolution: LONGINT; normal: PT; color: Color);
END nstroke;
PROCEDURE nstrokerec*(p:PT; resolution,scale: LONGINT; normal: PT; color: Color);
END nstrokerec;
PROCEDURE mstroke*(a,b,c: LONGINT; resolution: LONGINT; vname: Name);
BEGIN
END mstroke;

PROCEDURE lock*;
BEGIN
	lockTF:=TRUE
END lock;
PROCEDURE unlock*;
BEGIN
	lockTF:=FALSE
END unlock;
PROCEDURE copy*():Voxel;
BEGIN
	RETURN(SELF)
END copy;

PROCEDURE engrain*(w: Streams.Writer);
BEGIN
	w.Bytes(code,0,NL);	 
END engrain;

PROCEDURE sprout*(r: Streams.Reader);
BEGIN
END sprout;

PROCEDURE showcode*;
VAR
	VAR res : LONGINT; 
	command: Strings.String;
	msg : ARRAY 128 OF CHAR;
BEGIN
	NEW(command,80);
	Strings.Concat("NanonyPET.Open ",code,command^);
	Strings.Concat(command^,".Mod",command^);
	Commands.Call(command^, {Commands.Wait}, res, msg); (* ignore res *)
END showcode;

PROCEDURE play*();
BEGIN
(*	XNXLAudio.LoadWav("grain.wav");
	XNXLAudio.Play *)
END play;

PROCEDURE touch*;
END touch; 

END Voxel; 

TYPE VoxelStack*=OBJECT

TYPE Transform=RECORD
	scale,x,y,z: REAL
END;

VAR
	top: Voxel;
	prev: VoxelStack;
	trans: Transform;  (* transform going OUT to prev *) 

PROCEDURE push*(v: Voxel):VoxelStack;
VAR
	vs: VoxelStack;
BEGIN
	NEW(vs);
	vs.top:=v;
	vs.prev:=SELF;
	RETURN(vs);
END push;

END VoxelStack;

TYPE VoxelFackery = PROCEDURE ( ): Voxel;

(*TYPE VoxelList*=OBJECT;
VAR
	voxel:Voxel;
	next,previous: VoxelList;
PROCEDURE push*(v: Voxel);
BEGIN
	NEW(next);
	next.voxel:=v;
END push;
END VoxelList;
*)

TYPE Light*=RECORD
	red*,green*,blue*: REAL
END;

TYPE LightCube*=RECORD
	light*:ARRAY[6] OF Light
END;

TYPE FR*=OBJECT
VAR
	bbc1*,bbc2*,norml*: PT;		(*any two diagonally opposite corners of the bounding box of the object *)
	scale*: REAL; 	(*might be needed as this object is handed down to mcell levels in v-rasterization*)
	vox*,imposter*: Voxel;
	mir*: REAL;
	cxolor*:Color;
	allowdeath*,passable*:BOOLEAN;
	
PROCEDURE in*(p:PT):BOOLEAN;
BEGIN
	RETURN FALSE
END in;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
BEGIN
	norml:=p;
	RETURN 0
END d2s;

PROCEDURE closestPT*(p:PT):PT;  
VAR
	cp: PT;
BEGIN
	RETURN cp
END closestPT;

PROCEDURE normaltf*(p:PT):BOOLEAN;
BEGIN
	RETURN FALSE
END normaltf;

PROCEDURE normal*(p:PT):PT;
BEGIN
	normalizePT(norml);		(* norml is often calculated in d2s but not normalized there *)
	RETURN norml					(* this is the normal for the most recent point handed to d2s *)
END normal;

PROCEDURE setvoxel*(v:Voxel);  
BEGIN
	vox:=v;
	imposter:=v
END setvoxel;

PROCEDURE setcolor*(r,g,b: REAL);  
BEGIN
	cxolor.red:=r; cxolor.green:=g; cxolor.blue:=b; 
END setcolor;

PROCEDURE getcolor*(p:PT):Color;
BEGIN
	RETURN cxolor
END getcolor;

PROCEDURE setimposter*(v:Voxel);  
BEGIN
	imposter:=v
END setimposter;

PROCEDURE getimposter*(p:PT):Voxel;
BEGIN
	RETURN imposter
END getimposter;

PROCEDURE mirror*(p:PT):REAL;
BEGIN
	RETURN mir
END mirror;

PROCEDURE voxel*(p:PT):Voxel;
BEGIN
	RETURN vox
END voxel;

PROCEDURE color*(p:PT):Color;
BEGIN	
	RETURN cxolor		
END color;

PROCEDURE death*(p:PT):BOOLEAN;
BEGIN
	RETURN allowdeath
END death;

PROCEDURE pass*(p:PT):BOOLEAN;
BEGIN
	RETURN passable
END pass;

END FR;

TYPE P=PROCEDURE (v:Voxel):Voxel;

VAR
	voxelist: ARRAY 100 OF V;
(*	clock*: Clock;*)
	fog*:REAL;
	rlimit*: INTEGER;
	iterlimit*: LONGINT;
	speed*,maxspeed*:REAL;
	frame*: LONGINT;
	rand*:Random.Sequence;
	worldalive*: BOOLEAN;
	gravity*:REAL;
	fuzzon*, STOP*: BOOLEAN;
	singleray*: Ray;	(* for when a single ray is most convenient *)
	blankray*: Ray;
	Face*: ARRAY 6 OF PT;
	EMPTY*,OPAQUE*: Voxel;
	deathflag*:BOOLEAN;
	rays*,frays*:RAYS;
	dtlrays*:DTLRAYS;
	LOOK*, LLOOK*: Ray;
	world*:Voxel;
	injection*: Voxel;
	cameraPT*,cursorPT*,avatarPT*,previouscursorPT*,previouscameraPT*,previousavatarPT*,Origin*: PT;
	dward*,fward*,rward*:PT;
	rezvox*, cursorvox*:Voxel;
	aperture*: Aperture;
	m2sdelta*,m3sdelta*:REAL;
	DTL*,DTL2*: REAL;
	frameblack*:REAL;
	avatar*:Voxel;
	avatarsize*: INTEGER;
	cursordist*:REAL;
	RVR*:BOOLEAN;
	vlist*: ARRAY 100 OF Voxel;
	copy*: Raster.Mode;
	skydistance*:REAL;
	rnf*:REAL; (*random number for frame*);
	fulllight: Light;
	fulllightcube*,nolightcube*: LightCube;
	
PROCEDURE VoxelFromName*(modname: Name): Voxel;
	VAR voxel: Voxel;  fackery: VoxelFackery;
	BEGIN
		Out.String(".... ");	 
		IF modname[0]='N' THEN
			GETPROCEDURE(modname, "thisvox", fackery );
			IF (fackery # NIL) THEN  
				voxel := fackery();		 
			END		 
		END;
		IF voxel=NIL THEN 
			Out.String("failed");
			Out.String("rezzing ");
			Out.String(modname); 
			Out.String(".Mod");
			Out.Ln;  
			voxel:=EMPTY
		ELSE
			voxel.code:=modname;
		 END;
		RETURN voxel; (* this may return EMPTY which is what we want *)
END VoxelFromName;

PROCEDURE radiositize*(l:LightCube; p:PT; face:INTEGER);
VAR
	i: INTEGER;
	ray: Ray;
BEGIN
	l.light[face].red:=0;
	l.light[face].green:=0;
	l.light[face].blue:=0;
	FOR i:=0 TO 10 DO
		ray:=blankray;
		ray.xyz:=p;
		ray.dxyz:=randnormPT();
		IF dot(ray.xyz,Face[face])>1 THEN	
			world.Shade(ray);
			l.light[face].red:=l.light[face].red+ray.r/11;
			l.light[face].green:=l.light[face].green+ray.g/11;
			l.light[face].blue:=l.light[face].blue+ray.b/11
		END
	END;
	l.light[face].red:=rand.Uniform();
	l.light[face].green:=rand.Uniform();
	l.light[face].blue:=rand.Uniform();	
END radiositize;

PROCEDURE updatecamera*(x,y,z,a,b,c,d,e,f:  REAL);
BEGIN
	previouscursorPT:=cursorPT;
	previouscameraPT:=cameraPT;
	cameraPT.x:=x; cameraPT.y:=y; cameraPT.z:=z;
	cursorPT.x:=x+a; cursorPT.y:=y+b; cursorPT.z:=z+c; 
	avatarPT.x:=x+d; avatarPT.y:=y+e; avatarPT.z:=z+f; 
END updatecamera;
	
PROCEDURE clearvoxelist*;
VAR i: INTEGER;
BEGIN
	FOR i:=0 TO 99 DO voxelist[i]:=NIL END 
END clearvoxelist;

PROCEDURE clamp*(VAR x: REAL);
BEGIN
	IF x < 0 THEN x := 0 ELSIF x>1 THEN x := 0.9999999 END;
END clamp;

PROCEDURE clamp3*(VAR r,g,b: REAL);
BEGIN
	IF r < 0 THEN r := 0 ELSIF r>1 THEN r := 0.9999999 END;
	IF g < 0 THEN g := 0 ELSIF g>1 THEN g := 0.9999999 END;
	IF b < 0 THEN b := 0 ELSIF b>1 THEN b := 0.9999999 END;
END clamp3;

PROCEDURE clamPT*(VAR a: PT);
BEGIN
	IF a.x < 0 THEN a.x := 0 ELSIF a.x>=1 THEN a.x := 0.9999999 END;
	IF a.y < 0 THEN a.y := 0 ELSIF a.y>=1 THEN a.y := 0.9999999 END;
	IF a.z < 0 THEN a.z := 0 ELSIF a.z>=1 THEN a.z := 0.9999999 END;
END clamPT;

PROCEDURE inzerodotdotonePT*(a: PT):BOOLEAN;
BEGIN
	IF a.x < 0 THEN  RETURN FALSE END;	
	IF a.x >1  THEN  RETURN FALSE END;
	IF a.y < 0 THEN  RETURN FALSE END;	
	IF a.y >1  THEN  RETURN FALSE END;
	IF a.z < 0 THEN  RETURN FALSE END;	
	IF a.z >1  THEN  RETURN FALSE END;	
	RETURN TRUE;
END inzerodotdotonePT;

PROCEDURE addPT*(p,q: PT):PT;
VAR
	r: PT;
BEGIN
	r.x:=p.x+q.x; r.y:=p.y+q.y; r.z:=p.z+q.z;
	RETURN(r);
END addPT;

PROCEDURE subPT*(p,q: PT):PT;
VAR
	r: PT;
BEGIN
	r.x:=p.x-q.x; r.y:=p.y-q.y; r.z:=p.z-q.z;
	RETURN(r);
END subPT;

PROCEDURE mulPT*(p: PT; d: REAL):PT;
VAR
	r: PT;
BEGIN
	r.x:=p.x*d; r.y:=p.y*d; r.z:=p.z*d;
	RETURN(r);
END mulPT;

PROCEDURE divPT*(p: PT; d: REAL):PT;
VAR
	r: PT;
BEGIN
	r.x:=p.x/d; r.y:=p.y/d; r.z:=p.z/d;
	RETURN(r);
END divPT;

PROCEDURE clampColor*(VAR a: Color);
BEGIN
	IF a.red < 0 THEN a.red := 0 ELSIF a.red>=1 THEN a.red := 0.9999999 END;
	IF a.green < 0 THEN a.green := 0 ELSIF a.green >=1 THEN a.green := 0.9999999 END;
	IF a.blue < 0 THEN a.blue := 0 ELSIF a.blue>=1 THEN a.blue := 0.9999999 END;
END clampColor;

PROCEDURE mkcolor*(r,g,b: REAL): Color;
VAR
	c:Color;
BEGIN
	c.red:=r; c.green:=g; c.blue:=b;
	RETURN(c);
END mkcolor;

PROCEDURE mkPT*(x,y,z: REAL): PT;
VAR
	p:PT;
BEGIN
	p.x:=x; p.y:=y; p.z:=z;
	RETURN(p);
END mkPT;

PROCEDURE fuzz3*(VAR x,y,z: REAL; fuzz: REAL);
VAR
	q: REAL;
BEGIN
	q := rand.Uniform()*fuzz - fuzz/2;
	x := x+q; y := y + q; z :=z + q;
	clamp3(x,y,z);
END fuzz3;

PROCEDURE fuzz3noclamp*(VAR x,y,z: REAL; fuzz: REAL);
VAR
	q: REAL;
BEGIN
	q := rand.Uniform()*fuzz - fuzz;
	x := x+q; y := y + q; z :=z + q;
END fuzz3noclamp;

PROCEDURE fuzznorm3*(VAR x,y,z: REAL; fuzz: REAL);
VAR
	q: REAL;
BEGIN
	q := rand.Uniform()*fuzz - fuzz;
	x := x+q; y := y + q; z :=z + q;
	normalize(x,y,z);
END fuzznorm3;

PROCEDURE fzz3*(VAR x,y,z: REAL; fuzz: REAL);
VAR
	q: REAL;
BEGIN
	q := rand.Uniform()*fuzz - fuzz;
	x := x+q; y := y + q; z :=z + q;
END fzz3;

PROCEDURE tick*;
VAR i: INTEGER;
BEGIN
	IF ~STOP THEN
		i := 0;
		WHILE i < 20 DO
			IF voxelist[i] # NIL THEN voxelist[i].tick END;
			INC(i);
		END;
		INC(frame);    
	END
END tick; 

(*PROCEDURE sniprobe;
VAR
	v:Voxel;
	ray: Ray;
	x,y: LONGINT;
BEGIN
	x:=W DIV 2;
	y:=H DIV 2;
	ray:=XNXLBase.rays[x,y];
	v:=world.proberay(ray); 
(*	XNXLBase.cursordist:=2*ray.length/3; *)
END sniprobe;
*)
PROCEDURE cleartick*;
VAR i: INTEGER;
BEGIN
	i:=0;
	WHILE voxelist[i]#NIL DO
		voxelist[i]:=NIL;
		INC(i)
	END
END cleartick; 

PROCEDURE RESET*;
BEGIN
  frame:=0;
END RESET;

PROCEDURE STOPGO*;
BEGIN
 	STOP := ~STOP;
END STOPGO;

PROCEDURE normalize*(VAR x,y,z: REAL);
VAR
	d: REAL;
BEGIN
	d := Math.sqrt(x*x + y*y+z*z);
	IF d = 0 THEN 
		x := 1;
		d := 1;
	END;
	x := x/d; y := y/d; z:= z/d
END normalize;	

PROCEDURE printPT*(p:PT);
BEGIN
(* Where is AosOut.Real()? *)
(*	Out.Real(p.x, 10);
	Out.Real(p.y, 10);
	Out.Real(p.z, 10);
	Out.Ln; *)
END printPT;

PROCEDURE normalizePT*(VAR n:PT);
VAR
	d: REAL;
BEGIN
	d := Math.sqrt(n.x*n.x + n.y*n.y +n.z*n.z);
	IF d = 0 THEN 
		n.x := 1;
		d := 1;
	END;
	n.x := n.x/d; n.y := n.y/d; n.z:=n.z/d
END normalizePT;	

PROCEDURE normalizePTd*(VAR n:PT; VAR d:REAL);
BEGIN
	d := Math.sqrt(n.x*n.x + n.y*n.y +n.z*n.z);
	IF d = 0 THEN 
		n.x := 1;
		d := 1;
	END;
	n.x := n.x/d; n.y := n.y/d; n.z:=n.z/d
END normalizePTd;	

PROCEDURE distance*(a,b: PT):REAL;
VAR
	x,y,z,d: REAL;
BEGIN
	x := b.x-a.x;
	y := b.y-a.y;
	z := b.z-a.z;	
	RETURN(Math.sqrt(x*x+y*y+z*z)); 
END distance;

PROCEDURE string*(CONST s: ARRAY OF CHAR);
BEGIN
	Out.String(s); Out.Ln;
END string;

PROCEDURE setPT*(VAR p:PT; x,y,z: REAL);
BEGIN
	p.x := x; 
	p.y := y;
	p.z := z;
END setPT;

PROCEDURE setnormPT*(VAR p:PT; x,y,z: REAL);
BEGIN
	p.x := x; 
	p.y := y;
	p.z := z;
	normalizePT(p);
END setnormPT;

PROCEDURE setColor*(VAR p:Color; r,g,b: REAL);
BEGIN
	p.red := r; 
	p.green := g;
	p.blue := b;
END setColor;

PROCEDURE randPT*():PT;
VAR
	p:PT;
BEGIN
	p.x := rand.Uniform();	
	p.y := rand.Uniform();	
	p.z := rand.Uniform();	
	RETURN p
END randPT;

PROCEDURE randColor*():Color;
VAR
	c:Color;
BEGIN
	c.red:= rand.Uniform();	
	c.green:= rand.Uniform();	
	c.blue := rand.Uniform();	
	RETURN c
END randColor;

PROCEDURE randnormPT*():PT;
VAR
	p:PT;
BEGIN
	p.x := (rand.Uniform()*2)-1;	
	p.y := (rand.Uniform()*2)-1;	
	p.z := (rand.Uniform()*2)-1;	
	normalizePT(p);
	RETURN(p)
END randnormPT;

PROCEDURE randsphPT*(VAR p,n,center:PT; radius: REAL);
(*random point and surface normal on sphere *)
BEGIN
	p.x := (rand.Uniform()*2)-1;	
	p.y := (rand.Uniform()*2)-1;	
	p.z := (rand.Uniform()*2)-1;	
	normalizePT(p);
	n:=p;
	p.x:= center.x+(p.x*radius);
	p.y:= center.y+(p.y*radius);
	p.z:= center.z+(p.z*radius);	
END randsphPT;

PROCEDURE dot*(a,b:PT):REAL;
BEGIN
	normalizePT(a);
	normalizePT(b);
	RETURN(ABS(a.x*b.x+a.y*b.y+a.z+b.z));
END dot;

PROCEDURE dixt*(a,b:PT):REAL;
VAR
	dx,dy,dz,x:REAL;
BEGIN
	dx := a.x-b.x;
	dy := a.y-b.y;
	dz := a.z-b.z;
	IF dx>dy THEN
		x:=dx
	ELSE
		x:=dy
	END;
	IF dz>x THEN
		x:=dz
	END;
	RETURN(x);
END dixt;

PROCEDURE setAxes*(a,b:PT);
VAR
	x:REAL;
	p:PT;
BEGIN
	p.x := a.x-b.x;
	p.y := a.y-b.y;
	p.z := a.z-b.z;
	IF ABS(p.x)>ABS(p.y) THEN
		p.y:=0;
		x:=p.x
	ELSE
		p.x:=0;
		x:=p.y
	END;
	IF ABS(p.z)>ABS(x) THEN
		p.x:=0;
		p.y:=0
	ELSE
		p.z:=0
	END;
	IF p.x#0 THEN
		IF p.x<0 THEN
			setPT(dward,-1,0,0);
			setPT(fward,0,-1,0);
			setPT(rward,0,0,-1)
		ELSE
			setPT(dward,1,0,0);
			setPT(fward,0,1,0);
			setPT(rward,0,0,1)
		END
	ELSIF p.y#0 THEN
		IF p.y<0 THEN
			setPT(dward,0,1,0);
			setPT(fward,1,0,0);
			setPT(rward,0,0,1)
		ELSE
			setPT(dward,0,1,0);
			setPT(fward,1,0,0);
			setPT(rward,0,0,1)
		END;
	ELSE
		IF p.z<0 THEN
			setPT(dward,0,0,1);
			setPT(fward,0,1,0);
			setPT(rward,1,0,0)
		ELSE
			setPT(dward,0,0,1);
			setPT(fward,0,1,0);
			setPT(rward,1,0,0)
		END	
	END
END setAxes;

PROCEDURE dist*(a,b:PT):REAL;
VAR
	dx,dy,dz:REAL;
BEGIN
	dx := a.x-b.x;
	dy := a.y-b.y;
	dz := a.z-b.z;
	RETURN(Math.sqrt(dx*dx+dy*dy+dz*dz));
END dist;

PROCEDURE distsquared*(a,b:PT):REAL;
VAR
	dx,dy,dz:REAL;
BEGIN
	dx := a.x-b.x;
	dy := a.y-b.y;
	dz := a.z-b.z;
	RETURN(dx*dx+dy*dy+dz*dz);
END distsquared;

PROCEDURE midPT*(a,b:PT):PT;
VAR
	m:PT;
BEGIN
	m.x:=(a.x+b.x)/2;
	m.y:=(a.y+b.y)/2;
	m.z:=(a.z+b.z)/2;
	RETURN(m)
END midPT;

PROCEDURE Exit*(ray: Ray):PT;
VAR
	drx, dry, drz: REAL;
	exit:PT;
BEGIN
	clamPT(ray.lxyz);
	IF ray.dxyz.x>0 THEN
		drx:= (1-ray.lxyz.x)/ ray.dxyz.x
	ELSE
		drx :=  (-ray.lxyz.x) / ray.dxyz.x
	END;
	IF ray.dxyz.y > 0 THEN
		dry := (1 - ray.lxyz.y) / ray.dxyz.y
	ELSE
		dry :=  (-ray.lxyz.y) / ray.dxyz.y
	END;
	IF ray.dxyz.z > 0 THEN
		drz := (1-ray.lxyz.z) / ray.dxyz.z
	ELSE
		drz :=  (-ray.lxyz.z) / ray.dxyz.z
	END;
	IF (drx < dry) THEN
		IF (drx < drz ) THEN
			IF ray.dxyz.x>0 THEN
				exit.x:=1; exit.y:=ray.lxyz.y+drx*ray.dxyz.y; exit.z:=ray.lxyz.z+ drx*ray.dxyz.z;
			ELSE
				exit.x:=0; exit.y:=ray.lxyz.y+drx*ray.dxyz.y; exit.z:=ray.lxyz.z+ drx*ray.dxyz.z;
			END;	
		ELSE
			IF ray.dxyz.z>0 THEN
				exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=1;
			ELSE
				exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=0;
			END;		
		END;
	ELSIF (dry < drz) THEN
		IF ray.dxyz.y>0 THEN
			exit.x:=ray.lxyz.x+dry*ray.dxyz.x; exit.y:=1; exit.z:=ray.lxyz.z+dry*ray.dxyz.z;
		ELSE
			exit.x:=ray.lxyz.x+dry*ray.dxyz.x; exit.y:=0; exit.z:=ray.lxyz.z+dry*ray.dxyz.z;
		END;
	ELSE
		IF ray.dxyz.z>0 THEN
			exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=1;
		ELSE
			exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=0;
		END;		
	END;
	RETURN(exit);
END Exit;

(* object is fine except it messes up PET's program structure parser no matter where it is placed
TYPE Clock*=OBJECT
VAR
	timer: Kernel.Timer;
	time*:Time;
	i: INTEGER
PROCEDURE&init;
BEGIN
	sync;
	time.seconds:=0;
	time.centisecs:=0
END init;

PROCEDURE sync;
BEGIN
	(* get time from server *)
END sync;

BEGIN{ACTIVE, PRIORITY(Objects.Normal)}         (*this will drift! must add server synch with each server message *)
	NEW(timer);
	REPEAT
		FOR i:=0 TO 100 DO
			INC(time.centisecs);
			timer.Sleep(10)	
		END;
		INC(time.seconds);
		timer.Sleep(10)
	UNTIL FALSE
END Clock;
*)

BEGIN
	Out.String("Base loading...");
	WMFontManager.Install;
	NEW(rand);
(*	XNXLAudio.OpenDevice;
	NEW(clock); *)
	fward:=mkPT(1,0,0);
	rward:=mkPT(0,1,0);
	dward:=mkPT(0,0,-1);
	NEW(rays);
	NEW(frays);
	NEW(dtlrays);
	NEW(EMPTY);
	NEW(OPAQUE);
	EMPTY.passable:=TRUE;
	NEW(world);
	worldalive := TRUE;
	frame:=0;
	fog := 1/10;
	rlimit := 4;
	iterlimit := 500;
	DTL:=25;	
	STOP:=TRUE;
	Origin:=mkPT(0,0,0);   (* unneeded initialization *)
	blankray.bla := 1;
	blankray.ra := 1;
	blankray.ga := 1;
	blankray.ba := 1;
	blankray.scale := 1; 
	blankray.length := 0;
	blankray.tscale:=1;
	blankray.dtl:=2;	
	Face[0].x := 1; Face[0].y := 0; Face[0].z := 0; 
	Face[3].x := -1; Face[3].y := 0; Face[3].z := 0; 
	Face[1].x := 0; Face[1].y := 1; Face[1].z := 0; 
	Face[4].x := 0; Face[4].y := -1; Face[4].z := 0; 
	Face[2].x := 0; Face[2].y := 0; Face[2].z := 1; 
	Face[5].x := 0; Face[5].y := 0; Face[5].z := -1; 	
	m2sdelta:=25;
	m3sdelta:=25;
	speed:=0.00051;
	skydistance:=1.0;
	fulllight.red:=1; fulllight.green:=1;fulllight.blue:=1;
	fulllightcube.light[0]:=fulllight;	
	fulllightcube.light[1]:=fulllight;
	fulllightcube.light[2]:=fulllight;
	fulllightcube.light[3]:=fulllight;
	fulllightcube.light[4]:=fulllight;
	fulllightcube.light[5]:=fulllight;	
	Out.String("loaded.");
	Out.Ln;
END Base.