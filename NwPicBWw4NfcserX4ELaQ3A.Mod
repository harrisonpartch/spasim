MODULE NwPicBWw4NfcserX4ELaQ3A;

IMPORT Base, TexVox;
  
VAR vox: TexVox.TexCubeVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"beatabeatrix.jpg")  END;
	RETURN vox
END thisvox;

 END NwPicBWw4NfcserX4ELaQ3A. 