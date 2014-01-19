MODULE NxrglfWf3ZTXHHNB8BJ3sSQ;
 IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'caption.jpg')  END;
	RETURN vox
END thisvox;

 END NxrglfWf3ZTXHHNB8BJ3sSQ. 