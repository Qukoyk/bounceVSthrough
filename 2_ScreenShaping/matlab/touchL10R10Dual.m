% touchL10R10 Dual

function varargout = touchL10R10Dual(varargin)
% TOUCHL10R10DUAL M-file for touchL10R10Dual.fig
%      TOUCHL10R10DUAL, by itself, creates a new TOUCHL10R10DUAL or raises the existing
%      singleton*.
%
%      H = TOUCHL10R10DUAL returns the handle to a new TOUCHL10R10DUAL or the handle to
%      the existing singleton*.
%
%      TOUCHL10R10DUAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOUCHL10R10DUAL.M with the given input arguments.
%
%      TOUCHL10R10DUAL('Property','Value',...) creates a new TOUCHL10R10DUAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before touchL10R10Dual_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to touchL10R10Dual_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help touchL10R10Dual

% Last Modified by GUIDE v2.5 19-Oct-2020 18:42:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @touchL10R10Dual_OpeningFcn, ...
                   'gui_OutputFcn',  @touchL10R10Dual_OutputFcn, ...
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


% --- Executes just before touchL10R10Dual is made visible.
function touchL10R10Dual_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to touchL10R10Dual (see VARARGIN)

% Choose default command line output for touchL10R10Dual
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes touchL10R10Dual wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = touchL10R10Dual_OutputFcn(hObject, eventdata, handles) 
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
global leverPressData
global leverData
global leverActData
global timeData
x = 3; % FR(x)
timeMax = 5400;
trialsMax = 100;

