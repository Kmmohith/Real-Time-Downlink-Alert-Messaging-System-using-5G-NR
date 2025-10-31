function rxBits = alamoutiMimo(txBits, SNRdB)
% alamoutiMimo: simplified 2x2 Alamouti MIMO simulation for BPSK bits
% txBits : column vector (length must be even)
% returns rxBits : decoded bits (same length as txBits)

    if mod(length(txBits),2) ~= 0
        txBits = [txBits; 0];
    end

    numBlocks = length(txBits)/2;
    % BPSK mapping
    s = 2*txBits - 1;
    s1 = s(1:2:end).';
    s2 = s(2:2:end).';

    H11 = (randn(1,numBlocks)+1i*randn(1,numBlocks))/sqrt(2);
    H12 = (randn(1,numBlocks)+1i*randn(1,numBlocks))/sqrt(2);
    H21 = (randn(1,numBlocks)+1i*randn(1,numBlocks))/sqrt(2);
    H22 = (randn(1,numBlocks)+1i*randn(1,numBlocks))/sqrt(2);

    snrLin = 10^(SNRdB/10);
    noiseVar = 1/(2*snrLin);
    n1 = sqrt(noiseVar)*(randn(1,numBlocks)+1i*randn(1,numBlocks));
    n2 = sqrt(noiseVar)*(randn(1,numBlocks)+1i*randn(1,numBlocks));

    r1 = H11.*s1 + H12.*s2 + n1;
    r2 = H21.*s1 + H22.*s2 + n2;

    s1_hat = conj(H11).*r1 + H21.*conj(r2);
    s2_hat = conj(H12).*r1 + H22.*conj(r2);

    % Decision (BPSK)
    s1_bits = real(s1_hat) > 0;
    s2_bits = real(s2_hat) > 0;

    rxBits = zeros(length(txBits),1);
    rxBits(1:2:end) = s1_bits.';
    rxBits(2:2:end) = s2_bits.';
end
