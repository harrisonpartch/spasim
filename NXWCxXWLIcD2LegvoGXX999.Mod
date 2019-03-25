MODULE NXWCxXWLIcD2LegvoGXX999;

IMPORT Base, NM3, Nrdvolvox, Voxel4;
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
	IF ray.clr.alpha<0.3 THEN ray.terminate:=TRUE END;	
END Shade;

END TransparaVox;  

VAR 
	subserp: Voxel;
	sky: Voxel;
	nark, xot, dblue, empty: Voxel;
	darkblue:TransparaVox;
	s0,s1,s2,s3,s4: NM3.cell;
	rd: Nrdvolvox.RDVolVox; 
	fuzz: Voxel4.FuzzVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN s3
END thisvox;

BEGIN
	sky:=Base.VoxelFromName("NM3");  	
	nark:=Base.VoxelFromName("Narchillect"); 
	xot:=Base.VoxelFromName("Nbrownianspheres"); 
	NEW(s0);
	NEW(s1);
	NEW(s2);
	NEW(s3);
	NEW(darkblue);
	NEW(fuzz);
	NEW(empty);
	darkblue.setcolor(0.6,0,0,1,1,1);
	dblue := Base.VoxelFromName("NM3");  
	dblue.setcolor(13,13,13,13,13,13);
	s0.passable:=TRUE;
	s1.passable:=TRUE;	
	s2.passable:=TRUE;	
	s3.passable:=TRUE;	
	s0.setcolor(100,100,0,130,130,130);
	s1.setcolor(0,30,0,40,40,40);
	s2.setcolor(0,0,100,130,130,130);
	s3.setcolor(0,0,0,10,10,10);
	NEW(rd,darkblue,empty,empty);	
	rd.register;
	rd.passable:=TRUE;
	s0.fillsierp(nark,rd);
	s1.fillsierp(s0,NIL);	
	s2.fillsierp(s1,NIL);
	s3.fillsierp(s2,NIL);	
	s0.imposter:=nark;
	s1.imposter:=nark;	
	s2.imposter:=nark;
	s3.imposter:=nark;		
	s0.copyonstroke:=TRUE;
	s1.copyonstroke:=TRUE;	
	s2.copyonstroke:=TRUE;	
	s3.copyonstroke:=TRUE;
	dblue.copyonstroke:=TRUE;
END NXWCxXWLIcD2LegvoGXX999. 
 
Marsh.Rez NXWCxXWLIcD2LegvoGXX999
 
N5a2g4M6HYjPJxYSNQvYy7.Mod