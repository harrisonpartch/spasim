MODULE NXWCxXWLIcD2LegvoGXXBiQ;

IMPORT Base, NM3;
TYPE PT = Base.PT;
	Ray = Base.Ray;
	Voxel = Base.Voxel;  
	
TYPE TransparaVox*=OBJECT(Base.Voxel);
VAR
	r, g, b, black: REAL;	
PROCEDURE setcolor* (red, green, blue,bl , a : REAL); 
BEGIN
	r := red;
	g := green;
	b := blue;
	black:=bl;
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
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db; 
	ray.ra := (ray.ra - dr);
	ray.ga := (ray.ga - dg);
	ray.ba := (ray.ba - db); 
	ray.bla:=ray.bla-dbl;
	IF (ray.bla<0.1) THEN ray.terminate:=TRUE END;
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
	badopossum:=Base.VoxelFromName("Nbadopossum"); 
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
	alphablue.setcolor(0,0,1,1,1);

	s0.fillsierp(alphablue,s0);	
	s0.imposter:=badopossum;
	s0.copyonstroke:=TRUE;
	s0.DTL:=10;
	
	s1.fillsierp(s2,blue);	
	s1.imposter:=blue;
	s1.copyonstroke:=TRUE;
	s1.DTL:=60;

	s2.fillsierp(s2,reddot);	
	s2.imposter:=blue;
	s2.DTL:=60;
	s2.lockTF:=TRUE;
	
	RETURN s0
END thisvox;
 END NXWCxXWLIcD2LegvoGXXBiQ. 
 
 Marsh.Rez NXWCxXWLIcD2LegvoGXXBiQ