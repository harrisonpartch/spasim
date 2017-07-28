MODULE WarpMouse;
IMPORT Machine, X11Api,  XDisplay,  Out:= KernelLog;

PROCEDURE warp*(x,y:LONGINT);
BEGIN
		Machine.Acquire(Machine.X11);
		X11Api.WarpPointer(display.xdisp, X11Api.None, display.primary,0,0,0,0,x,y);
		Machine.Release(Machine.X11);
END warp;

PROCEDURE Open*;
END Open;

VAR
	display:  XDisplay.Display;

BEGIN
	display := XDisplay.DISP;
END WarpMouse.

WarpMouse.Open

SystemTools.Free WarpMouse~


