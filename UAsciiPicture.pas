unit UAsciiPicture;
{$mode objfpc}

interface

uses
  sysutils, classes;

type TAsciiPic = record
  id: integer;
  picture: array[0..3] of string;
end;

function GetAsciiPic(id: integer; timestr: string; sunrise: integer; sunset: integer)
                    : TAsciiPic;

implementation

function GetAsciiPic(id: integer; timestr: string; sunrise: integer; sunset: integer)
                    : TAsciiPic;
  var
    p: TAsciiPic;
    t, number: string;
    x: integer;
    split_time: TStringList;
    
  begin
    if(timestr = '') then 
      begin
        t := TimeToStr(Time);
        number := Copy(t, 0, 2);
        readStr(number, x);     // current time -> hours => as integer
      end
    else
      begin
        split_time := TStringlist.Create;
        split_time.Delimiter:=' ';
        split_time.DelimitedText := timestr; 
        t := split_time[1];
        number := Copy(t, 0, 2);
        readStr(number, x);     // forecast time -> hours => as integer
      end;
    
    case id of
      200..240: begin     // thunderstorm
                  p.picture[0] := ('  ---  ');
                  p.picture[1] := (' (___) ');
                  p.picture[2] := ('  _/   ');
                  p.picture[3] := (' /     ');
              end;
      300..330: begin     // drizzle
                  p.picture[0] := ('  ---  ');
                  p.picture[1] := (' (___) ');
                  p.picture[2] := ('   . . ');
                  p.picture[3] := ('       ');
              end;
      500..540: begin     // rain
                  p.picture[0] := ('  ---  ');
                  p.picture[1] := (' (___) ');
                  p.picture[2] := ('   * * ');
                  p.picture[3] := ('       ');
              end;
      600..630: begin     // snow
                  p.picture[0] := ('  \|/  ');
                  p.picture[1] := (' *-*-* ');
                  p.picture[2] := ('  /*\  ');
                  p.picture[3] := ('       ');
              end;
      700..790: begin     // mist
                  p.picture[0] := ('  ~~~  ');
                  p.picture[1] := ('  ~~~  ');
                  p.picture[2] := ('  ~~~  ');
                  p.picture[3] := ('       ');
              end;
      800: begin          // clear 
            if(x < sunset) and (x >= sunrise) then begin   // -> check
                        p.picture[0] := (' \ | / ');
                        p.picture[1] := ('-- O --');
                        p.picture[2] := (' / | \ ');
                        p.picture[3] := ('       ');
                      end
            else begin // moon
                        p.picture[0] := ('    _  ');
                        p.picture[1] := ('   /.  ');
                        p.picture[2] := ('  (.   ');
                        p.picture[3] := ('   \_  ');
                      end;
            end;
        801..802: begin     // few clouds
                    if(x < sunset) and (x >= sunrise) then begin
                          p.picture[0] := ('    \|/');
                          p.picture[1] := (' --- O-');
                          p.picture[2] := ('(___) \');
                          p.picture[3] := ('       ');
                      end
                    else begin
                        p.picture[0] :=('  ---  ');
                        p.picture[1] :=(' (___) ');
                        p.picture[2] :=('       ');
                        p.picture[3] :=('       ');
                      end;
                  end;
                  
        803..810: begin
                      p.picture[0] :=('  ---  ');
                      p.picture[1] :=(' (___) ');
                      p.picture[2] :=('       ');
                      p.picture[3] :=('       ');
                  end;
    end;
    p.id := id;
    
  Result := p;
end;

end.
