function icke(a : boolean):boolean;
begin
if a then icke:=false else icke:=true;
end;


procedure workout(r:double);
begin
 pcos:=cos(r*PI/360);
 ncos:=cos(-r*PI/360);
 psin:=sin(r*PI/360);
 nsin:=sin(-r*PI/360);
end;

{procedure workout(r:double);

procedure FSinCos(var S, C : extended ; A : extended) ; assembler ;
asm  fld [A] ; db $D9,$FB { >287: => fsincos; fpatan is D9F3  ;
  les di,[C] ; fstp es:tbyte ptr[di] ;
  les di,[S] ; fstp es:tbyte ptr[di] ;
  end ;

var q : double;
begin
 q:=360;
 pcos:=(r / 2*2*PI/360);
 psin:=(r / 2*2*PI/360);
 FSinCos(pcos,psin,q);

 ncos:=(r / 2*2*PI/360);
 nsin:=(r / 2*2*PI/360);
 FSinCos(ncos,nsin,q);
end;}



procedure rotx(dir,min,max:integer);
var y1,z1:double;
    i:integer;
begin
 if dir=1 then for i:=min to max do
  begin
   y1:=pcos*mesh[i].y-psin*mesh[i].z;
   z1:=psin*mesh[i].y+pcos*mesh[i].z;
   mesh[i].y:=y1;
   mesh[i].z:=z1;
  end
 else for i:=min to max do
  begin
   y1:=ncos*mesh[i].y-nsin*mesh[i].z;
   z1:=nsin*mesh[i].y+ncos*mesh[i].z;
   mesh[i].y:=y1;
   mesh[i].z:=z1;
  end;
end;

procedure roty(dir,min,max:integer);
var x1,z1:real;
    i:integer;
begin
 if dir=1 then for i:=min to max do
  begin
   x1:=pcos*mesh[i].x-psin*mesh[i].z;
   z1:=psin*mesh[i].x+pcos*mesh[i].z;
   mesh[i].x:=x1;
   mesh[i].z:=z1;
  end
 else for i:=min to max do
  begin
   x1:=ncos*mesh[i].x-nsin*mesh[i].z;
   z1:=nsin*mesh[i].x+ncos*mesh[i].z;
   mesh[i].x:=x1;
   mesh[i].z:=z1;
  end;
end;

procedure rotz(dir,min,max:integer);
var x1,y1:real;
    i:integer;
begin
 if dir=1 then for i:=min to max do
  begin
   y1:=pcos*mesh[i].y-psin*mesh[i].x;
   x1:=psin*mesh[i].y+pcos*mesh[i].x;
   mesh[i].x:=x1;
   mesh[i].y:=y1;
  end
  else for i:=min to max do
  begin
   y1:=ncos*mesh[i].y-nsin*mesh[i].x;
   x1:=nsin*mesh[i].y+ncos*mesh[i].x;
   mesh[i].x:=x1;
   mesh[i].y:=y1;
  end;
end;