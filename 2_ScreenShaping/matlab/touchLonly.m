% touchLonly.m
% スクリーンタッチ行動形成
% 
% Qukoyk
% 2020/10/15

function varargout = touchLonly(varargin)
% TOUCHSCREENCRF MATLAB code for touchLonly.fig
%      TOUCHSCREENCRF, by itself, creates a new TOUCHSCREENCRF or raises the existing
%      singleton*.
%
%      H = TOUCHSCREENCRF returns the handle to a new TOUCHSCREENCRF or the handle to
%      the existing singleton*.
%
%      TOUCHSCREENCRF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOUCHSCREENCRF.M with the given input arguments.
%
%      TOUCHSCREENCRF('Property','Value',...) creates a new TOUCHSCREENCRF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before touchLonly_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to touchLonly_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help touchLonly

% Last Modified by GUIDE v2.5 15-Oct-2020 17:18:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @touchLonly_OpeningFcn, ...
                   'gui_OutputFcn',  @touchLonly_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before touchLonly is made visible.
function touchLonly_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to touchLonly (see VARARGIN)

% Choose default command line output for touchLonly
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes touchLonly wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = touchLonly_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

global buttonAct
global timeButton
global timeData
global trials
global buttonTouch
global leverData
global leverPressData
global timeData

x = 3; % FR(x)
timeMax = 3600;
trialsMax = 100;

% ポート設定
a = digitalio('mwadlink', 0); 

addline(a, 0:15, 0, 'in');     %addline(a, 0:7, 0, 'out')が
                               %putvalue(a.Line(1), value) 〜 putvalue(a.Line(8), value)に対応
                               %addline(a, 8:15, 0, 'out')が
                               %putvalue(a.Line(9), value) 〜 putvalue(a.Line(16), value)に対応  
                               
addline(a, 16:31, 1, 'out');   %addline(a, 16:23, 1, 'out')が
                               %putvalue(a.Line(17), value) 〜 putvalue(a.Line(24), value)に対応
                               %DIN-100S-01の38 〜 45に対応(46[VDD3]を50 or 100と接続)
                               %addline(a, 24:31, 1, 'out')が
                               %putvalue(a.Line(25), value) 〜 putvalue(a.Line(32), value)に対応
                               %DIN-100S-01の88 〜 95に対応(96[VDD4]を50 or100と接続) 
% 出力設定
leverLeft = a.Line(18);
leverRight = a.Line(17);
houseLight = a.Line(20);
feeder = a.Line(21);
buzzer = a.Line(22);
centerLever = a.Line(23);

% 入力設定                               
leverLeftAct = a.Line(9);
leverRightAct = a.Line(10);

% ポート初期化
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(houseLight, 1);
putvalue(feeder, 1);
putvalue(buzzer, 1);
putvalue(centerLever, 1);


trials = 0;
leverPressCounter = 0;
buttonTouch = 0;

leverLeftTrials = 0;

reactions = 0;
reactionsLeft = 0;

leverData = [];
leverPressData = [];
timeData = [];
leverActData = [];


%%%   Return で BOX内モニター初期化   %%% 
Session_Start=input('Press Enter to Start ');   % Session_Start 変数はダミー

set(handles.Button,'visible','off');
set(handles.Button,'Enable','off');
set(handles.text4,'visible','off');

%%%   Return で　Start   %%%
disp('BOXに被験体を入れてください');
Session_Start=input('Press Enter to Start ');   % Session_Start 変数はダミー


timeStart = clock;
putvalue(houseLight, 0);     %Light点灯
% visible on
set(handles.Button,'visible','on');
set(handles.Button,'Enable','on');
disp('実験開始');
tic;

while etime(clock,timeStart) <= timeMax
    if leverLeftTrials >= trialsMax
        fprintf('最大試行数に達して終了');
        break
    end
    % touch反応があれば
    if buttonAct == 1
        buttonAct = 0;
        trials = trials + 1;
        % ボタンを隠す
        set(handles.Button,'visible','off');
        set(handles.Button,'Enable','off')
        % レバー提示
        putvalue(leverLeft, 0);
        % レバー押し
        while reactions ~= x
            timeNow = clock;

            if etime(clock,timeStart) > timeMax
                disp('最大時間に達して終了');
                break
            end

            if getvalue(leverLeftAct) == 1
                trials = trials + 1;
                leverPressCounter = leverPressCounter + 1;
                reactionsLeft = reactionsLeft + 1;
                timeNow = clock;
                timePast = toc;
                leverPressData(trials) = leverPressCounter;
                leftRight = 1;
                leverData(trials) = leftRight;
                timeData(trials) = timePast;
                fprintf('\nレバー押し反応 %d', leverPressCounter);
                fprintf('\n %d / %d \n',reactionsLeft,x);
                while getvalue(leverLeftAct) == 1
                    pause(0.01);
                end
            end
            
            if reactionsLeft == x
                reactions = x;
                reactionsLeft = 0;
            end
            pause(0.01);
        end
        
        reactions = 0;
        leftRight = 0;
        leverLeftTrials = leverLeftTrials + 1;
        leverActData(leverPressCounter) = leverLeftTrials;
        fprintf('\n左レバー試行 %d', leverLeftTrials);
        fprintf('\n反応時間 %7.2f\n', timePast);
        fprintf('\n==================\n');
        % 餌やり
        putvalue(feeder,0);
        pause(0.5);
        putvalue(feeder,1);
        pause(0.5);
        % レバー格納
        putvalue(leverLeft, 1);
        % ボタンを表す
        set(handles.Button,'visible','on');
        set(handles.Button,'Enable','on');
    end
    pause(0.01);
end

fprintf('OVER');
fprintf('\n%d試行完成',leverLeftTrials)
fprintf('\n%7.2f秒かかった',timePast);
% ポート初期化
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(houseLight, 1);
putvalue(feeder, 1);
putvalue(buzzer, 1);
putvalue(centerLever, 1);

% データ保存
dataMatrix = [leverData',timeData',leverActData'];
filter = {'*.csv'};
[fileName,pathName] = uiputfile(filter);
fileDir=strcat(pathName,fileName);
csvwrite(fileDir,dataMatrix);  
end


% --- Executes on button press in pushbutton1.
function Button_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timeButton
global buttonAct
global trials
global leftRight
global buttonTouch
global leverData
global leverPressData
global timeData

timeButton = toc;
trials = trials + 1;
buttonTouch = buttonTouch + 1;
buttonAct = 1;
timeData(trials) = timeButton;
leftRight = 3;
leverPressData(trials) = buttonTouch;
leverData(trials) = leftRight;
fprintf('\nスクリーンタッチ反応 %d \n',buttonTouch);
fprintf('反応時間%7.2f\n',timeButton);
end
