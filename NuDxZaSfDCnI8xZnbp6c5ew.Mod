MODULE NuDxZaSfDCnI8xZnbp6c5ew;(*anonymous module created by saboteur*)
  
IMPORT XNXLBase, XNXLVoxel,XNXLTexVox ;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'cthulhu.png')  END;
	RETURN vox
END thisvox;

 END NuDxZaSfDCnI8xZnbp6c5ew. 