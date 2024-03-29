  {¸ Maxisoft 2001, ™strabogymnasiet ECDT2}
  {---------------------------------------}
  { 780   - Rader Kod
    25248 - Bytes 'Code Size'
    29935 - Bytes 'Data Size'             }


program spejs;
uses games,thefont;
CONST
     CUBEWD       = 58;
     ZEYE         = -30;
     STARS        = 13;


type Virtual = array[0..64000] of byte;
     Sprites = array[0..64000] of byte;
     VirPtr  = ^Virtual;
     SprPtr  = ^Sprites;

var f      : text;
    VirScr : VirPtr;
    SprScr : SprPtr;
    SPRT,
    V64k   : Word;
    X,Y,I,Z: integer;
    C,R,G,B: Char;
    Way    : Double;
    Lvl    : integer;
    EnemyR,
    Enemy  : array[1..100] of Record
                               X,Y    : Double;
                               Active : Boolean;
                              end;
    GameOver : Boolean;
    Rocket,
    Explosion
           : array[1..100] of record
                               active : boolean;
                               x,y    : Integer;
                               Time   : Double;
                              end;
    Mesh   : Array[0..STARS] of record
                                 x,y,z : double;
                               end;
    Ship   : Record
               X,Y    : Integer;
               Points : Double;
               Point  : string;
             end;

    pcos,ncos,
    psin,nsin,
    afire1,afire : double;

{$i 3d.inc}

procedure ClearColor(C : Byte; Were : Word);
Assembler;
asm
   MOV AX,WERE
   MOV ES,AX
   XOR DI,DI
   MOV CX,7D00h
   MOV AL,C
   MOV AH,AL
   REP STOSW
end;

   procedure SetPixel(X,Y : Integer; C : Byte; were : word);
   begin
   MEM[WERE:(Y shl 8)+(Y shl 6)+X]:=C;
   end;

function invert(a : double):double;
begin
Invert:=A*(-1);
end;

procedure SetPal(nocol : byte; R,G,B : byte);
begin
 PORT[$3c8] := Nocol;
 PORT[$3c9] := R;
 PORT[$3c9] := G;
 PORT[$3c9] := B;
end;

procedure SetCodec(X,Y : integer);
var x1,y1 : integer;
    bak1, bak2, bak3 : integer;
begin
  for x1:=1  to 100 do
  for y1:=78+20 to 100+20 do begin
    bak1   := (Y1 shl 6)+(Y1 shl 8);
    if MEM[SPRT:bak1+X1]<>0 then begin
      bak2 := Y+Y1-20;
      bak3 := (bak2 shl 6)+(bak2 shl 8);
      MEM[V64K:bak3+(X+X1)]:=MEM[SPRT:bak1+X1];
    end;
  end;
end;

procedure SetRocket(X,Y : integer);
var x1,y1 : integer;
begin
  for x1:=40 to 62 do
  for y1:=35+20 to 68+20 do if
  MEM[SPRT:Y1*320+X1]<>0 then
  MEM[V64K:(Y+(Y1-17)-20)*320+(X+(X1-11))]:=MEM[SPRT:Y1*320+X1];
end;

procedure SetExplosion(X,Y : integer);
var x1,y1 : integer;
begin
  for x1:=1 to 34 do
  for y1:=38+20 to 68+20 do if
  MEM[SPRT:Y1*320+X1]<>0 then
  MEM[V64K:(Y+(Y1-15)-20)*320+(X+(X1-13))]:=MEM[SPRT:Y1*320+X1];
end;

procedure SetEnemyRock(X,Y : integer);
var x1,y1 : integer;
begin
  for x1:=74 to 100 do
  for y1:=1+20 to 27+20 do if
  MEM[SPRT:Y1*320+X1]<>0 then
  MEM[V64K:(Y+(Y1-15)-20)*320+(X+(X1-17))]:=MEM[SPRT:Y1*320+X1];
end;

procedure SetEnemy(X,Y : integer);
var x1,y1 : integer;
begin
  for x1:=36 to 72 do
  for y1:=1+20  to 33+20 do if
  MEM[SPRT:Y1*320+X1]<>0 then
  MEM[V64K:(Y+(Y1-16)-20)*320+(X+(X1-19))]:=MEM[SPRT:Y1*320+X1];
end;

