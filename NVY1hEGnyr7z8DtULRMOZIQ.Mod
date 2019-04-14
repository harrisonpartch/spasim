MODULE NVY1hEGnyr7z8DtULRMOZIQ;
IMPORT Base, TexVox;VAR
	vox: TexVox.TexVox; 
PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	IF vox=NIL THEN NEW(vox,'XNXL.gorge.png'); vox.tscale:=1  END;
	RETURN vox
END thisvox;
	
 END NVY1hEGnyr7z8DtULRMOZIQ. 