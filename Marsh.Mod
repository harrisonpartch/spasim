MODULE Marsh;
IMPORT  Base , Retina, Engrainer, Random, CellAuto,
 XNXLFRep, Files, Streams, Commands, Out:=KernelLog;

CONST sfile="marshstrokes.text"
TYPE Voxel=Base.Voxel;
	PT=Base.PT;
	Color=Base.Color;  
	VA=ARRAY 5 OF Voxel;

TYPE vloop=OBJECT
VAR
	vox: Voxel;
	prev,next: vloop;

PROCEDURE &init;
BEGIN
	prev:=SELF; 
	next:=SELF; 
	NEW(vox);
	vox.passable:=TRUE;
END init;

PROCEDURE push(v: Voxel):vloop;
VAR
	vl:vloop;
BEGIN
	vox:=v;
	NEW(vl);
	vl.prev:=SELF;
	vl.next:=next;
	next:=vl;
	RETURN(next);
END push;

PROCEDURE clockwise():vloop;
BEGIN
	ASSERT(next#NIL);
	RETURN next
END clockwise;

PROCEDURE anticlockwise():vloop;
BEGIN
	ASSERT(prev#NIL);
	RETURN prev
END anticlockwise;

END vloop;

TYPE mstroker=OBJECT
VAR f: Files.File; w: Files.Writer;
strokes: INTEGER;

PROCEDURE &init;
BEGIN
	f := Files.New(sfile);
	IF (f # NIL) THEN
		Files.OpenWriter(w, f, 0);
	END;
END init;

PROCEDURE tofile;
BEGIN
	IF (w.res = Streams.Ok) THEN
		w.Update;
		Files.Register(f)
	END
END tofile;

PROCEDURE stroke(p:PT; resolution: LONGINT; voxel:Voxel);
BEGIN
	IF (w.res = Streams.Ok)  THEN
		w.String("B.world.mstroke(");
		w.Int(ENTIER(p.x*1000000),6);
		w.Char(',');
		w.Int(ENTIER(p.y*1000000),6);
		w.Char(',');		
		w.Int(ENTIER(p.z*1000000),6);
		w.Char(',');	
		w.Int(resolution,4);
		w.Char(',');	
		w.String('"d41d8cd98f00b204e9800998ecf8427e"');
		w.String(");");
		w.Ln;
	END;
	INC(strokes);
	IF strokes>10 THEN
		strokes:=0;
		tofile;
	END	
END stroke;

END mstroker;

VAR
	marshv: vloop;
	cursorsave,drawvox,voxundo,avatarundo: Voxel;
	cursorTF*,lines*:BOOLEAN;
	ms: mstroker;
	i,j,k,ii,jj,kk,iii,jjj,kkk,t,s: LONGINT;
	cost: REAL;
	up,flat,down,right,away,slant,p,pp,q,qq,center,undercenter, normal,xaxis,yaxis,zaxis: PT;
	tnoise: XNXLFRep.tilednoise;
	noise: XNXLFRep.noise;
	gorgeplane: XNXLFRep.landscape;
	plane: XNXLFRep.plane;
	r,g,b: Base.Color;
	red,blue,green: REAL;
	EMPTY,cursormark:Voxel;
	rand: Random.Sequence;
	vlistN, vN*: INTEGER;
	cursorsize*,previouscursorsize: LONGINT;
	A,B: PT;
	SNIPE*,SNIPEINTO*:BOOLEAN;
	atmdark: REAL;

PROCEDURE draw*;
BEGIN
	stroke(Base.cursorPT,cursorsize,marshv.vox,voxundo)
END draw;

PROCEDURE key*(CONST c:CHAR);
BEGIN
	Out.Char(c);
END key;

PROCEDURE clear*;
BEGIN
	stroke(Base.cursorPT,cursorsize,EMPTY,voxundo)
END clear;

PROCEDURE line*;
BEGIN
	Base.world.line(A,B,cursorsize,marshv.vox);	
END line;

PROCEDURE stroke(p:PT; resolution:LONGINT; voxel,vundo:Voxel);
BEGIN
	A:=B;
	B:=p;
	Base.world.stroke(p,resolution,voxel,vundo);
	IF lines THEN line END
END stroke;

PROCEDURE snipeinto*;
VAR
	p,dp:PT;
	ray:Base.Ray;
	v: Voxel;
	d:REAL;
BEGIN
	ray:=Base.sniperay;
	Base.world.Shade(ray);
	IF ray.hitmirrorTF THEN 
		p:=ray.hitxyz; dp:=ray.hitdxyz
	ELSE
		p:= ray.xyz; dp:=ray.dxyz
	END;
	p.x:=p.x+dp.x/1000000;
	p.y:=p.y+dp.y/1000000;
	p.z:=p.z+dp.z/1000000;
	Base.cursorPT:=p; 	
	stroke(Base.cursorPT,cursorsize,marshv.vox,voxundo)
END snipeinto;

PROCEDURE snipeonto*;
VAR
	p,dp:PT;
	ray:Base.Ray;
	v: Voxel;
	d:REAL;
BEGIN
	ray:=Base.sniperay;
	Base.world.Shade(ray);
	IF ray.hitmirrorTF THEN 
		p:=ray.hitxyz; dp:=ray.hitdxyz
	ELSE
		p:= ray.xyz; dp:=ray.dxyz
	END;
	p.x:=p.x-dp.x/1000000;
	p.y:=p.y-dp.y/1000000;
	p.z:=p.z-dp.z/1000000;
	Base.cursorPT:=p; 	
	stroke(Base.cursorPT,cursorsize,marshv.vox,voxundo)
END snipeonto;

PROCEDURE sniprobe*():Voxel;
VAR
	v: Voxel;
BEGIN
	v:=Base.world.proberay(Base.sniperay);
	RETURN v
END sniprobe;

PROCEDURE drawHUD*;
VAR
	p:PT;
	v: Voxel;
	d:REAL;
BEGIN
	Base.world.stroke(Base.cameraPT,729,cursormark,voxundo); 	
END drawHUD;

PROCEDURE push*(v: Voxel);
BEGIN
	marshv:=marshv.push(v)
END push;

PROCEDURE incVN*;
BEGIN
	marshv:=marshv.clockwise();
END incVN;

PROCEDURE decVN*;
BEGIN
	marshv:=marshv.anticlockwise()
END decVN;

PROCEDURE drawavatar*;
VAR
	i: LONGINT;
	p: PT;
	v: Voxel;
BEGIN
	Base.world.strokephemeral(Base.avatarPT,Base.avatarsize,Base.avatar,avatarundo)
END drawavatar;

PROCEDURE Rez*(context: Commands.Context);
VAR
	xode: Base.Name;
	res: BOOLEAN;
BEGIN
	res:=context.arg.GetString(xode);
	marshv.vox:=Base.VoxelFromName(xode);
	Out.String("Rezzing ");
	Out.String(xode);
	Out.Ln	
END Rez;

PROCEDURE showcode*;
BEGIN
	marshv.vox.showcode
END showcode;

PROCEDURE engrain*;
BEGIN
	Out.String("engraining...");
	Engrainer.engrain(Base.world); 
END engrain;

PROCEDURE sprout*;
VAR v:Voxel;
BEGIN
	Out.String("sprouting...");
	v:=Engrainer.sprout(); 
	IF v=NIL THEN 
		Out.String("nilsprout");
		NEW(Base.world) 
	ELSE
		Base.world:=v;
	END
END sprout;

PROCEDURE randPT*():PT;
VAR
	p:PT;
BEGIN
	p.x :=1/2+((1/2-rand.Uniform())*0.97);	
	p.y := 1/2+((1/2-rand.Uniform())*0.97);
	p.z := 1/2+((1/2-rand.Uniform())*0.97);	
	RETURN p
END randPT;

PROCEDURE dawn*;
VAR
	z10: Voxel;
	sfish,gxy,w10,w11,v,lobster, btx,ash, dotz, GREEN,PURPLE,MCUBE:Voxel;
	undo,rd,blu, die,gren,granite,sand,whiteblock,lazy,pdestroyer,axolotl,xen,sky1,sky2,tigerlily,cloud: Voxel;
	die0,die1,die2,die3,die4,die5,etile0,etile1,etile2,etile3,etile4,grass,sparx,msphere,harrison,fuse:Voxel;
	sky,dieone, serp,cthulhu,greenball,rat,beatrix,blacksun,conglomerate,conglo2,caption,gorge,xot,xot2,cage,floop,volvox,life,iml: Voxel;
	 
BEGIN
	NEW(ms);
	NEW(EMPTY);
	EMPTY.passable:=TRUE;
      rand:=Base.rand;	

  	w10:=Base.VoxelFromName("NM2");	
 	z10:=Base.VoxelFromName("NM2");	
    
	Out.String("EEEEP!");
	xot:=Base.VoxelFromName("Nharrisonavatar"); 
	push(xot);
	xot2:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU667"); 	
	push(xot2);
	msphere:=Base.VoxelFromName("NBsHFiBKkSckXBAd46Zbsss"); 	
	push(msphere);	
 	volvox:=Base.VoxelFromName("Nrdvolvox");  	
       push(volvox);
	beatrix:=Base.VoxelFromName("NwPicBWw4NfcserX4ELaQ3A"); 
	push(beatrix);
       lobster:=Base.VoxelFromName("NznGx2ySiHIGrO5t9Pzcw5Q"); 
	push(lobster);
	tigerlily:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw");  
       push(tigerlily);
 	iml:=Base.VoxelFromName("Niml");  
       push(iml);      
	floop:=Base.VoxelFromName("NFLOOP");	
 	push(floop);
     life:=Base.VoxelFromName("Nlife");  
       push(life);
  	MCUBE:=Base.VoxelFromName("Nr3kPtbyEYLFK3AN2UUVrqg");
	push(MCUBE);
  	
	cage:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU341");
  	push(cage);
 	fuse:=Base.VoxelFromName("NFuse");
 	ASSERT(fuse#NIL);
 	push(fuse);

	gxy:=Base.VoxelFromName("NmOgKSH5ZXYP3DODELOkO7g"); 	
	push(gxy);
	sfish:=Base.VoxelFromName("NcufbYokzVEuEfN5MYiDlhA"); 	 	
	push(sfish);
	dieone:=Base.VoxelFromName("NCjgzkmiTyecI5x6eOgYqpQ"); 	
  	push(dieone);   	
   	ash:=Base.VoxelFromName("NDQ0mOQYqpYYaLXJy4MS8BQ");	
  	push(ash);
	dotz:=Base.VoxelFromName("Nahf6T7P6CYGfcImQTejDpg");	
	btx:=Base.VoxelFromName("NVY1hEGnyr7z8DtULRMOZIQ");	
	conglomerate:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZOQ"); 			
	
	GREEN:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODg");	
	grass:=Base.VoxelFromName("NJOFc7qhMXMly3lot71bNUw"); 	
	serp:=Base.VoxelFromName("NXWCxXWLIcD2LegvoGXXBiQ"); 	
	cloud:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODh"); 		
	
  	push(dotz);
	push(btx);
	push(GREEN);
	push(grass);	
	push(serp);
	push(conglomerate);
	push(xot);	
	push(cloud);	
		 		
	rd:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODg"); 	
	push(rd);
	gren:=Base.VoxelFromName("NUeconrGpx7plz7ym76ibLw"); 		
	push(gren);
	die:=Base.VoxelFromName("NCjgzkmiTyecI5x6eOgYqpQ"); 
	push(die);
	granite:=Base.VoxelFromName("NGNYAfkxmEzxe6ZESmcMJtw"); 	
	push(granite);
	sand:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw"); 		
	push(sand);
	blacksun:=Base.VoxelFromName("NGNYAfkxmEzxe6ZESmcMJtw"); 	
	push(blacksun);
	
	lazy:=Base.VoxelFromName("NwPicBWw4NfcserX4ELxxx"); 	
	push(lazy);	
	
	pdestroyer:=Base.VoxelFromName("N7Z9LarKWKBcwXrDkSXezPg"); 	
	push(pdestroyer);
	axolotl:=Base.VoxelFromName("NnKyXYNiHwdxuM6wHrbxwuQ"); 	
	push(axolotl);
	etile0:=Base.VoxelFromName("NMRR8eVl6DBZXeJLNZ0KC6g"); 	
	push(etile0);
	etile1:=Base.VoxelFromName("NhYOBdcESgNhNEXS2S3OXsw"); 	
	push(etile1);
	etile2:=Base.VoxelFromName("NiHWuC6tiaYe9Qxl3e1DNqw"); 	
	push(etile2);
	etile3:=Base.VoxelFromName("N6illtDKEH5g6dsUifexH1Q"); 	
	push(etile3);
	caption:=Base.VoxelFromName("NxrglfWf3ZTXHHNB8BJ3sSQ"); 	
	push(caption);
	sparx:=Base.VoxelFromName("NSIsnYBTYL9BajD8fbPDSqg"); 
	push(sparx);
	xen:=Base.VoxelFromName("NZjDHYA8YHHcuymIh1fhHgg"); 		
	push(xen);
	sky:=Base.VoxelFromName("NtxxZorqH5oWxECOCwH59AQ"); 	
	push(sky);
	cthulhu:=Base.VoxelFromName("NuDxZaSfDCnI8xZnbp6c5ew"); 	
	push(cthulhu);
	greenball:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ"); 	
	push(greenball);
	rat:=Base.VoxelFromName("NGJBlQ95mTkoMhozr6XOJYg"); 	
	push(rat);
	conglo2:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZOZ"); 	
	push(conglo2);
	sky1:=Base.VoxelFromName("N5a2g4M6HYjPJxYSNQvYyvw"); 	
	push(sky1);
	sky2:=Base.VoxelFromName("NUzl1lqmBmaKyswkc70kO3w"); 	
	push(sky2);
	tigerlily:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw");  				
	push(tigerlily);
	gorge:=Base.VoxelFromName("NxxxGAernhjFK40xASZZVoQ"); 
	push(gorge);
      harrison:=Base.VoxelFromName("Nharrisonavatar"); 
	push(harrison);
 
	Base.setPT(up,0,0,1);
	Base.setPT(center,1/2,1/2,1/12);
	NEW(tnoise);
	tnoise.seed:=123666;	
	tnoise.a:=1;
	tnoise.b:=1;
	tnoise.c:=1;		
	tnoise.octaves:=4;
	tnoise.persistence:=4.5;
	tnoise.setvoxel(dotz);
	tnoise.va[0]:=sand;
	tnoise.va[1]:=axolotl;
	tnoise.va[2]:=etile0;
	tnoise.va[3]:=serp;
	tnoise.va[4]:=harrison;
	tnoise.va[5]:=btx;	

	NEW(noise);		
	noise.seed:=123666;		
	noise.a:=3;
	noise.b:=3;
	noise.c:=3;		
	noise.octaves:=4;
	noise.setvoxel(blacksun);
	noise.persistence:=3.1;
	Out.String("EEEEP!");
	Base.setPT(up,0,0,-1);
	Base.setPT(center,1/2,1/2,11/12);
	NEW(plane,center,up);
	plane.vox:=granite;	
	z10.FRaster(plane,32); 		
	z10.FRaster(noise,128); 	
	z10.FRaster(tnoise,256); 			
	z10.setcolor(0,1/2,0,1,0); 
	gorge.setcolor(0,0,0,0,0);
	Base.world:=z10; 	
	msphere.passable:=TRUE;
	Base.avatar:=lobster;
	Base.avatarsize:=10000;
	Out.String("EEEEP!");
END dawn;

PROCEDURE darken*;
BEGIN
	atmdark:= atmdark*1.5;
	Base.world.setcolor(0,0,atmdark,atmdark,atmdark);	
END darken;

PROCEDURE lighten*;
BEGIN
	IF atmdark>0.11 THEN atmdark:= atmdark/1.5 END;
	Base.world.setcolor(0,0,atmdark,atmdark,atmdark);	
END lighten

BEGIN
	NEW(marshv);
	cursorsize:=243*9;
	cursorTF:=TRUE;
	SNIPEINTO:=TRUE;
END Marsh.

XNXL.ourfounder.png

