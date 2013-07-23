MODULE NSIsnYBTYL9BajD8fbPDSqg;
IMPORT Base:=XNXLBase, XNXLTexVox;
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'sparx.png')  END;
	vox.passable:=TRUE;
	RETURN vox
END thisvox;

END NSIsnYBTYL9BajD8fbPDSqg. 