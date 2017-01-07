MODULE Marsh;
IMPORT  Base , Retina, Engrainer, Random, CellAuto,
 FRep, Files, Streams, Commands, Out:=KernelLog;

CONST sfile="marshstrokes.text"
TYPE Voxel=Base.Voxel;
	PT=Base.PT;
	Color=Base.Color;  
	Path=Base.Path;
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
	tnoise: FRep.tilednoise;
	noise: FRep.noise;
	bifr: FRep.bifr;;
	gorgeplane: FRep.landscape;
	plane: FRep.plane;
	sphere: FRep.sphere;	
	r,g,b: Base.Color;
	red,blue,green: REAL;
	EMPTY,cursormark:Voxel;
	rand: Random.Sequence;
	vlistN, vN*: INTEGER;
	cursorsize*,previouscursorsize: LONGINT;
	A,B: PT;
	SNIPE*,SNIPEINTO*:BOOLEAN;
	atmdark: REAL;
	pth: Path; 
PROCEDURE draw*;
BEGIN
	stroke(Base.cursorPT,cursorsize,marshv.vox)
END draw;

PROCEDURE key*(CONST c:CHAR);
BEGIN
	Out.Char(c);
END key;

PROCEDURE clear*;
BEGIN
	stroke(Base.cursorPT,cursorsize,EMPTY)
END clear;

PROCEDURE line*;
BEGIN
	Base.world.line(A,B,cursorsize,marshv.vox);	
END line;

PROCEDURE stroke(p:PT; resolution:LONGINT; voxel:Voxel);
BEGIN
	A:=B;
	B:=p;
	Base.world.stroke(p,resolution, voxel);
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
	stroke(Base.cursorPT,cursorsize,marshv.vox)
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
	stroke(Base.cursorPT,cursorsize,marshv.vox)
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
	Base.world.stroke(Base.cameraPT,729, cursormark); 	
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
	Base.world.copyclear;
	Engrainer.engrain(Base.world); 
END engrain;

PROCEDURE sprout*;
VAR v:Voxel;
BEGIN
	Out.String("sprouting...");
	Base.world:= Engrainer.sprout();
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
	undo,rd, rdpseudosolid, blu, die,gren,granite,sand,whiteblock,lazy,pdestroyer,axolotl,xen,sky1,sky2,tigerlily,cloud: Voxel;
	die0,die1,die2,die3,die4,die5,etile0,etile1,etile2,etile3,etile4,grass,sparx,msphere,harrison,fuse:Voxel;
	sky,dieone, serp,cthulhu,greenball,rat,beatrix,blacksun,conglomerate,conglo2,caption,gorge,xot,xot2,
	w3,z3,z3a,z2,z2a,cage,floop,volvox,life,iml,speckle, doge, reddot,treeserp,acidcats, badopossum, raccoon: Voxel;
	ball: FRep.sphere;
	noise: FRep.noise;	 
BEGIN
	NEW(ms);
	NEW(EMPTY);
	EMPTY.passable:=TRUE;
      rand:=Base.rand;	

  	w10:=Base.VoxelFromName("NM3");	
 	z10:=Base.VoxelFromName("NM2");	
	w3:=Base.VoxelFromName("NM3");	 
	z3:=Base.VoxelFromName("NM3");	
	z3a:=Base.VoxelFromName("NM4");	
	z2:=Base.VoxelFromName("NM2");
	z2a:=Base.VoxelFromName("NM3");	
	harrison:=Base.VoxelFromName("Nharrisonavatar"); 
	push(harrison);
	doge:=Base.VoxelFromName("Ndogepearl"); 
	push(doge);		
	xot:=Base.VoxelFromName("N5a2g4M6HYjPJxYSNQvYyv7"); 
	push(xot);
