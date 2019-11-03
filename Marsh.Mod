MODULE Marsh;
IMPORT  Base , Retina, Engrainer, Random, CellAuto, srVoxel, Voxel4,
 FRep, Files, Streams, Commands, Out:=KernelLog,NM3,NM10,NM20;

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

PROCEDURE stroke(p:PT; resolution: INTEGER; voxel:Voxel);
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
	i,j,k,ii,jj,kk,iii,jjj,kkk,t,s: INTEGER;
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
	cursorsize*,previouscursorsize: INTEGER;
	A,B: PT;
	SNIPE*,SNIPEINTO*:BOOLEAN;
	atmdark: REAL;
	pth: Path; 
	alternateworld: Voxel;

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

PROCEDURE stroke(p:PT; resolution:INTEGER; voxel:Voxel);
BEGIN
	A:=B;
	B:=p;
	Out.String(voxel.code);
	Out.Ln;
	Base.world.stroke(p,resolution, voxel);
	IF lines THEN line END
END stroke;

PROCEDURE tunnelinto*;
VAR
	p,dp:PT;
	ray:Base.Ray;
	v: Voxel;
	dx,dy,dz,d:REAL;
BEGIN
	ray:=Base.sniperay;
	dx:=ray.dxyz.x/10000000;
	dy:=ray.dxyz.y/10000000;
	dz:=ray.dxyz.z/10000000;	
	Base.world.Shade(ray);
	IF ray.firsthitTF THEN 
		p:=ray.firsthitxyz
	ELSE
		p:=ray.hitxyz
	END;
	p.x:=p.x+dx;
	p.y:=p.y+dy;
	p.z:=p.z+dz;
	Base.cursorPT:=p; 	
	Base.world.stroke(p,cursorsize, Base.EMPTY)
END tunnelinto;

PROCEDURE snipeinto*;
VAR
	p,dp:PT;
	ray:Base.Ray;
	v: Voxel;
	d:REAL;
BEGIN
	ray:=Base.sniperay;
	Base.world.Shade(ray);
	p:=ray.hitxyz;
	p.x:=p.x+ray.dxyz.x/10000000;
	p.y:=p.y+ray.dxyz.y/10000000;
	p.z:=p.z+ray.dxyz.z/10000000;
	Base.cursorPT:=p; 	
	stroke(p,cursorsize,marshv.vox)
END snipeinto;

PROCEDURE snipeonto*;
VAR
	p:PT;
	ray:Base.Ray;
	v: Voxel;
	d:REAL;
BEGIN
	ray:=Base.sniperay;
	Base.world.Shade(ray);
	p:=ray.hitxyz;
	p.x:=p.x-ray.dxyz.x/1000000;
	p.y:=p.y-ray.dxyz.y/1000000;
	p.z:=p.z-ray.dxyz.z/1000000;
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
	i: INTEGER;
	p: PT;
	v: Voxel;
BEGIN
	Base.world.stroke(Base.previousavatarPT,Base.avatarsize,Base.EMPTY);
	Base.world.stroke(Base.avatarPT,Base.avatarsize,Base.avatar);
	Base.previousavatarPT:=Base.avatarPT;
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

PROCEDURE swapworld*;
VAR v:Voxel;
BEGIN
	v:=Base.world;
	Base.world:=alternateworld;
	alternateworld:=v;
END swapworld;

PROCEDURE dawn*;
VAR
	z10: Voxel;
	sfish,gxy,w10,w11,v,lobster, btx,ash, dotz, GREEN,PURPLE,MCUBE:Voxel;
	undo,rd, rdpseudosolid, blu, die,gren,granite,sand,whiteblock,lazy,pdestroyer,axolotl,xen,sky1,sky2,tigerlily,cloud: Voxel;
	die0,die1,die2,die3,die4,die5,etile0,etile1,etile2,etile3,etile4,grass,sparx,msphere,harrison,fuse:Voxel;
	sky,dieone, serp,cthulhu,greenball,rat,beatrix,blacksun,conglomerate,conglo2,caption,gorge,xot,xot2,
	w3,z3,z3a,z3b,z2,z2a,z4,cage,floop,volvox,life,iml,speckle, doge, reddot,treeserp,acidcats, badopossum, raccoon,
	akatrump, archillect,arkilekt,kat,muratpak,dogepearl,
	jordan, bottle1,bottle2,bottle3,bottlepossum,bottlegrounds,greensuncouple,wstar,starspider,arevclock: Voxel;
	ball: FRep.randsphere;
	sqube: FRep.sqube;
	medley: NM20.cell;
	med1: NM20.cell;	
	med2: NM3.cell;
	fuzz: Voxel4.FuzzVox;
	siv: Voxel4.MirrorSphereInVox;
	noise: ARRAY 5 OF FRep.noise;	 
	twonoise: FRep.twonoise;
	hexgrid: FRep.hexgrid;
