% =========================================================================
% 
%              Espectro de trem de pulso com e sem uma sen�ide
%
% =========================================================================

% Inicializa��o 
clc, close all, clear all

% .................  Parametriza��o do Sistema  ...........................

Rb = 10e6;      % Taxa de Transmiss�o no sistema(bps)
Tb = 1/Rb;      % Dura��o de 1 bit
M = 4;          % N�vel de Modula��o (Mapeamento para codifica��o digital)
m = log2(M);    % Bits por simbolo 
Rs = Rb/m;      % Taxa de Simbolos (sps ou baud)
Ts= 1/Rs;       % Dura��o de cada simbolo (s)
nsamp = 4;      % Fator de reamostragem
snr = 3;        % Rela��o sinal ru�do (dado em 3db / Dobro da potencia)
Ndata = 10e3;   % Numero de Amostras
F = 10e6;       % Frequencia do Seno (Hz) 


% .................  Calculos de variaveis inicias  .......................

t = linspace(0,Ts*(Ndata/m), Ndata*nsamp);  % Vetor de Tempo
ts = t(2)-t(1);                             % Periodo de amostragem 
Fa = 1/ts;                                  % Taxa de Amostragem

% .................  Transmiss�o  ......................................... 

% Gera��o dos dados aleat�rios
dataIn = randi([0 M-1], Ndata, 1);

% Convers�o de bits em pulsos
x_pulse = pammod(dataIn, M);

% Defini��o da sen�ide
sinal = sin(2*pi*F*t);

% Conforma��o de pulso (Pulse Shaping) - Super Amostragem (Upsampling)
x_rect = rectpulse(x_pulse, nsamp); % Filtro Retangular

% Sinal multiplicado com a sen�ide
x_up_sen = sinal' .* x_rect;

% Sinal normal
x_up = x_rect;


% ------------------------Gera��o do espectro -----------------------------

 [X_up_fft, x_tf, f, df] = Analisador_de_Espectro(x_up,ts);
 X_up = 10*log(fftshift(abs(X_up_fft)));
 
 [X_up_fft2, x_tf2, f2, df2] = Analisador_de_Espectro(x_up_sen,ts);
 X_sen = 10*log(fftshift(abs(X_up_fft2)));
  
  
%................ Plotagem dos espectros ..................................
  
  figure;
  subplot(2,1,1),
  plot(f, X_up); % Espectro da Sinal sem a sen�ide
  title('Espectro do Sinal puro')
  xlabel('Frequencia (Hz)'), ylabel('psd(dBV/Hz)')
  
  subplot(2,1,2),
  plot(f, X_sen,'red'); % Espectro da Sinal com a sen�ide
  title('Espectro do Sinal com Sen�ide')
  xlabel('Frequencia (Hz)'), ylabel('psd(dBV/Hz)')

