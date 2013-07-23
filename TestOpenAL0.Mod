MODULE TestOpenAL0; (** AUTHOR ""; PURPOSE ""; *)

IMPORT  AL:=OpenAL, ALU := OpenALUtil, SYSTEM, Math, Strings, Kernel, KernelLog;

VAR
	 timer: Kernel.Timer;
	device : AL.ALCdevice;
	context : AL.ALCcontext;


PROCEDURE Play1*;
VAR
  buffer : AL.ALuint;
  source : AL.ALuint;
 test : POINTER TO ARRAY OF CHAR;
  z : LONGINT;
  
BEGIN 
  
NEW(test, 1000);
  
  FOR z := 0 TO 999 DO
    test[z] := CHR(SHORT(ENTIER(128*Math.sin(z*(2*Math.pi)/9.0)+128)));
  END;  
  

  AL.alGenBuffers(1, SYSTEM.ADR(buffer));
  AL.alBufferData(buffer, AL.AL_FORMAT_MONO8, SYSTEM.ADR(test[0]), 1000, 11024);
  	KernelLog.String("1-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 

  AL.alGenSources(1, SYSTEM.ADR(source));

  AL.alSourcef(source, AL.AL_PITCH, 1.0);
  AL.alSourcef(source, AL.AL_GAIN, 1.0);
  AL.alSourcei(source, AL.AL_LOOPING, AL.AL_TRUE); 
  AL.alSourcei(source, AL.AL_BUFFER, buffer);  
  	KernelLog.String("2- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
  
  AL.alSourcePlay(source);
  	KernelLog.String("3- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
  timer.Sleep(2000);
   

 AL.alSourceStop(source);
 
  AL.alDeleteSources(1, SYSTEM.ADR(source));
  AL.alDeleteBuffers(1, SYSTEM.ADR(buffer));
  KernelLog.String("-------- Ok ------- "); KernelLog.Ln; 

END Play1;

PROCEDURE Play2*;
CONST  D2R = 0.0174532925;
VAR
	buffer : AL.ALuint;
	source : AL.ALuint;
	data: POINTER TO ARRAY OF CHAR;
	i : LONGINT;
	x: REAL;
	samples: LONGINT;
	frequency: LONGINT;
	size,  freq: AL.ALsizei;

	srcPos, lstPos: ARRAY [3] OF AL.ALfloat;
	
BEGIN 
 
  AL.alGenBuffers(1, SYSTEM.ADR(buffer));
  
  IF AL.alIsBuffer(buffer) THEN
	  KernelLog.String("isbuffer"); KernelLog.Ln; 
  ELSE
  	KernelLog.String("isnotbuffer"); KernelLog.Ln; 
  END;

 KernelLog.String("Generating sine wave on user parameters"); KernelLog.Ln; 
  (* Generate using math
   We want a note of 440 Hz. 32 samples for each oscillation
   for 1 seconds, means 440*32 bytes  
  *)
  
  frequency := 1000; (* which freaquency *)
  samples := 4; (* How many samples for the wave? [try me between 2 and 16] *)

freq := samples * frequency;
 
  size := freq; (* We don't need an higher frequency than the signal*)

 NEW( data, size);
 
  FOR i := 0 TO size-1 DO
    x := i * 360.0 / samples;
   data[i]  := CHR(SHORT(ENTIER(128*Math.sin(x * D2R)  + 128))) ; (* Clamp to [0,255] *)
  END;    
    
  AL.alBufferData(buffer, AL.AL_FORMAT_MONO8, SYSTEM.ADR(data), samples, freq);
  	KernelLog.String("1-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 

  AL.alGenSources(1, SYSTEM.ADR(source));
  IF AL.alIsSource(source) THEN
	  KernelLog.String("issource"); KernelLog.Ln; 
  ELSE
  	KernelLog.String("isnotsource"); KernelLog.Ln; 
  END;


  srcPos := [-0.3, 0.0, -3.0];

AL.alSourcef(source, AL.AL_PITCH, 1.0);
AL.alSourcef(source, AL.AL_GAIN, 1.0);
 
 AL.alSourcefv(source, AL.AL_POSITION, SYSTEM.ADR(srcPos[0]));
 AL.alSourcei(source, AL.AL_LOOPING, AL.AL_TRUE);
 AL.alSourcei(source, AL.AL_BUFFER, buffer);
  
 lstPos := [0.0, 0.0, -3.0];
 AL.alListenerfv(AL.AL_POSITION, SYSTEM.ADR(lstPos[0]));

 AL.alSourcePlay(source);
  timer.Sleep(2000);


(* AL.alSourceStop(source); *)
  (* Clear the things *)
 AL.alDeleteSources(1, SYSTEM.ADR(source));
 AL.alDeleteBuffers(1, SYSTEM.ADR(buffer));
 KernelLog.String("-------- Ok ------- "); KernelLog.Ln; 
END Play2;


(* 16 bit data *)
PROCEDURE Play3*;
VAR
	buffer : AL.ALuint;
	source : AL.ALuint;

	test : POINTER TO ARRAY OF INTEGER; (* for 16 bits data*)
	z : LONGINT;
  	sizeBytes: LONGINT;
  	y: REAL;
  	freq: LONGINT;
BEGIN 
 
 NEW(test, 10000);
 
 freq := 11025;
  FOR z := 0 TO 9999 DO
    y := Math.exp(-z/10000)*Math.sin(z*(2.0*Math.pi*freq)/10000);	
    test[z] := SHORT(ENTIER(32760*(y-0.5)));
  END;  

  AL.alGenBuffers(1, SYSTEM.ADR(buffer));
  sizeBytes := LEN(test)*SYSTEM.SIZEOF(INTEGER);
  
  AL.alBufferData(buffer, AL.AL_FORMAT_MONO16, SYSTEM.ADR(test[0]), sizeBytes, freq);
  	KernelLog.String("1-- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 

  AL.alGenSources(1, SYSTEM.ADR(source));

  AL.alSourcef(source, AL.AL_PITCH, 1.0);
  AL.alSourcef(source, AL.AL_GAIN, 1.0);
(*  AL.alSourcei(source, AL.AL_LOOPING, AL.AL_TRUE); *)
  AL.alSourcei(source, AL.AL_BUFFER, buffer);
  
  	KernelLog.String("2- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 
  

  AL.alSourcePlay(source);
 
	KernelLog.String("3- alGetError= "); KernelLog.Hex(AL.alGetError(), 4); KernelLog.Ln; 

   timer.Sleep(2000);
   
 (* AL.alSourceStop(source);*)
 
  AL.alDeleteSources(1, SYSTEM.ADR(source));
  AL.alDeleteBuffers(1, SYSTEM.ADR(buffer));
    
 KernelLog.String("-------- Ok ------- "); KernelLog.Ln; 

END Play3;

(* for commandline run*)
PROCEDURE Do*;
BEGIN

	Play1;
	Play2;
	Play3;

END Do;

BEGIN
 NEW(timer);
END TestOpenAL0.

TestOpenAL0.Play1 ~

TestOpenAL0.Play2 ~

TestOpenAL0.Play3 ~

TestOpenAL0.Do ~

SystemTools.Free TestOpenAL0~ 