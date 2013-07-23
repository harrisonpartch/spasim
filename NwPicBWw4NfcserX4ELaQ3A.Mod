MODULE NwPicBWw4NfcserX4ELaQ3A;

IMPORT XNXLBase, XNXLTexVox;
  
VAR vox: XNXLTexVox.TexCubeVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'whiteblock')  END;
	RETURN vox
END thisvox;

 END NwPicBWw4NfcserX4ELaQ3A. 