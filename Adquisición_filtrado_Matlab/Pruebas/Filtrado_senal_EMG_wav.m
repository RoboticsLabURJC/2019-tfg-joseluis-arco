%Filtado de señal EMG y procesamiento
%https://es.mathworks.com/matlabcentral/fileexchange/68245-digital-processing-of-electromyographic-signals-for-control?focused=8007e7ee-29d3-419f-a58a-8dc7b6f9d933&tab=example

close all
clear all

[EMG,fm]=audioread('EMG_1.wav') %Extrae la información del fichero y lo guarda en una matriz EMG, además de la frecuencia de muestreo de la señal
%EMG = load('emg_myopathy.txt');
%fidi = fopen('emg.txt', 'rt');
%T_EMG = textscan(fidi, '%f%f');
%fclose(fidi);
%t = T_EMG{1};
%EMG = T_EMG{2};
%L = length(t);
%Ts = mean(diff(t));                                 % Sampling Time
%fm = 1/Ts                                      % Sampling Frequency
  
%fm=11025

EMGn=fft(EMG); %Dominio de la frecuencia

%Procesamiento digital señal adquirida
%Discriminación de sus características intrínsecas

tm=1/fm %Periodo de muestreo
EMGk=EMG(:,1)' %Cada columna de la matriz EMG es una señal, elegimos la primera
               %Convierte la columna de la matriz en un vector
N=length(EMGk) %Numero de muestras
time=N*tm     
t=0:tm:time-tm  %Duración de la señal, desde 0 hasta el tiempo total
f0=fm/N %Frecuencia por muestra

figure 
subplot(2,2,1)
plot(t,EMG(:,1),'k') %Cada columna de la matriz EMG es una señal, elegimos la primera
title('Señal EMG adquirida')
xlabel('Muestras'),ylabel('Magnitud'),grid on

subplot(2,2,2)
plot(f0*(0:N-1),abs(EMGn),'g')
title('Espectro en frecuencia señal EMG adquirida')
xlabel('Frecuencia(Hz)'),ylabel('Energía'),grid on
xlim([0 fm/2])


subplot(2,2,3)
plot(t,EMGk,'k')
title('Señal EMG original')
xlabel('Tiempo(s)'),ylabel('Magnitud(mV)'),grid on
ylim([-1.2 1.2]) %limitamos entre -1.2 mv y 1.2mv
xlim([0 time])

EMGF=fft(EMGk); %Dominio de la frecuencia

subplot(2,2,4)
plot(f0*(0:N-1),abs(EMGF),'g')
title('Espectro en frecuencia señal EMG original')
xlabel('Frecuencia(Hz)'),ylabel('Energía'),grid on
xlim([0 fm/2])

%Eliminar offset

EMGR=detrend(EMGk); %Elimina una tendencia de los datos
figure

subplot(3,2,1)
plot(t,EMGR,'k')
title('Señal EMG original')
xlabel('Tiempo(s)'),ylabel('Magnitud(mV)'),grid on
ylim([-1.2 1.2]) %limitamos entre -1.2 mv y 1.2mv
xlim([0 time])

subplot(3,2,2)
plot(t,EMGR,'k')
title('Señal original sin offset')
xlabel('Tiempo(s)'),ylabel('Magnitud(mV)'),grid on
ylim([-1.2 1.2])
xlim([0 time])

%Filtro pasa-banda EMG: 4Hz a 500Hz
%Las señales EMG tienen su información más importante entre 4 y 500Hz

cb=4;
ca=500;
[b,a]=butter(4,[cb*2/fm ca*2/fm]) %Filtro butterworth 
EMGf1=filter(b,a,EMGR); %Señal con filtrado paso banda

subplot(3,2,3)
plot(t,EMGf1,'k')
title('Señal EMG filtrada (4Hz a 500Hz)')
xlabel('Tiempo(s)'),ylabel('Magnitud(mV)'),grid on
xlim([0 time])

EMGF1=fft(EMGf1); %Dominio de la frecuencia

subplot(3,2,4)
plot(f0*(0:N-1),abs(EMGF1),'g')
title('Espectro señal filtrada (4Hz a 500Hz)')
xlabel('Frecuencia(Hz)'),ylabel('Energía'),grid on
xlim([0 1500])

%Filtro rechazo-banda EMG:50 Hz 
%Eliminar frecuencia red electrica(50Hz España)

cb=47;
ca=53;
[b,a]=butter(3,[cb*2/fm ca*2/fm],'stop'); %Filtro butterworth 
EMGf2=filter(b,a,EMGf1);%Señal con filtrado rechazo banda

EMGF2=fft(EMGf2);

subplot(3,2,5)
plot(t,EMGf2,'k')
title('Señal EMG filtrada  (4 a 500Hz - 60Hz)')
xlabel('Tiempo(s)'),ylabel('Magnitud(mV)'),grid on
xlim([0 time])

subplot(3,2,6)
plot(f0*(0:N-1),abs(EMGF2),'g')
title('Espectro en frecuencia Señal EMG filtrada (4 a 500Hz - 60Hz)')
xlabel('Frecuencia(Hz)'),ylabel('Magnitud'),grid on
xlim([20 300])

%Comparativa Señal original y filtrada

figure
subplot(1,2,1)
plot(t,EMGR,'r')
hold on
plot(t,EMGf2,'k')
title('Comparativa Señal original y filtrada en el tiempo')
xlabel('Tiempo(s)'),ylabel('Magnitud(mV)'),grid on
xlim([0 time])
legend('EMG original','EMG filtrada')

subplot(1,2,2)
plot(f0*(0:N-1),abs(EMGF),'r')
hold on
plot(f0*(0:N-1),abs(EMGF2),'k')
title('Comparativa Señal original y filtrada en frecuencia')
xlabel('Frecuencia(Hz)'),ylabel('Magnitud'),grid on
xlim([0 1000])

%Algoritmo para detectar la envolvente usando ventanas

L=250; %Duración de la ventana en milisegundos
SV=round(L/2); %tiempo en el que hay superposición de una ventana con otra
EMG=EMGf2;
Tms=time*1000; %tiempo de la señal en milisegundos
W=floor(Tms/(L-SV)); %Numero de ventanas

%Usamos IAV(Suma de los valores absolutos)para caracterizar
%la señal

EMGE_IAV(W) = 0;
Start=1;
End=L;

for i = 1:W
    EMGE_IAV(i) = sum(abs(EMG(Start:End)));
    Start=Start+SV;
    End=End+SV;
end
EMGE_IAV=EMGE_IAV/max(EMGE_IAV); %Para normalizar

figure
T=linspace(0,time,W);
hold on
plot(T,EMGE_IAV,'-mo')
title('IAV')
xlabel('Tiempo(s)'),ylabel('Magnitud normalizada'),grid on
xlim([0 time])

EMGE=EMGE_IAV;

%Categoríes:
%For a magnitude equal to 1 is labeled: Category 1 (contraction of maximum effort).
%For a magnitude greater than 0.75 it is labeled: Category 2 (contraction with the intention of lifting an object).
%For a magnitude higher than 0.6 it is labeled: Category 3 (contraction of slight movement, the muscle contracts with little force).
%For a magnitude less than 0.6 is labeled: Category 4 (relaxation or absence of muscle contraction).

X(W)=0;
for i = 1:W
    if EMGE(i)>0.5
        category=1;
    else
        category=2;
    end
    
    switch category
        case 1
            disp('Contracción muscular')
        case 2
            disp('Relajación muscular')
        
    end
end