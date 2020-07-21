MODULE WarpMouse;
IMPORT Machine, X11,  XDisplay,  Out:= KernelLog;

PROCEDURE warp*(x,y:INTEGER);
BEGIN
	(*	Machine.Acquire(Machine.X11); *)
		X11.WarpPointer(display, X11.None, X11.None,0,0,0,0,x,y);
	(*	Machine.Release(Machine.X11); *)
END warp;
PROCEDURE Open*;
BEGIN
	warp(100,100)
END Open;

VAR
	display:  X11.DisplayPtr;

BEGIN
	display := XDisplay.DISP;
END WarpMouse.

WarpMouse.Open

System.Free WarpMouse~


