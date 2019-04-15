MODULE NIXARXB2vH6ieKZmsc6mODh;
IMPORT Base, TexVox;
  
TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Voxel = Base.Voxel;  
TYPE TransparaVox*=OBJECT(Base.Voxel);
PROCEDURE setcolor* (r, g, b, rbl, gbl, bbl : REAL); 
BEGIN
	red := r;
	green := g;
	blue := b;
	redblack := rbl;
	greenblack := gbl;
	blueblack := bbl;
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
	depth:=1;
	dr := red*depth*ray.clr.ra;
	dg := green*depth*ray.clr.ga;
	db := blue*depth*ray.clr.ba;
	ray.clr.r := ray.clr.r + dr;
	ray.clr.g := ray.clr.g + dg;
	ray.clr.b := ray.clr.b + db; 
	ray.clr.ra := ray.clr.ra - redblack*depth;
	ray.clr.ga := ray.clr.ga - greenblack*depth;
	ray.clr.ba := ray.clr.ba - blueblack*depth;
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
vox.setcolor(0,50, 0,100,100,100);
END NIXARXB2vH6ieKZmsc6mODh. 