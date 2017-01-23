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
	bpossum:=Base.VoxelFromName("Nbadopossum"); 
	greenball:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ"); 	
	red:=Base.VoxelFromName("Ndiffusered"); 
	reddot:=Base.VoxelFromName("Nreddot"); 
	gmdot:=Base.VoxelFromName("Nr3kPtbyEYLFK3AN2UUVrqg"); 	
	NEW(s0);
	NEW(s1);
	NEW(s2);
	s2.setcolor(0,0,0,1/3,1/3);
	NEW(alphablue);
	alphablue.setcolor(0,0,1,1/12,1/15);

	s0.fillsierp(s0,red);	
	s0.imposter:=reddot;
	s0.copyonstroke:=TRUE;



	RETURN s0
END thisvox;
 END NXWCxXWLIcD2LegvoGXX666. 
 
 Marsh.Rez NXWCxXWLIcD2LegvoGXX666