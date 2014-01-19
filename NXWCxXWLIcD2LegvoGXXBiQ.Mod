MODULE NXWCxXWLIcD2LegvoGXXBiQ;

IMPORT Base;
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
	dr := r*depth;
	dg := g*depth;
	db := b*depth;
	dbl:=black*depth;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db; 
	ray.ra := (ray.ra - dr);
	ray.ga := (ray.ga - dg);
	ray.ba := (ray.ba - db); 
	ray.bla:=ray.bla-dbl;
	IF (ray.bla<0.1) THEN ray.terminate:=TRUE END;
END Shade;

END TransparaVox;  

VAR 
	serp, subserp, beatrix,lobster,sparx: Voxel;
	greenball: Voxel;
	v: Voxel;
	blue: Voxel;
	alphablue: TransparaVox

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	beatrix:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw"); 
	lobster:=Base.VoxelFromName("N5a2g4M6HYjPJxYSNQvYyv7"); 
	greenball:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ"); 	
	blue:=Base.VoxelFromName("N5a2g4M6HYjPJxYSNQvYy7"); 
	subserp:=Base.VoxelFromName("NM3"); 	
	serp:=Base.VoxelFromName("NM3"); 	
	NEW(alphablue);
	alphablue.setcolor(1/4,0,0,1/4,0);

	subserp.DTL:=90;
(*	subserp.imposter:=greenball;		*)

	serp.DTL:=60;	

	subserp.fill(blue);

	subserp.stroke(Base.mkPT(1/2,1/2,1/4),1,subserp,v);
	subserp.stroke(Base.mkPT(1/2,1/2,3/4),1,subserp,v);
	subserp.stroke(Base.mkPT(1/4,1/2,1/2),1,subserp,v);
	subserp.stroke(Base.mkPT(3/4,1/2,1/2),1,subserp,v);
	subserp.stroke(Base.mkPT(1/2,1/4,1/2),1,subserp,v);
	subserp.stroke(Base.mkPT(1/2,3/4,1/2),1,subserp,v);
	subserp.stroke(Base.mkPT(1/2,1/2,1/2),1,beatrix,v);		
(*	subserp.stroke(Base.mkPT(0,0,0),1,beatrix,v);		
	subserp.stroke(Base.mkPT(1,0,0),1,greenball,v);		
	subserp.stroke(Base.mkPT(0,0,1),1,beatrix,v);		
	subserp.stroke(Base.mkPT(0,1,1),1,greenball,v);	
	subserp.stroke(Base.mkPT(1,1,0),1,beatrix,v);		
	subserp.stroke(Base.mkPT(0,1,0),1,greenball,v);		
	subserp.stroke(Base.mkPT(1,0,1),1,beatrix,v);		
	subserp.stroke(Base.mkPT(1,1,1),1,greenball,v);	
*)	serp.fill(serp);	
	serp.imposter:=blue;
	serp.stroke(Base.mkPT(1/2,1/2,1/2),1,alphablue,v);
	serp.stroke(Base.mkPT(1/2,0,1),1,alphablue,v);
	serp.stroke(Base.mkPT(1/2,1,0),1,alphablue,v);
	serp.stroke(Base.mkPT(0,0,1/2),1,alphablue,v);	
	serp.stroke(Base.mkPT(0,1,1/2),1,alphablue,v);
	serp.stroke(Base.mkPT(1,0,1/2),1,alphablue,v);	
	serp.stroke(Base.mkPT(1,1,1/2),1,alphablue,v);
	subserp.copyonstroke:=TRUE;	
	serp.copyonstroke:=TRUE;	
	lobster.copyonstroke:=TRUE;
	serp.probelock:=FALSE;
	RETURN serp
END thisvox;
 END NXWCxXWLIcD2LegvoGXXBiQ. 
 
 Marsh.Rez NXWCxXWLIcD2LegvoGXXBiQ