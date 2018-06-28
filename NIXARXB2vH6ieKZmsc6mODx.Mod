MODULE NIXARXB2vH6ieKZmsc6mODx;
IMPORT Base;
  
TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Voxel = Base.Voxel;  
TYPE TransparaVox*=OBJECT(Base.Voxel);
VAR
	r, g, b, black: REAL;	
PROCEDURE setcolor* (red, green, blue,bl,a  : REAL); 
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
	depth:=Base.dist(ray.lxyz,exit)/ray.scale;
	dr := r*depth;
	dg := g*depth;
	db := b*depth;
	dbl:=black*depth;
	ray.clr.r := ray.clr.r + dr;
	ray.clr.g := ray.clr.g + dg;
	ray.clr.b := ray.clr.b + db; 
	ray.clr.ra := (ray.clr.ra - dr)-dbl;
	ray.clr.ga := (ray.clr.ga - dg)-dbl;
	ray.clr.ba := (ray.clr.ba - db)-dbl; 
	IF (ray.clr.ra<0.1)&(ray.clr.ga<0.1)&(ray.clr.ba<0.1) THEN ray.terminate:=TRUE END;
END Shade;

END TransparaVox;  
  
VAR vox:TransparaVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
NEW(vox); 
vox.setcolor(0,100,0,500,0);
END NIXARXB2vH6ieKZmsc6mODx. 

XNXLMarsh.Rez  NIXARXB2vH6ieKZmsc6mODx