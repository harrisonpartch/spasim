MODULE Base;

IMPORT  Math:=MathL, Random,  Out:=KernelLog, (*AL:=OpenAL, ALUT := OpenALUtil,  *)
Strings, Streams, CryptoMD5, WMFontManager, Raster, WMRasterScale, WMRectangles, Graphics := WMGraphics, Commands(*, XNXLAudio*);

CONST
	NL*=24;
	MIP0=8;
	MIP1=32;
	MIP2=128;

TYPE Name*=ARRAY 32 OF CHAR;

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
	width*, height*: REAL  (* these are ANGLES *)
END;

TYPE Color*=RECORD
	red*,green*,blue*,alpha*,mirror*: REAL
END;

TYPE ray_color*=RECORD
	r*,g*,b*,ra*,ga*,ba*,alpha*: REAL
END;

TYPE Colr*=RECORD
	r*,g*,b*: REAL
END;

TYPE NCube*=RECORD
	TF*:BOOLEAN;
	point*,normal*: PT; 
	color*: Color;
	mirrorTF*:BOOLEAN;
END;

TYPE RCube*=RECORD
	TF*:BOOLEAN;
	point*,normal*: PT; 
	color*: Color;
	mirrorTF*:BOOLEAN;
END;

TYPE Time*=RECORD
	seconds*:SIZE; (*global from server*)
	s2cs*:SIZE;
	centisecs*:SIZE
END;

TYPE V*= OBJECT  (*abstract base type for voxel and texture and anything else that may animate *)
PROCEDURE tick*;
END tick;

PROCEDURE register*;
VAR i: INTEGER;
BEGIN
	i := 0;
	Out.Char('*');
	WHILE voxelist[i] # NIL DO INC(i) END;
	IF i < 99 THEN voxelist[i] := SELF END;
END register;

END V;

TYPE Texture*=OBJECT(V)
VAR
	img*,mip_zero,mip_one,mip_two: Raster.Image;
	W*,H*: SIZE;
	transparent*: BOOLEAN;
	copy: Raster.Mode;

PROCEDURE & init*(CONST n: ARRAY OF CHAR);
VAR
	i,j,ix,jy: INTEGER;
BEGIN
	Raster.InitMode(copy,Raster.srcCopy);
	img :=Graphics.LoadImage(n, FALSE); (* img format is BGRA8888 *)
	IF img=NIL THEN 
		img := defaultimg;
	END;
	W:=img.width;
	H:=img.height;
	NEW(mip_zero);
	NEW(mip_one);	
	NEW(mip_two);
	Raster.Create(mip_zero,MIP0,MIP0,Raster.BGRA8888);
	Raster.Create(mip_one,MIP1,MIP1,Raster.BGRA8888);		
	Raster.Create(mip_two,MIP2,MIP2,Raster.BGRA8888);		
	WMRasterScale.Scale(img,WMRectangles.MakeRect(0,0, img.width, img.height), mip_zero,
			WMRectangles.MakeRect(0,0, mip_zero.width, mip_zero.height),
				WMRectangles.MakeRect(0,0,mip_zero.width, mip_zero.height),
					WMRasterScale.ModeCopy,
						WMRasterScale.ScaleBox);
	WMRasterScale.Scale(img,WMRectangles.MakeRect(0,0, img.width, img.height), mip_one,
			WMRectangles.MakeRect(0,0, mip_one.width, mip_one.height), 
				WMRectangles.MakeRect(0,0, mip_one.width, mip_one.height),
					WMRasterScale.ModeSrcOverDst,
						WMRasterScale.ScaleBilinear);	
	WMRasterScale.Scale(img,WMRectangles.MakeRect(0,0, img.width, img.height), mip_two,
				WMRectangles.MakeRect(0,0, mip_two.width, mip_two.height),
					WMRectangles.MakeRect(0,0, mip_two.width, mip_two.height),
						WMRasterScale.ModeSrcOverDst,
							WMRasterScale.ScaleBilinear);	
END init;

PROCEDURE pixelmip_zero*(x,y:REAL):Color;
VAR
	i,j: INTEGER;
	p: Raster.Pixel;
	c: Color;
BEGIN
	i:= ENTIER(x*MIP0) MOD MIP0;
	j:=ENTIER(y*MIP0) MOD MIP0;
	Raster.Get(mip_zero,i,j,p,copy);
	c.red := ORD(p[2])/255; c.green := ORD(p[1])/255; c.blue := ORD(p[0])/255; c.alpha:= ORD(p[3])/255;	
	RETURN c
