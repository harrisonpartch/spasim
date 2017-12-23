MODULE FilmLoop;
IMPORT MPEG,Kernel, Codec := Codecs, Raster, Base, Files, Strings, Objects, Out:=KernelLog;

TYPE Name=Base.Name;

TYPE floop*=OBJECT(Base.V);
VAR
	alive:BOOLEAN;
	demux: MPEG.Demuxer;
	decoder: MPEG.Decoder;
	file: Files.File;
	fileinputstream: Codec.FileInputStream;
	vstream: Codec.DemuxStream;
	result: LONGINT;
	filename:Name;
	W*,H*,ms:LONGINT;
	img: Raster.Image;
	mode: Raster.Mode;
	go:BOOLEAN;
	gReen: REAL;
	frames,f: LONGINT;
	
PROCEDURE&init*(fname:Name; frn: LONGINT);
BEGIN
	filename:=fname;
	frames:=frn;
	file := Files.Old(filename);
	IF file = NIL THEN
		Out.String("Couldn't open File "); Out.String(filename);
		Out.Ln()
	ELSE
		Out.String("Opened File "); Out.String(filename);
		alive:=TRUE	
	END;	
	register
END init;

PROCEDURE stop*;
BEGIN
	alive:=FALSE
END stop;

PROCEDURE shade*(VAR x,y: REAL; VAR c:Base.Color);
VAR
	w,h:LONGINT;
	red,green,blue,alpha:LONGINT;
	pix: Raster.Pixel;
	
BEGIN
	w:= ENTIER(x*img.width) MOD img.width;
(*	y:=1-y; *)
	h:= ENTIER(y*img.height) MOD img.height;
	Raster.Get(img,w,h, pix, mode);
	Raster.GetRGBA(pix,red,green,blue,alpha);
	c.red:=red/256; 
	c.green:=green/256;
	c.blue:=blue/256;
	tick;
END shade;


PROCEDURE tick*;
BEGIN{EXCLUSIVE}
	go:=TRUE;
(*	gReen:=Base.rand.Uniform();
	Out.String("floop tick") *)
END tick;

BEGIN{ACTIVE, PRIORITY(Objects.Low)}
	IF alive THEN
		Raster.InitMode(mode, Raster.srcCopy);
		NEW(fileinputstream, file, 0);
		NEW(demux);
		demux.Open(fileinputstream, result);
		IF result # Codec.ResOk THEN
			Out.String("error opening the demultiplexer"); Out.Ln;
		ELSE
			vstream := demux.GetStream(0);
			NEW(decoder);
			decoder.Open(vstream, result);
			ASSERT(result=Codec.ResOk);
			decoder.GetVideoInfo(W,H,ms);
			NEW(img);
			Raster.Create(img,W,H,Raster.BGR888);
			Out.Int(W,6); Out.Ln;
			Out.Int(H,6); Out.Ln;
				REPEAT
					f:=0;
					REPEAT
						BEGIN{EXCLUSIVE}
							AWAIT(go);
							go:=FALSE
						END;
						INC(f);
						(* Out.Int(f,4); *)
						decoder.Next();
						decoder.Render(img) 
					UNTIL f=frames;
					file := Files.Old(filename);	
					IF file = NIL THEN
						Out.String("Couldn't open File "); Out.String(filename);
						Out.Ln();
						file := Files.New(filename);
						alive:=FALSE;
					END;						
					NEW(fileinputstream, file, 0);
					NEW(demux);
					demux.Open(fileinputstream, result);
					ASSERT(result=Codec.ResOk);				
					vstream := demux.GetStream(0);
					NEW(decoder);
					decoder.Open(vstream, result);	
					ASSERT(result=Codec.ResOk);
					decoder.GetVideoInfo(W,H,ms);
				UNTIL ~alive;
		END	
	END
END floop;

END FilmLoop.