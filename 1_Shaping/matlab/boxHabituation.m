% Box Habituation

clc;

a = digitalio('mwadlink', 0); 
 
%Opens DIO functionality of device #0 (PCI-7432); 
%object name =  dio_device;
%Display Summary of DigitalIO (DIO) Object Using 'PCI/cPCI-7432:0'.

%         Port Parameters:  Port 0 is port configurable for reading.
%                           Port 1 is port configurable for writing.

addline(a, 0:15, 0, 'in');     %addline(a, 0:7, 0, 'out')が
                               %putvalue(a.Line(1), value) 〜 putvalue(a.Line(8), value)に対応
                               %addline(a, 8:15, 0, 'out')が
                               %putvalue(a.Line(9), value) 〜 putvalue(a.Line(16), value)に対応  
                               
addline(a, 16:31, 1, 'out');   %addline(a, 16:23, 1, 'out')が
                               %putvalue(a.Line(17), value) 〜 putvalue(a.Line(24), value)に対応
                               %DIN-100S-01の38 〜 45に対応(46[VDD3]を50 or 100と接続)
                               %addline(a, 24:31, 1, 'out')が
                               %putvalue(a.Line(25), value) 〜 putvalue(a.Line(32), value)に対応
                               %DIN-100S-01の88 〜 95に対応(96[VDD4]を50 or 100と接続)   

leverLeftAct = getvalue(a.Line(9));
leverRightAct = getvalue(a.Line(10));

leverLeft = a.Line(18);
leverRight = a.Line(17);
houseLight = a.Line(20);
feeder = a.Line(21);
buzzer = a.Line(22);
leverCenter = a.Line(23);

% 初期化
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(leverCenter, 1);
putvalue(houseLight, 1);
putvalue(buzzer, 1);
putvalue(feeder, 1);

pause(1);

timeMax = 20*60;
tic;
disp('box habituation START');
while toc < timeMax
    putvalue(houseLight, 0);
    pause(1);
end
disp('box habituation OVER');
% 消灯
putvalue(houseLight,1);