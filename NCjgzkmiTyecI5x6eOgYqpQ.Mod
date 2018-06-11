MODULE NCjgzkmiTyecI5x6eOgYqpQ;
IMPORT Base, TexVox;
  
TYPE
	Voxel = Base.Voxel;  
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(vox,'die.1.png');
	vox.tscale:=10000;
	RETURN vox
END thisvox;

END NCjgzkmiTyecI5x6eOgYqpQ. 

die.1.png