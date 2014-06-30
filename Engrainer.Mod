MODULE Engrainer;
IMPORT  Base, Files, Streams, GZip, Strings, Out:=KernelLog;

CONST NL=Base.NL;

TYPE Voxel=Base.Voxel;
Name=Base.Name;

PROCEDURE engrain*(voxel: Voxel);
VAR 
	f,fgz: Files.File; 
	w: Files.Writer;
BEGIN
	voxel.copyclear;
	f := Files.New("grain");
	fgz := Files.New("sprout");
	Files.OpenWriter(w, f, 0);
	Base.engrain(w);
	voxel.copyclear;
	voxel.engrain(w);
	IF (w.res = Streams.Ok) THEN
		w.Update;
		GZip.Deflate(f,fgz,GZip.BestSpeed,GZip.DefaultStrategy,GZip.NoFlush); 
		Files.Register(f);
		Files.Register(fgz);
		Out.String("sprout saved");
		Out.Ln
	END;
END engrain;

PROCEDURE sprout*():Voxel;
VAR 
	f,fgz: Files.File; 
	r: Files.Reader; 
	name: Name;
	cell: Voxel;
	len: LONGINT;
BEGIN
	NEW(cell);
	fgz:= Files.Old("sprout");
	f:=Files.New("cotyledon");
	IF (fgz # NIL) THEN
		 GZip.Inflate(fgz,f); 
		NEW(r,f,0);
		Files.OpenReader(r, f, 0);
		Base.sprout(r);
		r.Bytes(name,0,NL,len);
		Out.String(name); 
		cell:=Base.VoxelFromName(name);
		IF cell#NIL THEN 
			cell.sprout(r);
			Out.String("germination succeeded")
		ELSE
			Out.String("germination failed");
			Base.world:=Base.VoxelFromName("NM3")
		END
	ELSE
		Out.String("germination failed: nonesuch file");
		Base.world:=Base.VoxelFromName("NM3")
	END;
	RETURN cell
END sprout;

END Engrainer.