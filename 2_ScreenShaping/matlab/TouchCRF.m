
%%%   H26年度卒業生 飯尾
%%%   TouchCRF
%%%   2014/06/11 完成
%%%   2014/06/11 BOX1用に位置を調整
%%%   BOX1-Display2
%%%      width:157
%%%      height:50
%%%      monitor中央73.5

function varargout = TouchCRF(varargin)
% TOUCHCRF M-file for TouchCRF.fig
%      TOUCHCRF, by itself, creates a new TOUCHCRF or raises the existing
%      singleton*.
%
%      H = TOUCHCRF returns the handle to a new TOUCHCRF or the handle to
%      the existing singleton*.
%
%      TOUCHCRF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOUCHCRF.M with the given input arguments.
%
%      TOUCHCRF('Property','Value',...) creates a new TOUCHCRF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TouchCRF_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TouchCRF_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TouchCRF

% Last Modified by GUIDE v2.5 31-Oct-2014 09:50:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TouchCRF_OpeningFcn, ...
                   'gui_OutputFcn',  @TouchCRF_OutputFcn, ...
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


% --- Executes just before TouchCRF is made visible.
function TouchCRF_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TouchCRF (see VARARGIN)

% Choose default command line output for TouchCRF
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TouchCRF wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = TouchCRF_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%   変数設定   %%%
global a;          %ポート関連
global MaxTrial;   %最大試行数
global Trial;      %現在の試行数
global T2;         %TT決定変数
global TT;         %タッチスクリーン反応時間(実験開始から)
global button;     %タッチスクリーン反応完了確認(0=未反応,1=反応済)
global To;
global MaxTime;
global AutoFeedTime;
global AutoFeed;

%%%   定数設定   %%%
MaxTrial=100;
MaxTime=4200;
Trial=1;
button=0;


%%%   ポート設定   %%%
a = digitalio('mwadlink', 0); 

addline(a, 0:15, 0, 'in');     %addline(a, 0:7, 0, 'out')が
                               %putvalue(a.Line(1), value) ～ putvalue(a.Line(8), value)に対応
                               %addline(a, 8:15, 0, 'out')が
                               %putvalue(a.Line(9), value) ～ putvalue(a.Line(16), value)に対応  
                               
addline(a, 16:31, 1, 'out');   %addline(a, 16:23, 1, 'out')が
                               %putvalue(a.Line(17), value) ～ putvalue(a.Line(24), value)に対応
                               %DIN-100S-01の38 ～ 45に対応(46[VDD3]を50 or 100と接続)
                               %addline(a, 24:31, 1, 'out')が
                               %putvalue(a.Line(25), value) ～ putvalue(a.Line(32), value)に対応
                               %DIN-100S-01の88 ～ 95に対応(96[VDD4]を50 or100と接続) 

%%%   ポート初期化   %%%     0:on  1:off
putvalue(a.Line(17), 1)   %RightLeverPresent
putvalue(a.Line(18), 1)   %LeftLeverPresent
putvalue(a.Line(19), 1)   %NotUsed
putvalue(a.Line(20), 1)   %HouseLight
putvalue(a.Line(21), 1)   %Feeder
putvalue(a.Line(22), 1)   %Buzzer
putvalue(a.Line(23), 1)   %CenterLever

%%%   Return で BOX内モニター初期化   %%% 
Session_Start=input('Press Enter to Start ');   % Session_Start 変数はダミー

set(handles.Button,'visible','off');
set(handles.Button,'Enable','off');
set(handles.text4,'visible','off');

%%%   Return で　Start   %%%
disp('BOXに被験体を入れてください');
Session_Start=input('Press Enter to Start ');   % Session_Start 変数はダミー

%%%   実験プログラム開始   %%%
tic;
To=clock;
disp('start')
StartTime=datestr(clock)
putvalue(a.Line(20),0);     %Light点灯
fprintf('Trial=')
disp(Trial)

set(handles.Button,'visible','on');
set(handles.Button,'Enable','on');
set(handles.text4,'visible','on');

%%%   実験メインプログラム   %%%　　　←これをMaxTrialまでループ

while etime(clock,To)<=MaxTime  
    
    pause(0.1);
    
    if button==1
        set(handles.Button,'visible','off');
        set(handles.Button,'Enable','off');
        set(handles.text4,'visible','off');
            
            %%%%%     報酬     %%%%%
            putvalue(a.Line(21),0);     %Feeder
            putvalue(a.Line(22),0);     %FeederBuzzer
            pause(0.5);
            putvalue(a.Line(21),1);     %Feeder
            putvalue(a.Line(22),1);     %FeederBuzzer
            %%%%%             %%%%%
    
        Trial=Trial+1;
        fprintf('Trial=')
        disp(Trial)      
            
        if Trial>=MaxTrial+1        %SessionEnd判定
            break;
        end                
            
        button=0;
        
        pause(5);     %%% ITI
    
        set(handles.Button,'visible','on');
        set(handles.Button,'Enable','on');
        set(handles.text4,'visible','on');
    end 
           
end   %%%   while Trial<=MaxTrial

%%%   SessionEnd処理   %%%

disp('end')
EndTime=datestr(clock)

%%%   ポート初期化   %%%     0:off  1:on
putvalue(a.Line(17), 1)   %RightLeverPresent
putvalue(a.Line(18), 1)   %LeftLeverPresent
putvalue(a.Line(19), 1)   %NotUsed
putvalue(a.Line(20), 1)   %HouseLight
putvalue(a.Line(21), 1)   %Feeder
putvalue(a.Line(22), 1)   %Buzzer
putvalue(a.Line(23), 1)   %CenterLever

set(handles.Button,'visible','off');
set(handles.Button,'Enable','off');
set(handles.text4,'visible','off');

%%%   Return で　DataSave   %%%
disp('Returnで保存画面に移行します')
Save_Session=input('Press Enter to Save ');   % Save_Session 変数はダミー

%%%   DataSave   %%%
TT=TT';
[fn,pn] = uiputfile('TT.xls','TT');
filename=strcat(pn,fn);
save(filename,'TT','-ASCII','-tabs');  

end

% --- Executes on button press in Button.
function Button_Callback(hObject, eventdata, handles)
% hObject    handle to Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Trial;
global button;
global T2;
global TT;

T2=toc;   %ticからの経過時間を測定

button=1;
TT(Trial)=T2;
fprintf('TT=')
disp(TT(Trial))      

end 
