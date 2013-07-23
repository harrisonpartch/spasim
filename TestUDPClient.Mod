MODULE TestUDPClient;

IMPORT IP, UDP, Out := KernelLog;


PROCEDURE Send*;
VAR s: UDP.Socket;
	res: LONGINT;
	ip: IP.Adr;
BEGIN
	NEW( s, UDP.NilPort, res );
	ip := IP.StrToAdr( "78.174.238.147" );
	s.Send( ip, 19768, "hello fnecati i could not have started this project without your code so thx++", 0, 20, res );
	IF res # UDP.Ok THEN
		Out.String( "UDP send failed" );  Out.Ln
	END;
	s.Close
END Send;

END TestUDPClient.

Compiler.Compile Unix.Sockets.Mod Unix.UDP.Mod TestUDPServer.Mod TestUDPClient.Mod ~

TestUDPClient.Send ~

SystemTools.Free  TestUDPClient ~
SystemTools.Free TestUDPServer TestUDPClient UDP Sockets ~


TestUDPServer.Mod

TestUDPServer.Start ~

TestUDPServer.Stop ~
