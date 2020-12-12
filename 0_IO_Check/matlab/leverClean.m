% leverClean


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

% 初期化
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(leverCenter, 1);
putvalue(houseLight, 1);
putvalue(buzzer, 1);
putvalue(feeder, 1);
pause(1);

a = 1;

putvalue(houseLight, 0);
putvalue(leverLeft, 0);
putvalue(leverRight, 0);

disp('掃除終わったら Space を押しください');
pause;

% 初期化
disp('終了');
putvalue(leverLeft, 1);
putvalue(leverRight, 1);
putvalue(leverCenter, 1);
putvalue(houseLight, 1);
putvalue(buzzer, 1);
putvalue(feeder, 1);
pause(1);

