MODULE TestOpenALWav3; (** AUTHOR "fnecati"; PURPOSE "test WAV file playing using OpenALUtil"; *)
(* uses stripped version of WAVcodec *)

IMPORT  AL:=OpenAL, ALU := OpenALUtil,  KernelLog, Kernel, Commands;


VAR
	buffer : AL.ALuint;
	source : AL.ALuint;

	timer: Kernel.Timer;
	gain, pitch: AL.ALfloat;
	

(* play this filename *)		
PROCEDURE Play*(fname: ARRAY OF CHAR); 
BEGIN 
		
  (* Clear the source and buffers if they are not empty *)
	 IF source # 0 THEN AL.alDeleteSources(1, ADDRESSOF(source)); source := 0; END;
	 IF buffer # 0 THEN AL.alDeleteBuffers(1, ADDRESSOF(buffer)); buffer := 0; END;
			
	(* create an AL buffer object from a wav file data *)
	buffer := ALU.LoadWavFileToBuffer(fname);	

	(* create a source object *)	
	 AL.alGenSources(1, ADDRESSOF(source));	
	 
	 (* bind source to buffer *)
	 AL.alSourcei(source, AL.AL_BUFFER, buffer(AL.ALint));
	 
	 (* set source properties and listenet position *)
	ALU.SetPitch(source, pitch);
	ALU.SetGain(source, gain); 	
	ALU.SetSourcePosition(source, 0.0, 0.0, 0.0);
	ALU.SetLoop(source, FALSE); 
 
	ALU.SetListenerPosition(0.0, 0.0 ,0.0);
	ALU.ALWriteError("LoadWavSource error : ");
	
	ALU.Play(source);
	ALU.ALWriteError("Playing Error : "); 
	
END Play;

PROCEDURE IncGain*;
BEGIN
	gain := gain + 0.1;
	ALU.SetGain(source, gain);
END IncGain;

PROCEDURE DecGain*;
BEGIN
	gain := gain - 0.1;
	ALU.SetGain(source, gain);
END DecGain;

PROCEDURE IncPitch*;
BEGIN
	pitch := pitch + 0.01;
	ALU.SetPitch(source, pitch);
END IncPitch;

PROCEDURE DecPitch*;
BEGIN
	pitch := pitch - 0.01;
	ALU.SetPitch(source, pitch);	
END DecPitch;


(** from A2 command,  *)
PROCEDURE Open*(cmd: Commands.Context);
VAR fname: ARRAY 128 OF  CHAR;
BEGIN
	IF ~cmd.arg.GetString(fname) THEN
		KernelLog.String("invalid filename"); KernelLog.Ln; 
		RETURN;
	END;
	Play(fname);	
END Open;

(** create 3 buffer data and 3 source object and play them *)
PROCEDURE Do1*;
VAR buf0, buf1, buf2: AL.ALuint;
	sources: ARRAY 3 OF AL.ALuint;
BEGIN

	
	(* create an AL buffer object from a wav file data *)
	buf0 := ALU.LoadWavFileToBuffer("openaloberon/test.wav");	

	(* create 3 source object *)	
	 AL.alGenSources(3, ADDRESSOF(sources[0]));	
	 
	 (* bind source to buffer *)
	 AL.alSourcei(sources[0], AL.AL_BUFFER, buf0(AL.ALint));
	 
	 (* set source properties *)
	ALU.SetPitch(sources[0], pitch);
	ALU.SetGain(sources[0], gain); 	
	ALU.SetSourcePosition(sources[0], 0.0, 0.0, 0.0);
	ALU.SetLoop(sources[0], FALSE); 
 

	(* create an AL buffer object from a wav file data *)
	buf1 := ALU.LoadWavFileToBuffer("openaloberon/desktoplogin.wav");	
	 
	 (* bind source to buffer *)
	 AL.alSourcei(sources[1], AL.AL_BUFFER, buf1(AL.ALint));
	 
	 (* set source properties and listenet position *)
	ALU.SetPitch(sources[1], pitch);
	ALU.SetGain(sources[1], gain); 	
	ALU.SetSourcePosition(sources[1], 0.0, 0.1, 0.0);
	ALU.SetLoop(sources[1], FALSE); 


	(* create an AL buffer object from a wav file data *)
	buf2 := ALU.LoadWavFileToBuffer("openaloberon/s11k16bitpcm.wav");
	 
	 (* bind source to buffer *)
	 AL.alSourcei(sources[2], AL.AL_BUFFER, buf2(AL.ALint));
	 
	 (* set source properties and listenet position *)
	ALU.SetPitch(sources[2], pitch);
	ALU.SetGain(sources[2], gain); 	
	ALU.SetSourcePosition(sources[2], 0.1, 0.0, 0.0);
	ALU.SetLoop(sources[2], FALSE); 


	ALU.SetListenerPosition(0.0, 0.0 ,0.0);
	ALU.Playv(sources)

