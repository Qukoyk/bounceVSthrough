% trainingL10R10Mono.m
% レバー押しトレーニング　～左・右１０試行ずっつ交替１レバー版
% Qukoyk
% 2020.10.07

clc;

% 定数設定
x = 3; % FR(x)
timeMax = 60*60; % 最大実験時間
trialsMax = 100; % 最大試行数
reinforcers = 1; % 強化量
sideThreshold = 10; % 片方最大10回連続
leverLeftMax = 50;
leverRightMax = 50;


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
trials = 0;
leverLeftTrials = 0;
leverRightTrials = 0;

leverPressCounter = 0;

reactions = 0;
reactionsLeft = 0;
reactionsRight = 0;

sideLeft = 0;
sideRight = 0;

leftRight = 0;

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

% putvalue(leverLeft, 0);
putvalue(leverRight, 0);
putvalue(houseLight, 0);

disp('START');

while (etime(clock,timeStart) <= timeMax)
    timeNow = clock;

    while reactions ~= x
        timeNow = clock;

        if etime(clock,timeStart) > timeMax
            disp('最大時間に達して終了');
            break
        end

        if sideLeft >= sideThreshold
            putvalue(leverLeft, 1);
            putvalue(leverRight, 0);
        end
        if sideRight >= sideThreshold
            putvalue(leverLeft, 0);
            putvalue(leverRight, 1);
        end

        if reactionsLeft == x || reactionsRight == x
            reactions = x;
            reactionsLeft = 0;
            reactionsRight = 0;
        end

        if getvalue(leverLeftAct) == 1
            trials = trials + 1;
            leverPressCounter = leverPressCounter + 1;
            reactionsLeft = reactionsLeft + 1;
            timeNow = clock;
            timePast = toc;
            leverPressData(end+1) = leverPressCounter;
            leftRight = 1;
            leverData(end+1) = leftRight;
            timeData(end+1) = timePast;
            fprintf('\n反応 %d', leverPressCounter);
            fprintf('\n %d / %d \n',reactionsLeft,x);
            while getvalue(leverLeftAct) == 1
                pause(0.01);
            end
        end
        if getvalue(leverRightAct) == 1
            trials = trials + 1;
            leverPressCounter = leverPressCounter + 1;
            reactionsRight = reactionsRight + 1;
            timeNow = clock;
            timePast = toc;
            leverPressData(end+1) = leverPressCounter;
            leftRight = 2;
            leverData(end+ 1) = leftRight;
            timeData(end+1) = timePast;
            fprintf('\n反応 %d', reactionsRight);
            fprintf('\n %d / %d \n',reactionsRight,x);
            while getvalue(leverRightAct) == 1
                pause(0.01);
            end
        end

        pause(0.01);
    end
    
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
        fprintf('\n左レバー試行 %d', leverLeftTrials);
        fprintf('\n反応時間 %7.2f\n', timePast);
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
        fprintf('\n右レバー試行 %d', leverRightTrials);
        fprintf('\n反応時間 %7.2f\n', timePast);
        putvalue(feeder, 0);
        pause(0.5);
        putvalue(feeder, 1);
        pause(0.5);
    end

    if (leverLeftTrials + leverRightTrials) >= trialsMax
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

dataMatrix = [leverPressData',leverData',leverActData',timeData'];
filter = {'*.csv'};
[file,path] = uiputfile(filter);
fileDir = strcat(path,file);
csvwrite(fileDir,dataMatrix);

fprintf('\n左レバー %d 回', leverLeftTrials);
fprintf('\n右レバー %d 回', leverRightTrials);
fprintf('\n%7.2f 秒かかった',toc);