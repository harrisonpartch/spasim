MODULE TuringPll;
IMPORT Base,Raster, Random, Objects, WMRectangles, WMGraphics, Modules, Strings,
	WM := WMWindowManager, Math;

CONST
	M =1000; 
	M2 = (M DIV 2);
	MSIZE =1

TYPE Twindow* =  OBJECT(WM.BufferWindow)
VAR
	mesh1, mesh2, n1 : ARRAY M,M OF REAL;
	alive, dead: BOOLEAN;
	i : LONGINT;
		
PROCEDURE KeyEvent (ucs : LONGINT; flags : SET; keysym : LONGINT);
BEGIN
	CASE CHR(ucs) OF
		| 'q': Close
	ELSE
	END
END KeyEvent;

PROCEDURE &New*;
VAR 
	i, j : LONGINT;
BEGIN
	Init(M*MSIZE, M*MSIZE, FALSE);
	manager := WM.GetDefaultManager();
	manager.Add(100, 100, SELF, {WM.FlagFrame, WM.FlagClose, WM.FlagNoResizing});
	SetTitle(Strings.NewString("TuringPll Tutorial For Lac"));
	SetIcon(WMGraphics.LoadImage("WMIcons.tar://TuringCoatWnd.png", TRUE));
	FOR i := 0 TO M - 1 DO
		FOR j := 0 TO M - 1 DO
			mesh1[i, j] := 0;
			mesh2[i, j] := 0;
			n1[i, j] := 0
		END
	END;
	FOR i :=  1 TO M - 2 DO
		FOR j := 1 TO M - 2 DO
			IF random.Dice(100) > 98 THEN mesh1[i, j] := random.Dice(1000)/1000 END
		END
	END;
END New;

PROCEDURE Draw*(canvas : WMGraphics.Canvas; w, h, q : LONGINT);
BEGIN
	Draw^(canvas, w, h, 0)
END Draw;

PROCEDURE Close;
BEGIN
	alive := FALSE;
	BEGIN {EXCLUSIVE} AWAIT(dead); END;
	Close^;
END Close;

PROCEDURE Generation;
VAR i, j,im1,ip1,jm1,jp1: LONGINT;
BEGIN
	FOR i := 0 TO M - 1 DO
		FOR j := 0 TO M - 1 DO
			im1:=(i-1)MOD M; ip1:=(i+1)MOD M; jm1:=(j-1)MOD M; jp1:=(j+1)MOD M; 
			n1[i, j] := mesh1[im1, j] + mesh1[ip1, j] + mesh1[i, jm1] + mesh1[i, jp1]
				+ mesh1[im1, jm1] +  mesh1[ip1, jp1] + mesh1[ip1, jm1] + mesh1[im1, jp1]
		END
	END;
	FOR i := 0 TO M - 1 DO
		FOR j := 0 TO M - 1 DO
			(*  HERE ARE THE DIFFERENCE RULES! *)	
			mesh1[i, j] := mesh1[i, j] + n1[i, j]/(73+i/113) - mesh2[i, j];
			mesh2[i, j] := ABS(mesh2[i, j] +  mesh1[i, j]/100 - 0.0000073*j);   
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
	r,g,blue: INTEGER;
BEGIN
	Raster.InitMode(mode, Raster.srcCopy);
	FOR i := 0 TO M - 1 DO
		ix := i * MSIZE;
		FOR j := 0 TO M - 1 DO
			jy := j * MSIZE;
			r:=SHORT((ENTIER(mesh1[i, j] * 255)));
			g:=SHORT((ENTIER(mesh2[i, j] * 55)));
			blue:= SHORT(255- ENTIER(mesh1[i, j] * 1357) MOD 255);
			Raster.SetRGB(pix,r,g,blue);
			Raster.Fill(img, ix, jy, ix+MSIZE, jy+MSIZE, pix, mode)
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
	(*	Objects.Sleep(10) *)
	END;
	BEGIN {EXCLUSIVE} dead := TRUE; END;
END Twindow;

VAR
	tw: Twindow;
	random : Random.Generator;
	
PROCEDURE Open*;
BEGIN
	NEW(tw);
END Open;

PROCEDURE Close*;
BEGIN
	IF tw#NIL THEN tw.Close; tw:=NIL END;
END Close;

BEGIN
	Modules.InstallTermHandler(Close);
	NEW(random);
END TuringPll.

SystemTools.Free TuringPll ~

TuringPll.Open ~
