MODULE Nanony ;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	cyl: FRep.cyl;
	v: Voxel;
	star: Voxel;
	reddot,bludot,yellodot,greendot: Voxel;
	center,q,qq:  PT;
	p:ARRAY 7 OF PT;
	i,j,k:LONGINT;
	GO: BOOLEAN;
PROCEDURE thisvox*():Base.Voxel;
VAR
	copy: Voxel;
BEGIN
	drawstar(copy);
	star:=copy;
	RETURN star
END thisvox;

PROCEDURE drawstar(VAR starr: Voxel);
VAR
	vox: Voxel;
BEGIN
	Out.String("drawing star");
	v:=Base.VoxelFromName("NUzl1lqmBmaKyswkc70kO1w"); 
	starr:=Base.VoxelFromName("NM3"); 
	starr.code:="N2qeD84Fv78X2XEj8PtUZOQ";		
	starr.copyonstroke:=TRUE;
	starr.setcolor(0,0,10,10,0);		
	reddot:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO6"); 	
	bludot:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO7"); 	
	yellodot:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO8"); 	
	greendot:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO9"); 	
	reddot.copyonstroke:=TRUE;		
	bludot.lock;	
	yellodot.lock;
	greendot.lock;
	Base.setPT(center,1/2,1/2,1/2);
	Base.setPT(q,1/2,1/2,0);
	Base.setPT(qq,1/2,1/2,1);
	NEW(ball,center,6/12);
	ball.setcolor(1,1,0);
	ball.setvoxel(v); 
	starr.FRaster(ball,27);	
	FOR i:= 0 TO 1000 DO
		starr.stroke(Base.randPT(),27,reddot,vox);
		starr.stroke(Base.randPT(),27,bludot,vox);			
		starr.stroke(Base.randPT(),27,yellodot,vox);			
		starr.stroke(Base.randPT(),27,greendot,vox);
	END;
END drawstar;

BEGIN		

END Nanony. 
 
XNXLMarsh.Rez Nanony ~
 
