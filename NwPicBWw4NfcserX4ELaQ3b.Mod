MODULE NwPicBWw4NfcserX4ELaQ3b;

IMPORT Base, TexVox;
  
VAR vox: TexVox.TexCubeVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"grain.png")  END;
	RETURN vox
END thisvox;

 END NwPicBWw4NfcserX4ELaQ3b. 
 
 Marsh.Rez NwPicBWw4NfcserX4ELaQ3b ~