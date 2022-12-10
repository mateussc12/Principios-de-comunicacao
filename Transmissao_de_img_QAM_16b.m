% =========================================================================
% 
% C�digo para convers�o de imagem em sequencia de bits para transmiss�o em
% um canal adicionando ru�do AWGN e realizando a recep��o utilizando a
% modula��o 16-QAM
%
% =========================================================================

% Inicializa��o 
clc, close all, clear all


% .................  Parametriza��o do Sistema  ...........................
Rb = 10e6; % Taxa de Transmiss�o no sistema(bps)
Tb = 1/Rb; % Dura��o de 1 bit
M = 16; % N�vel de Modulu��o(Mapeamento para codifica��o digital)- QAM 16b
nsamp = 4; % Fator de reamostragem
snr = 12; % Rela��o sinal ru�do (dado em 3db / Dobro da potencia)
m = log2(M); % Bits por simbolo 
Rs = Rb/m; % Taxa de Simbolos (sps ou baud)
Ts= 1/Rs; % Dura��o de cada simbolo (s)
% -------------------------  TRANSMISS�O ----------------------------------

    % Leitura da imagem 
    img_1 = imread('rover.jpg');

    % Convers�o da imagem para matriz de bits
    img_1_bin = de2bi(img_1);

    % Transforma��o da matriz de bits em um vetor
    img_Tx_bin = img_1_bin(:);

    % Convers�o de bits em pulsos com Modula��o QAM
    x_pulse = qammod(img_Tx_bin, M, 'InputType', 'bit');

    % Conforma��o de pulso (Pulse Shaping) - Super Amostragem (Upsampling)
    x_up = rectpulse(x_pulse, nsamp); % Filtro Retangular

    % .................  Calculos de variaveis inicias  .......................
    Ndata = length(x_up);
    t = linspace(0,Ts*(Ndata/m), Ndata*nsamp);
    ts = t(2)-t(1);  % Periodo de amostragem 
   
% ------------------------ Gera��o do espectro ----------------------------
    [X_up_fft, x_tf, f, df] = Analisador_de_Espectro(real(x_up),ts);
     X_real = 10*log(fftshift(abs(X_up_fft)));
 
    [X_up_fft2, x_tf2, f2, df2] = Analisador_de_Espectro(imag(x_up),ts);
     X_imag = 10*log(fftshift(abs(X_up_fft2)));

% ------------------------  CANAL DE TRANSMISS�O --------------------------
   
    % Adicionando Ru�do AWGN
    x_up_noise = awgn(x_up,snr,'measured');

% ------------------------------  RECEP��O --------------------------------
    
    % Desfazendo a conforma��o de pulso (Downsampling)
    x_down = intdump(x_up_noise, nsamp);

    % Demodula��o QAM para M = 16
    img_Rx_bin = qamdemod(x_down, M, 'OutputType', 'bit');

    % Convers�o do vetor de bits recuperados para uma matriz de pixels
    recovered_img_1_bin = uint8(reshape(img_Rx_bin,size(img_1_bin)));
    
    % Convers�o para formato original da imagem, isto � 3D
    recovered_img_1 = reshape(bi2de(recovered_img_1_bin),size(img_1));


% -----------------------------  PLOTAGENS --------------------------------
    % Diagrama de constela��o QAM
    scatterplot(x_up)
    title(['Diagrama de constela��o QAM com M = ' num2str(M)]);

    % Espectro da Transmiss�o
    
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
    
    
    % Exibi��o das imagens lida e recuperada
    figure;
    subplot(2,1,1), image(img_1), title('Imagem Original');
    subplot(2,1,2), image(recovered_img_1), title('Imagem Recuperada');