END pixelmip_zero;


PROCEDURE pixelmip_one*(x,y:REAL):Color;
VAR
	i,j: INTEGER;
	p: Raster.Pixel;
	c: Color;
BEGIN
	i:= ENTIER(x*MIP1) MOD MIP1;
	j:=ENTIER(y*MIP1) MOD MIP1;
	Raster.Get(mip_one,i,j,p,copy); 
	c.red := ORD(p[2])/255; c.green := ORD(p[1])/255; c.blue := ORD(p[0])/255; c.alpha:= ORD(p[3])/255;	
	RETURN c
END pixelmip_one;

PROCEDURE pixelmip_two*(x,y:REAL):Color;
VAR
	i,j: INTEGER;
	p: Raster.Pixel;
	c: Color;
BEGIN
	i:= ENTIER(x*MIP2) MOD MIP2;
	j:=ENTIER(y*MIP2) MOD MIP2;
	Raster.Get(mip_two,i,j,p,copy); 
	c.red := ORD(p[2])/255; c.green := ORD(p[1])/255; c.blue := ORD(p[0])/255; c.alpha:= ORD(p[3])/255;	
	RETURN c
END pixelmip_two;

PROCEDURE pixel*(x,y:REAL):Color;
VAR
	i,j: SIZE;
	p: Raster.Pixel;
	c: Color;
BEGIN
	i:= ENTIER(x*W) MOD W;
	j:=ENTIER(y*H) MOD H;
	Raster.Get(img,i,j,p,copy); 
	c.red := ORD(p[2])/255; c.green := ORD(p[1])/255; c.blue := ORD(p[0])/255; c.alpha:= ORD(p[3])/255;	
	RETURN c
END pixel;

PROCEDURE pixelT*(x,y:REAL; T: INTEGER):Color;
VAR
	i,j: SIZE;
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
		side[1]:=side[0];		
		side[2]:=side[0];		
		side[3]:=side[0];		
		side[4]:=side[0];		
		side[5]:=side[0];		
	END
END init;	

PROCEDURE reload*(CONST name: ARRAY OF CHAR);
BEGIN
	side[0].img :=Graphics.LoadImage(name, FALSE); (* img format is BGRA8888 *)
	IF side[0].img=NIL THEN 
		side[0].img := defaultimg;
	END;
	side[0].W:=side[0].img.width;
	side[0].H:=side[0].img.height;	
END reload;

END TexCube;


TYPE Ray*=RECORD;
	xyz*, dxyz*, ddxyz*, lxyz*, lastlxyz*, txyz*, origin*, oxyz*, hitxyz*,firsthitxyz*: PT;	
	downxyz*,rightxyz*: PT;
	theta*,phi*, dtheta*,dphi*: REAL;
	clr*, lastclr*: ray_color;
	mirrors*: INTEGER;
	texcube*:TexCube;
	texcubeTF*:BOOLEAN;
	ncube*: NCube;
	ncubeTF*: BOOLEAN;
	terminate*: BOOLEAN;
	scale*,tscale*: REAL;
	length*: REAL; 
	dxdi*,dydi*,dzdi*,dxdj*,dydj*,dzdj*: REAL;
	di*,dj*,dk*: BOOLEAN;
	changed*: BOOLEAN; 
	face*: INTEGER;
	mirrortf*:BOOLEAN;	
	inside*: BOOLEAN;
	normal*,fnormal*: PT;  
	normalTF*: BOOLEAN;
	corner*:PT;
	dtl*: REAL;	
	dtlTF*:BOOLEAN;
	hitmirrorTF*:BOOLEAN;
	justhitTF*,firsthitTF*:BOOLEAN;
	justhit*:Voxel;
	thisvoxelisempty*:BOOLEAN;
	texdtl*:REAL;
	rand*: Random.Generator;
	lighting*: REAL;
END;

TYPE Path*=ARRAY 20 OF ARRAY 3 OF INTEGER;

TYPE Voxel*=OBJECT(V)
VAR
	complex*, passable*: BOOLEAN;
	imposter*, texture*, deepcopyofme*: Voxel;
	lockTF*, copymarker*, emptysplit*: BOOLEAN;
	DTL*: REAL;
	code*, ncode*:Name;  
	tscale*: REAL;
	red*, green*, blue*, black*, alpha*, redblack*, greenblack*, blueblack*: REAL;
	colored*, colorlock*, frozen*, probelock*, copyonstroke*, baked*:BOOLEAN;
	offset*:PT;
	lighting*: REAL;
	
