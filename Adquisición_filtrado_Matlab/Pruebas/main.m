clear all; clc; close all; 

load data.mat;
EMG1=x1(1001:6000);
y=EMG1;
d=dalt;
t=thalt;
a=alpha;
b=belta;
fs=256;
nfft=1024;
noverlap = 750;

[cxy1,f1]=mscohere(d,y,boxcar(nfft),noverlap,nfft,fs);
[cxy2,f2]=mscohere(t,y,boxcar(nfft),noverlap,nfft,fs);
[cxy3,f3]=mscohere(a,y,boxcar(nfft),noverlap,nfft,fs);
[cxy4,f4]=mscohere(b,y,boxcar(nfft),noverlap,nfft,fs);

figure(1);

subplot(221);plot(f1,cxy1);xlabel('f/Hz');ylabel('dalt');axis([1 4 0 1]);
subplot(222);plot(f2,cxy2);xlabel('f/Hz');ylabel('thalt');axis([4 8 0 1]);
subplot(223);plot(f3,cxy3);xlabel('f/Hz');ylabel('alpha');axis([8 13 0 1]);
subplot(224);plot(f4,cxy4);xlabel('f/Hz');ylabel('belta');axis([13 30 0 1]);
