MODULE NIXARXB2vH6ieKZmsc6mODg;
IMPORT Base, TexVox;
  
TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Voxel = Base.Voxel;  
TYPE TransparaVox*=OBJECT(Base.Voxel);

PROCEDURE Shade (VAR ray: Ray);
VAR 
	depth: REAL;
	exit:PT;
	dr,dg,db,dbl: REAL;
BEGIN
	exit:=Base.Exit(ray);
	depth:=Base.dist(ray.lxyz,exit);
	dbl:=black*depth;
	dr := red*depth*ray.clr.ra;
	dg := green*depth*ray.clr.ga;
	db := blue*depth*ray.clr.ba;
	ray.clr.r := ray.clr.r + dr;
	ray.clr.g := ray.clr.g + dg;
	ray.clr.b := ray.clr.b + db; 
	ray.clr.ra := (ray.clr.ra - (dr + dbl));
	ray.clr.ga := (ray.clr.ga - (dg + dbl));
	ray.clr.ba := (ray.clr.ba - (db + dbl)); 	
	ray.clr.alpha:=ray.clr.ra+ray.clr.ga+ray.clr.ba;
	IF ray.clr.alpha<0.3 THEN ray.terminate:=TRUE END;	
END Shade;

END TransparaVox;  
  
VAR vox:TransparaVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
NEW(vox); 
vox.setcolor(0,0,5,1,1,1);
END NIXARXB2vH6ieKZmsc6mODg. 