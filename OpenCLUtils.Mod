MODULE OpenCLUtils; (** AUTHOR "fnecati"; PURPOSE "OpenCL utilities"; *)
IMPORT CL:=OpenCL, S:= SYSTEM, Files, KernelLog, Strings;

TYPE 
	  PChar = CL.PChar;
	  String=ARRAY 64 OF CHAR;
       StringArray=POINTER TO ARRAY OF String;

VAR 
	  clerror: StringArray; (* OpenCL errors *)
	  imformat: PChar;   (* imageformat cl_channel_order, cl_channel_type strings *)
	  
(** 
 Loads an ASCII Program file and prepends the header to the code.
	fname        program filename
	header        code that is prepended to the loaded file, typically a set of #defines or a header
*)

PROCEDURE LoadProgramSource*(fname: ARRAY OF CHAR; header: ARRAY OF CHAR): PChar;
VAR 
     f: Files.File;
      rider: Files.Rider;
      str: PChar;
      len: LONGINT;
BEGIN
	f := Files.Old(fname);
	IF f = NIL THEN RETURN NIL END;
	len := Strings.Length(header);

	NEW(str, f.Length()+1+len);
	Strings.Append(str^, header);
	Strings.AppendChar(str^,0AX);	
	f.Set(rider, 0);
	
	f.ReadBytes(rider, str^, len, f.Length());
	(* KernelLog.String(str^); KernelLog.Ln; *)
	
	 RETURN S.VAL(PChar, S.ADR(str[0]));
	
END LoadProgramSource;

(** Roundup division function for efficient workgrup size calculation *)
PROCEDURE RoundUp*(groupsize, globalsize: LONGINT): LONGINT; (* size_t *)
VAR r: LONGINT;
BEGIN
	r := globalsize MOD groupsize;
	IF r = 0 THEN RETURN globalsize END;
	RETURN globalsize + groupsize - r;
END RoundUp;
         
(* Helper function to get OpenCL clerroror string from constant *)
PROCEDURE InitCLErrors;
BEGIN
	   NEW(clerror, 64);	
        clerror[0] := "SUCCESS";
        clerror[1] := "DEVICE_NOT_FOUND";
        clerror[2] := "DEVICE_NOT_AVAILABLE";
        clerror[3] := "COMPILER_NOT_AVAILABLE";
        clerror[4] := "MEM_OBJECT_ALLOCATION_FAILURE";
        clerror[5] := "OUT_OF_RESOURCES";
        clerror[6] := "OUT_OF_HOST_MEMORY";
        clerror[7] := "PROFILING_INFO_NOT_AVAILABLE";
        clerror[8] := "MEM_COPY_OVERLAP";
        clerror[9] := "IMAGE_FORMAT_MISMATCH";
        clerror[10] := "IMAGE_FORMAT_NOT_SUPPORTED";
        clerror[11] := "BUILD_PROGRAM_FAILURE";
        clerror[12] := "MAP_FAILURE";
        clerror[13] := "";
        clerror[14] := "";
        clerror[15] := "";
        clerror[16] := "";
        clerror[17] := "";
        clerror[18] := "";
        clerror[19] := "";
        clerror[20] := "";
        clerror[21] := "";
        clerror[22] := "";
        clerror[23] := "";
        clerror[24] := "";
        clerror[25] := "";
        clerror[26] := "";
        clerror[27] := "";
        clerror[28] := "";
        clerror[29] := "";
        clerror[30] := "INVALID_VALUE";
        clerror[31] := "INVALID_DEVICE_TYPE";
        clerror[32] := "INVALID_PLATFORM";
        clerror[33] := "INVALID_DEVICE";
        clerror[34] := "INVALID_CONTEXT";
        clerror[35] := "INVALID_QUEUE_PROPERTIES";
        clerror[36] := "INVALID_COMMAND_QUEUE";
        clerror[37] := "INVALID_HOST_PTR";
        clerror[38] := "INVALID_MEM_OBJECT";
        clerror[39] := "INVALID_IMAGE_FORMAT_DESCRIPTOR";
        clerror[40] := "INVALID_IMAGE_SIZE";
        clerror[41] := "INVALID_SAMPLER";
        clerror[42] := "INVALID_BINARY";
        clerror[43] := "INVALID_BUILD_OPTIONS";
        clerror[44] := "INVALID_PROGRAM";
        clerror[45] := "INVALID_PROGRAM_EXECUTABLE";
        clerror[46] := "INVALID_KERNEL_NAME";
        clerror[47] := "INVALID_KERNEL_DEFINITION";
        clerror[48] := "INVALID_KERNEL";
        clerror[49] := "INVALID_ARG_INDEX";
        clerror[50] := "INVALID_ARG_VALUE";
        clerror[51] := "INVALID_ARG_SIZE";
        clerror[52] := "INVALID_KERNEL_ARGS";
        clerror[53] := "INVALID_WORK_DIMENSION";
        clerror[54] := "INVALID_WORK_GROUP_SIZE";
        clerror[55] := "INVALID_WORK_ITEM_SIZE";
        clerror[56] := "INVALID_GLOBAL_OFFSET";
        clerror[57] := "INVALID_EVENT_WAIT_LIST";
        clerror[58] := "INVALID_EVENT";
        clerror[59] := "INVALID_OPERATION";
        clerror[60] := "INVALID_GL_OBJECT";
        clerror[61] := "INVALID_BUFFER_SIZE";
        clerror[62] := "INVALID_MIP_LEVEL";
        clerror[63] := "INVALID_GLOBAL_WORK_SIZE";