END Do1;


(** create 1 buffer data and 3 source object and play them *)
PROCEDURE Do2*;
VAR buf0, buf2: AL.ALuint;
	sources: ARRAY 3 OF AL.ALuint;
	s2: AL.ALuint;
BEGIN
	
	(* create an AL buffer object from a wav file data *)
	buf0 := ALU.LoadWavFileToBuffer("openaloberon/s11k16bitpcm.wav");

	(* create 3 source object *)	
	 AL.alGenSources(3, ADDRESSOF(sources[0]));	
	 
	 (* bind source 0 to buffer0 *)
	 AL.alSourcei(sources[0], AL.AL_BUFFER, buf0(AL.ALint));
	 
	 (* set source 0 properties *)
	ALU.SetPitch(sources[0], 1.1);
	ALU.SetGain(sources[0], gain); 	
	ALU.SetSourcePosition(sources[0], 1.0, 0.0, 0.0);
	ALU.SetLoop(sources[0], FALSE); 
 
	 
	 (* bind source 1 to buffer0 *)
	 AL.alSourcei(sources[1], AL.AL_BUFFER, buf0(AL.ALint));
	 
	 (* set source 1 properties *)
	ALU.SetPitch(sources[1], pitch);
	ALU.SetGain(sources[1], gain); 	
	ALU.SetSourcePosition(sources[1], 0.0, 0.0, 0.0);
	ALU.SetLoop(sources[1], FALSE); 


	 (* bind source 2 to buffer0 *)
	 AL.alSourcei(sources[2], AL.AL_BUFFER, buf0(AL.ALint));
	 
	 (* set source 2 properties *)
	ALU.SetPitch(sources[2], 2.0);
	ALU.SetGain(sources[2], gain); 	
	ALU.SetSourcePosition(sources[2], -1.0, 0.0, 0.0);
	ALU.SetLoop(sources[2], FALSE); 

	(* finally, set listener position *)
	ALU.SetListenerPosition(0.0, 0.0 ,0.0);
	
	(* and play all sources *)
	ALU.Playv(sources);

	(* a background source playing with looping enabled *)
	(* create an AL buffer object from a wav file data *)
	buf2 := ALU.LoadWavFileToBuffer("openaloberon/Wave4.WAV");
	(* create a source object *)	
	 AL.alGenSources(1, ADDRESSOF(s2));	
	 
	 (* bind source s2 to buf2 *)
	 AL.alSourcei(s2, AL.AL_BUFFER, buf2(AL.ALint));
	 
	 (* set source s2 properties *)
	ALU.SetPitch(s2, 1.1);
	ALU.SetGain(s2, 1.0); 	
	ALU.SetSourcePosition(s2, 0.0, 0.0, 0.0);
	ALU.SetLoop(s2, TRUE);  (* looping enabled *)
	ALU.Play(s2);
END Do2;


BEGIN
	NEW(timer);
	gain := 1.0; pitch := 1.0;

END TestOpenALWav3.


TestOpenALWav3.Open "openaloberon/test.wav" ~
TestOpenALWav3.Open "openaloberon/rugby.wav" ~
TestOpenALWav3.Open "openaloberon/s11k16bitpcm.wav" ~
TestOpenALWav3.Open "openaloberon/s11k8bitpcm.wav" ~
TestOpenALWav3.Open "openaloberon/s11kulaw.wav" ~
TestOpenALWav3.Open "openaloberon/s8k16bitpcm.wav" ~
TestOpenALWav3.Open "openaloberon/s8k8bitpcm.wav" ~
TestOpenALWav3.Open "openaloberon/s8kulaw.wav" ~
TestOpenALWav3.Open "openaloberon/Wave4.WAV" ~

TestOpenALWav3.Open "openaloberon/desktoplogin.wav" ~

TestOpenALWav3.DecGain ~  TestOpenALWav3.IncGain~  

TestOpenALWav3.DecPitch ~  TestOpenALWav3.IncPitch~  


TestOpenALWav3.Do1 ~ 

TestOpenALWav3.Do2 ~ 

System.FreeDownTo  OpenAL~ 

System.Free TestOpenALWav3~ 

