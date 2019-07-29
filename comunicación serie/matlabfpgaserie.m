%https://forum.arduino.cc/index.php?topic=258909.msg1828784#msg1828784

close all;
clear all;
clc;
com='COM7';

%Inicializo el puerto serie

delete(instrfind({'Port'},{com}));
puerto_serie=serial(com);
puerto_serie.BaudRate=115200;
warning('off','MATLAB:serial:fscanf:unsuccessfulRead');

%Abro el puerto serie

fopen(puerto_serie);
pause(0.2);
dato=[1];
dato2=[2];
dato3=[255]
numerobinario = dec2bin(dato)

%unicodestr 0 230 50= native2unicode(i); % Convierte el entreo i (0 a 255) a codigo ASCII

fwrite(puerto_serie,dato,'uint8');     % se envia un dato de tipo entero sin signo de 8 bits,
pause(1);
fwrite(puerto_serie,dato2,'uint8'); 
pause(1)
fwrite(puerto_serie,dato3,'uint8'); 



% pause(2);

%Cerramos el puerto serie

fclose(puerto_serie);
delete(puerto_serie)
clear puerto_serial
disp('STOP')