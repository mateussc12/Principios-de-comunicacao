% Inicializa��o 
clc, close all, clear all
format shortEng

% Parametriza��o do sistema
M = 16; % Nivel de modula��o
nsamp = 4; % Fator de reamostragem
snr_max = 15; % Rela��o sinal ru�do (em dB)
snr_escolhido = 3; % SNR espec�fico a ser escolhido para printar a imagem
Rb = 10e6; % Taxa de Transmiss�o no sistema(bps)
Tb = 1/Rb; % Dura��o de 1 bit
m = log2(M); % Bits por simbolo 
Rs = Rb/m; % Taxa de Simbolos (sps ou baud)
Ts= 1/Rs; % Dura��o de cada simbolo (s)

% .................  Transmiss�o  ......................................... 
%{
Leitura da imagem - transforma a imagem em uma matriz 240x480x3 com os
valores na escala RGB de cada pixel.
%}  
img = imread('rover.jpg');

%{
Converte a matriz com os valores RGB de cada pixel em bytes
(matriz 345600x8 de bits) 
%}
img_bin = de2bi(img);

% Converte a matriz de bytes em um vetor ("juntou" as linhas da matrix)
% Modula��o QAM para M = 16
% Para que a modolu��o funcione a deve-se inverter a ordem da matrix, pela
% forma que a fun��o qammod foi feita
img_Tx_bin = img_bin(:);
x_mod = qammod(img_Tx_bin, M, 'InputType', 'bit');

% Super Amostragem
x_up = rectpulse(x_mod, nsamp);

% FFT
[espectro_x_up, ~, freq, ~] = Analisador_de_Espectro(x_up, Tb);

% .................  Canal  ............................................... 
% Adicionando ru�do termico Gaussiano
vetor_ber = zeros(1, snr_max + 1);
vetor_recovered_img_bin = zeros(snr_max, length(x_up));
for snr = 0:snr_max
    
    x_up_noise = awgn(x_up, snr, 'measured');


    % ................. Recep��o ..........................................

    % Desfazendo a conforma��o de pulso (Downsampling)
    x_down = intdump(x_up_noise, nsamp);

    % Demodula��o QAM para M = 16
    img_Rx_bin = qamdemod(x_down, M, 'OutputType', 'bit');
    vetor_recovered_img_bin(snr + 1, :) = img_Rx_bin;
    
    % Calculo do BER
    %[~, BER] = biterr(img_Tx_bin, img_Rx_bin);
    [~, BER] = biterr(img_Tx_bin(:, 1), img_Rx_bin(:, 1));
    vetor_ber(1, snr+1) = BER;

end


% +++++++++++++++++++  Plotagens  +++++++++++++++++++++++++++++++++++++++++
% Mapa de constela��o
scatterplot(x_up)
title(['Mapa de constelcao do QAMmod com M: ' num2str(M)]);

% Espectro do sinal no sinal da transmiss�o
figure;
subplot(2,1,1) 
plot(freq, 10*log10(abs(fftshift(real(espectro_x_up)))))
title('Espectro Sinal parte real')
ylabel('Densidade espectral')

subplot(2,1,2) 
plot(freq, 10*log10(abs(fftshift(imag(espectro_x_up)))))
title('Espectro Sinal parte imaginaria')
xlabel('Frequencia')
ylabel('Densidade espectral')

% Ber para cada SNR
figure;
semilogy(0:snr_max, vetor_ber);
title("BERs para cada SNR")
xlabel('SNR')
ylabel('BER')
xlim([0, snr_max])

%-----------------------Roover---------------------------------------------
% Convers�o do vetor de bits recuperados para uma matriz de pixels
recovered_img_1_bin = uint8(reshape(vetor_recovered_img_bin(snr_escolhido, :),size(img_bin)));

% Convers�o para formato original da imagem, isto � 3D
recovered_img_1 = reshape(bi2de(recovered_img_1_bin),size(img));

% Exibi��o das imagens lida e recuperada
figure;
subplot(2,1,1) 
image(img)
title('Imagem Original')

subplot(2,1,2) 
image(recovered_img_1) 
title('Imagem Recuperada')
title(['Imagem Recuperada com SNR: ' num2str(snr_escolhido)]);
