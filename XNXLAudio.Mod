MODULE XNXLAudio;

IMPORT  AL:=OpenAL, SYSTEM, Streams, KernelLog, SoundDevices, Codecs, Files, Strings;

CONST 
	debug = FALSE;
	playConfilename="openalplay.ini";	(* configuration file for name of play devices *)
VAR
	device : AL.ALCdevice;
	context : AL.ALCcontext;
	source : AL.ALuint;
	buffer : AL.ALuint;
	decoder : Codecs.AudioDecoder;
	pitch, gain: AL.ALfloat;
	sourcePos, listenerPos: ARRAY [3] OF AL.ALfloat;

(** get device name from file *)
PROCEDURE LoadDeviceName*(CONST fname: ARRAY OF CHAR; VAR sdev: ARRAY OF CHAR);
VAR file: Files.File;
	rd: Files.Reader;
	found: BOOLEAN;
BEGIN
	sdev := ""; (* default device*)
	file := Files.Old(fname);
	IF file = NIL THEN RETURN ; END;
	Files.OpenReader(rd, file, 0);
	rd.SkipWhitespace();
	found := FALSE ;
	WHILE  (~found) & (rd.res = Streams.Ok)  DO
		rd.Ln(sdev);
		Strings.Trim(sdev, " ");
		found := sdev[0] # "#";
		rd.SkipWhitespace();
	END;	
END LoadDeviceName;
	
(* for error checking *)
PROCEDURE ALWriteError(CONST tit: ARRAY OF CHAR);
VAR s: Strings.String;
	err: AL.ALuint;
BEGIN
	err := AL.alGetError();
	IF ~ debug THEN RETURN END;
	s := AL.ALGetString(err);
	IF s # NIL THEN
		(* KernelLog.String(tit);  KernelLog.String(s^); KernelLog.Ln; *)
	END;
END ALWriteError;

PROCEDURE ALCWriteError(d: AL.ALCdevice; CONST tit: ARRAY OF CHAR);
VAR s: Strings.String;
	err: AL.ALuint;
BEGIN
	err := AL.alcGetError(d);
	IF ~ debug THEN RETURN END;
	s := AL.ALCGetString(d, err);
	IF s # NIL THEN
		KernelLog.String(tit); KernelLog.String(s^); KernelLog.Ln; 
	END;
END ALCWriteError;

		
PROCEDURE LoadWav*(fname: ARRAY 64 OF CHAR);
VAR
	fmt: AL.ALuint; 

	dres: LONGINT;
	
	file: Files.File;
	in: Files.Reader;
	sbuffer  : SoundDevices.Buffer;	

	nofChannels, samplePerSecond, bitsPerSample, samples, sizeBytes : LONGINT;
		
BEGIN

	file := Files.Old(fname);
	IF file = NIL THEN
		KernelLog.String(fname);  KernelLog.String( ": WAV file Open Error. "); KernelLog.Ln; 
		RETURN 
	END;

	Files.OpenReader( in, file, 0);
	decoder.Open(in, dres);
	IF dres # Codecs.ResOk THEN 
		KernelLog.String( "WAV decoder Open Error. "); KernelLog.Ln; 
		RETURN 
	END;
	
	(* KernelLog.String(fname); KernelLog.String(" loaded.");KernelLog.Ln; *)
	 
	decoder.GetAudioInfo(nofChannels, samplePerSecond, bitsPerSample);
	samples := decoder.GetTotalSamples();

	(* data size in bytes *)
	sizeBytes := nofChannels*samples*(bitsPerSample DIV 8);
	
	NEW(sbuffer);
	sbuffer.len := sizeBytes;
	NEW(sbuffer.data, sbuffer.len);
	
	decoder.FillBuffer(sbuffer);
	
	(* format of wav  *)
	IF nofChannels = 1 THEN
	  	CASE bitsPerSample OF
	  		8:  fmt := AL.AL_FORMAT_MONO8
	  		|16: fmt := AL.AL_FORMAT_MONO16
	  	ELSE fmt:= AL.AL_FORMAT_MONO8;	
	  	END;
	ELSIF nofChannels = 2 THEN
	  	CASE bitsPerSample OF
	  		8:  fmt := AL.AL_FORMAT_STEREO8
	  		|16: fmt := AL.AL_FORMAT_STEREO16
	  	ELSE fmt:= AL.AL_FORMAT_STEREO8;	
	  	END;
	ELSE 
		fmt := AL.AL_FORMAT_MONO8
	END;

	IF debug THEN
		KernelLog.String("nofChannels= "); KernelLog.Int(nofChannels, 0); KernelLog.Ln; 
		KernelLog.String("samplePerSecond = "); KernelLog.Int(samplePerSecond, 0); KernelLog.Ln; 
		KernelLog.String("bitsPerSample= "); KernelLog.Int(bitsPerSample, 0); KernelLog.Ln; 
		KernelLog.String("samples= "); KernelLog.Int(samples, 0); KernelLog.Ln; 
		KernelLog.String("fmt= "); KernelLog.Hex(fmt, 8); KernelLog.Ln;
	END;	
	
  (* Clear the source and buffers if they are not empty *)
	 IF source # 0 THEN AL.alDeleteSources(1, ADDRESSOF(source)); source := 0; END;
	 IF buffer # 0 THEN AL.alDeleteBuffers(1, ADDRESSOF(buffer)); buffer := 0; END;
		
	AL.alGenBuffers(1, ADDRESSOF(buffer)); 
	ALWriteError("0- loadwav: ");
		
	AL.alBufferData(buffer, fmt, ADDRESSOF(sbuffer.data[0]), sizeBytes, samplePerSecond); 
	ALWriteError("1- loadwav: ");
	
	 AL.alGenSources(1, ADDRESSOF(source));
	 	
	 AL.alSourcef(source, AL.AL_PITCH, pitch);
	AL.alSourcef(source, AL.AL_GAIN, gain); 
	sourcePos := [0.0, 0.0, 0.0];
	AL.alSourcefv(source, AL.AL_POSITION, ADDRESSOF(sourcePos[0]));
	AL.alSourcei(source, AL.AL_LOOPING, AL.AL_FALSE); 
	 AL.alSourcei(source, AL.AL_BUFFER, buffer);
 
	listenerPos := [0.0, 0.0, 0.0];
	AL.alListenerfv(AL.AL_POSITION, ADDRESSOF(listenerPos[0]));
	ALWriteError("2-loadwav: ");
  END LoadWav;	