END InitCLErrors;

(** convert clerroror number to corresponding string *)
PROCEDURE ErrorToStr*(n: LONGINT): String;
VAR
	s: String;
	n0: LONGINT;
BEGIN
 n0 := ABS(n);
 IF (n0 >= 0) & (n0 < 64) THEN s := clerror[n0] ELSE s := " Unspecified Error ";  END;
 RETURN s;
END ErrorToStr;

(** Helper function to get OpenCL image format string (channel order and type) from constant *)
PROCEDURE ImageFormatString* (imf: CL.cl_uint): PChar;
BEGIN
	imformat^ := "Unknown";
	
    (* cl_channel_order *)
    IF imf = CL.R THEN imformat^ := "R";  
    ELSIF imf = CL.A THEN imformat^ := "A";  
    ELSIF imf = CL.RG THEN imformat^ := "RG";  
    ELSIF imf = CL.RA THEN imformat^ := "RA";  
    ELSIF imf = CL.RGB THEN imformat^ := "RGB";
    ELSIF imf = CL.RGBA THEN imformat^ := "RGBA";  
    ELSIF imf = CL.BGRA THEN imformat^ := "BGRA";  
    ELSIF imf = CL.ARGB THEN imformat^ := "ARGB";  
    ELSIF imf = CL.INTENSITY THEN imformat^ := "INTENSITY";  
    ELSIF imf = CL.LUMINANCE THEN imformat^ := "LUMINANCE"; 

    (* cl_channel_type *)
    ELSIF imf = CL.SNORM_INT8 THEN imformat^ := "SNORM_INT8";
    ELSIF imf = CL.SNORM_INT16 THEN imformat^ := "SNORM_INT16";
    ELSIF imf = CL.UNORM_INT8 THEN imformat^ := "UNORM_INT8";
    ELSIF imf = CL.UNORM_INT16 THEN imformat^ := "UNORM_INT16";
    ELSIF imf = CL.UNORM_SHORT_565 THEN imformat^ := "UNORM_SHORT_565";
    ELSIF imf = CL.UNORM_SHORT_555 THEN imformat^ := "UNORM_SHORT_555";
    ELSIF imf = CL.UNORM_INT_101010 THEN imformat^ := "UNORM_INT_101010";
    ELSIF imf = CL.SIGNED_INT8 THEN imformat^ := "SIGNED_INT8";
    ELSIF imf = CL.SIGNED_INT16 THEN imformat^ := "SIGNED_INT16";
    ELSIF imf = CL.SIGNED_INT32 THEN imformat^ := "SIGNED_INT32";
    ELSIF imf = CL.UNSIGNED_INT8 THEN imformat^ := "UNSIGNED_INT8";
    ELSIF imf = CL.UNSIGNED_INT16 THEN imformat^ := "UNSIGNED_INT16";    
    ELSIF imf = CL.UNSIGNED_INT32 THEN imformat^ := "UNSIGNED_INT32";
    ELSIF imf = CL.HALF_FLOAT THEN imformat^ := "HALF_FLOAT";
    ELSIF imf = CL.FLOAT THEN imformat^ := "FLOAT";
    END;
   	
     RETURN imformat;
END ImageFormatString;

BEGIN
 NEW(imformat, 32);
 InitCLErrors; 
END OpenCLUtils.


