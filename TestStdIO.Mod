MODULE TestStdIO;

IMPORT StdIO, Commands, Streams, Files;


PROCEDURE Args*;
VAR 
	unix: Commands.Context;
	ch: CHAR;
BEGIN
	unix := StdIO.env;
	WHILE unix.arg.Available() > 0 DO
		unix.arg.Char( ch );  unix.out.Char( ch );
	END;
	unix.out.Ln;  unix.out.Update
END Args;


PROCEDURE Cat*;
VAR 
	arg: Streams.Reader; fin: Files.Reader;
	unix: Commands.Context;
	fname: ARRAY 32 OF CHAR;
	f: Files.File;
	ch: CHAR;
BEGIN
	IF StdIO.argc > 3 THEN  (* aos  -x  M.P  filename ... *)
		unix := StdIO.env;  arg := unix.arg;
		(* skip:  aos  -x  M.P *)
		IF arg.GetString( fname ) & arg.GetString( fname ) & arg.GetString( fname ) THEN
			WHILE arg.GetString( fname ) DO
				f := Files.Old( fname );
				IF f = NIL THEN
					unix.error.String( "could not open file " );  unix.error.String( fname );  
					unix.error.Ln;  unix.error.Update;
					RETURN
				ELSE
					Files.OpenReader( fin, f, 0 );  
					WHILE fin.Available() > 0 DO
						fin.Char( ch );  unix.out.Char( ch );
					END;
				END
			END
		END
	ELSE
		WHILE unix.in.Available() > 0 DO
			unix.in.Char( ch );  unix.out.Char( ch );
		END;
	END;
	unix.out.Update
END Cat;


END TestStdIO.


	TestStdIO.Args
	
	
	SystemTools.Free TestStdIO TestStdIO StdIO ~
	
	Unix.StdIO.Mod
	
