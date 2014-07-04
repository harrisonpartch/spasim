MODULE FileTest;
IMPORT  Files, Streams, Strings, Out:=KernelLog;

PROCEDURE write*;
VAR 
	f: Files.File; 
	w: Files.Writer;
BEGIN
	f := Files.New("testfile");
	Files.Register(f);	
	IF (f # NIL) THEN
		Files.OpenWriter(w, f, 0);		
		w.Bytes("this is only a test",0,50);	 
		IF (w.res = Streams.Ok) THEN
			w.Update;
			Out.String("this is only a test");
			Out.Ln
		END
	END;
END write;

END FileTest.write

SystemTools.Free	FileTest 