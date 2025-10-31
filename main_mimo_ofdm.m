function main_mimo_ofdm
% main_mimo_ofdm.m
% 2x2 MIMO-OFDM using Alamouti STBC. Plots BER vs SNR.

clc; clear; close all;
disp('=== main_mimo_ofdm: 2x2 MIMO-OFDM (Alamouti) ===');

%% Parameters
Nfft = 64;
cpLen = 16;
M = 4;                  % QPSK
numBlocks = 2000;       % number of Alamouti blocks (increase for smoother BER curve)
SNRs = 0:2:20;

rng(0); % seed for reproducibility

BER = zeros(length(SNRs),1);

for si = 1:length(SNRs)
    snr_dB = SNRs(si);
    numErr = 0;
    totalBits = 0;

    for blk = 1:numBlocks
        % Generate two QPSK symbols (per Alamouti block)
        bits_block = randi([0 1], 2*log2(M),1);
        sym_block = qammod(bits_block, M, 'InputType','bit','UnitAveragePower',true);

        s1 = sym_block(1);
        s2 = sym_block(2);

        % Alamouti encoding: two time slots for each transmit antenna
        % Create frequency-domain OFDM symbol (place s1/s2 on first two subcarriers)
        X1 = zeros(Nfft,1); X2 = zeros(Nfft,1);
        X1(1) = s1; X1(2) = -conj(s2);
        X2(1) = s2; X2(2) = conj(s1);

        % IFFT to time domain
        x1_ifft = ifft(X1,Nfft);
        x2_ifft = ifft(X2,Nfft);

        % Add CP
        tx1 = [x1_ifft(end-cpLen+1:end); x1_ifft];
        tx2 = [x2_ifft(end-cpLen+1:end); x2_ifft];

        % Flat-fading 2x2 MIMO channel (complex Gaussian)
        H11 = (randn+1i*randn)/sqrt(2);
        H12 = (randn+1i*randn)/sqrt(2);
        H21 = (randn+1i*randn)/sqrt(2);
        H22 = (randn+1i*randn)/sqrt(2);

        % AWGN
        snrLin = 10^(snr_dB/10);
        noiseVar = 1/(2*snrLin);
        n1 = sqrt(noiseVar)*(randn(size(tx1)) + 1i*randn(size(tx1)));
        n2 = sqrt(noiseVar)*(randn(size(tx2)) + 1i*randn(size(tx2)));

        % Received signals (time domain)
        r1 = H11*tx1 + H12*tx2 + n1;
        r2 = H21*tx1 + H22*tx2 + n2;

        % Remove CP and FFT
        r1_noCP = r1(cpLen+1:end);
        r2_noCP = r2(cpLen+1:end);
        R1 = fft(r1_noCP, Nfft);
        R2 = fft(r2_noCP, Nfft);

        % Alamouti decoding for subcarrier 1 and 2 (we only used 2 subcarriers)
        % For subcarrier 1:
        y1 = [R1(1); R2(1)];
        H_sub1 = [H11 H12; H21 H22];

        % Apply Alamouti combining (ZF/ML simplified)
        s1_hat = conj(H11)*R1(1) + H21*conj(R2(1));
        s2_hat = conj(H12)*R1(1) + H22*conj(R2(1));
        normFactor = abs(H11)^2 + abs(H12)^2 + abs(H21)^2 + abs(H22)^2 + eps;
        s1_hat = s1_hat / normFactor;
        s2_hat = s2_hat / normFactor;

        % Decision via QPSK demod
        rx_bits = qamdemod([s1_hat; s2_hat], M, 'OutputType','bit','UnitAveragePower',true);

        numErr = numErr + sum(rx_bits ~= bits_block);
        totalBits = totalBits + length(bits_block);
    end

    BER(si) = numErr / totalBits;
    fprintf('SNR=%2d dB -> BER=%.3e\n', snr_dB, BER(si));
end

% Plot BER
figure;
semilogy(SNRs, BER, '-o','LineWidth',2);
grid on; xlabel('SNR (dB)'); ylabel('Bit Error Rate (BER)');
title('BER vs SNR for 2x2 MIMO-OFDM with Alamouti STBC');
