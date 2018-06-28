MODULE NH6nvNlOJNlCtpkDB56ljSx;
IMPORT Base, TexVox, NM3; 
TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
TYPE TransparaVox*=OBJECT(Voxel);
VAR
	r, g, b, black: REAL;	
PROCEDURE setcolor* (red, green, blue,bl, alpha  : REAL); 
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
	depth:=Base.distsquared(ray.lxyz,exit);
	dr := r*depth;
	dg := g*depth;
	db := b*depth;
	dbl:=black*depth;
	ray.clr.r := ray.clr.r + dr;
	ray.clr.g := ray.clr.g + dg;
	ray.clr.b := ray.clr.b + db; 
	ray.clr.ra := ray.clr.ra -dbl;
	ray.clr.ga := ray.clr.ga -dbl;
	ray.clr.ba := ray.clr.ba -dbl; 
	IF (ray.clr.ra<0.1)&(ray.clr.ga<0.1)&(ray.clr.ba<0.1) THEN ray.terminate:=TRUE END;
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
	red.setcolor(1/3,0,0,1/2,0);
	blue.setcolor(1/3,0,0,1/2,0);
	green.setcolor(0,1/3,0,1/2,0);	
	purple.setcolor(1/3,0,1/3,12,0);	
	s3.fillsierp(kitty,red);
	s2.fillsierp(s3,blue);
	s1.fillsierp(s2,green);
	s0.fillsierp(s1,purple);
	RETURN s0
END thisvox;

 END NH6nvNlOJNlCtpkDB56ljSx. 