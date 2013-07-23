MODULE NxxxGAernhjFK40xASZZVoQ;(*anonymous module created by saboteur [ideally] *)
  
IMPORT XNXLBase,  XNXLFRep;

TYPE Ray = XNXLBase.Ray;
	Voxel = XNXLBase.Voxel;  
	PT =XNXLBase.PT;
	
VAR 
	gorgeplane:XNXLFRep.landscape;
	gorge: Voxel;
	v:Voxel;
	up, center:  PT;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	RETURN gorge
END thisvox;

BEGIN
	v:=XNXLBase.VoxelFromName("NwPicBWw4NfcserX4ELaQ3A"); 
	XNXLBase.setPT(center,1/2,1/2,1/2);
	XNXLBase.setPT(up,0,0,1);		
	NEW(gorgeplane,center,up,"XNXL.gorge.png","XNXL.gorge.png");
	gorgeplane.vox:= v;
	gorge:=XNXLBase.VoxelFromName("NM2");
	gorge.FRaster(gorgeplane,82);
	
END NxxxGAernhjFK40xASZZVoQ. mv 