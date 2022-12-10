% Inicialização 
clc, close all, clear all
format shortEng

% Parametrização do sistema
M = 32; % Nivel de modulação
snr = 40; % Relalção sinal ruído

% .................  Transmissão  .........................................
tamanho_vetor = 10e5;
vector_bits_ale = randi([0 M-1],1,tamanho_vetor);


% .................  Modulações  ..........................................
x_pulse_pam(1, :) = pammod(vector_bits_ale, M);
x_pulse_qam(1, :) = qammod(vector_bits_ale, M);
x_pulse_psk(1, :) = pskmod(vector_bits_ale, M);


% ................. Ruído .................................................

x_pulse_pam_noise = awgn(x_pulse_pam, snr, 'measured');
x_pulse_qam_noise = awgn(x_pulse_qam, snr, 'measured');
x_pulse_psk_noise = awgn(x_pulse_psk, snr, 'measured');


% .................  Plotagens  ...........................................
scatterplot(x_pulse_pam_noise(1, :))
title(['Mapa de constelcao do PAMmod com M: ' num2str(M)]);

    
scatterplot(x_pulse_qam_noise(1, :))
title(['Mapa de constelcao do QAMmod com M: ' num2str(M)]);

    
scatterplot(x_pulse_psk_noise(1, :))
title(['Mapa de constelcao do PSKmod com M: ' num2str(M)]);
  