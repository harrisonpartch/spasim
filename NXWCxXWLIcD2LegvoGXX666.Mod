MODULE NXWCxXWLIcD2LegvoGXX666;

IMPORT Base, NM3;
TYPE PT = Base.PT;
	Ray = Base.Ray;
	Voxel = Base.Voxel;  
	
TYPE TransparaVox*=OBJECT(Base.Voxel);
VAR
	r, g, b, black: REAL;	
PROCEDURE setcolor* (red, green, blue, rbl,gbl, bbl : REAL); 
BEGIN
	r := red;
	g := green;
	b := blue;
	black:=bbl;
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
	sky: Voxel;
	nark, xot: Voxel;
	darkblue, alphablue: TransparaVox;
	s0,s1,s2,s3,s4: NM3.cell;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN s1
END thisvox;

BEGIN
	sky:=Base.VoxelFromName("N5a2g4M6HYjPJxYSNQvYy7");  	
	nark:=Base.VoxelFromName("Narchillect"); 
	xot:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU666"); 
	NEW(s0);
	NEW(s1);
	NEW(alphablue);
	alphablue.setcolor(0,0,0.46,0.56,1,1);
	s0.passable:=TRUE;
	s1.passable:=TRUE;		
	s0.fillsierp(nark,NIL);
	s1.fillsierp(s0,NIL);
	s0.lock();
	s1.lock();	
END NXWCxXWLIcD2LegvoGXX666. 
 
 Marsh.Rez NXWCxXWLIcD2LegvoGXX666
 
N5a2g4M6HYjPJxYSNQvYy7.Mod