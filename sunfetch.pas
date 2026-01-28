program wetter;
{$mode objfpc}

uses
  fphttpclient, fpjson, jsonparser, sysutils, opensslsockets, crt,
  UAsciiPicture;

const
  API_KEY = ''; { Enter your OpenWeather APi Key here }
  
  { Berlin              London        New York }
  { LAT = '52.52';      '51.50';      '40.71'; }   
  { LON = '13.40';      '-0.11';      '-74.00';}
  
  { Neustrelitz }
  LAT = '53.33';                                { LAT }
  LON = '13.09';                                { LON } 

  
  lang = 'en';               { language: 'de', 'en', 'es', ... }
  units = 'metric';          {e.g 'imperial', 'standard', 'metric'}

var
  Response: ansistring;
  JSONData: TJSONData;
  Root: TJSONObject;
  http: ansistring;
  
  // global -> required in both procedures
  //         -> when calling GetAsciiPic(id, timestr, sunrise, sunset)
  t_sunset: integer;
  t_sunrise: integer;

// Helper
function UnixToDateTime(UnixTime: Int64; zone: integer): TDateTime;
begin
  Result := (UnixTime + zone) / 86400 + 25569;
end;

procedure WaitForReturn;
begin
  cursoroff;
  gotoxy(3, 23);
  write('Press <ENTER> ');
  readln;
  ClrScr;
end;


// CurrentWeather
procedure CurrentWeather;
var 
  AsciiPic: TAsciiPic;   // in unit UAsciiPicture
  WeatherArray: TJSONArray;
  MainObj: TJSONObject;
  WindObj: TJSONObject;
  SysObj: TJSONObject;
  
  Description: string;
  id: integer;
  temp: double;
  WindSpeed: double;
  humidity: integer;
  sunrise, sunset: Int64;
  city: string;
  country: string;
  timezone: integer;
  
  YY,MM,DD : Word;
  
  // Get sunset / sunrise hours as string
  s_sunset: string;
  s_sunrise: string;
  
begin
  http := Concat('https://api.openweathermap.org/data/2.5/weather?lat=',
                LAT, '&lon=', LON, '&units=', units,'&lang=', lang, 
                '&appid=', API_KEY);
          
  Response := TFPHttpClient.SimpleGet(http);
  DeCodeDate(Date,YY,MM,DD);
  
  try
    JSONData := GetJSON(Response);
    Root := JSONData as TJSONObject;
    
    WeatherArray := Root.Arrays['weather'];
    description := WeatherArray.Objects[0].Strings['description'];
    id := WeatherArray.Objects[0].Integers['id'];
    
    MainObj := Root.Objects['main'];
    temp := MainObj.Floats['temp'];
    humidity := MainObj.Integers['humidity'];
    
    WindObj := Root.Objects['wind'];
    WindSpeed := WindObj.Floats['speed'];
    
    SysObj := Root.Objects['sys'];
    sunrise := SysObj.Int64s['sunrise'];
    sunset := SysObj.Int64s['sunset'];
    city := Root.Strings['name'];
    country := Root.Objects['sys'].Strings['country'];
    timezone := Root.Int64s['timezone'];
    
    s_sunset := FormatDateTime('hh', UnixToDateTime(sunset, timezone));
    s_sunrise := FormatDateTime('hh', UnixToDateTime(sunrise, timezone));
    readStr(s_sunset, t_sunset);  // convert hour string to integer
    readStr(s_sunrise, t_sunrise);
    
  except
    on E: Exception do
      writeln(E.Message);
  
  end;
  clrscr;
  writeln(' ______ ', Format('%2d/%2d/%2d %s ______', [dd,mm,yy, TimeToStr(Time)]));
  writeln('|                                 |');
  AsciiPic := GetAsciiPic(id, '', t_sunrise, t_sunset);
  writeln('|             ', AsciiPic.picture[0], '             |');
  writeln('|             ', AsciiPic.picture[1], '             |');
  writeln('|             ', AsciiPic.picture[2], '             |');
  writeln('|             ', AsciiPic.picture[3], '             |');
  writeln('|_________________________________|');
  writeln;
  writeln('  Location    : ', Format('%.13s - %.2s', [city, country]));
  writeln('  Description : ', Format('%.16s', [UTF8Encode(Description)]));
  writeln('  Temperature : ', Format('%5.2f °C', [Temp]));
  writeln('  Humidity    : ', Format('%5d  %s', [humidity, '%']));
  writeln('');
  writeln('  Wind        : ', Format('%3.2f km/h', [(windSpeed * 3.6)])); {change if units = 'imperial'}
  writeln('');
  writeln('  Sunrise     : ', FormatDateTime('hh:nn', UnixToDateTime(sunrise, timezone)));
  writeln('  Sunset      : ', FormatDateTime('hh:nn', UnixToDateTime(sunset, timezone)));
  writeln;
  writeln;
  writeln;
  writeln;
  writeln(' _________________________________ ');
