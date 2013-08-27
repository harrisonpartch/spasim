MODULE NBsHFiBKkSckXBAd46Zbsss;
 
IMPORT Base, XNXLVoxel, XNXLVoxel4;

VAR vox: XNXLVoxel4.SphereInVox;
PROCEDURE thisvox*():Base.Voxel;
VAR
	beatrix,lobster: Base.Voxel;
	red,yellow: XNXLVoxel.DiffuseVox;
BEGIN; 
	beatrix:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw"); 
	lobster:=Base.VoxelFromName("NznGx2ySiHIGrO5t9Pzcw5Q"); 
	NEW(red);
	red.setcolor(1,0,0,0,0);
	NEW(yellow);
	yellow.setcolor(1,1,0,0,0);
	NEW(vox,red,yellow,0.6);
	RETURN vox
END thisvox;
 END NBsHFiBKkSckXBAd46Zbsss. 