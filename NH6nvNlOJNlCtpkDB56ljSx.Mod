MODULE NH6nvNlOJNlCtpkDB56ljSx;
IMPORT Base, TexVox, NM3; 
TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
TYPE TransparaVox*=OBJECT(Voxel);

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
	kitty : Base.Voxel;
	red,blue,green,purple: TransparaVox;
	s0,s1,s2,s3: NM3.cell;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	kitty:=Base.VoxelFromName("NH6nvNlOJNlCtpkDB56ljSw");
	NEW(s3);
	NEW(s2);
	NEW(s1);
	NEW(s0);
	NEW(red);
	NEW(blue);	
	NEW(green);
	NEW(purple);
	s3.copyonstroke:=TRUE;
	s2.copyonstroke:=TRUE;
	s1.copyonstroke:=TRUE;
	s1.copyonstroke:=TRUE;	
	red.copyonstroke:=TRUE;
	red.setcolor(1/3,0,0,1/2,1/2,1/2);
	blue.setcolor(1/3,0,0,1/2,1/2,1/2);
	green.setcolor(0,1/3,0,1/2,1/2,1/2);	
	purple.setcolor(1/3,0,1/3,12,1/2,1/2);	
	s3.fillsierp(kitty,red);
	s2.fillsierp(s3,blue);
	s1.fillsierp(s2,green);
	s0.fillsierp(s1,purple);
	RETURN s0
END thisvox;

 END NH6nvNlOJNlCtpkDB56ljSx. 