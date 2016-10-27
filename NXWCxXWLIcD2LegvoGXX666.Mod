MODULE NXWCxXWLIcD2LegvoGXX666;

IMPORT Base, NM3;
TYPE PT = Base.PT;
	Ray = Base.Ray;
	Voxel = Base.Voxel;  
	
TYPE TransparaVox*=OBJECT(Base.Voxel);
VAR
	r, g, b, black,alpha: REAL;	
PROCEDURE setcolor* (red, green, blue,bl , a : REAL); 
BEGIN
	r := red;
	g := green;
	b := blue;
	black:=bl;
	alpha:=a;
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
	dr := r*depth*ray.bla;
	dg := g*depth*ray.bla;
	db := b*depth*ray.bla;
	dbl:=black*depth;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db; 
	ray.ra := (ray.ra - dr);
	ray.ga := (ray.ga - dg);
	ray.ba := (ray.ba - db); 
	ray.bla:=ray.bla-dbl;
	ray.alpha:=ray.alpha-alpha;
	IF (ray.bla<0.1) OR (ray.alpha<0.1) THEN ray.terminate:=TRUE END;
END Shade;

END TransparaVox;  

VAR 
	subserp, raccoon,bpossum,sparx: Voxel;
	greenball: Voxel;
	v: Voxel;
	red,reddot,gmdot: Voxel;
	alphablue: TransparaVox;
	s0,s1,s2,s3,s4: NM3.cell;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	raccoon:=Base.VoxelFromName("Nraccoon"); 
	bpossum:=Base.VoxelFromName("Nbadopossum"); 
	greenball:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ"); 	
	red:=Base.VoxelFromName("Ndiffusered"); 
	reddot:=Base.VoxelFromName("Ndiffusereddot"); 
	gmdot:=Base.VoxelFromName("Nr3kPtbyEYLFK3AN2UUVrqg"); 	
	NEW(s0);
	NEW(s1);
	NEW(s2);
	s2.setcolor(0,0,0,1/3,1/3);
	NEW(alphablue);
	alphablue.setcolor(0,0,1/5,1/12,1/15);

	s0.fillsierp(s0,s1);	
	s0.imposter:=raccoon;
	s0.copyonstroke:=TRUE;
	s0.DTL:=5;
	
	s1.fillsierp(s1,alphablue);	
	s1.imposter:=red;
	s1.copyonstroke:=TRUE;
	s1.DTL:=5;
	s1.passable:=FALSE;

	s2.fillsierp(alphablue,s2);	
	s2.blox[1,1,1]:=gmdot;
	s2.imposter:=gmdot;
	s2.copyonstroke:=TRUE;

	RETURN s0
END thisvox;
 END NXWCxXWLIcD2LegvoGXX666. 
 
 Marsh.Rez NXWCxXWLIcD2LegvoGXX666