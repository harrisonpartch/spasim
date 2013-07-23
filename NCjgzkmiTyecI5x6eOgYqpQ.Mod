MODULE NCjgzkmiTyecI5x6eOgYqpQ;
IMPORT Base, TexVox;
  
TYPE
	Voxel = Base.Voxel;  
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(vox,'granite.png');
	RETURN vox
END thisvox;

END NCjgzkmiTyecI5x6eOgYqpQ. 