 OpenGL Framework for A2- WinAos and LinuxAos versions

# =================================================
# OpenGL 4.5 - Header translation
# Version 4.5
# Date : 17.10.2014
# Works with : LinuxAos and WinAos
#
# All contributions and corrections are welcome ...
# Available at:  https://github.com/fnec/opengloberon
# =================================================

System.FreeDownTo OpenGLConst ~

System.CollectGarbage ~ 

# 1- Compile platform dependent bindings:

# LinuxAos:

Compiler.Compile
	OpenGLConst.Mod
	Unix.OpenGL.Mod
	Unix.GLU.Mod	
	GLShaderUtils.Mod
	Unix.GLContext.Mod	
	Unix.WMGLWindow.Mod
	Unix.GLXinfo.Mod
	GLShadersBuild.Mod
	Unix.XF86VMode.Mod
	Unix.OGLWindow.Mod	
	~
	
	GLXinfo.Do ~  # display opengl info
	
# WinAos:

Compiler.Compile 
	OpenGLConst.Mod
	Win32.WinApi.Mod	
	Win32.OpenGL.Mod
	Win32.GLU.Mod
	GLShaderUtils.Mod	
	Win32.WMGLWindow.Mod
	Win32.GLContext.Mod	
	Win32.WGLinfo.Mod
	GLShadersBuild.Mod
	Win32.OGLWindow.Mod
	 ~

	WGLinfo.Do ~ # display opengl info
#==========================================
# utilities
# =========================================
Compiler.Compile 
	GLLib.Mod	
	Containers.Mod
	Decoder3DS.Mod	
	~

# =========================================
# 2- Compile platform independent demo examples of GLContext :

Compiler.Compile 
	 GLTest.Mod
	 WMGLDemo.Mod
	 WMGLDemo1.Mod
	 WMGLDemo2.Mod
	 WMGLDemo3.Mod
	 WMGLDemo4.Mod
	 WMGLDemo6.Mod
	 WMGLDemo7.Mod
	 WMGLDemo9.Mod
	 WMGLDemoFlags.Mod
	 WMGLDemoLorenz.Mod
	 WMGLPlotSurface.Mod
	 WMGLSteamEngine.Mod
	 WMGLPolyStipple.Mod
	 WMGLSLBricks.Mod
	WMSpaceSim3.Mod	 
	~
# =========================================

# LinuxAos specific demos (using linux native X11-Window ):
Compiler.Compile
	Unix.X11KeySymDef.Mod
	MyXGear.Mod
	MyXGear1.Mod
	MyXGear2.Mod
	~


# WinAos specific version of WMGLDemo7.Mod by tobj..@ .., thanks :
Compiler.Compile  Win32.WMGLDemo7b.Mod ~  WMGLDemo7b.Open ~

# Run the following commands,  click Midle Mouse (MM) on the following commands
	
	WMGLDemo.Open ~
	WMGLDemo1.Open ~
	WMGLDemo2.Open ~
	WMGLDemo3.Open ~
	WMGLDemo4.Open ~
	WMGLDemo6.Open ~
	WMGLDemo7.Open ~
	WMGLDemo9.Open ~

	WMGLDemoFlags.Open ~
	WMGLDemoLorenz.Open ~
	WMGLPlotSurface.Open ~
	WMGLSteamEngine.Open ~
	WMGLPolyStipple.Open ~
	WMGLSLBricks.Open ~
	WMSpaceSim3.Open ~ 
 
# ***************************************
# 3- Compile demo examples of OGLWindow:

Compiler.Compile
	OGLDemo.Mod
	OGLDemo1.Mod
	OGLDemo2.Mod
	SpaceSim3.Mod 
	~

# Run Demos, click Midle Mouse (MM) on the following commands

	OGLDemo.Open ~
	OGLDemo1.Open ~
	OGLDemo2.Open ~
	SpaceSim3.Open ~
	
# **********************
# **********************

# Free OpenGL related modules from the memory:
System.FreeDownTo OpenGL ~



 =========================================================================
 4- How to use the framework:

 There are two OpenGL programming models with A2 Oberon:

 4.1- Internal GLContext and WMGLWindow objects that are usable in A2 WindowManager.

 4.2- External OGLWindow object which is used outside of A2 WindowManager.

=========================================================================

4.1- GLContext usage:

(A)-  Within an A2 command procedure, without opening a window, just render the opengl
	drawing into the supplied Raster.Image object (see GLTest.Mod ).

(* Import OpenGL, OpenGLConst and GLContext modules in to your module *)


IMPORT
     ... OpenGL, OpenGLConst, GLContext, ..., Raster, ..

(* Create an instance of GLContext.Context object, an Image object *)

