% autoShapingRonly.m
% �E���o�[�݂̂�Auto Shaping
% Qukoyk
% 2020.10.07

clc;

% �萔�ݒ�
x = 1; % FR(x)
timeMax = 60*60; % �ő��������
trialsMax = 100; % �ő厎�s��
reinforcers = 1; % ������


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
leverLeftCounter = 0;
leverRightCounter = 0;
autoShapingCounter = 0;
trials = 0;

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

dataMatrix = [leverPressData',leverData',timeData'];
filter = {'*.csv'};
[file,path] = uiputfile(filter);
fileDir = strcat(path,file);
csvwrite(fileDir,dataMatrix);

fprintf('\n���o�[���� %d ��', leverRightCounter);
fprintf('\nAuto Shaping %d ��', autoShapingCounter);
fprintf('\n%7.2f �b��������',toc);