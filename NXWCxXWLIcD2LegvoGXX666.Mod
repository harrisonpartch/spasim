MODULE NXWCxXWLIcD2LegvoGXX666;

IMPORT Base, NM3;
TYPE PT = Base.PT;
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
	dbl:=black*depth;
	dr := r*depth*ray.clr.ra;
	dg := g*depth*ray.clr.ga;
	db := b*depth*ray.clr.ba;
	ray.clr.r := ray.clr.r + dr;
	ray.clr.g := ray.clr.g + dg;
	ray.clr.b := ray.clr.b + db; 
	ray.clr.ra := (ray.clr.ra - (dr + dbl));
	ray.clr.ga := (ray.clr.ga - (dg + dbl));
	ray.clr.ba := (ray.clr.ba - (db + dbl)); 	
	ray.clr.alpha:=ray.clr.alpha-dbl-(dr+dg+db)/3;
	IF ray.clr.alpha<0.1 THEN ray.terminate:=TRUE END;	
END Shade;

END TransparaVox;  

VAR 
	subserp: Voxel;
	green: Voxel;
	xot: Voxel;
	alphablue: TransparaVox;
	s0,s1,s2,s3,s4: NM3.cell;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN s4
END thisvox;

BEGIN
	green:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw");  	
	xot:=Base.VoxelFromName("Narchillect"); 
	NEW(s0);
	NEW(s1);
	NEW(s2);
	NEW(s3);
	NEW(s4);	
	NEW(alphablue);
	alphablue.setcolor(0,0,1,1,1);
	s0.passable:=FALSE;
	s1.passable:=TRUE;	
	s2.passable:=TRUE;	
	s3.passable:=TRUE;	
	s4.passable:=TRUE;	
	s0.fillsierp(green,alphablue);
	s1.fillsierp(s0,alphablue);	
	s2.fillsierp(s1,alphablue);
	s3.fillsierp(s2,alphablue);	
	s4.fillsierp(s3,alphablue);
	s0.imposter:=green;	
	s0.copyonstroke:=TRUE;
	s1.copyonstroke:=TRUE;	
	s2.copyonstroke:=TRUE;	
	s3.copyonstroke:=TRUE;
	s4.copyonstroke:=TRUE;
END NXWCxXWLIcD2LegvoGXX666. 
 
 Marsh.Rez NXWCxXWLIcD2LegvoGXX666