PROCEDURE r90z*;
END r90z;

PROCEDURE count*(level: INTEGER):INTEGER;
BEGIN
	RETURN 1;
END count;

PROCEDURE Shade*(VAR ray: Ray);
END Shade;
PROCEDURE probe*(p:PT; resolution: INTEGER):Voxel;
BEGIN
	RETURN(SELF);
END probe;
PROCEDURE touchcache*;
END touchcache;
PROCEDURE passprobe*(p:PT):BOOLEAN;
BEGIN
	RETURN(passable);
END passprobe;
PROCEDURE chat*(in: CHAR):Strings.String;
VAR
	out: Strings.String;
BEGIN
	out:=Strings.NewString("generic voxel chat response");
	IF in='h' THEN 
		out:=Strings.NewString("i have nothing to say")
	END;
	RETURN out
 END chat;
PROCEDURE setcolor* (r,g,b,rb,gb,bb: REAL); 
BEGIN
	red :=r;
	green:=g;
	blue:=b;
	redblack:=rb;
	greenblack:=gb;
	blueblack:= bb;
END setcolor;
PROCEDURE setcolorrec* (r,g,b,rb,gb,bb: REAL); 
END setcolorrec;
PROCEDURE erase*(p:PT; resolution:INTEGER);
END erase;
PROCEDURE copyprime*;
END copyprime;
PROCEDURE deepcopy*():Voxel;
BEGIN
	RETURN(SELF)
END deepcopy;
PROCEDURE copyclear*;
END copyclear;
PROCEDURE fill*(v: Voxel);
END fill;
PROCEDURE line*(a,b: PT; level: INTEGER; v: Voxel);
END line;
PROCEDURE proberec*(p:PT; resolution,scale:INTEGER):Voxel;
END proberec;
PROCEDURE FRaster*( f: FR; resolution: INTEGER); 
END FRaster;
PROCEDURE FRasterrec*(f: FR; resolution: INTEGER; origin: PT; scale: INTEGER); 
END FRasterrec;
PROCEDURE FRasterSolid*( f: FR; resolution: INTEGER); 
END FRasterSolid;
PROCEDURE FRasterrecSolid*(f: FR; resolution: INTEGER; origin: PT; scale: INTEGER); 
END FRasterrecSolid;

PROCEDURE stroke*(p:PT; resolution: INTEGER; voxel:Voxel);
END stroke;
PROCEDURE strokerec*(p:PT; resolution,scale: INTEGER;  voxel: Voxel);
END strokerec;
PROCEDURE strokephemeral*(p:PT; resolution: INTEGER; voxel,voxundo:Voxel);
END strokephemeral;
PROCEDURE strokephemeralrec*(p:PT; resolution,scale: INTEGER; voxel,voxundo:Voxel);
END strokephemeralrec;
PROCEDURE nstroke*(p:PT; resolution: INTEGER; normal: PT; color: Color);
END nstroke;
PROCEDURE nstrokerec*(p:PT; resolution,scale: INTEGER; normal: PT; color: Color);
END nstrokerec;
PROCEDURE mstroke*(a,b,c: INTEGER; resolution: INTEGER; vname: Name);
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
	VAR res : INTEGER; 
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
	XNXLAudio.Play 

	ALUT.Play(basesource);	*)
END play;

PROCEDURE touch*;
END touch; 

PROCEDURE hash():Name;
BEGIN
	RETURN ncode	
END hash;

END Voxel; 

TYPE Cell*=OBJECT(Voxel);
VAR
	nposterTF*:BOOLEAN;
	nposter*: NCube;
	deepcopyofme*:Cell;
END Cell;

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
	cxolor*, sidecxolor*:Color;
	allowdeath*,passable*:BOOLEAN;

PROCEDURE & init*;
BEGIN
	setsidecolor(1/2,1/2,1/2,1,0);
END init;

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

PROCEDURE getnormal*(p:PT):PT;
BEGIN
	normalizePT(norml);		(* norml is often calculated in d2s but not normalized there *)
	RETURN norml					(* this is the normal for the most recent point handed to d2s *)
END getnormal;

