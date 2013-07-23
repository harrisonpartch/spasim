MODULE NznGx2ySiHIGrO5t9Pzcw5Q;
IMPORT XNXLBase, XNXLTexVox;
  
VAR
	vox: XNXLTexVox.TexVox; 
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN	
	IF vox=NIL THEN NEW(vox,'krill.png'); 	
 END;
	RETURN vox
END thisvox;

 END NznGx2ySiHIGrO5t9Pzcw5Q. 