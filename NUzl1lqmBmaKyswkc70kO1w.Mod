MODULE NUzl1lqmBmaKyswkc70kO1w;(*anonymous module created by saboteur*)
 
IMPORT Base,TexVox;
VAR vox: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(vox,'aspiedog.png');
	vox.tscale:=1000;
	RETURN vox
END thisvox;
END NUzl1lqmBmaKyswkc70kO1w. 