PROCEDURE setvoxel*(v:Voxel);  
BEGIN
	vox:=v;
	imposter:=v
END setvoxel;

PROCEDURE setcolor*(r,g,b,a,m: REAL);  
BEGIN
	cxolor.red:=r; cxolor.green:=g; cxolor.blue:=b; cxolor.alpha:=a; cxolor.mirror:=m;
END setcolor;

PROCEDURE setsidecolor*(r,g,b,a,m: REAL);  
BEGIN
	sidecxolor.red:=r; sidecxolor.green:=g; sidecxolor.blue:=b; sidecxolor.mirror:=m;
END setsidecolor;

PROCEDURE getcolor*(p:PT):Color;
BEGIN
	RETURN cxolor
END getcolor;

PROCEDURE getsidecolor*(p:PT):Color;
BEGIN
	RETURN sidecxolor
END getsidecolor;

PROCEDURE setimposter*(v:Voxel);  
BEGIN
	imposter:=v
END setimposter;

PROCEDURE getimposter*(p:PT):Voxel;
BEGIN
	RETURN vox
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

PROCEDURE strokeTF*(p:PT):BOOLEAN;
BEGIN	
	RETURN TRUE		
END strokeTF;

END FR;

TYPE P=PROCEDURE (v:Voxel):Voxel;

VAR
	voxelist: ARRAY 100 OF V;
(*	clock*: Clock;*)
	TICK*: BOOLEAN;
	TOCK*: BOOLEAN;
	fog*,horizon*,horizon2*,texdetail*:REAL;
	rlimit*: INTEGER;
	iterlimit*: INTEGER;
	speed*,maxspeed*:REAL;
	frame*: SIZE;
	rand*:Random.Generator;
	worldalive*: BOOLEAN;
	gravity*:REAL;
	fuzzon*, STOP*: BOOLEAN;
	singleray*: Ray;	(* for when a single ray is most convenient *)
	Face*: ARRAY 6 OF PT;
	EMPTY*,OPAQUE*: Voxel;
	deathflag*:BOOLEAN;
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
	sniperay*, blankray*, blankpray*:Ray;
	blackspeed*:REAL;
	defaultimg: Raster.Image;
	hasher*:CryptoMD5.Hash;
	PRO*: INTEGER;
	patchx*, patchy*: INTEGER;