(** *)
PROCEDURE Play*;
BEGIN
	AL.alSourcePlay(source);
(*	ALWriteError("Playing Error: "); *)
END Play;

PROCEDURE IncGain*;
BEGIN
	gain := gain + 0.1;
	IF gain > 1.0 THEN gain := 1.0; END;
	AL.alSourcef(source, AL.AL_GAIN, gain);
END IncGain;

PROCEDURE DecGain*;
BEGIN
	gain := gain - 0.1;
	IF gain < 0.0 THEN gain := 0.0; END;
	AL.alSourcef(source, AL.AL_GAIN, gain);
END DecGain;

PROCEDURE IncPitch*;
BEGIN
	pitch := pitch + 0.1;
	IF pitch > 2.0 THEN pitch := 2.0; END;
	AL.alSourcef(source, AL.AL_PITCH, pitch);
END IncPitch;

PROCEDURE DecPitch*;
BEGIN
	pitch := pitch - 0.1;
	IF pitch < 0 THEN pitch := 0.0; END;
	AL.alSourcef(source, AL.AL_PITCH, pitch);
END DecPitch;

(** *)
PROCEDURE OpenDevice*;
VAR
	str: Strings.String;
	res : AL.ALboolean;
	s: ARRAY 32 OF CHAR;
BEGIN
	IF device # 0 THEN 
		KernelLog.String("Device already Open" ); KernelLog.Ln;
		RETURN 
	END;
	device := AL.alcOpenDevice(""); (* use default *)
	ALCWriteError(device, "Device Open Error: ");	

	LoadDeviceName(playConfilename, s);
	KernelLog.String("Device from configuration file: ");  KernelLog.String(s); KernelLog.Ln; 
	
	device := AL.alcOpenDevice(s);
	ALCWriteError(device, "Device Open Error: ");	
		
	IF device = 0 THEN RETURN END;
	
	str := AL.ALCGetString(device,   AL.ALC_DEVICE_SPECIFIER);
		ALCWriteError(device, "Device Specifier Error: ");	
		KernelLog.String("ALC_DEVICE_SPECIFIER = "); KernelLog.String(str^); KernelLog.Ln; 
		
	context := AL.alcCreateContext(device, 0);
			ALCWriteError(device, "Device alcCreateContext Error: ");	

	res := AL.alcMakeContextCurrent(context);  
		ALCWriteError(device, "Device alcMakeContextCurrent Error: ");
		ALWriteError("x-OpenDevice: ");

	(* load sound decoder *)
	decoder := Codecs.GetAudioDecoder("WAV");		
		KernelLog.String("Device Opened" ); KernelLog.Ln; 	

END OpenDevice;

(** *)
PROCEDURE CloseDevice*;
VAR
 	res : AL.ALboolean;
BEGIN
	IF device = 0 THEN 
		KernelLog.String("Device already Closed" ); KernelLog.Ln;
		RETURN 
	END;
	
  (* Clear the source and buffers if they are not empty *)  	
	 IF source # 0 THEN AL.alDeleteSources(1, ADDRESSOF(source)); source := 0;  END;
	 IF buffer # 0 THEN AL.alDeleteBuffers(1, ADDRESSOF(buffer)); buffer := 0;  END;
	 
	res := AL.alcMakeContextCurrent(0);
	AL.alcDestroyContext(context); context := 0;
	res :=AL.alcCloseDevice(device); device :=0; 

  	KernelLog.String("Device Closed: "); KernelLog.Boolean(res); KernelLog.Ln; 
END CloseDevice;

BEGIN
gain := 1.0; pitch := 1.0;
OpenDevice

END XNXLAudio.

SystemTools.Free XNXLAudio ~
XNXLAudio.OpenDevice ~
