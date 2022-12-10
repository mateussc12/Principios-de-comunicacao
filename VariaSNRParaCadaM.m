function [vetor_BER, vetor_snr] = VariaSNRParaCadaM(vector_bits_ale, M, SNR_max, nsamp)
% Convers�o de bits em pulsos (modula��o PAM)
x_pulse_pam = pammod(vector_bits_ale, M);


% Conforma��o de pulso (pulse shaping) - Super Amostragem (Upsampling)
x_up = rectpulse(x_pulse_pam, nsamp); % Filtro retangular

vetor_snr = 1:SNR_max;

vetor_BER = zeros(1, length(vetor_snr));

for snr = 1:length(vetor_snr)
    
% -----------------  Canal  -----------------------------------------------
% Adicionando ru�do termico Gaussiano
x_up_noise = awgn(x_up, vetor_snr(snr), 'measured');
 
% -------------------------------------------------------------------------

% ................. Recep��o ..............................................


% Desfazendo a conforma��o de pulso (Downsampling)
x_down = intdump(x_up_noise, nsamp);

% Convers�o de pulsos em bits (demodula��o PAM)
img_Rx_bin = pamdemod(x_down, M);

[~, vetor_BER(snr)] = biterr(vector_bits_ale, img_Rx_bin);

end

end
