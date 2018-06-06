MODULE Turing;	

IMPORT
	Raster, Random, Objects, WMRectangles, WMGraphics, Modules, Strings,
	WM := WMWindowManager, WMMessages;

CONST
	M =350;
	N = 350;
	size =2;
	
	WindowWidth = M * size; WindowHeight = N * size;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	Stripe = OBJECT
	VAR
		GO: BOOLEAN;
		I: LONGINT;
		
	PROCEDURE go;
	BEGIN{EXCLUSIVE}
		GO:=TRUE
	END go;
	
	BEGIN{ACTIVE, PRIORITY(Objects.Low)}
		REPEAT
			BEGIN{EXCLUSIVE}
				AWAIT(GO)
			END;

			BEGIN{EXCLUSIVE}
				GO:=FALSE
			END;
			
		UNTIL FALSE;
	END Stripe;	
	
	TCW* =  OBJECT(WM.BufferWindow)
	VAR
		mesh1, mesh2, n1 : ARRAY M, M OF REAL;
		random : Random.Generator;
		alive, dead: BOOLEAN;
		i : LONGINT;

		PROCEDURE &New*;
		VAR i, j : LONGINT;
		BEGIN
			Init(WindowWidth, WindowHeight, FALSE);
			manager := WM.GetDefaultManager();
			manager.Add(100, 100, SELF, {WM.FlagFrame, WM.FlagClose, WM.FlagNoResizing});

			SetTitle(Strings.NewString("Turing"));
			SetIcon(WMGraphics.LoadImage("WMIcons.tar://TuringCoatWnd.png", TRUE));

			NEW(random);

			FOR i := 0 TO M - 1 DO
				FOR j := 0 TO M - 1 DO
					mesh1[i, j] := 0;
					mesh2[i, j] := 0;
					n1[i, j] := 0
				END
			END;
			FOR i :=  1 TO M - 2 DO
				FOR j := 1 TO M - 2 DO
					IF random.Dice(100) > 95 THEN mesh1[i, j] := random.Dice(1000)/1000 END
				END
			END;
			IncCount;
		END New;

		PROCEDURE Handle(VAR m: WMMessages.Message);
		BEGIN
			IF (m.msgType = WMMessages.MsgExt) & (m.ext # NIL) & (m.ext IS KillerMsg) THEN
				Close;
			ELSE Handle^(m)
			END
		END Handle;

		PROCEDURE Draw*(canvas : WMGraphics.Canvas; w, h, q : LONGINT);
		BEGIN
			Draw^(canvas, w, h, 0)
		END Draw;

		PROCEDURE Close;
		BEGIN
			alive := FALSE;
			BEGIN {EXCLUSIVE} AWAIT(dead); END;
			Close^;
			DecCount;
		END Close;

		PROCEDURE Generation;
		VAR i, j : LONGINT;
			 a,b,c: REAL;
		BEGIN
			FOR i := 1 TO M - 2 DO
				n1[i, 0] := mesh1[i - 1, 0] + mesh1[i + 1, 0] + mesh1[i, M - 1] + mesh1[i, 1]
				 	+ mesh1[i - 1, M - 1] +  mesh1[i + 1, 1] + mesh1[i + 1, M - 1] + mesh1[i - 1,  1];
				n1[i, M - 1] := mesh1[i - 1, M - 1] + mesh1[i + 1, M - 1] + mesh1[i, M - 2] + mesh1[i, 0]
					+ mesh1[i - 1, M - 2] +  mesh1[i + 1, 0] + mesh1[i + 1, M - 2] + mesh1[i - 1, 0];
				END;
			FOR j := 1 TO M - 2 DO
				n1[0, j] := mesh1[M - 1, j] + mesh1[1, j] + mesh1[0, j - 1] + mesh1[0, j + 1]
					+ mesh1[M - 1, j - 1] +  mesh1[1, j + 1] + mesh1[1, j - 1] + mesh1[M - 1, j + 1];
				n1[M - 1, j] := mesh1[M - 2, j] + mesh1[0, j] + mesh1[M - 1, j - 1] + mesh1[M - 1, j + 1]
					+ mesh1[M - 2, j - 1] +  mesh1[0, j + 1] + mesh1[0, j - 1] + mesh1[M - 2, j + 1]
			END;

			FOR i := 1 TO M - 2 DO
				FOR j := 1 TO M - 2 DO
					n1[i, j] := mesh1[i - 1, j] + mesh1[i + 1, j] + mesh1[i, j - 1] + mesh1[i, j + 1]
						+ mesh1[i - 1, j - 1] +  mesh1[i + 1, j + 1] + mesh1[i + 1, j - 1] + mesh1[i - 1, j + 1]
				END
			END; 
			a:=1;
			b:=10;
			FOR i := 1 TO M - 2 DO
				a:=a+0.48;
				b:=b+0.024;
				c:=0.0;
				FOR j := 1 TO M - 2 DO
					(*  HERE ARE THE DIFFERENCE RULES! *)		
					c:=c+0.0000711;
					mesh1[i, j] := mesh1[i, j] + n1[i, j] / a- (mesh2[i, j] * mesh2[i, j])  ;
					mesh2[i, j] := mesh2[i, j] +  mesh1[i, j] / b - c  ;
					IF mesh1[i, j] < 0 THEN mesh1[i, j] := 0 END;
					IF mesh2[i, j] < 0 THEN mesh2[i, j] := 0 END;
					IF mesh1[i, j] > 1 THEN mesh1[i, j] := 1 END;
					IF mesh2[i, j] > 1 THEN mesh2[i, j] := 1 END;
				END;
			END;
		END Generation;

		PROCEDURE DrawIt;
		VAR i, j, ix, jy : LONGINT;
			pix : Raster.Pixel;
			mode : Raster.Mode;
		BEGIN
			Raster.InitMode(mode, Raster.srcCopy);
			FOR i := 0 TO M - 1 DO
				ix := i * size ;
				FOR j := 0 TO M - 1 DO
					jy := j * size;
					Raster.SetRGB(pix, SHORT((200-ENTIER(mesh1[i, j] * 200)) ),SHORT((255-ENTIER(n1[i, j] * 255)) ), SHORT((ENTIER(mesh2[i, j] * 200)) ));
					Raster.Fill(img, ix, jy, ix+size, jy+size, pix, mode)
				END
			END;
			Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()))
		END DrawIt;

	BEGIN {ACTIVE}
		alive := TRUE;
		Objects.SetPriority(Objects.Low);
		WHILE alive DO
			FOR i := 0 TO 0 DO Generation END;
			DrawIt;
		END;
		BEGIN {EXCLUSIVE} dead := TRUE; END;
	END TCW;

VAR
	nofWindows : LONGINT;

PROCEDURE Open*;
VAR window : TCW;
BEGIN
	NEW(window);
	INC(nofWindows);
END Open;

PROCEDURE IncCount;
BEGIN {EXCLUSIVE}
	INC(nofWindows);
END IncCount;

PROCEDURE DecCount;
BEGIN {EXCLUSIVE}
	DEC(nofWindows);
END DecCount;

PROCEDURE Cleanup;
VAR die : KillerMsg;
	 msg : WMMessages.Message;
	 m : WM.WindowManager;
BEGIN {EXCLUSIVE}
	NEW(die); msg.ext := die; msg.msgType := WMMessages.MsgExt;
	m := WM.GetDefaultManager();
	m.Broadcast(msg);
	AWAIT(nofWindows = 0);
END Cleanup;

BEGIN
	Modules.InstallTermHandler(Cleanup);
END Turing.

SystemTools.Free Turing ~

Turing.Open ~