end;


// Forecast
procedure Forecast;
var
  AsciiPic: TAsciiPic;   // in unit UAsciiPicture
  DailyArr: TJSONArray;
  DayObj: TJSONObject;
  TempObj: TJSONObject;
  DayWeather: TJSONArray;
  i: integer;
  DayDate: string;
  temp: double;
  DayDesc: string;
  id: integer;
  
  xpos: integer;
  ypos: integer;
  

begin
  http := Concat('https://api.openweathermap.org/data/2.5/forecast?lat=',
                LAT, '&lon=', LON, '&units=metric&lang=', lang, 
                '&appid=', API_KEY);
          
  Response := TFPHttpClient.SimpleGet(http);
    
  try
    JSONData := GetJSON(Response);
    Root := JSONData as TJSONObject;
    DailyArr := Root.Arrays['list'];
    
    for i := 0 to 5 do
    begin
        DayObj := DailyArr.Objects[i];
        DayDate := DayObj.Strings['dt_txt'];  
        
        TempObj := DayObj.Objects['main'];
        temp := TempObj.Floats['temp'];
      
        DayWeather := DayObj.Arrays['weather'];
        DayDesc := DayWeather.Objects[0].Strings['description'];
        id := DayWeather.Objects[0].Integers['id'];
        
        case i of
         0: begin
              xpos := 36;
              ypos := 1;
            end;
         1: begin
              xpos := 36;
              ypos := 9
            end;
         2: begin
              xpos := 36;
              ypos := 17;
            end;
         3: begin
              xpos := 58;
              ypos := 1;
            end;
         4: begin
              xpos := 58;
              ypos := 9;
            end;
         5: begin
              xpos := 58;
              ypos := 17;
            end;
        end;
        
        gotoxy(xpos, ypos);
        write(' _', Format('%s_', [DayDate]));
        gotoxy(xpos, ypos+1);
        AsciiPic := GetAsciiPic(id, DayDate, t_sunrise, t_sunset);
        write('|       ', AsciiPic.picture[0], '       |');
        gotoxy(xpos, ypos+2);
        write('|       ', AsciiPic.picture[1], '       |');
        gotoxy(xpos, ypos+3);
        write('|       ', AsciiPic.picture[2], '       |');
        gotoxy(xpos, ypos+4);
        write('|       ', AsciiPic.picture[3], '       |');
        gotoxy(xpos, ypos+5);
        write('  Temp : ', Format('%-3.2f °C', [temp]));
        gotoxy(xpos, ypos+6);
        write('  -> ', Format('%.16s', [UTF8Encode(DayDesc)]));
    end;
  
  except
    on E: Exception do
      writeln(E.Message);
  end;

end;


// main
begin
  CurrentWeather;
  Forecast;
  WaitForReturn;
  
  JSONData.Free;
end.
