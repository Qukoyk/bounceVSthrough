% IO F**K
% ����IO Check�����������̂œ{�������炱��IO F**K�������

clc;

a = digitalio('mwadlink', 0); 
 
%Opens DIO functionality of device #0 (PCI-7432); 
%object name =  dio_device;
%Display Summary of DigitalIO (DIO) Object Using 'PCI/cPCI-7432:0'.

%         Port Parameters:  Port 0 is port configurable for reading.
%                           Port 1 is port configurable for writing.

addline(a, 0:15, 0, 'in');     %addline(a, 0:7, 0, 'out')��
                               %putvalue(a.Line(1), value) �` putvalue(a.Line(8), value)�ɑΉ�
                               %addline(a, 8:15, 0, 'out')��
                               %putvalue(a.Line(9), value) �` putvalue(a.Line(16), value)�ɑΉ�  
                               
addline(a, 16:31, 1, 'out');   %addline(a, 16:23, 1, 'out')��
                               %putvalue(a.Line(17), value) �` putvalue(a.Line(24), value)�ɑΉ�
                               %DIN-100S-01��38 �` 45�ɑΉ�(46[VDD3]��50 or 100�Ɛڑ�)
                               %addline(a, 24:31, 1, 'out')��
                               %putvalue(a.Line(25), value) �` putvalue(a.Line(32), value)�ɑΉ�
                               %DIN-100S-01��88 �` 95�ɑΉ�(96[VDD4]��50 or 100�Ɛڑ�)   

leverLeftAct = a.Line(9);
leverRightAct = a.Line(10);

leverLeft = a.Line(18);
leverRight = a.Line(17);
houseLight = a.Line(20);
feeder = a.Line(21);
buzzer = a.Line(22);
leverCenter = a.Line(23);

leverLeftCounter = 0;
leverRightCounter = 0;
leftAction = 0;
rightAction = 0;
x = 3;

% ������
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(leverCenter, 1);
putvalue(houseLight, 1);
putvalue(buzzer, 1);
putvalue(feeder, 1);

pause(1);

% �n���I
putvalue(houseLight, 0);
putvalue(leverLeft, 0);
putvalue(leverRight, 0);
disp('�e�X�g�J�n');

while (leverLeftCounter < x || leverRightCounter < x)
    
    % �����o�[����
    if getvalue(leverLeftAct) == 1
        leftAction = 1;
        leverLeftCounter = leverLeftCounter + 1;
        fprintf('\n�����o�[ %d / %d\n', leverLeftCounter, x);
        while getvalue(leverLeftAct) == 1
            pause(0.01);
        end
    end
    
    % �E���o�[����
    if getvalue(leverRightAct) == 1
        rightAction = 1;
        leverRightCounter = leverRightCounter + 1;
        fprintf('\n�E���o�[ %d / %d\n', leverRightCounter, x);
        while getvalue(leverRightAct) == 1
            pause(0.01);
        end
    end
    
    if leverLeftCounter >= x
        putvalue(leverLeft, 1);
    end
    if leverRightCounter >= x
        putvalue(leverRight, 1);
    end
    
    pause(0.01)
end

disp('�e�X�g�I��');
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(leverCenter, 1);
putvalue(houseLight, 1);
putvalue(buzzer, 1);
putvalue(feeder, 1);

