MODULE NXWCxXWLIcD2LegvoGXX999;

IMPORT Base, NM3, Nrdvolvox, Voxel4, RotaVox;
TYPE PT = Base.PT;
	Ray = Base.Ray;
	Voxel = Base.Voxel;  
	
TYPE TransparaVox*=OBJECT(Base.Voxel)

PROCEDURE&new;
BEGIN
	setcolor(1/13,1/13,1/4,1/3,1/3,1/4);
	passable:=TRUE;
END new;

PROCEDURE Shade (VAR ray: Ray);
VAR 
	depth: REAL;
	exit:PT;
	dr,dg,db,dbl: REAL;
BEGIN
	exit:=Base.Exit(ray);
	depth:=Base.dist(ray.lxyz,exit);
	ray.clr.r := ray.clr.r+red*depth;
	ray.clr.g:= ray.clr.g+green*depth;
	ray.clr.b := ray.clr.b+blue*depth;
	ray.clr.ra := ray.clr.ra-redblack*depth;
	ray.clr.ga := ray.clr.ga-greenblack*depth;
	ray.clr.ba := ray.clr.ba-blueblack*depth;
END Shade;

END TransparaVox;  

VAR 
	subserp: Voxel;
	sky: Voxel;
	uk,echan,nark, xot, dblue, empty: Voxel;
	darkblue:TransparaVox;
	s0,s1,s2,s3,s4: NM3.cell;
	rd: Nrdvolvox.RDVolVox; 
	fuzz: Voxel4.FuzzVox;
	mirrorball: Voxel4.MirrorSphereInVox;
	p,q: Base.PT;
	sball: RotaVox.RVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN s3
END thisvox;

BEGIN
	sky:=Base.VoxelFromName("NM3");  	
	nark:=Base.VoxelFromName("Narchillect"); 
	xot:=Base.VoxelFromName("Nearthchan"); 
	echan:=Base.VoxelFromName("Nearthchan");  	
	uk:=Base.VoxelFromName("Nugandaknuckles");  	
	NEW(s0);
	NEW(s1);
	NEW(s2);
	NEW(s3);
	NEW(darkblue);
	NEW(fuzz);
	NEW(mirrorball);
	NEW(empty);
	darkblue.setcolor(1,1,1,1,1,1);
	dblue := Base.VoxelFromName("NM3");  
	dblue.setcolor(13,13,13,13,13,13);

(*	NEW(sball, s0, Base.randPT(),Base.randPT(),1,1);
	NEW(rd,empty,nark,empty);	
	rd.register;
	rd.passable:=TRUE;
*)	s0.fillsierp(echan,uk);
	s1.fillsierp(s0,nark);	
	s2.fillsierp(s1,NIL);
	s3.fillsierp(s2,NIL);
	s0.passable:=FALSE;	
	s1.passable:=FALSE;	
	s2.passable:=FALSE;	
	s3.passable:=FALSE;			
	s3.setcolor(0,0,0,1/4,1/2,1/4);	
	s2.setcolor(0,0,0,1/14,1/14,1/2);	
	s1.setcolor(0,1/2,0,1/4,1/4,1/14);	
	s0.setcolor(0,1/2,0,1/4,1/14,1/4);	
	s0.imposter:=echan;
	s1.imposter:=echan;	
	s2.imposter:=echan;
	s3.imposter:=echan;		
	s0.copyonstroke:=TRUE;	
	s1.copyonstroke:=TRUE;	
	s2.copyonstroke:=TRUE;	
	s3.copyonstroke:=TRUE;
	dblue.copyonstroke:=TRUE;
END NXWCxXWLIcD2LegvoGXX999. 
 
Marsh.Rez NXWCxXWLIcD2LegvoGXX999
 
N5a2g4M6HYjPJxYSNQvYy7.Mod