MODULE NFuse;
IMPORT Base, CellAuto;

VAR
	fuse: CellAuto.FuseVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(fuse);
	RETURN fuse	
END thisvox;

END NFuse.