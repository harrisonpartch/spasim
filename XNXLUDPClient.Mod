MODULE XNXLUDPClient; (** AUTHOR "SAGE"; PURPOSE "XNXL Chat Client" *)

IMPORT 
	Base := XNXLUDPBase, XNXLUDPSecret, UDP, IP, DNS,
	Dates, Strings,
	WMStandardComponents, WMComponents, WM := WMWindowManager,
	WMDialogs, WMEditors, WMRectangles,
	Modules, Texts, UTF8Strings, Inputs, Kernel, Events,
	Out:=DebugLog, XNXLBase;

CONST
	serverStr = "127.0.0.1";

	branchInit					= 0;
	branchPacketReceive	= 1;
	branchVersionCheck	= 2;
	branchPacketHandle	= 3;
	branchEnd					= 4;
	branchTerminated		= 5;

	moduleName = "XNXLChatClient";

	(* Event classification as in Events.XML *)
	EventClass = 3; (* XNXL Chat *)
	EventSubclass = 3; (* XNXL Chat Client *)

	(* Window size at application startup *)
	WindowWidth = 40 * 12;
	WindowHeight = 30 * 12;
	
TYPE PT=XNXLBase.PT;

TYPE

	msg = ARRAY 1500 OF CHAR; (* Maximum allowed message length caused by Network MTU limit *)

	String = Strings.String;

	Instance = OBJECT
	VAR
		next: Instance;

		server: ARRAY 256 OF CHAR;
		CRLF: ARRAY 3 OF CHAR;

		login: ARRAY 9 OF CHAR;
		password, passwordConfirm: ARRAY 33 OF CHAR;
		shortName, fullName, eMail: ARRAY 65 OF CHAR;

		uin, res, n: LONGINT;
		dt: Dates.DateTime;

		keepAliveTimer: Kernel.MilliTimer;
		xtimer: Kernel.Timer;

		s: UDP.Socket;
		serverIP, ip: IP.Adr;
		running, terminated, onLine: BOOLEAN;

		str1, str2: ARRAY 256 OF CHAR;

		branch, command, seqNum, messageType, inSeqNum, outSeqNum: INTEGER;
		senderUin, receiverUin, port, len, receiveBufOffset: LONGINT;
		sendBuf-: Base.Buffer;

		receiveBuf, message, string: String;

		userInfos: Base.List;
		userInfo: Base.UserInfo;

		ACKReqList: Base.List;
		ACKReq: Base.ACKRec;

		csa: Texts.CharacterStyleArray;
		psa: Texts.ParagraphStyleArray;

	PROCEDURE &New*(udp: UDP.Socket);
	BEGIN
		s:=udp;
		(* Chain the previous instance(s) to this new one, for guaranteed cleanup. *)
		next := instances;
		instances := SELF;
		INC(instancenumber)
	END New;

	PROCEDURE Finalize;
	BEGIN
		running := FALSE;

		BEGIN {EXCLUSIVE}
			
			AWAIT (terminated)
		END;

		FreeInstance (SELF);

	END Finalize;

	PROCEDURE Client_ACK (seqNum: INTEGER; uin: LONGINT; sendBuf: Base.Buffer;
		s: UDP.Socket; ip: IP.Adr);
	VAR
		res: LONGINT;
		string: String;
	BEGIN {EXCLUSIVE}
		Base.ClientPacketInit (Base.ACK, uin, sendBuf);
		string := sendBuf.GetString ();
		s.Send (ip, Base.serverPort, string^, 0, sendBuf.GetLength (), res);
	END Client_ACK;

	PROCEDURE Client_NewUserReg (password, shortName, fullName, eMail: ARRAY OF CHAR;
		VAR seqNum: INTEGER; sendBuf: Base.Buffer;
		s: UDP.Socket; ip: IP.Adr);
	VAR
		len, res: LONGINT;
		string: String;
	BEGIN {EXCLUSIVE}
		Out.String("Client_NewUserReg");
		Base.ClientPacketInit (Base.NEW_USER_REG,  0, sendBuf);

		NEW (ACKReq);
		ACKReq.seqNum := seqNum;
		ACKReqList.Add (ACKReq);

		INC (seqNum);

		len := Strings.Length (password) + 1;
		sendBuf.AddInt (len, 2);
		sendBuf.Add (password, 0, len, TRUE, res);

		len := Strings.Length (shortName) + 1;
		sendBuf.AddInt (len, 2);
		sendBuf.Add (shortName, 0, len, TRUE, res);

		len := Strings.Length (fullName) + 1;
		sendBuf.AddInt (len, 2);
		sendBuf.Add (fullName, 0, len, TRUE, res);

		len := Strings.Length (eMail) + 1;
		sendBuf.AddInt (len, 2);
		sendBuf.Add (eMail, 0, len, TRUE, res);

		string := sendBuf.GetString ();
		Out.String(string^); (*! Necati *)
		s.Send (ip, Base.serverPort, string^, 0, sendBuf.GetLength (), res);
		Out.Int(res,4);
	END Client_NewUserReg;

	PROCEDURE Client_Login (password: ARRAY OF CHAR;
		VAR seqNum: INTEGER; uin: LONGINT; sendBuf: Base.Buffer;
		s: UDP.Socket; ip: IP.Adr);
	VAR
		len, res: LONGINT;
		string: String;
	BEGIN {EXCLUSIVE}
		Out.String("Client_Login");
		Out.String(password);
		Base.ClientPacketInit (Base.LOGIN, uin, sendBuf);

		NEW (ACKReq);
		ACKReq.seqNum := seqNum;
		ACKReqList.Add (ACKReq);

		INC (seqNum);

		len := Strings.Length (password) + 1;
		sendBuf.AddInt (len, 2);
		sendBuf.Add (password, 0, len, TRUE, res);

		string := sendBuf.GetString ();
		s.Send (ip, Base.serverPort, string^, 0, sendBuf.GetLength (), res);
		Out.Int(res,4);
	END Client_Login;

	PROCEDURE Client_InfoReq (userUIN: LONGINT; VAR seqNum: INTEGER;
		uin: LONGINT; sendBuf: Base.Buffer;
		s: UDP.Socket; ip: IP.Adr);
	VAR
		res: LONGINT;
		string: String;
	BEGIN {EXCLUSIVE}
		Base.ClientPacketInit (Base.INFO_REQ, uin, sendBuf);

		NEW (ACKReq);
		ACKReq.seqNum := seqNum;
		ACKReqList.Add (ACKReq);

		INC (seqNum);

		sendBuf.AddInt (userUIN, 4);

		string := sendBuf.GetString ();
		s.Send (ip, Base.serverPort, string^, 0, sendBuf.GetLength (), res);
	END Client_InfoReq;
	
	PROCEDURE Stroke(x,y,z,resolution,voxel: LONGINT; 
		VAR seqNum: INTEGER; uin: LONGINT; sendBuf: Base.Buffer;
		s: UDP.Socket; ip: IP.Adr);
	VAR
		string: String;
		len, res: LONGINT;
	BEGIN {EXCLUSIVE}
		Base.ClientPacketInit (Base.STROKE, uin, sendBuf);
		sendBuf.AddInt (666, 4);
		sendBuf.AddInt (x, 4);
		sendBuf.AddInt (y, 4);
		sendBuf.AddInt (z, 4);
		sendBuf.AddInt (resolution, 4);
		sendBuf.AddInt (voxel, 4);	
		string := sendBuf.GetString ();
		s.Send (serverIP, Base.serverPort, string^, 0, sendBuf.GetLength (), res);
	END Stroke;	

	PROCEDURE Client_SendTextCode (code: String;
		VAR seqNum: INTEGER; uin: LONGINT; sendBuf: Base.Buffer;
		s: UDP.Socket; ip: IP.Adr);
	VAR
		string: String;
		len, res: LONGINT;
	BEGIN {EXCLUSIVE}
		Base.ClientPacketInit (Base.SEND_TEXT_CODE, uin, sendBuf);

		NEW (ACKReq);
		ACKReq.seqNum := seqNum;
		ACKReqList.Add (ACKReq);

		INC (seqNum);

		len := Strings.Length (code^) + 1;
		sendBuf.AddInt (len, 2);
		sendBuf.Add (code^, 0, len, TRUE, res);

		string := sendBuf.GetString ();
		s.Send (serverIP, Base.serverPort, string^, 0, sendBuf.GetLength (), res);
	END Client_SendTextCode;

	PROCEDURE Client_KeepAlive (VAR seqNum: INTEGER; uin: LONGINT; sendBuf: Base.Buffer;
		s: UDP.Socket; ip: IP.Adr);
	VAR
		res: LONGINT;
		string: String;
	BEGIN {EXCLUSIVE}
		Base.ClientPacketInit (Base.KEEP_ALIVE,  uin, sendBuf);

		NEW (ACKReq);
		ACKReq.seqNum := seqNum;
		ACKReqList.Add (ACKReq);

		INC (seqNum);

		string := sendBuf.GetString ();
		s.Send (ip, Base.serverPort, string^, 0, sendBuf.GetLength (), res);
	END Client_KeepAlive;

	PROCEDURE FindUserInfo (list: Base.List; uin: LONGINT): Base.UserInfo;
	VAR
		i: LONGINT;
		u: Base.UserInfo;
		ptr: ANY;
	BEGIN
		i := 0;
		WHILE i < list.GetCount () DO
			ptr := list.GetItem (i);
			u := ptr (Base.UserInfo);
			IF uin = u.uin THEN
				RETURN u;
			END;
			INC (i);
		END;
		RETURN NIL;
	END FindUserInfo;

	PROCEDURE Log (type, code : SHORTINT; msg: ARRAY OF CHAR; showOnKernelLog : BOOLEAN);
	VAR message : Events.Message;
	BEGIN
		COPY(msg, message);
		Events.AddEvent(moduleName, type, EventClass, EventSubclass, code, message, showOnKernelLog);
	END Log;

	 BEGIN {ACTIVE}

		branch := branchInit;
		NEW(xtimer);
		Out.String("Instance! ");
		REPEAT
			CASE branch OF
			| branchInit:
				server := serverStr;
				running := FALSE;
				terminated := TRUE;
				onLine := FALSE;

				branch := branchEnd;

				csa := Texts.GetCharacterStyleArray ();
				psa := Texts.GetParagraphStyleArray ();

				serverIP := IP.StrToAdr (Base.SERVER);
				IF ~IP.IsNilAdr (serverIP) THEN
					CRLF[0] := 0DX;
					CRLF[1] := 0AX;
					CRLF[2] := 0X;
					NEW (receiveBuf, Base.MaxUDPDataLen);
					NEW (sendBuf, 0);
					NEW (ACKReqList);
					uin:=XNXLUDPSecret.UIN;
					branch := branchPacketReceive;
				END;
			| branchPacketReceive:				
					s.Receive (receiveBuf^, 0, Base.MaxUDPDataLen, 1, ip, port, len, res);
					IF (res = UDP.Ok) & (len > 0) THEN
						receiveBufOffset := 0;
						branch := branchPacketHandle;
					END;
			| branchPacketHandle:	
			       n:=Base.BufGetLInt(receiveBuf, receiveBufOffset); (* waste spacer. this one isn't read correctly *)
				p.x:=Base.BufGetLInt(receiveBuf, receiveBufOffset);
				p.x:=p.x/1048576;
			       p.y:=Base.BufGetLInt(receiveBuf, receiveBufOffset);
		 		p.y:=p.y/1048576;
				p.z:=Base.BufGetLInt(receiveBuf, receiveBufOffset);
				p.z:=p.z/1048576;								
			       resolution:=Base.BufGetLInt(receiveBuf, receiveBufOffset);
				vox:=Base.BufGetLInt(receiveBuf, receiveBufOffset);
				vox:=vox MOD 20;
				XNXLBase.world.stroke(p,resolution,XNXLBase.vlist[vox]);	
				branch := branchPacketReceive;	
			| branchEnd:
				Out.String("branchEnd:");
				BEGIN {EXCLUSIVE}
					terminated := TRUE
				END;
				branch := branchTerminated;
			ELSE
			END;
		UNTIL branch = branchTerminated;
	END Instance;

VAR
	instances: Instance;
	instancenumber: INTEGER;
	resolution,vox: LONGINT;
	p: XNXLBase.PT;

(* Remove the instance from the linked list *)
PROCEDURE FreeInstance (free: Instance);
VAR
	instance: Instance;
BEGIN
	IF free = instances THEN		(* the element to free is the first in list *)
		instances := instances.next
	ELSE
		instance := instances;
		WHILE (instance # NIL) & (instance.next # free) DO
			instance := instance.next
		END;
		IF instance # NIL THEN			(* not yet at the end of the chain: unchain it*)
			instance.next := free.next
		END
	END
END FreeInstance;

PROCEDURE stroke*(p:PT; resolution, vox: LONGINT);
VAR
	instance: Instance;
	a,b,c: LONGINT;
BEGIN
	instance:=instances;
	instance.Stroke (ENTIER(p.x*1048576), ENTIER(p.y*1048576), ENTIER(p.z*1048576), resolution,vox,instance.outSeqNum, instance.uin, instance.sendBuf, instance.s, instance.serverIP); 
END stroke;

PROCEDURE Open*;
VAR
	instance: Instance;
	s:UDP.Socket;
	res: LONGINT;
BEGIN
	NEW (s, UDP.NilPort, res);
	Out.Int(res,0);
	NEW (instance,s);
END Open;

PROCEDURE Cleanup;
BEGIN
	WHILE instances # NIL DO
		instances.Finalize ();
	END
END Cleanup;

BEGIN
	Modules.InstallTermHandler (Cleanup);
	(* Open *)
END XNXLUDPClient.