procedure SetShip(X,Y : integer);
var x1,y1 : integer;
begin
  for x1:=0 to 34 do
  for y1:=20 to 33+20 do if
  MEM[SPRT:Y1*320+X1]<>0 then
  MEM[V64K:(Y+(Y1-16)-20)*320+(X+(X1-17))]:=MEM[SPRT:Y1*320+X1];
end;


procedure ClearVirtual(were : word); Assembler;
asm
  push were
  pop es
  mov cx, 32000
  xor di,di
  xor ax,ax
  cld
  rep stosw
end;

Procedure Flip;
BEGIN
  Move (VirScr^,MEM[$A000:0],64000);
END;

procedure DrawCube;
begin
    Workout(SIN(320));RotX(1,0,STARS);
    Workout(COS(200));RotY(1,0,STARS);

    For i := 0 to STARS do begin

     SetPixel(Round(Mesh[I].X*(ZEYE/(ZEYE-Mesh[I].Z)))+160,
              Round(Mesh[I].Y*(ZEYE/(ZEYE-Mesh[I].Z)))+100,
              ((Round(Mesh[I].Z)+CUBEWD) * 16 DIV (CUBEWD*2))+(256-25),
              V64k);
    end;


end;

procedure NewLevel;
var x,y,i : integer;
begin
  Lvl:=0;
  i:=0;
  for x := 1 to 7 do
  for y := 1 to 3 do begin
  inc(i);
   Enemy[i].Active:=TRUE;
   Enemy[i].X:=(X*33);
   Enemy[i].Y:=(Y*33);
  end;
  WriteG('lame o game',100,100,14,$A000);
  repeat until keydown[entscan];
end;

procedure DrawStuff;
var i,test : integer;
begin
for i := 1 to 100 do begin
  if Rocket[i].Active then SetRocket(Rocket[i].X,Rocket[i].Y);
  if EnemyR[i].Active then begin
    SetEnemyRock(Round(EnemyR[i].X),Round(EnemyR[i].Y));
    EnemyR[i].Y:=EnemyR[i].Y+0.31416;
  end;

  if Enemy[i].Active then begin
    SetEnemy(Round(Enemy[i].X),Round(Enemy[i].Y));
    Enemy[i].X:=Enemy[i].X+Way;
    if Random(1000)=1 then begin
      EnemyR[i].Active:=TRUE;
      EnemyR[i].X:=Round(Enemy[i].X);
      EnemyR[i].Y:=Round(Enemy[i].Y);
    end;
  end;
  if Explosion[i].Active then begin
   Explosion[i].Time:=Explosion[i].Time+0.2;
   if Explosion[i].Time>10 then Explosion[i].Active:=FALSE;
   SetExplosion(Explosion[i].X,Explosion[i].Y);
  end;
  {if random(10000)=1 then begin
   if not Enemy[i].Active then begin
    Enemy[i].Active:=TRUE;
    Enemy[i].X:=Random(220)+40;
    Enemy[i].Y:=10;
  end;end;}
  {for i := 1 to 100 do if Enemy[i].Active then inc(test);
  if test= 100 then NewLevel;}
end;
end;

procedure Collide;
var i,a : integer;
begin
if Ship.X>(320-18) then Ship.X:=(320-18);
if Ship.X<18 then Ship.X:=18;
if Ship.Y>(200-18) then Ship.Y:=(200-18);
if Ship.Y<16 then Ship.Y:=16;

For a := 1 to 100 do
For i := 1 to 100 do
 if Rocket[i].Active then
 if Enemy[a].Active then begin
 if (Rocket[i].X>(Enemy[A].X-19)) and (Rocket[i].X<(Enemy[A].X+19)) and
    (Rocket[i].Y>(Enemy[A].Y-16)) and (Rocket[i].Y<(Enemy[A].Y+16)) then begin
      Enemy[a].Active:=FALSE;
      Explosion[a].Active:=TRUE;
      Explosion[a].X:=round(Enemy[a].X)+34;
      Explosion[a].Y:=round(Enemy[a].Y)-33;
      Explosion[a].Time:=0;
      Rocket[i].Active:=FALSE;
      Ship.Points:=Ship.Points+ABS(Way);
      Inc(lvl);
      If Lvl=21 then NewLeveL;
    end;
  end;

