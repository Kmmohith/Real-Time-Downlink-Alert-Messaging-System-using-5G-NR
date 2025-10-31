function comparison_methods
% comparison_methods.m
% Comparison of QPSK-OFDM, 16-QAM-OFDM, OTFS (BPSK), and 2x2 MIMO (Alamouti)

clc; clear; close all;
disp('=== BER Comparison: QPSK / 16-QAM / OTFS / 2x2 MIMO ===');

rng(1);

SNRs = 0:2:20;
numBits = 4096;

% Parameters
Nfft = 64; cpLen = 16;
M_QPSK = 4; M_QAM = 16;
N_OTFS = 16;   % OTFS grid size
numBlocks_MIMO = 512;

BER_QPSK = zeros(size(SNRs));
BER_QAM  = zeros(size(SNRs));
BER_OTFS = zeros(size(SNRs));
BER_MIMO = zeros(size(SNRs));

for idx = 1:length(SNRs)
    snr = SNRs(idx);

    % --- QPSK-OFDM ---
    bits_qpsk = randi([0 1], numBits,1);
    tx_qpsk = qammod(bits_qpsk, M_QPSK, 'InputType','bit','UnitAveragePower',true);
    tx_qpsk_ofdm = ofdmMod(tx_qpsk,Nfft,cpLen);
    rx_qpsk_ofdm = awgn(tx_qpsk_ofdm, snr, 'measured');
    rx_qpsk = ofdmDemod(rx_qpsk_ofdm,Nfft,cpLen);
    rxBits_QPSK = qamdemod(rx_qpsk, M_QPSK, 'OutputType','bit','UnitAveragePower',true);
    BER_QPSK(idx) = sum(bits_qpsk ~= rxBits_QPSK(1:length(bits_qpsk))) / length(bits_qpsk);

    % --- 16-QAM-OFDM ---
    bits_qam = randi([0 1], numBits,1);
    tx_qam = qammod(bits_qam, M_QAM, 'InputType','bit','UnitAveragePower',true);
    tx_qam_ofdm = ofdmMod(tx_qam,Nfft,cpLen);
    rx_qam_ofdm = awgn(tx_qam_ofdm, snr, 'measured');
    rx_qam = ofdmDemod(rx_qam_ofdm,Nfft,cpLen);
    rxBits_QAM = qamdemod(rx_qam, M_QAM, 'OutputType','bit','UnitAveragePower',true);
    BER_QAM(idx) = sum(bits_qam ~= rxBits_QAM(1:length(bits_qam))) / length(bits_qam);

    % --- OTFS ---
    otfsBits = randi([0 1], N_OTFS^2, 1);
    tx_otfs = otfsMod(otfsBits, N_OTFS);
    rx_otfs = awgnChannel(tx_otfs, snr);
    rxBits_otfs = otfsDemod(rx_otfs, N_OTFS);
    BER_OTFS(idx) = sum(otfsBits ~= rxBits_otfs) / length(otfsBits);

    % --- MIMO ---
    txMIMO = randi([0 1], 2*numBlocks_MIMO, 1);
    rxMIMO_bits = alamoutiMimo(txMIMO, snr);
    BER_MIMO(idx) = sum(txMIMO ~= rxMIMO_bits) / length(txMIMO);
end

% Plot
figure;
semilogy(SNRs,BER_QPSK,'-o','LineWidth',2); hold on;
semilogy(SNRs,BER_QAM,'-s','LineWidth',2);
semilogy(SNRs,BER_OTFS,'-^','LineWidth',2);
semilogy(SNRs,BER_MIMO,'-d','LineWidth',2);
grid on;
xlabel('SNR (dB)'); ylabel('Bit Error Rate (BER)');
title('BER Comparison: QPSK / 16-QAM / OTFS / 2x2 MIMO');
legend('QPSK-OFDM','16-QAM-OFDM','OTFS (BPSK)','2x2 MIMO','Location','southwest');

end  % <---- Important: close the main function here

% ---------- Helper Functions Below ----------

function ofdmSig = ofdmMod(symbols,Nfft,cpLen)
    symbols = symbols(:);
    numSymbols = length(symbols);
    numOFDM = ceil(numSymbols/Nfft);
    symbolsPad = [symbols; zeros(numOFDM*Nfft - numSymbols,1)];
    X = reshape(symbolsPad,Nfft,numOFDM);
    x_ifft = ifft(X,Nfft,1);
    ofdmMat = [x_ifft(end-cpLen+1:end,:); x_ifft];
    ofdmSig = ofdmMat(:);
end

function rxSymbols = ofdmDemod(rxSig,Nfft,cpLen)
    numOFDM = floor(length(rxSig)/(Nfft+cpLen));
    if numOFDM==0
        rxSymbols = [];
        return;
    end
    rxMat = reshape(rxSig(1:(Nfft+cpLen)*numOFDM),Nfft+cpLen,numOFDM);
    rxNoCP = rxMat(cpLen+1:end,:);
    X = fft(rxNoCP,Nfft,1);
    rxSymbols = X(:);
end

