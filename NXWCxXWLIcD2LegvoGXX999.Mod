MODULE NXWCxXWLIcD2LegvoGXX999;

IMPORT Base, NM3, Voxel4, RotaVox (*, CamTexVox *);
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

TYPE DiffuseVox* = OBJECT(Base.Voxel);

PROCEDURE Shade*(VAR ray: Ray);
VAR
	nx, ny, nz: INTEGER;
	dot: REAL;
	inside: BOOLEAN;
BEGIN
	CASE ray.face OF
		0: inside := TRUE
		|1: nx := 1
		|2: ny := 1
		|3: nz := 1
		|4: nx := -1
		|5: ny := -1
		|6: nz := -1
	END;
	dot := ABS(nx*ray.dxyz.x + ny*ray.dxyz.y+ nz*ray.dxyz.z);
	ray.clr.r := ray.clr.r + red * ray.clr.ra*dot ;
	ray.clr.g := ray.clr.g + green * ray.clr.ga*dot;
	ray.clr.b := ray.clr.b + blue * ray.clr.ba*dot;
	ray.terminate:=TRUE;
END Shade;

END DiffuseVox;

VAR 
	subserp: Voxel;
	sky: Voxel;
	uk, echan, nark, nepal, xot, dblue, empty: Voxel;
	darkblue:TransparaVox;
	gray: DiffuseVox;
	s0,s1,s2,s3: NM3.cell;
	fuzz: Voxel4.FuzzVox;
	mirrorball: Voxel4.MirrorSphereInVox;
	p,q: Base.PT;
	sball: RotaVox.RVox;
(*	camvox: CamTexVox.CamVox;*)
	i: INTEGER;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN s0
END thisvox;

BEGIN
	sky:=Base.VoxelFromName("NM3");  
	nepal:=Base.VoxelFromName("Nlachlan"); 	
	nark:=Base.VoxelFromName("Narchillect"); 
	echan:=Base.VoxelFromName("Nearthchan"); 
	xot:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU341");  	
	uk:=Base.VoxelFromName("Nugandaknuckles"); 
(*	NEW(camvox); 	*)
	NEW(s0);
	NEW(s1);
	NEW(s2);
	NEW(s3);
	NEW(darkblue);
	NEW(fuzz);
	NEW(mirrorball);
	NEW(empty);
	NEW(gray);
	gray.setcolor(0.7, 0.7, 0.7, 1, 1, 1);
	darkblue.setcolor(1/3, 1/2, 0, 1, 1, 1);
	darkblue.passable:=TRUE;
	dblue:=Base.VoxelFromName("NM3");  
	nark.tscale:=100;

	NEW(sball, s0, Base.randPT(),Base.randPT(),1,1);
(*	NEW(rd,empty,nark,empty);	
	rd.register;
	rd.passable:=TRUE;
	
	FOR i:=0 TO 5 DO
		s0.stroke(Base.randPT(),9,sball)
	END;
*)s0.blox[1,1,1]:=s1;
	s1.fillsierp(s3,uk);	
	s2.fillsierp(s1,NIL);
	s3.fillsierp(s2,s1);	
	s3.setcolor(0,1/7,0,1/6,1/6,1/6);	
	s2.setcolor(0, 0, 2/7,1/3,1/3,1/3);	
	s1.setcolor(2/13, 2/13, 0,1/3,1/3,1/3);			
	s0.setcolor(0, 1/6, 1/9, 1/5,1/5,1/5);	
	s0.imposter:=gray;
	s1.imposter:=gray;
	s2.imposter:=gray;
	s3.imposter:=gray;
	s0.passable:=TRUE;	
	s0.copyonstroke:=TRUE;	
	s1.copyonstroke:=TRUE;	
	s2.copyonstroke:=TRUE;	
	s3.copyonstroke:=TRUE;
END NXWCxXWLIcD2LegvoGXX999. 
 
Marsh.Rez NXWCxXWLIcD2LegvoGXX999
 
N5a2g4M6HYjPJxYSNQvYy7.Mod