{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.BaseController;

interface

uses
  System.Classes, System.SysUtils, Web.HTTPApp, MVC.View, System.Net.URLClient,
  System.Net.HttpClientComponent, IdURI, IdGlobal, MVC.RedisM, MVC.RedisList,
  xsuperobject, MVC.command, MVC.Config;

procedure SetRoule(name: string; ACtion: TClass; path: string = ''; isInterceptor: Boolean = True);

type
  TBaseController = class(TPersistent)
  private
    FRequest: TWebRequest;
    FResponse: TWebResponse;
    FActionPath: string;
    FActionRoule: string;
    procedure SetRequest(const Value: TWebRequest);
    procedure SetResponse(const Value: TWebResponse);
    procedure SetActionPath(const Value: string);
    procedure SetActionRoule(const Value: string);
  protected
    procedure CreateView(); virtual;
  public
    View: TView;
    Error: Boolean;
    function isPOST: Boolean;
    function isGET: Boolean;
    function isPut: Boolean;
    function isAny: Boolean;
    function isDelete: Boolean;
    function isHead: Boolean;
    function isPatch: Boolean;
    function isNil(text: string): Boolean;
    function isNotNil(text: string): Boolean;
    function URLDecode(Asrc: string; AByteEncoding: IIdTextEncoding = nil): string;
    function URLEncode(Asrc: string; AByteEncoding: IIdTextEncoding = nil): string;
    function Interceptor: boolean;
    procedure SetParams(); virtual;
    procedure ShowHTML(html: string);
    procedure FreeDb;
    function HttpGet(url: string; encode: TEncoding): string;
    constructor Create();
    destructor Destroy; override;
    function AppPath: string; //获取项目物理路径
    property Request: TWebRequest read FRequest write SetRequest;
    property Response: TWebResponse read FResponse write SetResponse;
    property ActionPath: string read FActionPath write SetActionPath;
    property ActionRoule: string read FActionRoule write SetActionRoule;
  end;

implementation

procedure SetRoule(name: string; ACtion: TClass; path: string; isInterceptor: Boolean);
begin
   CreateRouleMap();
  _RouleMap.SetRoule(name, ACtion, path, isInterceptor);
end;

{ TBaseController }
function TBaseController.Interceptor: boolean;
begin
  if Config.open_interceptor then
  begin
    Result := _interceptor.execute(View, Error);
  end
  else
  begin
    Result := false;
  end;
end;

function TBaseController.isAny: Boolean;
begin
  Result := Request.MethodType = mtAny;
end;

function TBaseController.isDelete: Boolean;
begin
  Result := Request.MethodType = mtDelete;
end;

function TBaseController.isGET: Boolean;
begin
  Result := Request.MethodType = mtGet;
end;

function TBaseController.isHead: Boolean;
begin
  Result := Request.MethodType = mtHead;
end;

function TBaseController.isNil(text: string): Boolean;
begin
  if (Trim(text) = '') then
    Result := true
  else
    Result := false;
end;

function TBaseController.isNotNil(text: string): Boolean;
begin
  Result := not isNil(text);
end;

function TBaseController.isPatch: Boolean;
begin
  Result := Request.MethodType = mtPatch;
end;

function TBaseController.isPOST: Boolean;
begin
  Result := Request.MethodType = mtPost;
end;

function TBaseController.isPut: Boolean;
begin
  Result := Request.MethodType = mtPut;
end;

procedure TBaseController.SetActionPath(const Value: string);
begin
  FActionPath := Value;
end;

procedure TBaseController.SetActionRoule(const Value: string);
begin
  FActionRoule := Value;
end;

procedure TBaseController.SetParams;
begin
  try
    if View = nil then
    begin
      View := TView.Create(Response, Request, ActionPath, ActionRoule);
      CreateView;
    end
    else
      View.setData(Response, Request, ActionPath, ActionRoule);
  except
    on e: Exception do
    begin
      self.Response.Content := e.ToString;
      Error := true;
    end;
  end;
end;

procedure TBaseController.SetRequest(const Value: TWebRequest);
begin
  FRequest := Value;
end;

procedure TBaseController.SetResponse(const Value: TWebResponse);
begin
  FResponse := Value;
end;

procedure TBaseController.ShowHTML(html: string);
begin
  View.ShowHTML(html);
end;

function TBaseController.URLDecode(Asrc: string; AByteEncoding: IIdtextEncoding): string;
begin
  if AByteEncoding <> nil then
    Result := TIdURI.URLDecode(Asrc, AByteEncoding)
  else
    Result := TIdURI.URLDecode(Asrc);
end;

function TBaseController.URLEncode(Asrc: string; AByteEncoding: IIdTextEncoding): string;
begin
  if AByteEncoding <> nil then
    Result := TIdURI.URLEncode(Asrc, AByteEncoding)
  else
    Result := TIdURI.URLEncode(Asrc);
end;

function TBaseController.AppPath: string;
begin
  Result := WebApplicationDirectory+Config.__WebRoot__+'/';
end;

constructor TBaseController.Create();
begin
  View := nil;
  ActionPath := '';
end;

procedure TBaseController.CreateView;
begin

end;

destructor TBaseController.Destroy;
begin
  View.Free;
  inherited;
end;

procedure TBaseController.FreeDb;
begin
  view.FreeDb;
end;

function TBaseController.HttpGet(url: string; encode: TEncoding): string;
var
  http: TNetHTTPClient;
  html: TStringStream;
  ret: string;
begin
  ret := '';
  if Trim(url) <> '' then
  begin
    try
      http := TNetHTTPClient.Create(nil);
      html := TStringStream.Create('', encode);
      http.UserAgent := 'User-Agent:Mozilla/4.0(compatible;MSIE7.0;WindowsNT5.1;360SE)';
      try
        http.Get(url, html);
        ret := (html.DataString);
      except
        ret := '请求异常';
      end;
    finally
      html.Clear;
      FreeAndNil(html);
      FreeAndNil(http);
    end;
  end;
  Result := ret;
end;

end.

