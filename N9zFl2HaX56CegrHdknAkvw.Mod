MODULE N9zFl2HaX56CegrHdknAkvw;
IMPORT Base, XNXLVoxel;
VAR
	vox: XNXLVoxel.DiffuseVox; 
PROCEDURE thisvox*():Base.Voxel;

BEGIN
	IF vox=NIL THEN NEW(vox); vox.setcolor(0.2,0.8,0.3,0,0);  END;
	RETURN vox
END thisvox;
END N9zFl2HaX56CegrHdknAkvw. 