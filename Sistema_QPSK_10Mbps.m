% =========================================================================
% 
%                          Sistema QPSK 10 Mbps 
%
% =========================================================================

% Inicialização 
clc, close all, clear all


% .................  Parametrização do Sistema  ...........................
Rb = 10e6; % Taxa de Transmissão no sistema(bps)
Tb = 1/Rb; % Duração de 1 bit
M = 4; % Nível de Modulação (Mapeamento para codificação digital)
m = log2(M); % Bits por simbolo 
Rs = Rb/m; % Taxa de Simbolos (sps ou baud)
Ts= 1/Rs; % Duração de cada simbolo (s)
nsamp = 4; % Fator de reamostragem
snr = 3; % Relação sinal ruído (dado em 3db / Dobro da potencia)
Ndata = 10e4;

% .................  Calculos de variaveis inicias  .......................
t = linspace(0,Ts*(Ndata/m), Ndata*nsamp);
ts = t(2)-t(1);  % Periodo de amostragem 

% .................  Transmissão  ......................................... 

% Geração dos dados aleatórios
dataIn = randi([0 M-1], Ndata, 1);

% Conversão de bits em pulsos
x_pulse = pskmod(dataIn, M);

% Conformação de pulso (Pulse Shaping) - Super Amostragem (Upsampling)
x_up = rectpulse(x_pulse, nsamp); % Filtro Retangular

% -----------------  Canal  -----------------------------------------------
% Adicionando Ruído
x_up_noise = awgn(x_up, snr,'measured');

% ------------------------Geração do espectro -----------------------------

 [X_up_fft, x_tf, f, df] = Analisador_de_Espectro(real(x_up),ts);
 X_real = 10*log(fftshift(abs(X_up_fft)));
 
 [X_up_fft2, x_tf2, f2, df2] = Analisador_de_Espectro(imag(x_up),ts);
 X_imag = 10*log(fftshift(abs(X_up_fft2)));
  
  
% % ................. Recepção ............................................
% 
%................ Plotagem dos sinais.....................................
  title_scatter = sprintf('Diagrama de Constelação - QPSK com M = %d',M);
  scatterplot(x_pulse) ,title(title_scatter);  % Diagrama de constelação
  
  
  figure;
  subplot(2,1,1),
    plot(t,real(x_up))  % sinal no dominio do tempo em função da taxa
    title('Sinal no dominio do tempo (Parte Real)')
    xlabel('Tempo(s)'), ylabel('Amplitude(u.a.)')
    ylim([-1.5 1.5]), xlim([0 10e-6]);
  
  subplot(2,1,2),
    plot(t,imag(x_up),'red') % sinal no dominio do tempo função taxa transmissão
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