(*	basesource*, texsound*, grainsound*: AL.ALuint;
	listenerPos*: ARRAY [3] OF AL.ALfloat; (* global position *)
	sourcePos: ARRAY 3 OF AL.ALfloat;
	buffer1*, buffer2*, buffer3* : AL.ALuint;	
*)	
PROCEDURE VoxelFromName*(modname: Name): Voxel;
	VAR voxel: Voxel;  fackery: VoxelFackery;
	BEGIN
		IF modname[0]='N' THEN
			GETPROCEDURE(modname, "thisvox", fackery );
			IF (fackery # NIL) THEN  
				voxel := fackery();		 
			END;
			IF voxel=NIL THEN 
				 Out.String("failed voxelfromname 1"); 
				voxel:=EMPTY
			ELSE
				voxel.code:=modname;
			END;
		ELSE
			  Out.String("failed voxelfromname 2"); 
			voxel:=EMPTY
		END;
		RETURN voxel
END VoxelFromName;

PROCEDURE updatecamera*(x,y,z,a,b,c,d,e,f:  REAL);
BEGIN
	previouscursorPT:=cursorPT;
	previouscameraPT:=cameraPT;
	cameraPT.x:=x; cameraPT.y:=y; cameraPT.z:=z;
	cursorPT.x:=x+a; cursorPT.y:=y+b; cursorPT.z:=z+c; 
	avatarPT.x:=x+a+d; avatarPT.y:=y+b+e; avatarPT.z:=z+c+f; 
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
	IF r < 0 THEN r := 0 ELSIF r>1 THEN r := 0.99 END;
	IF g < 0 THEN g := 0 ELSIF g>1 THEN g := 0.99 END;
	IF b < 0 THEN b := 0 ELSIF b>1 THEN b := 0.99 END;
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

PROCEDURE clampclr*(VAR a: ray_color);
BEGIN
	IF a.r < 0 THEN a.r := 0 ELSIF a.r>=1 THEN a.r := 0.9999999 END;
	IF a.g < 0 THEN a.g := 0 ELSIF a.g >=1 THEN a.g := 0.9999999 END;
	IF a.b < 0 THEN a.b := 0 ELSIF a.b>=1 THEN a.b := 0.9999999 END;
END clampclr;

PROCEDURE mkcolor*(r,g,b: REAL): Color;
VAR
	c:Color;
BEGIN
	c.red:=r; c.green:=g; c.blue:=b;
	RETURN(c);
END mkcolor;

PROCEDURE mixcolor*(a,b: Color; m: REAL):Color;
VAR
	c:Color;
	tmm:REAL;
BEGIN
	tmm:=1-m;
	c.red:=(a.red*m+b.red*tmm); c.green:=(a.green*m+b.green*tmm); c.blue:=(a.blue*m+b.blue*tmm); c.alpha:=(a.alpha*m+b.alpha*tmm);
	RETURN(c);
END mixcolor;

PROCEDURE avgcolor*(a,b: Color): Color;
VAR
	c:Color;
BEGIN
	c.red:=(a.red+b.red)/2; c.green:=(a.green+b.green)/2; c.blue:=(a.blue+b.blue)/2;
	RETURN(c);
END avgcolor;

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
	IF  ~STOP THEN
		Out.String("t"); 
		i := 0;
		WHILE i < 90 DO
			IF voxelist[i] # NIL THEN voxelist[i].tick END;
			INC(i);
		END;
		INC(frame);    
	END
END tick; 

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

PROCEDURE randnormalPT*():PT;
VAR
	p:PT;
BEGIN
	p.x := rand.Uniform();	
	p.y := rand.Uniform();	
	p.z := rand.Uniform();	
	normalizePT(p);
	RETURN p
END randnormalPT;


PROCEDURE randColor*():Color;
VAR
	c:Color;
BEGIN
	c.red:= rand.Uniform();	
	c.green:= rand.Uniform();	
	c.blue := rand.Uniform();	
	c.alpha:=1;
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
				ray.face := 0; ray.fnormal:= Face[0] 
			ELSE
				exit.x:=0; exit.y:=ray.lxyz.y+drx*ray.dxyz.y; exit.z:=ray.lxyz.z+ drx*ray.dxyz.z;
				ray.face := 0; ray.fnormal:= Face[0] 
			END;	
		ELSE
			IF ray.dxyz.z>0 THEN
				exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=1;
				ray.face := 2; ray.fnormal:= Face[2] 
			ELSE
				exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=0;
				ray.face := 5; ray.fnormal:= Face[5]
			END;		
		END;
	ELSIF (dry < drz) THEN
		IF ray.dxyz.y>0 THEN
			exit.x:=ray.lxyz.x+dry*ray.dxyz.x; exit.y:=1; exit.z:=ray.lxyz.z+dry*ray.dxyz.z;
			ray.face := 1; ray.fnormal:= Face[1] 
		ELSE
			exit.x:=ray.lxyz.x+dry*ray.dxyz.x; exit.y:=0; exit.z:=ray.lxyz.z+dry*ray.dxyz.z;
			ray.face := 4; ray.fnormal:= Face[4] 
		END;
	ELSE
		IF ray.dxyz.z>0 THEN
			exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=1;
			ray.face := 2; ray.fnormal:= Face[2] 
		ELSE
			exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=0;
			ray.face := 5; ray.fnormal:= Face[5]
		END;		
	END;
	RETURN(exit);
END Exit;

PROCEDURE ExitF*(ray: Ray; VAR exit: PT; VAR face: INTEGER);
VAR
	drx, dry, drz: REAL;
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
				face := 0
			ELSE
				exit.x:=0; exit.y:=ray.lxyz.y+drx*ray.dxyz.y; exit.z:=ray.lxyz.z+ drx*ray.dxyz.z;
				face := 3
			END;	
		ELSE
			IF ray.dxyz.z>0 THEN
				exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=1;
				face := 2
			ELSE
				exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=0;
				face := 5
			END;		
		END;
	ELSIF (dry < drz) THEN
		IF ray.dxyz.y>0 THEN
			exit.x:=ray.lxyz.x+dry*ray.dxyz.x; exit.y:=1; exit.z:=ray.lxyz.z+dry*ray.dxyz.z;
			face := 1
		ELSE
			exit.x:=ray.lxyz.x+dry*ray.dxyz.x; exit.y:=0; exit.z:=ray.lxyz.z+dry*ray.dxyz.z;
			face := 4
		END;
	ELSE
		IF ray.dxyz.z>0 THEN
			exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=1;
			face := 2
		ELSE
			exit.x:=ray.lxyz.x+drz*ray.dxyz.x; exit.y:=ray.lxyz.y+drz*ray.dxyz.y; exit.z:=0;
			face := 5
		END;		
	END
END ExitF;

PROCEDURE InitSounds;

(*BEGIN
*(	ALUT.OpenPlayDevice();
	buffer1 := ALUT.LoadWavFileToBuffer("grain.wav");
	
	 AL.alGenSources(1, ADDRESSOF(basesource));
	 AL.alSourcef(basesource, AL.AL_PITCH, 1.0);
	AL.alSourcef(basesource, AL.AL_GAIN, 1.0); 
	sourcePos := [0.0, 0.0, 0.0];
	AL.alSourcefv(basesource, AL.AL_POSITION, ADDRESSOF(sourcePos[0]));
	AL.alSourcei(basesource, AL.AL_LOOPING, AL.AL_FALSE); 
	 AL.alSourcei(basesource, AL.AL_BUFFER, buffer1);
	 
	 (* the same sound, wav *)
	buffer2 := buffer1;
	grainsound := basesource;
	
	(* sound for TexVox *)
	buffer3 := ALUT.LoadWavFileToBuffer("test.wav");		
	 AL.alGenSources(1, ADDRESSOF(texsound));
	 	
	 AL.alSourcef(texsound, AL.AL_PITCH, 1.0);
	AL.alSourcef(texsound, AL.AL_GAIN, 1.0); 
	sourcePos := [0.0, 0.0, 0.0];
	AL.alSourcefv(texsound, AL.AL_POSITION, ADDRESSOF(sourcePos[0]));
	AL.alSourcei(texsound, AL.AL_LOOPING, AL.AL_FALSE); 
	AL.alSourcei(texsound, AL.AL_BUFFER, buffer3);
 
 	
 	(* finally create one listener *)
	listenerPos := [0.0, 0.0, 0.0];
	AL.alListenerfv(AL.AL_POSITION, ADDRESSOF(listenerPos[0]));
	ALUT.ALWriteError("2-loadwav: ");	
*)
END InitSounds;

BEGIN
	Out.String("Base loading...");
	WMFontManager.Install;
	NEW(rand);
(*	XNXLAudio.OpenDevice;
	NEW(clock); *)
	fward:=mkPT(1,0,0);
	rward:=mkPT(0,1,0);
	dward:=mkPT(0,0,1);
	NEW(EMPTY);
	EMPTY.code:="EMPTY";
	EMPTY.passable:=TRUE;
	NEW(world);
	worldalive := TRUE;
	frame:=0;
	fog := 1.1;
	texdetail:=10;
	horizon:=0.11;
	horizon2:=1;
	rlimit := 4;
	iterlimit := 500;
	DTL:=30;	
	PRO:=1;
	patchx:=1;
	patchy:=1;
	Origin:=mkPT(0,0,0);   (* unneeded initialization *)
	Face[0].x := -1; Face[0].y := 0; Face[0].z := 0; 
	Face[3].x := 1; Face[3].y := 0; Face[3].z := 0; 
	Face[1].x := 0; Face[1].y := 1; Face[1].z := 0; 
	Face[2].x := 0; Face[4].y := -1; Face[4].z := 0; 
	Face[5].x := 0; Face[2].y := 0; Face[2].z := 1; 
	Face[4].x := 0; Face[5].y := 0; Face[5].z := -1; 	
	blankray.clr.ra := 1;
	blankray.clr.ga := 1;
	blankray.clr.ba := 1;
	blankray.clr.alpha:=1;
	blankray.scale := 1; 
	blankray.tscale:=1;
	blankray.dtl:=0.075;	
	blankray.rand:=rand;
	blankpray.clr.ra := 1;
	blankpray.clr.ga := 1;
	blankpray.clr.ba := 1;
	blankpray.clr.alpha:=1;
	blankpray.scale := 1; 
	blankpray.tscale:=1;
	blankpray.dtl:=0.075;	
	m2sdelta:=25;
	m3sdelta:=25;
	speed:=0.00051;
	skydistance:=1.0;
	Out.String("loaded.");
	Out.Ln;
	InitSounds();	
	defaultimg := Graphics.LoadImage("grain.png", TRUE); 
	ASSERT(defaultimg#NIL);
END Base.