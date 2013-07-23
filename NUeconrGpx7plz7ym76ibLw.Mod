MODULE NUeconrGpx7plz7ym76ibLw;
IMPORT Base:=XNXLBase, XNXLTexVox;
VAR
	vox: Base.Voxel  ; 
PROCEDURE  thisvox*():Base.Voxel;
BEGIN
	vox:=Base.VoxelFromName("NM3");	
	vox.setcolor(0,100000,0,100000,0);
	RETURN vox
END thisvox;

 END NUeconrGpx7plz7ym76ibLw. 