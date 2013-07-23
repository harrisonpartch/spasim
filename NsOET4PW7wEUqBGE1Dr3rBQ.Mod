MODULE NsOET4PW7wEUqBGE1Dr3rBQ;(*anonymous module created by saboteur*)
 
IMPORT Base:=XNXLBase,  Streams,Tex:=XNXLTexVox, M3:=XNXLM3Space;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
TYPE Grass=OBJECT(M3.cell);
PROCEDURE engrain(w: Streams.Writer);
VAR
	i,j,k: INTEGER;
BEGIN
	w.Bytes(code,0, Base.NL);	 
END engrain;
END Grass;
VAR 
	grass,v: Voxel;
	conglomerate: Grass;
	center:  PT;
	i,det:LONGINT;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF conglomerate=NIL THEN
		grass:=Base.VoxelFromName("NJOFc7qhMXMly3lot71bNUw"); 	
		NEW(conglomerate);
		conglomerate.setcolor(1,1,1,0,0);
		conglomerate.imposter:=grass;
		FOR i :=0 TO 5000 DO
			Base.setPT(center,Base.rand.Uniform(),Base.rand.Uniform(),Base.rand.Uniform());	
			IF Base.rand.Dice(30)>0 THEN det:=9 ELSE det:=3 END;
			conglomerate.stroke(center,det,grass,v)
		END
	END;	
	RETURN conglomerate
END thisvox;


END NsOET4PW7wEUqBGE1Dr3rBQ. 