For i := 1 to 100 do begin
if EnemyR[i].Active then begin
 if EnemyR[i].Y>190 then EnemyR[i].Active:=FALSE;
 if (EnemyR[i].X>Ship.X-16) and (EnemyR[i].X<Ship.X+16) and
    (EnemyR[i].Y>Ship.Y-16) and (EnemyR[i].Y<Ship.Y+16) then begin
     EnemyR[i].Active:=FALSE;
     Ship.Points:=Ship.Points-1.2;
 end;
 end;

if Enemy[i].Active then begin
 if Enemy[i].Y>190 then GameOver:=TRUE;
 if (Enemy[i].X+49)>320 then begin
   Way:=Invert(Way);
   for i := 1 to 100 do if Enemy[i].Active then Enemy[i].Y:=Enemy[I].Y+1;
 end;
 if (Enemy[i].X+20)<0 then begin
   Way:=Invert(Way);
   for i := 1 to 100 do if Enemy[i].Active then Enemy[i].Y:=Enemy[I].Y+1;
 end;

end;


if Rocket[i].Active then
 if Rocket[i].Y<0 then Rocket[i].Active:=FALSE
 else dec(Rocket[i].Y);

end;

end;

BEGIN (************************)
ASM
   MOV AX,0013h
   INT 10h
END;
  GetMem(VirScr,64000);
  V64K:=SEG(VirScr^);
  GetMem(SprScr,64000);
  SPRT:=SEG(SprScr^);
  ClearVirtual(V64k);

  Ship.X:=160;
  Ship.Y:=180;

  assign(f,'spejs.dat');
  reset(f);
  Randomize;
  For I := 0 to STARS do begin
    if Random(2)=1 then Mesh[I].X:=Random(CUBEWD)
     else begin Mesh[I].X:=Random(CUBEWD); Mesh[I].X:=Mesh[I].X-CUBEWD; end;
    if Random(2)=1 then Mesh[I].Y:=Random(CUBEWD)
     else begin Mesh[I].Y:=Random(CUBEWD); Mesh[I].Y:=Mesh[I].Y-CUBEWD; end;
    if Random(2)=1 then Mesh[I].Z:=Random(CUBEWD)
     else begin Mesh[I].Z:=Random(CUBEWD); Mesh[I].Z:=Mesh[I].Z-CUBEWD; end;
  end;

  for i := 1 to 100 do begin
    Rocket[i].Active:=FALSE;
    Enemy[i].Active:=FALSE;
  end;

  for x := 0 to 255 do begin
    read(f,r);
    read(f,g);
    read(f,b);
    SetPal(X,
             ORD( R ),
             ORD( G ),
             ORD( B ));
  end;
  ClearVirtual(SPRT);

  for x := 0 to 100 do
   for y := 0 to 100 do begin
     Read(f,c);
     MEM[SPRT:(Y+20)*320+X]:=Ord(C);
  end;


  Close(F);
  Way:=0.3;
  Lvl:=0;

  InitNewKeyInt;

    NewLevel;

  (*** MAIN LOOP ***)
  Repeat
    ClearVirtual(V64K);
    SetCodec(1,100);
    DrawCube;
    SetShip(Ship.X,Ship.Y);
    Collide;
    DrawStuff;
    Afire:=Afire+0.2;
    Str(Ship.Points:6:3,Ship.Point);
    WriteG(Concat('points: ',ship.Point),1,10,14,V64k);

    IF KEYDOWN[LEFTSCAN] then Dec(Ship.X);
    IF KEYDOWN[RightSCAN] then Inc(Ship.X);
    IF KEYDOWN[UpSCAN] then dec(Ship.Y);
    IF KEYDOWN[DownSCAN] then Inc(Ship.Y);
    if afire>5 then
    IF KEYDOWN[scanof(' ')] then begin
    i:=0;
    repeat
      inc(i);
    until (not rocket[i].active) or (i>100);
    if i<>101 then begin
      Rocket[i].Active:=TRUE;
      Rocket[i].X:=Ship.X-36;
      Rocket[i].Y:=Ship.Y-37;
    end;
    afire:=0;
    end;
    Flip;
  Until (KEYDOWN[escscan]) or GameOver;

  ASM
     MOV AX, 0003h
     INT 10h
  END;
  SetOldKeyInt;
  FreeMem(SprScr,64000);
  FreeMem(VirScr,64000);
END.