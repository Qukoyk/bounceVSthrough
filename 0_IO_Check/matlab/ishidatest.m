a = digitalio('mwadlink', 0); 
 
%Opens DIO functionality of device #0 (PCI-7432); 
%object name =  dio_device;
%Display Summary of DigitalIO (DIO) Object Using 'PCI/cPCI-7432:0'.

%         Port Parameters:  Port 0 is port configurable for reading.
%                           Port 1 is port configurable for writing.

addline(a, 0:15, 0, 'in');     %addline(a, 0:7, 0, 'out')‚ª
                               %putvalue(a.Line(1), value) ` putvalue(a.Line(8), value)‚É‘Î‰
                               %addline(a, 8:15, 0, 'out')‚ª
                               %putvalue(a.Line(9), value) ` putvalue(a.Line(16), value)‚É‘Î‰  
                               
addline(a, 16:31, 1, 'out');   %addline(a, 16:23, 1, 'out')‚ª
                               %putvalue(a.Line(17), value) ` putvalue(a.Line(24), value)‚É‘Î‰
                               %DIN-100S-01‚Ì38 ` 45‚É‘Î‰(46[VDD3]‚ğ50 or 100‚ÆÚ‘±)
                               %addline(a, 24:31, 1, 'out')‚ª
                               %putvalue(a.Line(25), value) ` putvalue(a.Line(32), value)‚É‘Î‰
                               %DIN-100S-01‚Ì88 ` 95‚É‘Î‰(96[VDD4]‚ğ50 or 100‚ÆÚ‘±)   

leverLeftAct = a.Line(9);
leverRightAct = a.Line(10);

leverLeft = a.Line(18);
leverRight = a.Line(17);
houseLight = a.Line(20);
feeder = a.Line(21);
buzzer = a.Line(22);
leverCenter = a.Line(23);

putvalue(houseLight,0);
pause(1);
putvalue(houseLight,1);
