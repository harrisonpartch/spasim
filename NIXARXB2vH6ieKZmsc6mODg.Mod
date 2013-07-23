MODULE NIXARXB2vH6ieKZmsc6mODg;
IMPORT XNXLBase, XNXLTexVox;
  
TYPE PT = XNXLBase.PT;
	Color = XNXLBase.Color;
	Ray = XNXLBase.Ray;
	Voxel = XNXLBase.Voxel;  
TYPE TransparaVox*=OBJECT(XNXLBase.Voxel);
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
	exit:=XNXLBase.Exit(ray);
	depth:=XNXLBase.dist(ray.lxyz,exit)/ray.scale;
	dr := r*depth;
	dg := g*depth;
	db := b*depth;
	dbl:=black*depth;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db; 
	ray.ra := (ray.ra - dr)-dbl;
	ray.ga := (ray.ga - dg)-dbl;
	ray.ba := (ray.ba - db)-dbl; 
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;
END Shade;

END TransparaVox;  
  
VAR vox:TransparaVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
NEW(vox); 
vox.setcolor(0,0,500,500,0);
END NIXARXB2vH6ieKZmsc6mODg. 