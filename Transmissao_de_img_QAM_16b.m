% =========================================================================
% 
% Código para conversão de imagem em sequencia de bits para transmissão em
% um canal adicionando ruído AWGN e realizando a recepção utilizando a
% modulação 16-QAM
%
% =========================================================================

% Inicialização 
clc, close all, clear all


% .................  Parametrização do Sistema  ...........................
Rb = 10e6; % Taxa de Transmissão no sistema(bps)
Tb = 1/Rb; % Duração de 1 bit
M = 16; % Nível de Modulução(Mapeamento para codificação digital)- QAM 16b
nsamp = 4; % Fator de reamostragem
snr = 12; % Relação sinal ruído (dado em 3db / Dobro da potencia)
m = log2(M); % Bits por simbolo 
Rs = Rb/m; % Taxa de Simbolos (sps ou baud)
Ts= 1/Rs; % Duração de cada simbolo (s)
% -------------------------  TRANSMISSÃO ----------------------------------

    % Leitura da imagem 
    img_1 = imread('rover.jpg');

    % Conversão da imagem para matriz de bits
    img_1_bin = de2bi(img_1);

    % Transformação da matriz de bits em um vetor
    img_Tx_bin = img_1_bin(:);

    % Conversão de bits em pulsos com Modulação QAM
    x_pulse = qammod(img_Tx_bin, M, 'InputType', 'bit');

    % Conformação de pulso (Pulse Shaping) - Super Amostragem (Upsampling)
    x_up = rectpulse(x_pulse, nsamp); % Filtro Retangular

    % .................  Calculos de variaveis inicias  .......................
    Ndata = length(x_up);
    t = linspace(0,Ts*(Ndata/m), Ndata*nsamp);
    ts = t(2)-t(1);  % Periodo de amostragem 
   
% ------------------------ Geração do espectro ----------------------------
    [X_up_fft, x_tf, f, df] = Analisador_de_Espectro(real(x_up),ts);
     X_real = 10*log(fftshift(abs(X_up_fft)));
 
    [X_up_fft2, x_tf2, f2, df2] = Analisador_de_Espectro(imag(x_up),ts);
     X_imag = 10*log(fftshift(abs(X_up_fft2)));

% ------------------------  CANAL DE TRANSMISSÃO --------------------------
   
    % Adicionando Ruído AWGN
    x_up_noise = awgn(x_up,snr,'measured');

% ------------------------------  RECEPÇÃO --------------------------------
    
    % Desfazendo a conformação de pulso (Downsampling)
    x_down = intdump(x_up_noise, nsamp);

    % Demodulação QAM para M = 16
    img_Rx_bin = qamdemod(x_down, M, 'OutputType', 'bit');

    % Conversão do vetor de bits recuperados para uma matriz de pixels
    recovered_img_1_bin = uint8(reshape(img_Rx_bin,size(img_1_bin)));
    
    % Conversão para formato original da imagem, isto é 3D
    recovered_img_1 = reshape(bi2de(recovered_img_1_bin),size(img_1));


% -----------------------------  PLOTAGENS --------------------------------
    % Diagrama de constelação QAM
    scatterplot(x_up)
    title(['Diagrama de constelação QAM com M = ' num2str(M)]);

    % Espectro da Transmissão
    
  figure;
  subplot(2,1,1),
    %plot(f(end/2:end), X_real(end/2:end)); % Espectro da parte real do Sinal
    plot(f, X_real);
    title('Espectro do Sinal - Parte Real')
    xlabel('Frequencia (Hz)'), ylabel('psd(dBV/Hz)')
  
  subplot(2,1,2),
   % plot(f2(end/2:end), X_imag(end/2:end),'red'); % Espectro da parte imaginaria do Sinal
    plot(f2, X_imag,'red');
    title('Espectro do Sinal - Parte Imaginaria')
    xlabel('Frequencia (Hz)'), ylabel('psd(dBV/Hz)')
    
    
    % Exibição das imagens lida e recuperada
    figure;
    subplot(2,1,1), image(img_1), title('Imagem Original');
    subplot(2,1,2), image(recovered_img_1), title('Imagem Recuperada');
