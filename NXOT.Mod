MODULE NXOT;

IMPORT Base:=XNXLBase, XNXLXot;

VAR
	xot: XNXLXot.Xot;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(xot);
	xot.xotcolor(1,1,0);
	RETURN xot
END thisvox;

END NXOT.