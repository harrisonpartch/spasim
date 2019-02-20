MODULE NIXARXB2vH6ieKZmsc6mODh;
IMPORT Base, TexVox;
  
TYPE PT = Base.PT;
	Color = Base.Color;
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
	dr := r*depth*ray.clr.ra;
	dg := g*depth*ray.clr.ga;
	db := b*depth*ray.clr.ba;
	dbl:=1-black*depth;
	ray.clr.r := ray.clr.r + dr;
	ray.clr.g := ray.clr.g + dg;
	ray.clr.b := ray.clr.b + db; 
	ray.clr.ra := (ray.clr.ra - dr)-dbl;
	ray.clr.ga := (ray.clr.ga - dg)-dbl;
	ray.clr.ba := (ray.clr.ba - db)-dbl; 
	IF (ray.clr.ra<0.1) OR (ray.clr.ga<0.1) OR(ray.clr.ba<0.1) THEN ray.terminate:=TRUE END;
END Shade;

END TransparaVox;  
  
VAR vox:TransparaVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
NEW(vox); 
vox.setcolor(0, 1/3, 1/2, 1/7,1/2);
END NIXARXB2vH6ieKZmsc6mODh. 