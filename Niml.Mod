MODULE Niml;
IMPORT Base, TexVox;
  
TYPE
	Voxel = Base.Voxel;  
  
VAR vox: TexVox.TexCubeVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(vox,'iml');
	RETURN vox
END thisvox;

END Niml. 