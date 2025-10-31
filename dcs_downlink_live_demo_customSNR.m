function dcs_downlink_live_demo_customSNR(snr_dB)
% ===============================================================
% Digital Communication System: Downlink Demo (Adjustable SNR)
% Integrated TX/RX visualization for GUI
% ===============================================================

clc; close all;

% --- System Parameters ---
msg = 'Earthquake Detected - Evacuate!';
M = 16;                % 16-QAM
Nfft = 64;             % OFDM FFT size
cpLen = 16;            % Cyclic prefix length

% --- Convert message to bits ---
msg_codes = double(msg);
nbits_char = max(8, ceil(log2(max(msg_codes)+1)));
bits_matrix = de2bi(msg_codes, nbits_char, 'left-msb');
bits_col = bits_matrix.'; bits_col = bits_col(:);

bitsPerSym = log2(M);
L = lcm(nbits_char, bitsPerSym);
padBits = mod(-length(bits_col), L);
if padBits > 0, bits_col = [bits_col; zeros(padBits,1)]; end

sym_bits = reshape(bits_col, bitsPerSym, []).';
tx_symbols = qammod(bi2de(sym_bits,'left-msb'), M, 'UnitAveragePower', true);

% --- OFDM Transmitter ---
[tx_sig, ~, ~] = helper_ofdm_tx(tx_symbols, Nfft, cpLen);

% --- Channel: AWGN ---
rx_sig = awgn(tx_sig, snr_dB, 'measured');

% --- OFDM Receiver ---
rx_symbols = helper_ofdm_rx(rx_sig, Nfft, cpLen);
rx_symbols = rx_symbols(1:length(tx_symbols));

% --- QAM Demodulation ---
rx_bits = de2bi(qamdemod(rx_symbols,M,'UnitAveragePower',true), log2(M), 'left-msb').';
rx_bits = rx_bits(:);
if padBits > 0, rx_bits = rx_bits(1:end-padBits); end
usableBits = floor(length(rx_bits)/nbits_char)*nbits_char;
rx_bits = rx_bits(1:usableBits);
rx_chars = reshape(rx_bits, nbits_char, []).';
rx_msg = char(bi2de(rx_chars,'left-msb')).';

% --- Print to console (optional) ---
fprintf('\n--- TX Message ---\n%s\n', msg);
fprintf('\n--- RX Message ---\n%s\n', rx_msg);

% ===============================================================
%           COMBINED 4-IN-1 VISUALIZATION WINDOW
% ===============================================================
figure('Name', sprintf('DCS Downlink Demo (SNR = %d dB)', snr_dB), ...
       'Position', [200 100 1000 700]);

% ===============================================================
%           COMBINED 4-IN-1 VISUALIZATION WINDOW
% ===============================================================
figure('Name', sprintf('DCS Downlink Demo (SNR = %d dB)', snr_dB), ...
       'Position', [200 100 1000 700]);

% 1️⃣ Transmitted OFDM signal
subplot(2,2,1);
Nplot = min(length(tx_sig), 200);
plot(real(tx_sig(1:Nplot)),'b'); hold on;
plot(imag(tx_sig(1:Nplot)),'r');
title('Transmitted Signal (first samples)');
xlabel('Sample Index'); ylabel('Amplitude');
legend('Real','Imag'); grid on;

% 2️⃣ Received signal with noise
subplot(2,2,2);
Nplot = min(length(rx_sig), 200);
plot(real(rx_sig(1:Nplot)),'b'); hold on;
plot(imag(rx_sig(1:Nplot)),'r');
title(sprintf('Received Signal (SNR = %d dB)', snr_dB));
xlabel('Sample Index'); ylabel('Amplitude');
legend('Real','Imag'); grid on;

% 3️⃣ Frequency-domain magnitude (FFT)
subplot(2,2,3);
rx_fft = fft(rx_sig(1:min(length(rx_sig), Nfft)));
stem(abs(rx_fft),'filled');
title('RX FFT Magnitude (first OFDM symbol)');
xlabel('Subcarrier Index'); ylabel('|Amplitude|');
grid on;

% 4️⃣ Constellation: TX vs RX
subplot(2,2,4);
scatter(real(tx_symbols), imag(tx_symbols), 25, 'b', 'filled'); hold on;
scatter(real(rx_symbols), imag(rx_symbols), 25, 'r');
axis equal; grid on;
title(sprintf('TX (blue) vs RX (red) 16-QAM Constellation\nSNR = %d dB', snr_dB));
xlabel('In-phase'); ylabel('Quadrature');
legend('TX','RX','Location','best');


% ===============================================================
%                 MESSAGE BOX SUMMARY
% ===============================================================
msgbox({['SNR = ' num2str(snr_dB) ' dB'], ...
        ['Transmitted Message:  ' msg], ...
        ['Recovered Message:    ' rx_msg]}, ...
        'Transmission Result');

end
