MODULE TestUDPServer;

IMPORT IP, UDP, Out := KernelLog;

VAR s: UDP.Socket;

PROCEDURE Start*;
VAR 
	res: LONGINT;
	data: ARRAY 1024 OF CHAR;
	fip: IP.Adr;  fport, len: LONGINT;
	i: LONGINT;
BEGIN
	NEW( s, 19768, res ); 
	IF res = UDP.Ok THEN
		Out.String( "UDP Server started at port 19768" ); Out. Ln;
		REPEAT
			s.Receive( data, 0, 500, -1, fip, fport, len, res );
			IF res = UDP.Ok THEN
				Out.String( "Data: " );
				FOR i := 0 TO len -1 DO  Out.Char( data[i] )  END;
				Out.Ln
			END;
		UNTIL res # UDP.Ok
	ELSE
		Out.String( "UDP socket open at port 5300 failed" );  Out.Ln
	END
END Start;

PROCEDURE Stop*;
BEGIN
	s.Close;
	Out.String( "UDP Server stopped" ); Out.Ln
END Stop;


END TestUDPServer.