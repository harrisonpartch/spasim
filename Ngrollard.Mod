MODULE Ngrollard;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base, FRep, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 	
	w10,lobster,tigerlily: Voxel;
	sphere: FRep.sphere;
	plane: FRep.plane;
	up,center: PT;
	

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	w10:=Base.VoxelFromName("NM2");	
	Base.setPT(up,0,0,1);
	Base.setPT(center,1/2,1/2,1/2);
	NEW(sphere,center,5/9);
	sphere.vox:=lobster;	
	w10.FRaster(sphere,8); 
	Base.setPT(up,0,1,0);
	NEW(plane,center,up);
	plane.vox:=tigerlily;
	w10.FRaster(plane,9); 
	Base.setPT(up,1,0,0);
	NEW(plane,center,up);
	plane.vox:=tigerlily;	
	w10.FRaster(plane,9); 	
	w10.copyonstroke:=TRUE;	
	RETURN w10
END thisvox;

BEGIN
	lobster:=Base.VoxelFromName("NznGx2ySiHIGrO5t9Pzcw5Q"); 
	tigerlily:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw");  	
END Ngrollard. 
 
XNXLMarsh.Rez Ngrollard ~
 
