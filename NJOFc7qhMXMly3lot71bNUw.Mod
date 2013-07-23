MODULE NJOFc7qhMXMly3lot71bNUw;
IMPORT  XNXLBase, XNXLTexVox;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"hktarot.png")  END;
	RETURN vox
END thisvox;

 END NJOFc7qhMXMly3lot71bNUw.  