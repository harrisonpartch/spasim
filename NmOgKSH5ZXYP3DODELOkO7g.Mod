MODULE NmOgKSH5ZXYP3DODELOkO7g;
IMPORT XNXLBase, XNXLTexVox;
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'heliorose.png'); vox.lock()  END;
	RETURN vox
END thisvox;

 END NmOgKSH5ZXYP3DODELOkO7g. 
