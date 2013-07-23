MODULE VNCTuringServer; (** AUTHOR "TF"; PURPOSE "VNC Tetris server"; *)
(** old aged *)

IMPORT Raster, KernelLog, Commands, Kernel, Random, VNCServer, WMRectangles,
	WMGraphics, Inputs, Modules, Files, IP, Dates, Strings;

CONST
	M =250; 
	M2 = M DIV 2;
	sze =2;
	W =M*sze;
	H= M*sze;

VAR 
	i, j : LONGINT;
	shuttingDown : BOOLEAN;
	server: VNCServer.Server;

TYPE
	TimeDate = RECORD h, m, s, day,month,year: LONGINT END;
	TT = OBJECT
	VAR
		mesh1, mesh2, n1 : ARRAY M,M OF REAL;
		alive, dead: BOOLEAN;
		i : LONGINT;
		timer : Kernel.Timer;
		mode : Raster.Mode;
		random : Random.Generator;
		lines, blocks, delay, delayDec: LONGINT;
		img : Raster.Image;
		paused, run: BOOLEAN;
		cheated: LONGINT;
		time : TimeDate;
		adrStr, timeStr:ARRAY 32 OF CHAR;
		vncInfo : VNCServer.VNCInfo;
		canvas : WMGraphics.BufferCanvas;

		PROCEDURE &Create*(vncInfo : VNCServer.VNCInfo);
		BEGIN
			NEW(img);
			Raster.Create(img, W, H, Raster.BGR565);
			Raster.InitMode(mode, Raster.srcCopy); NEW(timer); NEW(random); random.InitSeed(Kernel.GetTicks()); lines := 0;
			NEW(canvas, img);
			SELF.vncInfo := vncInfo;
			run := FALSE;
			seed
		END Create;

		PROCEDURE seed*;
		VAR 
			i, j : LONGINT;
		BEGIN
			FOR i := 0 TO M - 1 DO
				FOR j := 0 TO M - 1 DO
					mesh1[i, j] := 0;
					mesh2[i, j] := 0;
					n1[i, j] := 0
				END
			END;
			FOR i :=  1 TO M - 2 DO
				FOR j := 1 TO M - 2 DO
					IF random.Dice(100) > 80 THEN mesh1[i, j] := 0.9 END
				END
			END;
		END seed;
		
		PROCEDURE Run;
		BEGIN {EXCLUSIVE}
			run := TRUE
		END Run;

		PROCEDURE Bound(VAR x:LONGINT; min, max:LONGINT);
		BEGIN IF x<min THEN x:=min ELSE IF x>max THEN x:=max END END
		END Bound;

		PROCEDURE ClipAtImage(VAR x: WMRectangles.Rectangle; img:Raster.Image);
		BEGIN
			Bound(x.l, 0, img.width);Bound(x.r, 0, img.width);
			Bound(x.t, 0, img.height);Bound(x.b, 0, img.height)
		END ClipAtImage;

		PROCEDURE AddDirty(l, t, r, b:LONGINT);
		VAR x: WMRectangles.Rectangle;
		BEGIN
			WMRectangles.SetRect(x, l, t, r, b);
			ClipAtImage(x, img);
			IF vncInfo.agent # NIL THEN vncInfo.agent.AddDirty(x) END
		END AddDirty;

		PROCEDURE Close;
		BEGIN
			alive := FALSE
		END Close;

		PROCEDURE Generation;
		VAR i, j,im1,ip1,jm1,jp1: LONGINT;
		BEGIN
			FOR i := 0 TO M - 1 DO
				FOR j := 0 TO M - 1 DO
					im1:=(i-1)MOD M; ip1:=(i+2)MOD M; jm1:=(j-1)MOD M; jp1:=(j+2)MOD M; 
					n1[i, j] := mesh1[im1, j] + mesh1[ip1, j] + mesh1[i, jm1] + mesh1[i, jp1]
						+ mesh1[im1, jm1] +  mesh1[ip1, jp1] + mesh1[ip1, jm1] + mesh1[im1, jp1]
				END
			END;
			FOR i := 0 TO M - 1 DO
				FOR j := 0 TO M - 1 DO
					(*  HERE ARE THE DIFFERENCE RULES! *)			
					mesh1[i, j] := mesh1[i, j] + n1[i, j]/400- mesh2[i, j];
					mesh2[i, j] := mesh2[i, j] +  mesh1[i, j]/200 - 0.002;
		(*			mesh2[i, j] := ABS(mesh2[i, j] +  mesh1[i, j] / 10 - (Math.sqrt((M2-i)*(M2-i)+(M2-j)*(M2-j))/333 + 0.001)); *)
					IF mesh1[i, j] < 0 THEN mesh1[i, j] := 0 END;
					IF mesh2[i, j] < 0 THEN mesh2[i, j] := 0 END;
					IF mesh1[i, j] > 1 THEN mesh1[i, j] := 1 END;
					IF mesh2[i, j] > 1 THEN mesh2[i, j] := 1 END;
				END;
			END;
		END Generation;		

		PROCEDURE Draw;
		VAR 
			i, j, ix, jy : LONGINT;
			pix : Raster.Pixel;
			mode : Raster.Mode;
		BEGIN
			Raster.InitMode(mode, Raster.srcCopy);
			FOR i := 0 TO M - 1 DO
				ix := i * sze;
				FOR j := 0 TO M - 1 DO
					jy := j * sze;
					Raster.SetRGB(pix, SHORT((255-ENTIER(mesh1[i, j] * 255)) ),0, SHORT((255-ENTIER(mesh2[i, j] * 255)) ));
					Raster.Fill(img, ix, jy, ix+sze, jy+sze, pix, mode)
				END
			END;
			Raster.SetRGB(pix, 100,100,100);
			Raster.Fill(img, 0,0,W,H,pix, mode);
			AddDirty(0, 0, W,H)
		END Draw;	

		PROCEDURE KeyPressed(ucs : LONGINT; flags: SET; keysym: LONGINT);
		VAR ignore : BOOLEAN;
		BEGIN {EXCLUSIVE}
			IF ~alive THEN RETURN END;
			IF Inputs.Release IN flags THEN RETURN END;		
			IF (ucs = ORD("q")) THEN Close END; 			
		END KeyPressed;
	
		PROCEDURE AwaitRun;
		BEGIN {EXCLUSIVE}
			AWAIT(run)
		END AwaitRun;

	BEGIN {ACTIVE}
		AwaitRun;
		IP.AdrToStr(vncInfo.connection.fip, adrStr);
		KernelLog.Enter;
		Strings.DateToStr(Dates.Now(), timeStr); KernelLog.String(timeStr); KernelLog.String(" ");
		Strings.TimeToStr(Dates.Now(), timeStr); KernelLog.String(timeStr);
		KernelLog.String(" IP: "); KernelLog.String(adrStr);
		KernelLog.String(":"); KernelLog.Int(vncInfo.connection.fport, 5);
		KernelLog.String(" started");
		KernelLog.Exit;
		alive:=TRUE;
		seed;
		Draw;
		WHILE alive DO
			timer.Sleep(1000); 
			Generation;
			Draw;	
		END;

		KernelLog.Enter;
		Strings.DateToStr(Dates.Now(), timeStr); KernelLog.String(timeStr); KernelLog.String(" ");
		Strings.TimeToStr(Dates.Now(), timeStr); KernelLog.String(timeStr);
		KernelLog.String(" IP: "); KernelLog.String(adrStr);
		KernelLog.String(":"); KernelLog.Int(vncInfo.connection.fport, 5);
		KernelLog.String(" Score: "); KernelLog.Int(lines * 10 + blocks, 1);
		IF (cheated > 0) THEN KernelLog.String(" (cheated "); KernelLog.Int(cheated, 0); KernelLog.String(" times)") END;
		KernelLog.Exit;
	END TT;

