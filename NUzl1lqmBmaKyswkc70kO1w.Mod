MODULE NUzl1lqmBmaKyswkc70kO1w;(*anonymous module created by saboteur*)
 
IMPORT XNXLBase,XNXLTexVox;
VAR vox: XNXLTexVox.TexVox;

PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	NEW(vox,'aspiedog.png');
	vox.pstscale:=1000;
	RETURN vox
END thisvox;
END NUzl1lqmBmaKyswkc70kO1w. 