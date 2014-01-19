MODULE NWdMWLJtPzMMIp2UEA2iYwQ;
 IMPORT Base, TexVox;  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'diethree.png')  END;
	RETURN vox
END thisvox;

 END NWdMWLJtPzMMIp2UEA2iYwQ. 