PROCEDURE StartTT(vncInfo : VNCServer.VNCInfo);
VAR t: TT;
BEGIN
	NEW(t, vncInfo);
	vncInfo.img := t.img;
	vncInfo.kl := t.KeyPressed;
	t.Run
END StartTT;

(* Standard Procedures *)

PROCEDURE Max(x, y: LONGINT): LONGINT;
BEGIN
	IF x > y THEN RETURN x ELSE RETURN y END
END Max;

PROCEDURE Run*(context : Commands.Context);
BEGIN
	server := VNCServer.OpenService(5999, StartTT);
	context.out.String("VNC Turing server started."); context.out.Ln;
END Run;

PROCEDURE StopNew*(context : Commands.Context);
BEGIN {EXCLUSIVE}
	shuttingDown := TRUE;
	context.out.String("VNC Turing server shut down."); context.out.Ln;
END StopNew;

PROCEDURE Uninstall*;
VAR f: Files.File; w: Files.Writer;
BEGIN
	IF server # NIL THEN
		server.Close
	END;
END Uninstall;

PROCEDURE Cleanup;
BEGIN
	Uninstall;
END Cleanup;

BEGIN
	Modules.InstallTermHandler(Cleanup)
END VNCTuringServer.

VNCTuringServer.Run
VNCTuringServer.StopNew
VNCTuringServer.Uninstall

SystemTools.Free VNCTuringServer VNCServer~