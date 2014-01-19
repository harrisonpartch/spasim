MODULE NvZjNvNLlZ4yUPfoMC5zI;(*anonymous module created by saboteur*)
  
IMPORT Base,  FRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	conglomerate:Voxel;
	center:  PT;
	i:INTEGER;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN conglomerate
END thisvox;

BEGIN
	conglomerate:=Base.VoxelFromName("NM3");
	FOR i :=0 TO 100 DO
		Base.setPT(center,Base.rand.Uniform(),Base.rand.Uniform(),Base.rand.Uniform());
		NEW(ball,center,Base.rand.Uniform()/10);
		ball.setcolor(Base.rand.Uniform(),Base.rand.Uniform(),Base.rand.Uniform());		
		Base.setPT(center,1/2,1/2,1/2);
		conglomerate.FRaster(ball,81)
	END;
	conglomerate.DTL:=10000;
	conglomerate.frozen:=TRUE
 END NvZjNvNLlZ4yUPfoMC5zI. 