MODULE NXWCxXWLIcD2LegvoGXXBiQ;

IMPORT Base;
TYPE PT = Base.PT;
	Ray = Base.Ray;
	Voxel = Base.Voxel;  
	
TYPE AlphaVox* = OBJECT(Voxel);
VAR
	r, g, b : REAL;
PROCEDURE setcolor* (red, green, blue, black,alpha : REAL);
BEGIN
	r := red * alpha;
	g := green * alpha;
	b := blue * alpha;
END setcolor;
PROCEDURE Shade(VAR ray: Ray);
VAR 
	dr, dg, db: REAL;
BEGIN
	dr :=  r*ray.ra;
	dg :=  g*ray.ga;
	db :=  b*ray.ba;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;
	ray.ra := ray.ra - (dg+db)/2;
	ray.ga := ray.ga - (dr+db)/2;
	ray.ba := ray.ba - (dr+dg)/2;
	ray.bla := ray.bla -(dr+dg+db)/3;
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;
END Shade;

PROCEDURE deepcopy*():Voxel;
VAR	v:AlphaVox;
BEGIN
	NEW(v);
	v.setcolor(r,g,b,0,1);
	RETURN(v)
END deepcopy;
END AlphaVox; 

VAR 
	serp, subserp, beatrix,lobster,sparx: Voxel;
	greenball: Voxel;
	v: Voxel;
	blue: AlphaVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	beatrix:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw"); 
	lobster:=Base.VoxelFromName("NznGx2ySiHIGrO5t9Pzcw5Q"); 
	greenball:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ"); 	
	subserp:=Base.VoxelFromName("NM3"); 	
	serp:=Base.VoxelFromName("NM3"); 	
	NEW(blue);
	blue.setcolor(1/2,0,0,1/2,0);
	subserp.DTL:=300;
	subserp.imposter:=greenball;		

	serp.DTL:=300;	
	subserp.fill(subserp);
	subserp.stroke(Base.mkPT(1/2,1/2,1/4),1,subserp,v);
	subserp.stroke(Base.mkPT(1/2,1/2,3/4),1,subserp,v);
	subserp.stroke(Base.mkPT(1/4,1/2,1/2),1,subserp,v);
	subserp.stroke(Base.mkPT(3/4,1/2,1/2),1,subserp,v);
	subserp.stroke(Base.mkPT(1/2,1/4,1/2),1,subserp,v);
	subserp.stroke(Base.mkPT(1/2,3/4,1/2),1,subserp,v);
	subserp.stroke(Base.mkPT(1/2,1/2,1/2),1,beatrix,v);		
	subserp.stroke(Base.mkPT(0,0,0),1,beatrix,v);		
	subserp.stroke(Base.mkPT(1,0,0),1,greenball,v);		
	subserp.stroke(Base.mkPT(0,0,1),1,beatrix,v);		
	subserp.stroke(Base.mkPT(0,1,1),1,beatrix,v);	
	subserp.stroke(Base.mkPT(1,1,0),1,beatrix,v);		
	subserp.stroke(Base.mkPT(0,1,0),1,beatrix,v);		
	subserp.stroke(Base.mkPT(1,0,1),1,beatrix,v);		
	subserp.stroke(Base.mkPT(1,1,1),1,beatrix,v);	
	serp.fill(beatrix);	
	serp.imposter:=beatrix;
	serp.stroke(Base.mkPT(1/2,1/2,1/4),1,beatrix,v);
	serp.stroke(Base.mkPT(1/2,1/2,3/4),1,serp,v);
	serp.stroke(Base.mkPT(1/4,1/2,1/2),1,beatrix,v);
	serp.stroke(Base.mkPT(3/4,1/2,1/2),1,serp,v);
	serp.stroke(Base.mkPT(1/2,1/4,1/2),1,beatrix,v);
	serp.stroke(Base.mkPT(1/2,3/4,1/2),1,serp,v);
	serp.stroke(Base.mkPT(1/2,1/2,1/2),1,greenball,v);	
	subserp.copyonstroke:=TRUE;	
	serp.copyonstroke:=TRUE;	
	beatrix.copyonstroke:=TRUE;
	RETURN serp
END thisvox;
 END NXWCxXWLIcD2LegvoGXXBiQ. 
 
 Marsh.Rez NXWCxXWLIcD2LegvoGXXBiQ