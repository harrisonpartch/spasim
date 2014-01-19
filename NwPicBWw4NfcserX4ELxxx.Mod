MODULE NwPicBWw4NfcserX4ELxxx;

IMPORT Base, TexVox;
  
VAR vox: TexVox.TexCubeVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'lazyblock')  END;
	RETURN vox
END thisvox;

 END NwPicBWw4NfcserX4ELxxx. 