VAR
	context: GLContext.Context;
	image: Raster.Image;
	width, height: LONGINT;
	...

	width := 300; height := 300;

	(* create an image object using Raster module with BGRA8888 mode (32 bpp image *)
	NEW(image);
	Raster.Create(image, width, height, Raster.BGRA8888);

 	NEW(context);

 	(* init the context; width, height, title, isvisible *)

 	context.Init(width, height); (* context size and image size should be the same *)


 	(*
 	Since, creating a GL context needs a window, Init creates a dumy window on the underlying OS.
 	In WinAos a Win32 window  and in UnixAos an X11 window dumy windows are cretated to obtain
 	a valid OpenGL context.


	*)


	(* before using any OpenGL commands acquire the OpenGL context *)

	context.MakeCurrent();

		 (*
			...
			your OpenGL commands
			...
  		*)

	(* After finishing your commands, get the rendered image from OpenGL framebuffer (GPU) to the Image object (CPU) *)

 	 context.RenderInto(image);

	(* finally, release the OpenGL context *)

	context.DeActivate();
  	context.Close();
  	context := NIL;
		...

 (* Whatever you like with image object.
	You may store this image or show it in any WMWindowManager.Window object.
	Note that, OpenGL picture origin is lover-left corner, while Oberon image's origin
	top-left. context.RenderInto procedure flips the OpenGL image while reading pixel
	to Image object.

 *)

(B)- Using WMGLWindow.Window in A2 WindowManager. This object is an extension of 
	  WM.DoubleBufferWindow window object. It is resizable and used for opengl rendering.
	  Look at the WMGLDemo*.Mod demo files for usage

	  IMPORT .. WMGL := WMGLWindow, WM := WMWindowManager, ...
	  			 GL:=OpenGL, GLG := OpenGLConst, ....
	  
	  TYPE GLWin=OBJECT(WMGL.Window)
	  	
	  	PROCEDURE &New();
	  	BEGIN
	  		Init(100,100, FALSE)
	  		WM.AddWindow(SELF, 200, 200);	  		
	  	END New;
	  	
	  	PROCEDURE Reshape(w, h: LONGINT);
		BEGIN
			MakeCurrent();
				(* GL codes *)
				GL.Viewport(0,0,w, h);
				
			DeActivate();
	  	END Reshape;
	  	
	  	PROCEDURE UpdateImage;
	  	BEGIN
	  		MakeCurrent();
	  			(* your GL codes ... *)
	  			
	  			SwapGLBuffer();  (* render into back image *)
	  			
	  		DeActivate();
	  		Swap(); (* swap double buffered window *)
	  		Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));	
	  	END UpdateImage;
	  	
	  	END GLWin;
	  	
	  	......
.
=========================================================================

4.2- OGLWindow object usage:
	This object creates a native window object (Win32 Window for Windows and
	X11-Window for Linux). It's methods are similar to A2-Window manager's.
	Look at OGLDemo*.Mod files for simple demos.

	In short:

	...
	IMPORT OpenGL, OpenGLConst, OGLWindow;

	Extend OGLWindow.Window object

	TYPE GLWindow=OBJECT(OGLWindow.Window)
		VAR ...


		(* KeyEvent and PointerMove methods are similar to A2 WindowManager's *)

		(* called by OGLWindow object *)
		PROCEDURE Display;
		BEGIN

		(* .. your opengl display codes .. *)

		SwapBuffers();
		END Display;

		(* called by OGLWindow *)
		PROCEDURE Reshape(w, h: LONGINT);
		BEGIN

		END Reshape;

		BEGIN
			
		END GLWindow.
	.....

  VAR win: GLWindow;
....
  	create an instance of this object in a command procedure.

  	NEW(win, width, height, xofset, yofset, fulscreen);

 	that is all ...




# *************************************************************************

NOTE:

 By default, all OpenGL core functions loaded by the driver. If you would like to use higher extensions,
 1.2 .. 4.x,  use OpenGL.ReadExtensions after MakeCurrent().


 While using OpenGL with WMWindowManager.Window care should be taken. The OpenGL contexts
 is process and thread sensitive. One context to one one thread. If more than one available, as in Active objects,
 after first thread acquires the OpenGL context using context.MakeCurrent the other thread can not access the
 context untill previous thread release it (DeActivate).

  Nvidia, Ati, Intel, Mesa drivers may behave differently depending on extensions. The examples are tested on
  Nvidia 8500GT GPU vith latest driver (Windows-XP32-SP3, Ubuntu 10.04 AMD64, i386 and Ubuntu 12.04 AMD64, 
  i386, Pardus-32bit-2011 with MESA) and not  all OpenGL functions are not tested, there can be missing and 
  miss-definitions in the OpenGL.Mod mudule.


# =============================================================================
# =============================================================================
# =============================================================================
This Oberon OpenGL header translation is inspired and based on:
# =============================================================================
# =============================================================================
#==============================================================================
#       Contains the translations of glext.h, gl_1_1.h, glu.h and weglext.h.
#       It also contains some helperfunctions that were inspired by those
#       found in Mike Lischke's OpenGL12.pas.
#
#       Copyright (C) DGL-OpenGL2-Portteam
#       All Rights Reserved
#
#       Obtained through:
#       Delphi OpenGL Community(DGL) - www.delphigl.com
#
#       Converted and maintained by DGL's GL2.0-Team :
#         - Sascha Willems             - http://www.saschawillems.de
#         - Steffen Xonna (Lossy eX)   - http://www.dev-center.de
#       Additional input :
#         - Andrey Gruzdev (Mac OS X patch for XE2 / FPC)
#         - Lars Middendorf
#         - Martin Waldegger (Mars)
#         - Benjamin Rosseaux (BeRo)   - http://www.0ok.de
#       Additional thanks:
#           sigsegv (libdl.so)
#
#
#==============================================================================
# You may retrieve the latest version of this file at the Delphi OpenGL
# Community home page, located at http://www.delphigl.com/
#
# The contents of this file are used with permission, subject to
# the Mozilla Public License Version 1.1 (the "License"); you may
# not use this file except in compliance with the License. You may
# obtain a copy of the License at
# http://www.mozilla.org/MPL/MPL-1.1.html
#
# Software distributed under the License is distributed on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
# implied. See the License for the specific language governing
# rights and limitations under the License.
#==============================================================================
