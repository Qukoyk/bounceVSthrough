% trainingL10R10Mono.m
% ���o�[�����g���[�j���O�@�`���E�E�P�O���s������ւP���o�[��
% Qukoyk
% 2020.10.07

clc;

% �萔�ݒ�
x = 3; % FR(x)
timeMax = 60*60; % �ő��������
trialsMax = 100; % �ő厎�s��
reinforcers = 1; % ������
sideThreshold = 10; % �Е��ő�10��A��
leverLeftMax = 50;
leverRightMax = 50;


% �|�[�g�ݒ�
a = digitalio('mwadlink', 0);
addline(a, 0:15, 0, 'in');
addline(a, 16:31, 1, 'out');
% ���͐ݒ�
leverLeftAct = a.Line(9);
leverRightAct = a.Line(10);
% �o�͐ݒ�
leverLeft = a.Line(18);
leverRight = a.Line(17);
houseLight = a.Line(20);
feeder = a.Line(21);
buzzer = a.Line(22);
leverCenter = a.Line(23);


% �ϐ��ݒ�
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

% putvalue(leverLeft, 0);
putvalue(leverRight, 0);
putvalue(houseLight, 0);

disp('START');

while (etime(clock,timeStart) <= timeMax)
    timeNow = clock;

    while reactions ~= x
        timeNow = clock;

        if etime(clock,timeStart) > timeMax
            disp('�ő厞�ԂɒB���ďI��');
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