BEGIN
	NEW(ms);
	NEW(EMPTY);
	EMPTY.passable:=TRUE;
  	NEW(rand);
(*	xot:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoR"); 
	push(xot);
	cage:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU341");
	cage.copyonstroke:=TRUE;
  	push(cage);	
	archillect:=Base.VoxelFromName("Narchillect"); 
	push(archillect);
	greenball:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ"); 	
	push(greenball);	
	conglomerate:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO7"); 	
	conglomerate.copyonstroke:=TRUE;
	push(conglomerate);	
	reddot:=Base.VoxelFromName("Nbrownianspheres"); 	
	push(reddot);		
	rd:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODg"); 	
	push(rd);
		
	greenball:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ"); 	
	push(greenball);
	akatrump:=Base.VoxelFromName("Nakatrump"); 
	push(akatrump);
	archillect:=Base.VoxelFromName("Narchillect"); 
	push(archillect);
	arkilekt:=Base.VoxelFromName("Narkilekt"); 
	push(arkilekt);
	kat:=Base.VoxelFromName("Nkat"); 
	push(kat);
	muratpak:=Base.VoxelFromName("Nmuratpak"); 
	push(muratpak);
	dogepearl:=Base.VoxelFromName("Ndogepearl"); 
	push(dogepearl);
	harrison:=Base.VoxelFromName("Nharrisonavatar"); 
	push(harrison);
	doge:=Base.VoxelFromName("Ndogepearl"); 
	push(doge);		

  volvox:=Base.VoxelFromName("Nrdvolvox");  	
  push(volvox);
  serp:=Base.VoxelFromName("NXWCxXWLIcD2LegvoGXX999"); 
	push(serp);	
	badopossum:=Base.VoxelFromName("Nbadopossum"); 	
	raccoon:=Base.VoxelFromName("Nraccoon"); 	
	push(raccoon);	
 	gorge:=Base.VoxelFromName("NxxxGAernhjFK40xASZZVoQ"); 
	push(gorge);
	xot2:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU667"); 	
	push(xot2);
	reddot:=Base.VoxelFromName("Nreddot"); 	
	push(reddot);
	msphere:=Base.VoxelFromName("NBsHFiBKkSckXBAd46Zbsss"); 	
	 push(msphere);	
 
      rdpseudosolid:=Base.VoxelFromName("Nrdpseudosolid"); 
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


	sfish:=Base.VoxelFromName("NcufbYokzVEuEfN5MYiDlhA"); 	 	
	push(sfish);
	dieone:=Base.VoxelFromName("NCjgzkmiTyecI5x6eOgYqpQ"); 	
  	push(dieone);   	
   	ash:=Base.VoxelFromName("NDQ0mOQYqpYYaLXJy4MS8BQ");	
  	push(ash);
	dotz:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU666");	
	btx:=Base.VoxelFromName("NVY1hEGnyr7z8DtULRMOZIQ");	
	conglomerate:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO7"); 			
	
	GREEN:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODg");	(*actually blue atm*)
	grass:=Base.VoxelFromName("NJOFc7qhMXMly3lot71bNUw"); 	
	cloud:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODh"); 		
	
  	push(dotz);
	push(btx);
	push(GREEN);
	push(grass);	
	conglomerate.copyonstroke:=TRUE;
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

	push(sand);
	blacksun:=Base.VoxelFromName("Nbluedot"); 	
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
	rat:=Base.VoxelFromName("NGJBlQ95mTkoMhozr6XOJYg"); 	
	push(rat);
	conglo2:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZOq"); 	
	push(conglo2);
	sky1:=Base.VoxelFromName("N5a2g4M6HYjPJxYSNQvYy7"); 	
	push(sky1);
	sky2:=Base.VoxelFromName("NXWCxXWLIcD2LegvoGXXBiQ"); 	
	push(sky2);
	bottle1:=Base.VoxelFromName("Nbottle1");  
	push(bottle1);
	bottle2:=Base.VoxelFromName("Nbottle2");  
	push(bottle2);

	bottlepossum:=Base.VoxelFromName("Njellywish");  
	push(bottlepossum);	
	bottlegrounds:=Base.VoxelFromName("Nbottlegrounds");  

	wstar:=Base.VoxelFromName("Nwstar");  
	starspider:=Base.VoxelFromName("Nstarspider");  
	arevclock:=Base.VoxelFromName("Narevclock");  
	push(arevclock);
	jordan:=Base.VoxelFromName("Njbp");  	

	gxy:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU667"); 	
	push(gxy);
	bottle3:=Base.VoxelFromName("Nbottle3");  
	push(bottle3);
	sand:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw"); 	
	push(sand);	
	greensuncouple:=Base.VoxelFromName("Ngreensuncouple");  
	push(greensuncouple);
*)
		NEW(noise[0]);		
	noise[0].seed:=435678;		
	noise[0].a:=1;
	noise[0].b:=1;
	noise[0].c:=1;		
	noise[0].octaves:=5;
	noise[0].persistence:=3.41;	
	starspider:=Base.VoxelFromName("Nstarspider");
  	noise[0].setvoxel(starspider);		
	NEW(noise[1]);		
	noise[1].seed:=567483;		
	noise[1].a:=1;
	noise[1].b:=1;
	noise[1].c:=1;		
	noise[1].octaves:=4;
	noise[1].persistence:=3.81;	
	noise[1].setcolor(0.8,2.8,4,1/2,0);	
	wstar:=Base.VoxelFromName("Nwstar"); 
	push(wstar);
	noise[1].setvoxel(wstar);	
	NEW(noise[2]);	
	noise[2].seed:=900909;		
	noise[2].a:=7.5;
	noise[2].b:=7.5;
	noise[2].c:=3.5;		
	noise[2].octaves:=4;
	noise[2].persistence:=3.61;	
	noise[2].setvoxel(wstar);	
	NEW(noise[3]);		
	noise[3].seed:=8866688;		
	noise[3].a:=1;
	noise[3].b:=1;
	noise[3].c:=1;		
	noise[3].octaves:=3;
	noise[3].persistence:=3.91;	
	gxy:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU667"); 	
	push(gxy);
	noise[3].setvoxel(gxy);	
	NEW(noise[4]);		
	noise[4].seed:=123456;		
	noise[4].a:=1;
	noise[4].b:=1;
	noise[4].c:=1;		
	noise[4].octaves:=4;
	noise[4].persistence:=3.71;	
	noise[4].setvoxel(gxy);		

	Out.String("EEEEP!");
	Base.setPT(up,0,0,1);
	Base.setPT(center,1/2,1/2,9/10);
	Base.setPT(up,0,0,1);
	
	z3:=Base.VoxelFromName("NM20");

	z3a:=Base.VoxelFromName("NM3");
	z3b:=Base.VoxelFromName("NM3");

	dieone:=Base.VoxelFromName("NCjgzkmiTyecI5x6eOgYqpQ"); 	
  	push(dieone);
  	dieone.tscale:=100;
  			
	Base.setPT(center,1/2,1/2,1/2);

	GREEN:=Base.VoxelFromName("Nwaterdrops");	
	push(GREEN);
	serp:=Base.VoxelFromName("NXWCxXWLIcD2LegvoGXX999"); 
	push(serp);	

	NEW(medley); 
	NEW(med1);
	medley.setcolor(0,0,0,0.1,0.1,0.1);
	NEW(sqube,center,0.1,3,3,3,1,0.5,2);
	sqube.setcolor(0.99,0.31,0.991,1,0);
	sqube.setsidecolor(0,0.5,0.5,1,0);	
	medley.FRaster(sqube,20);
	NEW(ball,center,0.45);	
	ball.setcolor(0.1,0.831,0.1,1,0);
	ball.setsidecolor(0.15,0.09,0.1,1,0.5);		
	med1.FRaster(ball,20);		



	medley.fillwithprobability(med1,0.3);		

	
	noise[1].setvoxel(serp); 
	noise[3].setvoxel(dieone);	
		
	z3.FRaster(noise[1],27);	
	
	Base.setPT(center,1/2,1/2,2/3);	
	NEW(plane,center,up);
	plane.setvoxel(Base.EMPTY);			
	z3.FRaster(plane,1);	

	harrison:=Base.VoxelFromName("Nharrisonavatar"); 
	push(harrison);	
	Base.avatar:=harrison;

		
	Base.avatarsize:=216; 	
	
	med1.copyonstroke:=TRUE;		
	medley.copyonstroke:=TRUE;
	
	Base.world:=z3;
	alternateworld:=z3;	

	Out.String('end of Marsh.dawn')
END dawn;

PROCEDURE darken*;
BEGIN
	atmdark:= atmdark*1.5;
	Base.world.setcolor(0,0,0,atmdark,atmdark,atmdark);	
END darken;

PROCEDURE lighten*;
BEGIN
	IF atmdark>0.11 THEN atmdark:= atmdark/1.5 END;
	Base.world.setcolor(0,0,0,atmdark,atmdark,atmdark);	
END lighten

BEGIN
	NEW(marshv);
	marshv.vox:= Base.EMPTY;
	push(Base.EMPTY);
	dawn; 
	cursorsize:=4000;
	cursorTF:=TRUE;
	atmdark:=0;
	SNIPEINTO:=TRUE;
END Marsh.

XNXL.ourfounder.png