% �|�[�g�ݒ�
a = digitalio('mwadlink', 0); 

addline(a, 0:15, 0, 'in');     %addline(a, 0:7, 0, 'out')��
                               %putvalue(a.Line(1), value) �` putvalue(a.Line(8), value)�ɑΉ�
                               %addline(a, 8:15, 0, 'out')��
                               %putvalue(a.Line(9), value) �` putvalue(a.Line(16), value)�ɑΉ�  
                               
addline(a, 16:31, 1, 'out');   %addline(a, 16:23, 1, 'out')��
                               %putvalue(a.Line(17), value) �` putvalue(a.Line(24), value)�ɑΉ�
                               %DIN-100S-01��38 �` 45�ɑΉ�(46[VDD3]��50 or 100�Ɛڑ�)
                               %addline(a, 24:31, 1, 'out')��
                               %putvalue(a.Line(25), value) �` putvalue(a.Line(32), value)�ɑΉ�
                               %DIN-100S-01��88 �` 95�ɑΉ�(96[VDD4]��50 or100�Ɛڑ�) 
% �o�͐ݒ�
leverLeft = a.Line(18);
leverRight = a.Line(17);
houseLight = a.Line(20);
feeder = a.Line(21);
buzzer = a.Line(22);
leverCenter = a.Line(23);

% ���͐ݒ�                               
leverLeftAct = a.Line(9);
leverRightAct = a.Line(10);

% �|�[�g������
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(houseLight, 1);
putvalue(feeder, 1);
putvalue(buzzer, 1);
putvalue(leverCenter, 1);

% �ϐ��ݒ�
trials = 1;
leverLeftTrials = 0;
leverRightTrials = 0;

leverLeftMax = 50;
leverRightMax = 50;

leverPressCounter = 0;

sideThreshold = 10;

reactions = 0;
reactionsLeft = 0;
reactionsRight = 0;

sideLeft = 0;
sideRight = 0;

leftRight = 0;

buttonAct = 0;

% �f�[�^�֌W
leverPressData = [];
leverActData = [];
leverData = [];
latencyData = [];
timeData = [];

% ������
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(leverCenter, 1);
putvalue(houseLight, 1);
putvalue(buzzer, 1);
putvalue(feeder, 1);
pause(1);

% ���C���v���O����
timeNow = clock;
timeStart = clock;
timeTrial = clock;
tic;

%%%   Return �� BOX�����j�^�[������   %%% 
Session_Start=input('Press Enter to Start ');   % Session_Start �ϐ��̓_�~�[

set(handles.Button,'visible','off');
set(handles.Button,'Enable','off');
set(handles.text4,'visible','off');

%%%   Return �Ł@Start   %%%
disp('BOX�ɔ팱�̂����Ă�������');
Session_Start=input('Press Enter to Start ');   % Session_Start �ϐ��̓_�~�[

putvalue(houseLight, 0);



disp('START');

while (etime(clock,timeStart) <= timeMax)
    timeNow = clock;
    
    putvalue(leverLeft, 1);
    putvalue(leverRight, 1);
    % visible on
    set(handles.Button,'visible','on');
    set(handles.Button,'Enable','on');

    while buttonAct == 0
        pause(0.01)
    end
    
    % �{�^�����B��
    set(handles.Button,'visible','off');
    set(handles.Button,'Enable','off')
    % ���o�[��
    putvalue(leverLeft, 0);
    putvalue(leverRight, 0);
    
    while reactions ~= x
        timeNow = clock;
        

        if etime(clock,timeStart) > timeMax
            disp('�ő厞�ԂɒB���ďI��');
            break
        end

%         if sideLeft >= sideThreshold
%             putvalue(leverLeft, 1);
%             putvalue(leverRight, 0);
%         end
%         if sideRight >= sideThreshold
%             putvalue(leverLeft, 0);
%             putvalue(leverRight, 1);
%         end

        if reactionsLeft == x || reactionsRight == x
            reactions = x;
            reactionsLeft = 0;
            reactionsRight = 0;
        end

        if getvalue(leverLeftAct) == 1
            trials = trials + 1;
            leverPressCounter = leverPressCounter + 1;
            reactionsLeft = reactionsLeft + 1;
            reactionsRight = 0;
            timeNow = clock;
            timePast = toc;
            leverPressData(end+1) = leverPressCounter;
            leftRight = 1;
            leverData(end+1) = leftRight;
            timeData(end+1) = timePast;
            fprintf('\n���� %d', leverPressCounter);
            fprintf('\n %d / %d \n',reactionsLeft,x);
            while getvalue(leverLeftAct) == 1
                pause(0.01);
            end
        end
        if getvalue(leverRightAct) == 1
            trials = trials + 1;
            leverPressCounter = leverPressCounter + 1;
            reactionsRight = reactionsRight + 1;
            reactionsLeft = 0;
            timeNow = clock;
            timePast = toc;
            leverPressData(end+1) = leverPressCounter;
            leftRight = 2;
            leverData(end+ 1) = leftRight;
            timeData(end+1) = timePast;
            fprintf('\n���� %d', reactionsRight);
            fprintf('\n %d / %d \n',reactionsRight,x);
            while getvalue(leverRightAct) == 1
                pause(0.01);
            end
        end

        pause(0.01);
    end
    
    buttonAct = 0;
    
    if (leftRight == 1 && reactions == x && leverLeftTrials < leverLeftMax && sideLeft < sideThreshold)
        reactions = 0;
        leftRight = 0;
        sideRight = sideThreshold;
        sideLeft = sideLeft + 1;
        if sideLeft == sideThreshold
            sideRight = 0;
        end
        leverLeftTrials = leverLeftTrials + 1;
        leverActData(leverPressCounter) = leverLeftTrials;
        fprintf('\n�����o�[���s %d', leverLeftTrials);
        fprintf('\n�������� %7.2f\n', timePast);
        putvalue(feeder,0);
        pause(0.5);
        putvalue(feeder,1);
        pause(0.5);
    end
    if (leftRight == 2 && reactions == x && leverRightTrials < leverRightMax && sideRight < sideThreshold)
        reactions = 0;
        leftRight = 0;
        sideLeft = sideThreshold;
        sideRight = sideRight + 1;
        if sideRight == sideThreshold
            sideLeft = 0;
        end
        leverRightTrials = leverRightTrials + 1;
        leverActData(leverPressCounter) = leverRightTrials;
        fprintf('\n�E���o�[���s %d', leverRightTrials);
        fprintf('\n�������� %7.2f\n', timePast);
        putvalue(feeder, 0);
        pause(0.5);
        putvalue(feeder, 1);
        pause(0.5);
    end
    
    % wrong lever
    if reactions == x
        reactions = 0;
        fprintf('\nWrong Lever');
        leverPressData(end+1) = leverPressCounter;
        leverData(end+1) = 9;
        timeData(end+1) = timePast;
        fprintf('\n�������� %7.2f\n', timePast);
    end

    if (leverLeftTrials + leverRightTrials) >= trialsMax
        disp('�ő厎�s���ɒB���ďI��');
        break
    end
    pause(0.01);
end

% ������
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(leverCenter, 1);
putvalue(houseLight, 1);
putvalue(buzzer, 1);
putvalue(feeder, 1);

dataMatrix = [leverPressData',leverData',leverActData',timeData'];
filter = {'*.csv'};
[file,path] = uiputfile(filter);
fileDir = strcat(path,file);
csvwrite(fileDir,dataMatrix);

fprintf('\n�����o�[ %d ��', leverLeftTrials);
fprintf('\n�E���o�[ %d ��', leverRightTrials);
fprintf('\n%7.2f �b��������',toc);
end

% --- Executes on button press in Button.
function Button_Callback(hObject, eventdata, handles)
% hObject    handle to Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timeButton
global buttonAct
global trials
global leftRight
global buttonTouch
global leverPressData
global leverData
global leverActData
global timeData

timeButton = toc;
trials = trials + 1;
buttonTouch = buttonTouch + 1;
buttonAct = 1;
timeData(trials) = timeButton;
leftRight = 3;
leverPressData(end+1) = buttonTouch;
leverData(trials) = leftRight;
fprintf('\n�X�N���[���^�b�`���� %d \n',buttonTouch);
fprintf('��������%7.2f\n',timeButton);

end 
