MODULE Nsphere;
IMPORT Base;
VAR vox: SphereVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"foxbreadmirror.png"); 
	vox.passable:=FALSE;
END Nsphere. 