<?xml version="1.0" encoding="UTF-8"?>
<?bluebottle format version="0.1" ?>
<?xml-stylesheet type="text/xsl" href="http://bluebottle.ethz.ch/bluebottle.xsl" ?>
<Text>
<Span style="Bold"><![CDATA[MODULE UDPChatServer;]]></Span><Span style="Normal"><![CDATA[ ]]></Span><Span style="Comment"><![CDATA[(** AUTHOR "SAGE"; PURPOSE "UDP Chat Server" *)]]></Span><Span style="Normal"><![CDATA[

]]></Span><Span style="Bold"><![CDATA[IMPORT]]></Span><Span style="Normal"><![CDATA[
	Base := UDPChatBase, UDP := AosUDP, IP := AosIP,
	Utilities, AosModules, AosKernel, AosEvents;
	
]]></Span><Span style="Bold"><![CDATA[CONST]]></Span><Span style="Normal"><![CDATA[
	branchInit				= 0;
	branchPacketReceive	= 1;
	branchVersionCheck	= 2;
	branchAuthentication	= 3;
	branchPacketHandle	= 4;
	branchEnd				= 5;
	branchTerminated		= 6;
	
	moduleName = "]]></Span><Span style="Bold"><![CDATA[UDPChatServer]]></Span><Span style="Normal"><![CDATA[";
	
	]]></Span><Span style="Comment"><![CDATA[(* Event classification as in AosEvents.XML *)]]></Span><Span style="Normal"><![CDATA[
	EventClass = 3; ]]></Span><Span style="Comment"><![CDATA[(* UDP Chat *)]]></Span><Span style="Normal"><![CDATA[
	EventSubclass = 3; ]]></Span><Span style="Comment"><![CDATA[(* UDP Chat Server *)]]></Span><Span style="Normal"><![CDATA[
	
]]></Span><Span style="Bold"><![CDATA[TYPE]]></Span><Span style="Normal"><![CDATA[
	
	]]></Span><Span style="Bold"><![CDATA[String = Utilities.String;]]></Span><Span style="Normal"><![CDATA[
	
	]]></Span><Span style="Bold"><![CDATA[Instance = OBJECT
	VAR]]></Span><Span style="Normal"><![CDATA[
		s: UDP.Socket;
		dt: Utilities.TDateTime;
		running, terminated: BOOLEAN;
		ip: IP.Adr;
		branch, command, seqNum, messageType: INTEGER;
		uin, receiverUin, port, len, res, receiveBufOffset: LONGINT;
		user: Base.User;
		users: Base.Users;
		clients: Base.List;
		client, receiver: Base.Client;
		sendBuf: Base.Buffer;
		receiveBuf, password, shortName, fullName, eMail, message, textCode: String;
		str1, str2: ARRAY 256 OF CHAR;
		ACKReq: Base.ACKRec;
		
	]]></Span><Span style="Bold"><![CDATA[PROCEDURE &New (udp: UDP.Socket);
	BEGIN]]></Span><Span style="Normal"><![CDATA[
		s := udp
	]]></Span><Span style="Bold"><![CDATA[END New;]]></Span><Span style="Normal"><![CDATA[
		
	]]></Span><Span style="Bold"><![CDATA[PROCEDURE Destroy;
	BEGIN]]></Span><Span style="Normal"><![CDATA[
		running := FALSE;
		s.Close;
		BEGIN {EXCLUSIVE}
			AWAIT (terminated)
		END;
	]]></Span><Span style="Bold"><![CDATA[END Destroy;]]></Span><Span style="Normal"><![CDATA[
	
	PROCEDURE FinalizeClients]]></Span><Span style="Bold"><![CDATA[(clients: Base.List]]></Span><Span style="Normal"><![CDATA[);
]]></Span><Span style="Bold"><![CDATA[	VAR]]></Span><Span style="Normal"><![CDATA[
		i: LONGINT;
		p: PTR;
		]]></Span><Span style="Bold"><![CDATA[client: Base.Client]]></Span><Span style="Normal"><![CDATA[;
	BEGIN
		i := 0;
		WHILE i < clients.GetCount () DO
			p := clients.GetItem (i);
			client := p (Base.Client);
			client.Finalize;
			INC (i);
		END;
	END FinalizeClients;

	]]></Span><Span style="Bold"><![CDATA[PROCEDURE FindClient (clients: Base.List;
]]></Span><Span style="Normal"><![CDATA[	]]></Span><Span style="Bold"><![CDATA[	uin: LONGINT;
]]></Span><Span style="Normal"><![CDATA[	]]></Span><Span style="Bold"><![CDATA[	VAR client: Base.Client): BOOLEAN;
	VAR]]></Span><Span style="Normal"><![CDATA[
		i: LONGINT;
		p: PTR;
	]]></Span><Span style="Bold"><![CDATA[BEGIN]]></Span><Span style="Normal"><![CDATA[
		i := 0;
		WHILE i < clients.GetCount () DO
			p := clients.GetItem (i);
			client := p (Base.Client);
			IF uin = client.uin THEN
				RETURN TRUE;
			END;
			INC (i);
		END;
		RETURN FALSE;
	]]></Span><Span style="Bold"><![CDATA[END FindClient;]]></Span><Span style="Normal"><![CDATA[
	
	]]></Span><Span style="Bold"><![CDATA[PROCEDURE CheckKeepAlive (clients: Base.List);
	VAR]]></Span><Span style="Normal"><![CDATA[
		i: LONGINT;
		p: PTR;
	]]></Span><Span style="Bold"><![CDATA[BEGIN]]></Span><Span style="Normal"><![CDATA[
		i := 0;
		WHILE i < clients.GetCount () DO
			p := clients.GetItem (i);
			client := p (Base.Client);
			IF AosKernel.Expired (client.keepAliveTimer) THEN
				MulticastStatus (clients, client, Base.USER_OFFLINE, sendBuf, s);
				client.Finalize;
				clients.Remove (client);
			END;
			INC (i);
		END;
	]]></Span><Span style="Bold"><![CDATA[END CheckKeepAlive;]]></Span><Span style="Normal"><![CDATA[
	
	
	]]></Span><Span style="Bold"><![CDATA[PROCEDURE Server_NewUserReply (ip: IP.Adr; port: LONGINT; uin: LONGINT;
		seqNum: INTEGER; sendBuf: Base.Buffer; s: UDP.Socket);
	VAR]]></Span><Span style="Normal"><![CDATA[
		res: LONGINT;
		string: String;]]></Span><Span style="Bold"><![CDATA[
	BEGIN {EXCLUSIVE}]]></Span><Span style="Normal"><![CDATA[
		Base.ServerPacketInit (Base.NEW_USER_REPLY, seqNum, sendBuf);
		
		sendBuf.AddInt (uin, 4);
		
		string := sendBuf.GetString ();
		]]></Span><Span style="Preferred"><![CDATA[s.Send (ip, port, string^, 0, sendBuf.GetLength (), res);]]></Span><Span style="Normal"><![CDATA[
	]]></Span><Span style="Bold"><![CDATA[END Server_NewUserReply;]]></Span><Span style="Normal"><![CDATA[
	
	]]></Span><Span style="Bold"><![CDATA[PROCEDURE Server_LoginReply (client: Base.Client;
		sendBuf: Base.Buffer; s: UDP.Socket);
	VAR]]></Span><Span style="Normal"><![CDATA[
		res: LONGINT;
		string: String;]]></Span><Span style="Bold"><![CDATA[
	BEGIN {EXCLUSIVE}]]></Span><Span style="Normal"><![CDATA[
		Base.ServerPacketInit (Base.LOGIN_REPLY, client.inSeqNum, sendBuf);
		
		sendBuf.AddInt (client.uin, 4);
		
		string := sendBuf.GetString ();]]></Span><Span style="Preferred"><![CDATA[
]]></Span><Span style="Normal"><![CDATA[		]]></Span><Span style="Preferred"><![CDATA[s.Send (client.ip, client.port, string^, 0, sendBuf.GetLength (), res);]]></Span><Span style="Normal"><![CDATA[
	]]></Span><Span style="Bold"><![CDATA[END Server_LoginReply;]]></Span><Span style="Normal"><![CDATA[
	
	]]></Span><Span style="Bold"><![CDATA[PROCEDURE Server_InfoReply (client: Base.Client;
		user: Base.User; sendBuf: Base.Buffer; s: UDP.Socket);
	VAR]]></Span><Span style="Normal"><![CDATA[
		string: String;
		res, len: LONGINT;
	]]></Span><Span style="Bold"><![CDATA[BEGIN {EXCLUSIVE}]]></Span><Span style="Normal"><![CDATA[
		Base.ServerPacketInit (Base.INFO_REPLY, client.inSeqNum, sendBuf);
		
		sendBuf.AddInt (user.uin, 4);
		
		len := Utilities.Length (user.shortName) + 1;
		sendBuf.AddInt (len, 2);
		sendBuf.Add (user.shortName, 0, len, TRUE, res);
		
		string := sendBuf.GetString ();
		]]></Span><Span style="Preferred"><![CDATA[s.Send (client.ip, client.port, string^, 0, sendBuf.GetLength (), res);]]></Span><Span style="Normal"><![CDATA[
	]]></Span><Span style="Bold"><![CDATA[END Server_InfoReply;]]></Span><Span style="Normal"><![CDATA[
	
	]]></Span><Span style="Bold"><![CDATA[PROCEDURE Server_ACK (client: Base.Client;
		sendBuf: Base.Buffer; s: UDP.Socket);
	VAR]]></Span><Span style="Normal"><![CDATA[
		res: LONGINT;
		string: String;]]></Span><Span style="Bold"><![CDATA[
	BEGIN {EXCLUSIVE}]]></Span><Span style="Normal"><![CDATA[
		Base.ServerPacketInit (Base.ACK, client.inSeqNum, sendBuf);
		
		string := sendBuf.GetString ();
		]]></Span><Span style="Preferred"><![CDATA[s.Send (client.ip, client.port, string^, 0, sendBuf.GetLength (), res);]]></Span><Span style="Normal"><![CDATA[
	]]></Span><Span style="Bold"><![CDATA[END Server_ACK;]]></Span><Span style="Normal"><![CDATA[
	
	]]></Span><Span style="Bold"><![CDATA[PROCEDURE Server_UserStatus (client, receiver: Base.Client;
		status: INTEGER; sendBuf: Base.Buffer; s: UDP.Socket);
	VAR]]></Span><Span style="Normal"><![CDATA[
		res: LONGINT;
		string: String;
	]]></Span><Span style="Bold"><![CDATA[BEGIN {EXCLUSIVE}]]></Span><Span style="Normal"><![CDATA[
		Base.ServerPacketInit (status, receiver.outSeqNum, sendBuf);
		
		NEW (ACKReq);
		ACKReq.seqNum := receiver.outSeqNum;
		receiver.ACKList.Add (ACKReq);
		
		INC (receiver.outSeqNum);
		
		sendBuf.AddInt (client.uin, 4);

		string := sendBuf.GetString ();
		]]></Span><Span style="Preferred"><![CDATA[s.Send (receiver.ip, receiver.port, string^, 0, sendBuf.GetLength (), res);]]></Span><Span style="Normal"><![CDATA[
	]]></Span><Span style="Bold"><![CDATA[END Server_UserStatus;]]></Span><Span style="Normal"><![CDATA[
	
	]]></Span><Span style="Bold"><![CDATA[PROCEDURE Server_ReceiveMessage (client, receiver: Base.Client; dt: Utilities.TDateTime;
		messageType: INTEGER; message: String; sendBuf: Base.Buffer; s: UDP.Socket);
	VAR]]></Span><Span style="Normal"><![CDATA[
		string: String;
		res, len: LONGINT;
	]]></Span><Span style="Bold"><![CDATA[BEGIN {EXCLUSIVE}]]></Span><Span style="Normal"><![CDATA[
		Base.ServerPacketInit (Base.RECEIVE_MESSAGE, receiver.outSeqNum, sendBuf);
		
		NEW (ACKReq);
		ACKReq.seqNum := receiver.outSeqNum;
		receiver.ACKList.Add (ACKReq);
		
		INC (receiver.outSeqNum);
		
		sendBuf.AddInt (client.uin, 4);
		sendBuf.AddInt (dt.Year, 2);
		sendBuf.AddInt (dt.Month, 1);
		sendBuf.AddInt (dt.Day, 1);
		sendBuf.AddInt (dt.Hour, 1);
		sendBuf.AddInt (dt.Minute, 1);
		
		sendBuf.AddInt (messageType, 2);
		
		(*
		len := Utilities.Length (message^) + 1;
		*)
		len := LEN (message^);

		sendBuf.AddInt (len, 2);
		sendBuf.Add (message^, 0, len, TRUE, res);
		
		string := sendBuf.GetString ();
		]]></Span><Span style="Preferred"><![CDATA[s.Send (receiver.ip, receiver.port, string^, 0, sendBuf.GetLength (), res);]]></Span><Span style="Normal"><![CDATA[
	]]></Span><Span style="Bold"><![CDATA[END Server_ReceiveMessage;]]></Span><Span style="Normal"><![CDATA[
	
	]]></Span><Span style="Bold"><![CDATA[PROCEDURE MulticastStatus (clients: Base.List;
		client: Base.Client;
		status: INTEGER; sendBuf: Base.Buffer; s: UDP.Socket);
	VAR]]></Span><Span style="Normal"><![CDATA[
		i: LONGINT;
		p: PTR;
		receiver: Base.Client;
	]]></Span><Span style="Bold"><![CDATA[BEGIN]]></Span><Span style="Normal"><![CDATA[
		i := 0;
		WHILE i < clients.GetCount () DO
			p := clients.GetItem (i);
			receiver := p (Base.Client);
			IF client.uin # receiver.uin THEN
				]]></Span><Span style="Bold"><![CDATA[Server_UserStatus]]></Span><Span style="Normal"><![CDATA[ (client, receiver, status, sendBuf, s);
				IF status = Base.USER_ONLINE THEN
					]]></Span><Span style="Bold"><![CDATA[Server_UserStatus]]></Span><Span style="Normal"><![CDATA[ (receiver, client, status, sendBuf, s);
				END;
			END;
			INC (i);
		END;
	]]></Span><Span style="Bold"><![CDATA[END MulticastStatus;]]></Span><Span style="Normal"><![CDATA[
	
	]]></Span><Span style="Bold"><![CDATA[PROCEDURE MulticastMessage (clients: Base.List;
		client: Base.Client; dt: Utilities.TDateTime; ]]></Span><Span style="Normal"><![CDATA[messageType]]></Span><Span style="Bold"><![CDATA[: INTEGER; message: String;
		sendBuf: Base.Buffer; s: UDP.Socket);
	VAR]]></Span><Span style="Normal"><![CDATA[
		i: LONGINT;
		p: PTR;
		receiver: Base.Client;
	]]></Span><Span style="Bold"><![CDATA[BEGIN]]></Span><Span style="Normal"><![CDATA[
		i := 0;
		WHILE i < clients.GetCount () DO
			p := clients.GetItem (i);
			receiver := p (Base.Client);
			]]></Span><Span style="Comment"><![CDATA[(*IF client.uin # receiver.uin THEN*)]]></Span><Span style="Normal"><![CDATA[

				]]></Span><Span style="Bold"><![CDATA[Server_ReceiveMessage]]></Span><Span style="Normal"><![CDATA[ (client, receiver, dt, messageType, message, sendBuf, s);

			]]></Span><Span style="Comment"><![CDATA[(*END;*)]]></Span><Span style="Normal"><![CDATA[
			INC (i);
		END;
	]]></Span><Span style="Bold"><![CDATA[END MulticastMessage;]]></Span><Span style="Normal"><![CDATA[
	
	]]></Span><Span style="Bold"><![CDATA[BEGIN {ACTIVE}]]></Span><Span style="Normal"><![CDATA[
	
		]]></Span><Span style="Bold"><![CDATA[branch := branchInit;]]></Span><Span style="Normal"><![CDATA[
		
		REPEAT
		
			CASE branch OF
			
			]]></Span><Span style="Bold"><![CDATA[| branchInit:]]></Span><Span style="Normal"><![CDATA[
				
				NEW (receiveBuf, Base.MaxUDPDataLen);
				NEW (sendBuf, 0);
				NEW (clients);
					
				NEW (users);
					
				running := TRUE;
				terminated := FALSE;
					
				]]></Span><Span style="Bold"><![CDATA[branch := branchPacketReceive;]]></Span><Span style="Normal"><![CDATA[
					
			]]></Span><Span style="Bold"><![CDATA[| branchPacketReceive:]]></Span><Span style="Normal"><![CDATA[
			
				IF running THEN
				
					s.Receive (receiveBuf^, 0, Base.MaxUDPDataLen, 1, ip, port, len, res);
					
					IF (res = UDP.Ok) & (len > 0) THEN
					
						receiveBufOffset := 0;
						
						]]></Span><Span style="Bold"><![CDATA[branch := branchVersionCheck;]]></Span><Span style="Normal"><![CDATA[
						
					END;
					
					CheckKeepAlive (clients);
					
				ELSE
				
					]]></Span><Span style="Bold"><![CDATA[branch := branchEnd;]]></Span><Span style="Normal"><![CDATA[
					
				END;
					
			]]></Span><Span style="Bold"><![CDATA[| branchVersionCheck:]]></Span><Span style="Normal"><![CDATA[
				
				IF Base.BufGetInt (receiveBuf, receiveBufOffset) = Base.VERSION THEN
				
					]]></Span><Span style="Bold"><![CDATA[branch := branchAuthentication;]]></Span><Span style="Normal"><![CDATA[
					
				ELSE
				
					]]></Span><Span style="Bold"><![CDATA[branch := branchPacketReceive;]]></Span><Span style="Normal"><![CDATA[
					
				END;
				
			]]></Span><Span style="Bold"><![CDATA[| branchAuthentication:]]></Span><Span style="Normal"><![CDATA[
			
				command := Base.BufGetInt (receiveBuf, receiveBufOffset);
				seqNum := Base.BufGetInt (receiveBuf, receiveBufOffset);
				uin := Base.BufGetLInt (receiveBuf, receiveBufOffset);
				
				Utilities.IntToStr (seqNum, str1);
				Utilities.Concat (" SeqNum: ", str1, str1);
				Utilities.Concat (str1, " Command: ", str1);
				
				Utilities.IntToStr (uin, str2);
				Utilities.Concat ("User ID: ", str2, str2);
				Utilities.Concat (str2, str1, str1);
				
				Base.CommandDecode (command, str2);
				Utilities.Concat (str1, str2, str1);
				
				]]></Span><Span style="Debug"><![CDATA[Log (AosEvents.Information, 0, str1, FALSE);]]></Span><Span style="Normal"><![CDATA[
			
				IF FindClient (clients, uin, client) THEN
				
					]]></Span><Span style="Comment"><![CDATA[(* Additional check *)]]></Span><Span style="Normal"><![CDATA[
					IF (IP.AdrsEqual (client.ip, ip)) & (client.port = port) THEN
						
						]]></Span><Span style="Bold"><![CDATA[branch := branchPacketHandle;]]></Span><Span style="Normal"><![CDATA[
					
					ELSE
					
						]]></Span><Span style="Bold"><![CDATA[branch := branchPacketReceive;]]></Span><Span style="Normal"><![CDATA[
					
					END;
				
				ELSE
				
					CASE command OF
					| Base.LOGIN:
					
						password := Base.BufGetString (receiveBuf, receiveBufOffset);
						
						IF users.PasswordCorrect (uin, password) THEN
						
							NEW (client);
							client.ip := ip;
							client.port := port;
							client.uin := uin;
							
							client.inSeqNum := seqNum;
							client.outSeqNum := 0;
							
							AosKernel.SetTimer (client.keepAliveTimer, Base.clientKeepAliveAwait);
								
							clients.Add (client);
							
							]]></Span><Span style="Bold"><![CDATA[Server_LoginReply]]></Span><Span style="Normal"><![CDATA[ (client, sendBuf, s);

							]]></Span><Span style="Comment"><![CDATA[(* Now we will send client status to all other On-Line clients,
]]></Span><Span style="Normal"><![CDATA[							]]></Span><Span style="Comment"><![CDATA[and they statuses to this client *)]]></Span><Span style="Normal"><![CDATA[
							MulticastStatus (clients, client, Base.USER_ONLINE, sendBuf, s);
								
						END;
						
					| Base.NEW_USER_REG:
					
						password := Base.BufGetString (receiveBuf, receiveBufOffset);
						
						shortName := Base.BufGetString (receiveBuf, receiveBufOffset);
							
						fullName := Base.BufGetString (receiveBuf, receiveBufOffset);
							
						eMail := Base.BufGetString (receiveBuf, receiveBufOffset);
					
						user := users.Add (password, shortName, fullName, eMail);
							
						]]></Span><Span style="Bold"><![CDATA[Server_NewUserReply]]></Span><Span style="Normal"><![CDATA[ (ip, port, user.uin, seqNum, sendBuf, s);
							
					ELSE
									
					END;
					
					]]></Span><Span style="Bold"><![CDATA[branch := branchPacketReceive;]]></Span><Span style="Normal"><![CDATA[
				
				END;
					
			]]></Span><Span style="Bold"><![CDATA[| branchPacketHandle:]]></Span><Span style="Normal"><![CDATA[
				
				IF command = Base.ACK THEN
					
					IF Base.SeqNumInACKList (client.ACKList, seqNum, ACKReq) THEN
						
						client.ACKList.Remove (ACKReq);
							
]]></Span><Span style="Stupid"><![CDATA[					]]></Span><Span style="Normal"><![CDATA[END;
					
				ELSIF Base.isNextSeqNum (seqNum, client.inSeqNum) THEN
					
					client.inSeqNum := seqNum;
					
					CASE command OF
					| Base.SEND_MESSAGE:
						
						]]></Span><Span style="Bold"><![CDATA[Server_ACK]]></Span><Span style="Normal"><![CDATA[ (client, sendBuf, s);
						
						receiverUin := Base.BufGetLInt (receiveBuf, receiveBufOffset);
						messageType := Base.BufGetInt (receiveBuf, receiveBufOffset);
						message := Base.BufGetString (receiveBuf, receiveBufOffset);
						
						dt := Utilities.Now ();
						
						IF receiverUin = 0 THEN
							
							MulticastMessage (clients, client, dt, messageType, message, sendBuf, s);
							
						ELSE
							
							IF FindClient (clients, receiverUin, receiver) THEN
								
								]]></Span><Span style="Bold"><![CDATA[Server_ReceiveMessage]]></Span><Span style="Normal"><![CDATA[ (client, receiver, dt, messageType, message, sendBuf, s);
								
							ELSE
								
								]]></Span><Span style="Stupid"><![CDATA[(*
								!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
								*)]]></Span><Span style="Normal"><![CDATA[
								
							END;
							
						END;
						
					| Base.KEEP_ALIVE:
						]]></Span><Span style="Bold"><![CDATA[
]]></Span><Span style="Normal"><![CDATA[						]]></Span><Span style="Bold"><![CDATA[Server_ACK]]></Span><Span style="Normal"><![CDATA[ (client, sendBuf, s);
						
						AosKernel.SetTimer (client.keepAliveTimer, Base.clientKeepAliveAwait);
						
					| Base.INFO_REQ:
						
						receiverUin := Base.BufGetLInt (receiveBuf, receiveBufOffset);
						user := users.Find (receiverUin);
						
						IF user # NIL THEN
							
							]]></Span><Span style="Bold"><![CDATA[Server_InfoReply]]></Span><Span style="Normal"><![CDATA[ (client, user, sendBuf, s);
							
						END;
						
					| Base.SEND_TEXT_CODE:
						
						]]></Span><Span style="Bold"><![CDATA[Server_ACK]]></Span><Span style="Normal"><![CDATA[ (client, sendBuf, s);
						
						textCode := Base.BufGetString (receiveBuf, receiveBufOffset);
							
						IF textCode^ = "USER_DISCONNECTED" THEN
														
							MulticastStatus (clients, client, Base.USER_OFFLINE, sendBuf, s);
								
							clients.Remove (client);
									
						ELSE

							]]></Span><Span style="Stupid"><![CDATA[(*
							!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
							*)]]></Span><Span style="Normal"><![CDATA[
									
						END;
						
					ELSE
							
					END;
					
				END;
				
				]]></Span><Span style="Bold"><![CDATA[branch := branchPacketReceive;]]></Span><Span style="Normal"><![CDATA[
				
			]]></Span><Span style="Bold"><![CDATA[| branchEnd:]]></Span><Span style="Normal"><![CDATA[
			
				users.Store;
				FinalizeClients (clients);
				clients.Clear;
				
				]]></Span><Span style="Bold"><![CDATA[BEGIN {EXCLUSIVE}]]></Span><Span style="Normal"><![CDATA[
					terminated := TRUE
				]]></Span><Span style="Bold"><![CDATA[END;]]></Span><Span style="Normal"><![CDATA[
			
				]]></Span><Span style="Bold"><![CDATA[branch := branchTerminated;]]></Span><Span style="Normal"><![CDATA[
					
			ELSE
			
			END;
			
		UNTIL branch = branchTerminated;
		
	]]></Span><Span style="Bold"><![CDATA[END Instance;]]></Span><Span style="Normal"><![CDATA[
	
]]></Span><Span style="Bold"><![CDATA[VAR]]></Span><Span style="Normal"><![CDATA[
	instance: Instance;

]]></Span><Span style="Bold"><![CDATA[PROCEDURE Log (type, code : SHORTINT; msg: ARRAY OF CHAR; showOnKernelLog : BOOLEAN);
VAR message : AosEvents.Message;
BEGIN]]></Span><Span style="Normal"><![CDATA[
	COPY(msg, message);	
	AosEvents.AddEvent(moduleName, type, EventClass, EventSubclass, code, message, showOnKernelLog);
]]></Span><Span style="Bold"><![CDATA[END Log;]]></Span><Span style="Normal"><![CDATA[

]]></Span><Span style="Bold"><![CDATA[PROCEDURE Start* (p: PTR): PTR;
VAR
]]></Span><Span style="Normal"><![CDATA[	s: UDP.Socket;
	res: LONGINT;
	str: ARRAY 256 OF CHAR;]]></Span><Span style="Bold"><![CDATA[
BEGIN]]></Span><Span style="Normal"><![CDATA[
	IF instance = NIL THEN
		NEW (s, Base.serverPort, res);
		IF res = UDP.Ok THEN
			
			NEW (instance, s);
			
			Utilities.IntToStr (Base.serverPort, str);
			Utilities.Concat ("server started on port: ", str, str);
			]]></Span><Span style="Debug"><![CDATA[Log (AosEvents.Information, 0, str, TRUE);]]></Span><Span style="Normal"><![CDATA[
			
		ELSE
			
]]></Span><Span style="Debug"><![CDATA[			Log (AosEvents.Error, 0, "server NOT started!", TRUE);]]></Span><Span style="Normal"><![CDATA[
			
		END;
	END;
	RETURN NIL
]]></Span><Span style="Bold"><![CDATA[END Start;]]></Span><Span style="Normal"><![CDATA[

]]></Span><Span style="Bold"><![CDATA[PROCEDURE Stop* (p: PTR): PTR;
BEGIN]]></Span><Span style="Normal"><![CDATA[
	]]></Span><Span style="Bold"><![CDATA[Cleanup]]></Span><Span style="Normal"><![CDATA[;
	RETURN NIL
]]></Span><Span style="Bold"><![CDATA[END Stop;]]></Span><Span style="Normal"><![CDATA[

]]></Span><Span style="Comment"><![CDATA[(** Termination handler. *)
]]></Span><Span style="Bold"><![CDATA[PROCEDURE Cleanup;
BEGIN]]></Span><Span style="Normal"><![CDATA[
	IF instance # NIL THEN
	
		instance.Destroy;
		
	END;
]]></Span><Span style="Bold"><![CDATA[END Cleanup;]]></Span><Span style="Normal"><![CDATA[

]]></Span><Span style="Bold"><![CDATA[BEGIN]]></Span><Span style="Normal"><![CDATA[
	AosModules.InstallTermHandler (Cleanup);
]]></Span><Span style="Bold"><![CDATA[END UDPChatServer.]]></Span><Span style="Normal"><![CDATA[
]]></Span>

</Text>
