% autoShapingRonly.m
% 右レバーのみのAuto Shaping
% Qukoyk
% 2020.10.07

clc;

% 定数設定
x = 1; % FR(x)
timeMax = 60*60; % 最大実験時間
trialsMax = 100; % 最大試行数
reinforcers = 1; % 強化量


% ポート設定
a = digitalio('mwadlink', 0); 
addline(a, 0:15, 0, 'in');
addline(a, 16:31, 1, 'out');
% 入力設定                               
leverLeftAct = a.Line(9);
leverRightAct = a.Line(10);
% 出力設定
leverLeft = a.Line(18);
leverRight = a.Line(17);
houseLight = a.Line(20);
feeder = a.Line(21);
buzzer = a.Line(22);
leverCenter = a.Line(23);


% 変数設定
leverLeftCounter = 0;
leverRightCounter = 0;
autoShapingCounter = 0;
trials = 0;

% データ関係
leverPressData = [];
leverActData = [];
leverData = [];
latencyData = [];
timeData = [];

% 初期化
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(leverCenter, 1);
putvalue(houseLight, 1);
putvalue(buzzer, 1);
putvalue(feeder, 1);
pause(1);

% メインプログラム
timeNow = clock;
timeStart = clock;
timeTrial = clock;
tic;

putvalue(leverRight, 0);
putvalue(houseLight, 0);

disp('START');

while (etime(clock,timeStart) <= timeMax)
    timeNow = clock;
    
    if (etime(clock,timeTrial) > 60)
        autoShapingCounter = autoShapingCounter + 1;
        timeNow = clock;
        timePast = toc;
        fprintf('\nAuto Shaping %d \n',autoShapingCounter);
        leverData(end+1) = 0;
        leverPressData(end+1) = autoShapingCounter;
        timeData(end+1) = timePast;
        putvalue(feeder, 0);
        pause(0.5);
        putvalue(feeder, 1);
        pause(0.5);
        timeTrial = clock;
    end
    
    if getvalue(leverRightAct) == 1
        leverRightCounter = leverRightCounter + 1;
        timeNow = clock;
        timePast = toc;
        leverPressData(end+1) = leverRightCounter;
        leverData(end+1) = 1;
        timeData(end+1) = timePast;
        fprintf('\n %d / %d \n',leverRightCounter,trialsMax);
        while getvalue(leverRightAct) == 1
            pause(0.01);
        end
        putvalue(feeder,0);
        pause(0.5);
        putvalue(feeder,1);
        pause(0.5);
        timeTrial = clock;
    end
    
    if (leverRightCounter + autoShapingCounter) >= trialsMax
        disp('最大試行数に達して終了');
        break
    end
    
    pause(0.01);
end

% 初期化
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(leverCenter, 1);
putvalue(houseLight, 1);
putvalue(buzzer, 1);
putvalue(feeder, 1);

dataMatrix = [leverPressData',leverData',timeData'];
filter = {'*.csv'};
[file,path] = uiputfile(filter);
fileDir = strcat(path,file);
csvwrite(fileDir,dataMatrix);

fprintf('\nレバー押し %d 回', leverRightCounter);
fprintf('\nAuto Shaping %d 回', autoShapingCounter);
fprintf('\n%7.2f 秒かかった',toc);