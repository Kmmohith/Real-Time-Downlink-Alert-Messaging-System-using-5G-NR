% dcs_downlink_live_demo.m
% Integrated Downlink TX -> AWGN Channel -> RX live demo
% Ready for Review 3 (prints transmitted & recovered message, shows plots)

clc; close all; clear;

disp('=== DCS: Downlink Live Demo (TX -> Channel -> RX) ===');

%% ---------- PARAMETERS ----------
msg = 'Earthquake Detected - Evacuate!';   % message to transmit
M = 16;           % 16-QAM
Nfft = 64;        % OFDM IFFT size
cpLen = 16;       % cyclic prefix
snr_dB = 20;      % channel SNR in dB
playSound = false; % set true to play the TX waveform as audio (optional)

%% ---------- Prepare message -> bits ----------
msg_codes = double(msg);
nbits_char = max(8, ceil(log2(max(msg_codes)+1))); % bits per character
bits_matrix = de2bi(msg_codes, nbits_char, 'left-msb');
bits_col = bits_matrix.'; bits_col = bits_col(:);

%% ---------- Pad bits so that total bits is multiple of bitsPerSym ----------
bitsPerSym = log2(M);
L = lcm(nbits_char, bitsPerSym);
padBits = mod(-length(bits_col), L);
if padBits>0
    bits_col = [bits_col; zeros(padBits,1)];
end

%% ---------- Map bits -> 16-QAM symbols ----------
sym_bits = reshape(bits_col, bitsPerSym, []).';
tx_symbol_indices = bi2de(sym_bits, 'left-msb');
tx_symbols = qammod(tx_symbol_indices, M, 'UnitAveragePower', true);

%% ---------- OFDM modulation ----------
[tx_sig, tx_ifft, tx_ofdm] = helper_ofdm_tx(tx_symbols, Nfft, cpLen);

%% Optional: play TX waveform (scaled)
if playSound
    try
        fs = 8192;
        sound(real(tx_sig)/max(abs(real(tx_sig))), fs);
    catch
        warning('Unable to play sound on this system.');
    end
end

%% ---------- Channel ----------
rx_sig = awgn(tx_sig, snr_dB, 'measured');  % Built-in AWGN

%% ---------- RX: OFDM demod ----------
rx_symbols = helper_ofdm_rx(rx_sig, Nfft, cpLen);
% Trim to original symbol count
rx_symbols = rx_symbols(1:length(tx_symbols));

%% ---------- QAM demodulation -> bits ----------
rx_symbol_indices = qamdemod(rx_symbols, M, 'UnitAveragePower', true);
rx_sym_bits = de2bi(rx_symbol_indices, log2(M), 'left-msb').';
rx_bits_col = rx_sym_bits(:);

% Remove padding
if padBits>0
    rx_bits_col = rx_bits_col(1:end-padBits);
end

% Keep only full characters
usableBits = floor(length(rx_bits_col)/nbits_char) * nbits_char;
rx_bits_col = rx_bits_col(1:usableBits);

if ~isempty(rx_bits_col)
    rx_chars_mat = reshape(rx_bits_col, nbits_char, []).';
    rx_msg = char(bi2de(rx_chars_mat,'left-msb')).';
else
    rx_msg = '';
end

%% ---------- Display textual results ----------
fprintf('\n--- Transmitted Message ---\n%s\n', msg);
fprintf('\n--- Recovered Message ---\n%s\n', rx_msg);

%% ---------- Visualization ----------
% 1) TX / RX constellation overlay
figure('Name','TX vs RX Constellation','NumberTitle','off');
scatter(real(tx_symbols), imag(tx_symbols), 36, 'b','filled'); hold on;
scatter(real(rx_symbols), imag(rx_symbols), 36, 'r');
axis equal; grid on;
title('TX (blue) vs RX (red) 16-QAM Constellation');
xlabel('In-phase'); ylabel('Quadrature'); legend('TX','RX');

% 2) OFDM time domain (first few samples)
figure('Name','OFDM Time Domain (TX)','NumberTitle','off');
Lplot = min(600, length(tx_sig));
plot((1:Lplot), real(tx_sig(1:Lplot))); hold on;
plot((1:Lplot), imag(tx_sig(1:Lplot))); hold off;
title('Transmitted OFDM Signal (first samples)');
legend('Real','Imag'); xlabel('Sample'); ylabel('Amplitude');

% 3) Received signal (first samples)
figure('Name','Received Time Domain','NumberTitle','off');
Lplot = min(600, length(rx_sig));
plot((1:Lplot), real(rx_sig(1:Lplot))); hold on;
plot((1:Lplot), imag(rx_sig(1:Lplot))); hold off;
title(sprintf('Received Signal (SNR=%d dB)', snr_dB));
legend('Real','Imag'); xlabel('Sample'); ylabel('Amplitude');

% 4) FFT magnitude of first OFDM symbol (RX)
numCols = floor(length(rx_sig)/(Nfft+cpLen));
if numCols>0
    rx_matrix = reshape(rx_sig(1:(Nfft+cpLen)*numCols), Nfft+cpLen, numCols);
    rx_noCP = rx_matrix(cpLen+1:end, :);
    firstFFT = fft(rx_noCP(:,1));
    figure('Name','RX FFT Magnitude (first OFDM symbol)','NumberTitle','off');
    stem(0:Nfft-1, abs(firstFFT), 'filled');
    title('RX: FFT Magnitude (first OFDM symbol)'); xlabel('Subcarrier Index'); ylabel('|X|');
end

disp('=== Demo complete ===');
