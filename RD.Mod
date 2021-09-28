MODULE RD;

IMPORT Objects, Base, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR
	rd: RDVox;

CONST M=20;

TYPE RDVox* = OBJECT(Voxel)

PROCEDURE & init*;
BEGIN
	fillnoise
END init;

PROCEDURE fillnoise;
VAR i,j,k: INTEGER
BEGIN
			FOR i :=  1 TO M - 2 DO
				FOR j := 1 TO M - 2 DO
					FOR k := 1 TO M - 2 DO
						m1[i, j,k] := rand.Uniform() END
				END
			END;
END fillnoise;

PROCEDURE Generation;
VAR i,j,k: INTEGER;
		a,b,c: REAL;
BEGIN
	FOR i := 1 TO M - 2 DO
		FOR j := 1 TO M - 2 DO
			n[i,j,k] := m1[i - 1, j,k] + m1[i + 1, j,k] + m1[i, j - 1,k] + m1[i, j + 1,k]
				+ m1[i, j,k-1] +  m1[i,j,k+1] 
		END
	END; 
	a:=1;
	b:=10;
	FOR i := 1 TO M - 2 DO
		a:=a+0.48;
		b:=b+0.024;
		FOR j := 1 TO M - 2 DO
			c:=0.0;
			FOR k := 1 TO M - 2 DO
				(*  HERE ARE THE DIFFERENCE RULES! *)		
				c:=c+0.0000711;
				m1[i,j,k] := m1[i,j,k] + n[i,j,k] / a- (m2[i,j,k] * m2[i,j,k])  ;
				m2[i,j,k] := m2[i,j,k] +  m1[i,j,k] / b - c  ;
				IF m1[i,j,k] < 0 THEN m1[i,j,k] := 0 END;
				IF m2[i,j,k] < 0 THEN m2[i,j,k] := 0 END;
				IF m1[i,j,k] > 1 THEN m1[i,j,k] := 1 END;
				IF m2[i,j,k] > 1 THEN m2[i,j,k] := 1 END;
			END
		END
	END
END Generation;

PROCEDURE m*(i,j,k: INTEGER):REAL;
BEGIN
	i:=i MOD M; j:= j MOD M; k := k MOD M;
	RETURN(m1[i,j,k]);
END m;

VAR
	m1,m2, n: ARRAY M,M,M OF REAL;
	rand: Random.Generator;
	GO*: BOOLEAN;

BEGIN{ACTIVE, PRIORITY(Objects.Normal)}
	NEW(rand);
	REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(GO);
		END;
		Generation;
		BEGIN{EXCLUSIVE}
			GO:=FALSE;
		END;
	UNTIL ~Base.worldalive;
END RDVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(rd);
	RETURN(rd);
END thisvox;

END RD.