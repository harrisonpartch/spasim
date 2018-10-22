MODULE NCjgzkmiTyecI5x6eOgYqpQ;
IMPORT Base, TexVox;
  
TYPE
	Voxel = Base.Voxel;  
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(vox,'sky.png');
	RETURN vox
END thisvox;

END NCjgzkmiTyecI5x6eOgYqpQ. 

die.1.png