MODULE NxxxGAernhjFK40xASZZVoQ;(*anonymous module created by saboteur [ideally] *)
  
IMPORT Base,  FRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR 
	gorgeplane: FRep.landscape;
	gorge: Voxel;
	v:Voxel;
	up, center:  PT;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN gorge
END thisvox;

BEGIN
	v:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU666"); 
	Base.setPT(center,1/2,1/2,1/2);
	Base.setPT(up,0,0,1);		
	NEW(gorgeplane,center,up,"XNXL.gorge.png","XNXL.gorge.png");
	gorgeplane.vox:= v;
	gorge:=Base.VoxelFromName("NM3");
	gorge.FRaster(gorgeplane,729);

END NxxxGAernhjFK40xASZZVoQ. mv 