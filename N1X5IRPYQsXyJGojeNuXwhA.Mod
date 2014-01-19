MODULE N1X5IRPYQsXyJGojeNuXwhA;IMPORT Base, Strings;
CONST 
	s="VAR
	vox: XNXLBase.Voxel;  
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox) END;
	RETURN vox
END thisvox;"

VAR
	vox: Base.Voxel;  
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox) END;
	RETURN vox
END thisvox;

VAR
	string: Strings.String;
BEGIN
	string^:=s;
END N1X5IRPYQsXyJGojeNuXwhA. 