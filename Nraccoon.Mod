MODULE Nraccoon;

IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"kantbot.png")  END;
	vox.tscale:=300;
	RETURN vox
END thisvox;

 END Nraccoon. 
 
 Marsh.Rez Nraccoon ~