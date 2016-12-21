MODULE Snowfall2;	

IMPORT
	Raster, Random, Objects, WMRectangles, WMGraphics, Modules, Strings,
	WM := WMWindowManager, WMMessages, Out:=DebugLog;

CONST
	m = 300;
	size = 3;


TYPE cell = RECORD
		type: CHAR
		END;
		
TYPE KillerMsg = OBJECT
		END KillerMsg;
		
TYPE Grid = OBJECT
	VAR
		grid: ARRAY m,m OF cell;	 
		poisongrid: ARRAY m,m OF SHORTINT;
	PROCEDURE clear;
		VAR i, j : LONGINT;
		BEGIN
			FOR i := 0 TO m - 1 DO
				FOR j := 0 TO m - 1 DO
					grid[i, j].type := ' ';
				END
			END;
		END clear;		

	BEGIN
		clear		
	END Grid;

TYPE TCW* =  OBJECT(WM.BufferWindow)
	VAR
		mesh, nmesh, amesh: Grid;
		random : Random.Generator;
		alive, dead, pause, alpha, pdown,switchingchar : BOOLEAN;
		currenttype: CHAR;
		i,j,mousex, mousey, count: LONGINT;

		PROCEDURE &New*(alpha : BOOLEAN);
		VAR i, j : LONGINT;
		BEGIN
			Init(size*m, size*m, alpha);
			SELF.alpha :=alpha;
			manager := WM.GetDefaultManager();
			manager.Add(100, 100, SELF, {WM.FlagFrame, WM.FlagClose, WM.FlagNoResizing});

			SetTitle(Strings.NewString("Turing"));
			SetIcon(WMGraphics.LoadImage("WMIcons.tar://Snowfall.png", TRUE));

			NEW(random);
			NEW(mesh);
			NEW(nmesh);
			currenttype:='a';
			clear;
		END New;
		
		PROCEDURE clear;
		VAR i, j : LONGINT;
		BEGIN
			FOR i := 0 TO m - 1 DO
				FOR j := 0 TO m - 1 DO
					mesh.grid[i, j].type := ' ';
				END
			END;
			FOR i :=  1 TO m - 2 DO
				FOR j := 1 TO m - 2 DO
					IF random.Dice(100) > 95 THEN mesh.grid[i, j].type := 'a' END
				END
			END;
		END clear;		

		PROCEDURE poisonclear;
		VAR i, j : LONGINT;
		BEGIN
			FOR i := 0 TO m - 1 DO
				FOR j := 0 TO m - 1 DO
					DEC(mesh.poisongrid[i, j])
				END
			END;
		END poisonclear;		
		

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
		VAR i, j: LONGINT;
		BEGIN
			FOR i := 2 TO m - 3 DO 
				FOR j:= 2 TO m-3 DO
					CASE mesh.grid[i,j].type OF
					'a':				
						IF mesh.grid[i,j+1].type=' ' THEN
							nmesh.grid[i,j].type:=' ';
							nmesh.grid[i,j+1].type:='a'
						ELSIF mesh.grid[i+1,j+1].type=' ' THEN
							nmesh.grid[i,j].type:=' ';
							nmesh.grid[i+1,j+1].type:='a'					
						ELSIF mesh.grid[i-1,j+1].type=' ' THEN
							nmesh.grid[i,j].type:=' ';
							nmesh.grid[i-1,j+1].type:='a';
						ELSE
							nmesh.grid[i,j].type:='a';	
						END		
					|'b':
						IF mesh.grid[i,j+1].type=' ' THEN
							nmesh.grid[i,j].type:=' ';
							nmesh.grid[i,j+1].type:='b'
						ELSIF mesh.grid[i+1,j+1].type=' ' THEN
							nmesh.grid[i,j].type:=' ';
							nmesh.grid[i+1,j+1].type:='b'					
						ELSIF mesh.grid[i-1,j+1].type=' ' THEN
							nmesh.grid[i,j].type:=' ';
							nmesh.grid[i+1,j+1].type:='b'			
						ELSE
							nmesh.grid[i,j].type:='b';							
						END	
					|'g': nmesh.grid[i,j].type:='z'
					|'z': nmesh.grid[i,j].type:='g'
					|'t' : INC(mesh.poisongrid[i,j]);
							IF mesh.poisongrid[i,j]>8 THEN 
								nmesh.grid[i,j].type:=' '
							ELSIF  mesh.poisongrid[i,j]=0 THEN
								nmesh.grid[i,j].type:='t';
								IF (mesh.grid[i,j-1].type=' ') &  (nmesh.grid[i,j-1].type=' ') THEN nmesh.grid[i,j-1].type:='t' END;
								IF (mesh.grid[i,j+1].type=' ') &  (nmesh.grid[i,j+1].type=' ') THEN nmesh.grid[i,j+1].type:='t' END;
								IF (mesh.grid[i+1,j].type=' ') &  (nmesh.grid[i+1,j].type=' ') THEN nmesh.grid[i+1,j].type:='t' END;
								IF (mesh.grid[i+1,j].type=' ') &  (nmesh.grid[i-1,j].type=' ') THEN nmesh.grid[i-1,j].type:='t' END;
