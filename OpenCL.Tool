
For UnixAos:									
Compiler.Compile Unix.OpenCL.Mod ~

For WinAos:
Compiler.Compile Win32.OpenCL.Mod ~


Utilities: 
Compiler.Compile OpenCLUtils.Mod OpenCLInfo.Mod OpenCLBuild.Mod ~ 

Demos:

Compiler.Compile
OpenCLVectorSquare.Mod
OpenCLVectorSquare1.Mod
MySimpleMandelbrotCL.Mod
MyMandelbrotCL.Mod
OpenCLEvents.Mod
MyImageRotateCL.Mod
MyJuliasetCL.Mod
~

OpenCLInfo.Show ~ 

MyMandelbrotCL.Open ~

MySimpleMandelbrotCL.Open ~

MyImageRotateCL.Open "BluebottlePic0.png" ~

MyJuliasetCL.Open ~ 

OpenCLBuild.Open ~ 








  
