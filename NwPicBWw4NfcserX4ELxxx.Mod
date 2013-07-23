MODULE NwPicBWw4NfcserX4ELxxx;

IMPORT XNXLBase, XNXLTexVox;
  
VAR vox: XNXLTexVox.TexCubeVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'lazyblock')  END;
	RETURN vox
END thisvox;

 END NwPicBWw4NfcserX4ELxxx. 