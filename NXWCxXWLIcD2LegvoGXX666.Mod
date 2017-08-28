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
	dr := r*depth*ray.clr.ra;
	dg := g*depth*ray.clr.ga;
	db := b*depth*ray.clr.ba;
	dbl:=black*depth;
	ray.clr.r := ray.clr.r + dr;
	ray.clr.g := ray.clr.g + dg;
	ray.clr.b := ray.clr.b + db; 
	ray.clr.ra := (ray.clr.ra - dr);
	ray.clr.ga := (ray.clr.ga - dg);
	ray.clr.ba := (ray.clr.ba - db); 
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
	bpossum:=Base.VoxelFromName("Ngreensuncouple"); 
	greenball:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ"); 	
	red:=Base.VoxelFromName("Ndiffusered"); 
	reddot:=Base.VoxelFromName("Nreddot"); 
	gmdot:=Base.VoxelFromName("Nr3kPtbyEYLFK3AN2UUVrqg"); 	
	NEW(s0);
	NEW(s1);
	NEW(s2);
	NEW(alphablue);
	alphablue.setcolor(1/2,0,0,1/2,1/2);
	s2.setcolor(1,0,0,1/3,1/3);
	s2.fill(s0);
	s0.passable:=FALSE;
	s2.passable:=FALSE;	
	s0.fillsierp(s0,alphablue);
	s0.imposter:=bpossum;	
	s0.copyonstroke:=TRUE;

	RETURN s0
END thisvox;
 END NXWCxXWLIcD2LegvoGXX666. 
 
 Marsh.Rez NXWCxXWLIcD2LegvoGXX666