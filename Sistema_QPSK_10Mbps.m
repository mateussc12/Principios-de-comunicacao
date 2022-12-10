% =========================================================================
% 
%                          Sistema QPSK 10 Mbps 
%
% =========================================================================

% Inicializa��o 
clc, close all, clear all


% .................  Parametriza��o do Sistema  ...........................
Rb = 10e6; % Taxa de Transmiss�o no sistema(bps)
Tb = 1/Rb; % Dura��o de 1 bit
M = 4; % N�vel de Modula��o (Mapeamento para codifica��o digital)
m = log2(M); % Bits por simbolo 
Rs = Rb/m; % Taxa de Simbolos (sps ou baud)
Ts= 1/Rs; % Dura��o de cada simbolo (s)
nsamp = 4; % Fator de reamostragem
snr = 3; % Rela��o sinal ru�do (dado em 3db / Dobro da potencia)
Ndata = 10e4;

% .................  Calculos de variaveis inicias  .......................
t = linspace(0,Ts*(Ndata/m), Ndata*nsamp);
ts = t(2)-t(1);  % Periodo de amostragem 

% .................  Transmiss�o  ......................................... 

% Gera��o dos dados aleat�rios
dataIn = randi([0 M-1], Ndata, 1);

% Convers�o de bits em pulsos
x_pulse = pskmod(dataIn, M);

% Conforma��o de pulso (Pulse Shaping) - Super Amostragem (Upsampling)
x_up = rectpulse(x_pulse, nsamp); % Filtro Retangular

% -----------------  Canal  -----------------------------------------------
% Adicionando Ru�do
x_up_noise = awgn(x_up, snr,'measured');

% ------------------------Gera��o do espectro -----------------------------

 [X_up_fft, x_tf, f, df] = Analisador_de_Espectro(real(x_up),ts);
 X_real = 10*log(fftshift(abs(X_up_fft)));
 
 [X_up_fft2, x_tf2, f2, df2] = Analisador_de_Espectro(imag(x_up),ts);
 X_imag = 10*log(fftshift(abs(X_up_fft2)));
  
  
% % ................. Recep��o ............................................
% 
%................ Plotagem dos sinais.....................................
  title_scatter = sprintf('Diagrama de Constela��o - QPSK com M = %d',M);
  scatterplot(x_pulse) ,title(title_scatter);  % Diagrama de constela��o
  
  
  figure;
  subplot(2,1,1),
    plot(t,real(x_up))  % sinal no dominio do tempo em fun��o da taxa
    title('Sinal no dominio do tempo (Parte Real)')
    xlabel('Tempo(s)'), ylabel('Amplitude(u.a.)')
    ylim([-1.5 1.5]), xlim([0 10e-6]);
  
  subplot(2,1,2),
    plot(t,imag(x_up),'red') % sinal no dominio do tempo fun��o taxa transmiss�o
    title('Sinal no dominio do tempo (Parte Imaginaria)')
    xlabel('Tempo(s)'), ylabel('Amplitude(u.a.)')
    ylim([-1.5 1.5]), xlim([0 10e-6]);
  
    
  figure;
  subplot(2,1,1),
    plot(f(end/2:end), X_real(end/2:end)); % Espectro da parte real do Sinal
    title('Espectro do Sinal - Parte Real')
    xlabel('Frequencia (Hz)'), ylabel('psd (dBV/Hz)')
  
  subplot(2,1,2),
    plot(f2(end/2:end), X_imag(end/2:end),'red'); % Espectro da parte imaginaria do Sinal
    title('Espectro do Sinal - Parte Imaginaria')
    xlabel('Frequencia (Hz)'), ylabel('psd (dBV/Hz)')
