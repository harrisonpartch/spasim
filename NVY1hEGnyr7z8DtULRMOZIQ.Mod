MODULE NVY1hEGnyr7z8DtULRMOZIQ;
IMPORT XNXLBase, XNXLTexVox;VAR
	vox: XNXLTexVox.TexVox; 
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN	
	IF vox=NIL THEN NEW(vox,'XNXL.gorge.png'); vox.texscale:=1  END;
	RETURN vox
END thisvox;
	
 END NVY1hEGnyr7z8DtULRMOZIQ. 