(*     floop:=Base.VoxelFromName("NFLOOP");  
     push(floop);
*) 
	serp:=Base.VoxelFromName("NXWCxXWLIcD2LegvoGXX666"); 	
	badopossum:=Base.VoxelFromName("Nbadopossum"); 	
	raccoon:=Base.VoxelFromName("Nraccoon"); 	
	push(treeserp);	
 	gorge:=Base.VoxelFromName("NxxxGAernhjFK40xASZZVoQ"); 
	push(gorge);
	xot2:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU667"); 	
	push(xot2);
	reddot:=Base.VoxelFromName("Nreddot"); 	
	push(reddot);
	msphere:=Base.VoxelFromName("NBsHFiBKkSckXBAd46Zbsss"); 	
	 push(msphere);	
(* 	volvox:=Base.VoxelFromName("Nrdvolvox");  	
      push(volvox);
*)       rdpseudosolid:=Base.VoxelFromName("Nrdpseudosolid"); 
       push(rdpseudosolid);
	beatrix:=Base.VoxelFromName("NwPicBWw4NfcserX4ELaQ3b"); 
	acidcats:=Base.VoxelFromName("Nacidcats"); 
       speckle:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO7"); 
       push(speckle);
       
       lobster:=Base.VoxelFromName("Ndiffusered"); 
	push(lobster);
	tigerlily:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw");  
       push(tigerlily);
 	iml:=Base.VoxelFromName("Niml");  
       push(iml);      
     	life:=Base.VoxelFromName("Nlife");  
       push(life);
	harrison:=Base.VoxelFromName("Nharrisonavatar"); 
	push(harrison);
	doge:=Base.VoxelFromName("Ndogepearl"); 
	push(doge);	
    	MCUBE:=Base.VoxelFromName("Nr3kPtbyEYLFK3AN2UUVrqg");
	push(MCUBE);
  	
	cage:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU341");
	cage.copyonstroke:=TRUE;
  	push(cage);
 	fuse:=Base.VoxelFromName("NFuse");

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
	conglomerate:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO7"); 			
	
	GREEN:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODg");	(*actually blue atm*)
	grass:=Base.VoxelFromName("NJOFc7qhMXMly3lot71bNUw"); 	
	cloud:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODh"); 		
	
  	push(dotz);
	push(btx);
	push(GREEN);
	push(grass);	

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
	blacksun:=Base.VoxelFromName("Nblacksun"); 	
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
	conglo2:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZOq"); 	
	push(conglo2);
	sky1:=Base.VoxelFromName("N5a2g4M6HYjPJxYSNQvYy7"); 	
	push(sky1);
	sky2:=Base.VoxelFromName("NXWCxXWLIcD2LegvoGXXBiQ"); 	
	push(sky2);
	tigerlily:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw");  				
	push(tigerlily);	
	NEW(noise);		
	noise.seed:=33666;		
	noise.a:=1;
	noise.b:=1;
	noise.c:=1;		
	noise.octaves:=4;

	noise.persistence:=3.1;
	Out.String("EEEEP!");
	Base.setPT(up,0,0,1);
	Base.setPT(center,1/2,1/2,9/10);
	Base.setPT(up,0,0,1);

	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,0.6);  
	serp.passable:=FALSE;   
	conglomerate.copyonstroke:=TRUE;
	noise.setvoxel(reddot);	
	reddot.tscale:=128;
	ball.setvoxel(axolotl);
	Base.setPT(center,1/2,1/2,9/12);
	NEW(plane,center,up);
	plane.vox:=rat;	
	rat.tscale:=16;
	z2a.FRaster(plane,64);  
	z2a.FRaster(ball,32); 	
	z2a.FRaster(noise,64);
 	Base.world:=z2a; 	
	Base.avatar:=harrison;
	Base.avatarsize:=1000; 
END dawn;

PROCEDURE darken*;
BEGIN
	atmdark:= atmdark*1.5;
	Base.world.setcolor(0,0,0,atmdark,0);	
END darken;

PROCEDURE lighten*;
BEGIN
	IF atmdark>0.11 THEN atmdark:= atmdark/1.5 END;
	Base.world.setcolor(0,0,0,atmdark,0);	
END lighten

BEGIN
	NEW(marshv);
	dawn;
	cursorsize:=512;
	cursorTF:=TRUE;
	atmdark:=1.2;
	SNIPEINTO:=TRUE;
END Marsh.

XNXL.ourfounder.png

