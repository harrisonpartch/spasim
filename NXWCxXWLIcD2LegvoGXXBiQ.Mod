MODULE NXWCxXWLIcD2LegvoGXXBiQ;

IMPORT Base, NM3;
TYPE PT = Base.PT;
	Ray = Base.Ray;
	Voxel = Base.Voxel;  
	
TYPE TransparaVox*=OBJECT(Base.Voxel);
VAR
	r, g, b, black: REAL;	
PROCEDURE setcolor* (red, green, blue,rbl, gbl, bbl: REAL); 
BEGIN
	r := red;
	g := green;
	b := blue;
	black:=bbl;
	passable := TRUE;
END setcolor;

PROCEDURE Shade (VAR ray: Ray);
VAR 
	depth: REAL;
	exit:PT;
	dr,dg,db,dbl: REAL;
BEGIN
	exit:=Base.Exit(ray);
	depth:=Base.dist(ray.lxyz,exit);
	dr := r*depth;
	dg := g*depth;
	db := b*depth;
	dbl:=black*depth;
	ray.clr.r := ray.clr.r + dr;
	ray.clr.g := ray.clr.g + dg;
	ray.clr.b := ray.clr.b + db; 
	ray.clr.ra := (ray.clr.ra - dr);
	ray.clr.ga := (ray.clr.ga - dg);
	ray.clr.ba := (ray.clr.ba - db); 
	ray.clr.alpha:=ray.clr.alpha-dbl;
	IF (ray.clr.alpha<0.1) THEN ray.terminate:=TRUE END;
END Shade;

END TransparaVox;  

VAR 
	subserp, badopossum, tree: Voxel;
	greenball: Voxel;
	v: Voxel;
	blue,red,reddot: Voxel;
	alphablue: TransparaVox;
	s0,s1,s2,s3,s4: NM3.cell;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	badopossum:=Base.VoxelFromName("Ngreensuncouple"); 
	greenball:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ"); 	
	blue:=Base.VoxelFromName("Ndiffuseblue"); 
	red:=Base.VoxelFromName("Ndiffusered"); 	
	reddot:=Base.VoxelFromName("Ndiffusereddot"); 
	blue.passable:=FALSE;
	subserp:=Base.VoxelFromName("NM3"); 	
	tree:=Base.VoxelFromName("NXWCxXWLIcD2LegvoGXX666"); 	
	NEW(s0);
	NEW(s1);
	NEW(s2);
	NEW(s3);
	NEW(s4);	
	NEW(alphablue);
	alphablue.setcolor(0,0,1/2,2/3,1,2/3);

	s0.fillsierp(s1,alphablue);	
	s0.imposter:=badopossum;
	s0.copyonstroke:=TRUE;
	s0.DTL:=60;
	
	s1.fillsierp(red,s2);	
	s1.imposter:=blue;
	s1.copyonstroke:=TRUE;
	s1.DTL:=60;

	s2.fillsierp(blue,s3);	
	s2.imposter:=blue;
	s2.copyonstroke:=TRUE;
	s2.DTL:=60;

	s3.fillsierp(red,s4);	
	s3.imposter:=red;
	s3.copyonstroke:=TRUE;
	s3.DTL:=60;
	
	s4.fillsierp(blue,red);	
	s4.imposter:=blue;
	s4.copyonstroke:=TRUE;
	s4.DTL:=60;
	
	
	RETURN s0
END thisvox;
 END NXWCxXWLIcD2LegvoGXXBiQ. 
 
 Marsh.Rez NXWCxXWLIcD2LegvoGXXBiQ