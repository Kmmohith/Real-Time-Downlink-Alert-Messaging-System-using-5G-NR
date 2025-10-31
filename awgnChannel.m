function rxSig = awgnChannel(txSig, SNRdB)
% rxSig = awgnChannel(txSig,SNRdB)
% Adds complex AWGN noise at specified SNR (for OTFS demo)

    snrLin = 10^(SNRdB/10);
    noiseVar = 1/(2*snrLin);
    noise = sqrt(noiseVar)*(randn(size(txSig)) + 1i*randn(size(txSig)));
    rxSig = txSig + noise;
end
