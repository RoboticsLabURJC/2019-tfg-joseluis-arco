%Procesamiento de señales EMG adquiridas mediante OpenSignals
%José Luis Arco López

close all
clear all


data=dlmread('EMG_señaltomada.txt', '\t', 3, 0); %Leemos los datos del fichero


Muestras=data(:,1);
N=length(Muestras); %Número de muestras
EMG=data(:,3);

EMG= EMG/(10000); %Queremos la señal en milivoltios
fm = 4000; %Frecuencia de muestreo
tm=1/fm; %Periodo de muestreo 
tiempo=N*tm  %Tiempo en segundos que dura la señal
t=0:tm:tiempo-tm  %Duración de la señal, desde 0 hasta el tiempo total
f0=fm/N %Frecuencia por muestra

EMG = detrend(EMG) %Eliminamos el offset de la señal
EMGn=fft(EMG); %Hacemos la fft para obtener su espectro

figure 

subplot(2,1,1)
plot(t,EMG,'k') 
title('Señal EMG adquirida')
xlabel('Muestras'),ylabel('mV'),grid on
ylim([-1.2 1.2]) %limitamos entre -1.2 mv y 1.2mv
xlim([0 tiempo])

subplot(2,1,2)
plot(f0*(0:N-1),abs(EMGn),'g')
title('Espectro en frecuencia señal EMG adquirida')
xlabel('Frecuencia(Hz)'),ylabel('Energía'),grid on
xlim([0 2000])

%Filtro pasa-banda EMG: 4Hz a 500Hz
%(Las señales EMG tienen su información más importante entre 4 y 500Hz)

cb=4;
ca=499;
[b,a]=butter(4,[cb*2/fm ca*2/fm]) %Filtro butterworth paso banda
EMGf1=filter(b,a,EMG); %Señal con filtrado paso banda

figure

subplot(2,2,1)
plot(t,EMGf1,'k')
title('Señal EMG filtrada (4Hz a 500Hz)')
xlabel('Tiempo(s)'),ylabel('Magnitud(mV)'),grid on
xlim([0 tiempo])

EMGF1=fft(EMGf1); %%Hacemos la fft para obtener su espectro

subplot(2,2,2)
plot(f0*(0:N-1),abs(EMGF1),'g')
title('Espectro señal filtrada (4Hz a 500Hz)')
xlabel('Frecuencia(Hz)'),ylabel('Energía'),grid on
xlim([0 2000])

%Filtro rechazo-banda EMG:50 Hz 
%Eliminar frecuencia red electrica(50Hz España)

cb=47;
ca=53;
[b,a]=butter(3,[cb*2/fm ca*2/fm],'stop'); %Filtro butterworth rechazo-banda
EMGf2=filter(b,a,EMGf1);%Señal con filtrado rechazo banda

EMGF2=fft(EMGf2);

subplot(2,2,3)
plot(t,EMGf2,'k')
title('Señal EMG filtrada  (4 a 500Hz - 60Hz)')
xlabel('Tiempo(s)'),ylabel('Magnitud(mV)'),grid on
xlim([0 tiempo])

subplot(2,2,4)
plot(f0*(0:N-1),abs(EMGF2),'g')
title('Espectro en frecuencia Señal EMG filtrada (4 a 500Hz - 60Hz)')
xlabel('Frecuencia(Hz)'),ylabel('Magnitud'),grid on
xlim([20 300])

%Comparativa Señal original y filtrada

figure
subplot(2,1,1)
plot(t,EMG,'r')
hold on
plot(t,EMGf2,'k')
title('Comparativa Señal original y filtrada en el tiempo')
xlabel('Tiempo(s)'),ylabel('Magnitud(mV)'),grid on
xlim([0 tiempo])
legend('EMG original','EMG filtrada')

subplot(2,1,2)
plot(f0*(0:N-1),abs(EMGn),'r')
hold on
plot(f0*(0:N-1),abs(EMGF2),'k')
title('Comparativa Señal original y filtrada en frecuencia')
xlabel('Frecuencia(Hz)'),ylabel('Magnitud'),grid on
xlim([0 1000])


%Algoritmo para detectar la envolvente usando ventanas

L=250; %Duración de la ventana en milisegundos
SV=round(L/2); %tiempo en el que hay superposición de una ventana con otra
EMG=EMGf2;
Tms=tiempo*1000; %tiempo de la señal en milisegundos
W=floor(Tms/(L-SV)); %Numero de ventanas

%Tres técnicas para caracterizar las señales: 
%MAV(media del valor absoluto de la señal)
%RMS(valor efectivo de la señal)
%IAV(suma de los valores absolutos de la señal)
%la señal

EMGE_MAV(W) = 0;
EMGE_RMS(W) = 0;
EMGE_IAV(W) = 0;
Start=1;
End=L;
for i = 1:W
    EMGE_MAV(i) = mean(abs(EMG(Start:End)));
    EMGE_RMS(i) = rms(EMG(Start:End));
    EMGE_IAV(i) = sum(abs(EMG(Start:End)));
    Start=Start+SV;
    End=End+SV;
end
EMGE_MAV=EMGE_MAV/max(EMGE_MAV);
EMGE_RMS=EMGE_RMS/max(EMGE_RMS);
EMGE_IAV=EMGE_IAV/max(EMGE_IAV);

figure
T=linspace(0,tiempo,W);
plot(T,EMGE_MAV,'-g*')
hold on
plot(T,EMGE_RMS,'-mo')
plot(T,EMGE_IAV,'-k')
title('MAV vs RMS vs IAV')
xlabel('Tiempo(s)'),ylabel('Magnitud normalizada'),grid on
xlim([0 tiempo])
legend('MAV','RMS','IAV')

%Para discriminar usaremos por ejemplo la IAV:

EMGE=EMGE_IAV;

%Categorías:
% Categoría 1 (Contracción máximo esfuerzo).
% Categoría 2 (Contracción leve).
% Categoría 3 (Contracción muy leve).
% Categoría 4 (Relajación).

X(W)=0;
for i = 1:W
    if EMGE(i)==1
        categoria=1;
    elseif EMGE(i)>0.75
        categoria=2;
    elseif EMGE(i)<0.6
        categoria=3;
    else 
        categoria=4;
    end
    
    switch categoria
        case 1
            disp('Contracción de máximo esfuerzo')
        case 2
            disp('Contracción leve')
        case 3 
            disp('Contracción muy leve')
        case 4
            disp('Relajación')
        
    end
end
