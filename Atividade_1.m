t = linspace(0, 1e-6, 1000); % vetor tempo

pa = t(2) - t(1); % periodo de amostragem

fa = 1/pa; % taxa de amostragem

freq = 1.\t; % vetor frequência

fc = fa/30; % fc 10 vezes menor que a taxa de amostragem(seguindo o teorema de Nyquist)

onda = 10 * cos(2 * pi * fc * t) + 5 * cos(2 * pi * (2*fc) * t); % Onda
potencia_onda = (sum(abs(onda))^2) / length(onda); % Sinal de energia
potencia_onda_dbm = 10 * log(potencia_onda / 1e-3); % dBm

[Sinal_ff_onda,sinal_tf,f_onda,df] = FFT_pot2(onda, pa); % faz a FFT da onda usando a função previamente disponibilizada

fft_onda = fftshift(abs(Sinal_ff_onda)); % Shiftando e tirando o módulo

figure()
% usando subsplot para plotar os dois gráficos na mesma imagem
subplot(2, 1, 1) 
plot(t, onda); % Plota a onda
title("Análise espectral da onda")
xlabel("Tempo (s)")

subplot(2, 1, 2) 
plot(f_onda(end/2:end), fft_onda(end/2:end)); % Plota a parte positiva da FFT da onda
title("FFT")
xlabel("Frequencia (Hz)")



% Pulso quadrado

pulso = zeros(size(t)); % cria um vetor de zeros do tamanho do vetor "t"
pulso((end/2) - (end/8):(end/2)+(end/8)) = ones(size(pulso((end/2) - (end/8):(end/2)+(end/8)))); % troca o valor de zero para um em uma parte do vetor

[Sinal_ff_pulso,sinal_tf,f_pulso,df] = FFT_pot2(pulso, pa); % faz a FFT do pulso quadrado usando a função previamente disponibilizada

fft_pulso = fftshift(abs(Sinal_ff_pulso)); % Shitando e tirando o módulo

figure()
% usando subsplot para plotar os dois gráficos na mesma imagem
subplot(2, 1, 1)
plot(t, pulso) % plota o pulso quadrado
title("Análise espectral do pulso quadrado")
xlabel("Tempo (s)")

subplot(2, 1, 2)
plot(f_pulso(end/2:end), fft_pulso(end/2:end)); % plota a FFT do pulso quadrado
 
title("FFT")
xlabel("Frequencia (Hz)")
