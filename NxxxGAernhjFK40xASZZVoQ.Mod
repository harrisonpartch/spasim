MODULE NxxxGAernhjFK40xASZZVoQ;(*anonymous module created by saboteur [ideally] *)
  
IMPORT Base,  XNXLFRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR 
	gorgeplane:XNXLFRep.landscape;
	gorge: Voxel;
	v:Voxel;
	up, center:  PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN gorge
END thisvox;

BEGIN
	v:=Base.VoxelFromName("NGNYAfkxmEzxe6ZESmcMJtw"); 
	Base.setPT(center,1/2,1/2,1/2);
	Base.setPT(up,0,0,1);		
	NEW(gorgeplane,center,up,"XNXL.gorge.png","XNXL.gorge.png");
	gorgeplane.vox:= v;
	gorge:=Base.VoxelFromName("NM2");
	gorge.FRaster(gorgeplane,256);
	
END NxxxGAernhjFK40xASZZVoQ. mv 