% otfs_helpers.m
% Simple helper functions for OTFS modulation/demodulation and AWGN

function txSig = otfsMod(bits, N)
% txSig = otfsMod(bits,N)
% Performs a lightweight OTFS-like modulation for demonstration.

    bits = bits(:);
    symbols = 2*bits - 1;           % BPSK mapping
    grid = reshape(symbols, N, N);  % Fill N×N grid
    % 2-D symplectic transform (simplified)
    txGrid = ifft(fft(grid,[],1),[],2);
    txSig = txGrid(:);              % Serialize
end


function rxBits = otfsDemod(rxSig, N)
% rxBits = otfsDemod(rxSig,N)
% Inverse operation of otfsMod.

    grid = reshape(rxSig, N, N);
    X_hat = fft(ifft(grid,[],1),[],2);
    rxBits = real(X_hat(:)) > 0;    % Hard-decision BPSK
end


function rxSig = awgnChannel(txSig, SNRdB)
% rxSig = awgnChannel(txSig,SNRdB)
% Adds complex AWGN noise at specified SNR.

    snrLin = 10^(SNRdB/10);
    noiseVar = 1/(2*snrLin);
    noise = sqrt(noiseVar) * (randn(size(txSig)) + 1i*randn(size(txSig)));
    rxSig = txSig + noise;
end
