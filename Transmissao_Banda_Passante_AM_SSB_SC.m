% =========================================================================
% 
%                      TRANSMISSAO BANDA PASSANTE AM-SSB/SC
%
% =========================================================================

% Inicialização 
clc, close all, clear all

% .................  Parametrização do Sistema  ...........................
snr = 30;% Relação sinal ruído

% -------------------------------  TRANSMISSOR  ---------------------------

% Conversão do áudio em decimal e obtendo sua Taxa de amostragem
[sound_dec, Fs] = audioread('Teste123.m4a');
x = sound_dec;

ta = 1/Fs; % Periodo de Amostragem
t = 0:ta:(length(x) * ta - ta); % Vetor tempo

% FFT
[X_fft, x_tf, f, df] = Analisador_de_Espectro(x,ta);
% Pegando o indice em que ocorre a máxima frequencia
[M, I] = max(X_fft);

f_x_max = abs(f(I)); %Máxima frequencia do sinal modulante
Fc = 10 * f_x_max; %Frequencia da Portadora
Fs_bp = 30 * Fs; %Taxa de amostragem em banda passante
Ta_bp = 1/Fs_bp; %Periodo de amostragem em banda passante

fase_ini = 0; % Fase inicial da portadora

% Modulucao da portadora (em AM)
y = ssbmod(x,Fc,Fs_bp,fase_ini);

% ------------------------  CANAL DE COMUNICACAO --------------------------

% Adicionando Ruído AWGN
y_ruidoso = awgn(y,snr,'measured');

% -------------------------------  RECEPTOR  ------------------------------

% Demodulacao
z = ssbdemod(y_ruidoso,Fc,Fs_bp,0);


% Analise dos Espectros dos sinais
%[X_fft, x_tf, f, df] = Analisador_de_Espectro(x,ta);
X = 10*log10(fftshift(abs(X_fft)));

[Y_fft, y_tf, f_bp, df2] = Analisador_de_Espectro(y,Ta_bp);
Y = 10*log10(fftshift(abs(Y_fft)));

[Yrui_fft, yrui_tf, f_bp, df4] = Analisador_de_Espectro(y_ruidoso,Ta_bp);
Y_ruidoso = 10*log10(fftshift(abs(Yrui_fft)));

[Z_fft, z_tf, f, df3] = Analisador_de_Espectro(z,ta);
Z = 10*log10(fftshift(abs(Z_fft)));

% Calculo do BER
x_bin_matriz = dec2bin(typecast(int8(x),'uint8'));
z_bin_matriz = dec2bin(typecast(int8(z),'uint8'));
x_bin_vec = reshape(x_bin_matriz, [length(x_bin_matriz(:,1)) * length(x_bin_matriz(1, :)), 1]);
z_bin_vec = reshape(z_bin_matriz, [length(z_bin_matriz(:,1)) * length(z_bin_matriz(1, :)), 1]);
[~, BER] = biterr(real(x_bin_vec), real(z_bin_vec));
BER

% Áudio retornado
sound(z, Fs);


% -----------------------------  PLOTAGENS --------------------------------

% Plota o sinal Modulador
figure(1), subplot(211), plot(t,x)
title('Sinal Modulador')
xlabel('Tempo (seg)')

subplot(212), plot(f, X)
%ax = axis; axis([0 Fs/2 ax(3) ax(4)]); % Plota metade da taxa de amostragem
title('Espectro do sinal Modulador')
xlabel('Frequencia (Hz)')


% Plota o sinal Modulado
figure(2), subplot(211), plot(t,y)
hold all, plot(t,y_ruidoso)
title('Sinal Modulado')
legend('Sinal Modulado','Sinal na saida do canal')
xlabel('Tempo (seg)')

subplot(212), plot(f_bp, Y)
hold all, plot(f,Y_ruidoso)
%ax = axis; axis([0 Fs/2 ax(3) ax(4)]); % Plota metade da taxa de amostragem
title('Espectro de sinais Modulados')
legend('Espectro do sinal Modulado','Espectro do sinal na saida do canal')
xlabel('Frequencia (Hz)')


% Plota o sinal Modulado
figure(3), subplot(211), plot(t,z)
title('Sinal Demodulado')
xlabel('Tempo (seg)')

subplot(212), plot(f,Z)
%ax = axis; axis([0 Fs/2 ax(3) ax(4)]); % Plota metade da taxa de amostragem
title('Espectro do sinal Demodulado')
xlabel('Frequencia (Hz)')