ELSE
								nmesh.grid[i,j].type:='t';
							END
					ELSE
						
					END
				END
			END;
		FOR i := 0 TO m - 1 DO
			FOR j := 0 TO m - 1 DO
					mesh.grid[i,j]:=nmesh.grid[i,j];
				END;
			END;
		END Generation;

		PROCEDURE DrawIt;
		VAR i, j, ix, jy : LONGINT;
			pix : Raster.Pixel;
			mode : Raster.Mode;
		BEGIN
			Raster.InitMode(mode, Raster.srcCopy);
			FOR i := 0 TO m - 1 DO
				ix := i * size;
				FOR j := 0 TO m - 1 DO
					jy := j * size;
					CASE mesh.grid[i,j].type OF
						'a': Raster.SetRGB(pix, 255, 0, 0)
						| 'b': Raster.SetRGB(pix, 0, 0, 255)
						| 'g': Raster.SetRGB(pix, 0, 255,0)
						| 'z': Raster.SetRGB(pix, 255, 255,0)			
						| 't': Raster.SetRGB(pix, 100, 100,255)						
						| ' ': Raster.SetRGB(pix, 0, 0, 0);
					ELSE
						Raster.SetRGB(pix, 0,255, 0)
					END;
					Raster.Fill(img, ix, jy, ix+size, jy+size, pix, mode)
				END
			END;
			Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()))
	END DrawIt;

	PROCEDURE PointerDown (x, y : LONGINT; keys : SET);
	BEGIN
		pdown:=TRUE;
	END PointerDown;
	
	PROCEDURE PointerUp (x, y : LONGINT; keys : SET);
	BEGIN
		pdown:=FALSE;
	END PointerUp;
	
	PROCEDURE PointerMove (x, y : LONGINT; keys : SET);
	BEGIN
		mousex:=x DIV size;
		mousey:=y DIV size;	
	END PointerMove;
	
	PROCEDURE KeyEvent (ucs : LONGINT; flags : SET; keysym : LONGINT);
	BEGIN
		IF switchingchar THEN
			currenttype:=CHR(ucs);
			switchingchar:=FALSE
		ELSE
			CASE CHR(ucs) OF
				'p': pause:=~pause
				|'q': Close
				|'x': clear
				|'s': switchingchar:=TRUE
			ELSE
			END
		END
	END KeyEvent;

	BEGIN {ACTIVE}
		alive := TRUE;
		Objects.SetPriority(Objects.Low);
		Out.String("the snow is beginning to fall...");
		WHILE alive DO
			IF ~pause THEN
				IF pdown & (mousex>0) & (mousex<m-2) &  (mousey>0) & (mousey<m-2) THEN
					mesh.grid[mousex,mousey].type:= currenttype
				END;
				Generation;
				DrawIt;
				count:=(count+1)MOD 5;
				IF count=0 THEN poisonclear END;
			END
		END;
		BEGIN {EXCLUSIVE} dead := TRUE; END;
	END TCW;

VAR
	nofWindows : LONGINT;

PROCEDURE OpenAlpha*;
VAR window : TCW;
BEGIN
	NEW(window, TRUE);
END OpenAlpha;

PROCEDURE Open*;
VAR window : TCW;
BEGIN
	NEW(window, FALSE);
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
END Snowfall2.

SystemTools.Free Snowfall2 ~

Snowfall2.Open ~
