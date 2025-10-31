function rxBits = otfsDemod(rxSig, N)
% rxBits = otfsDemod(rxSig, N)
% Simplified OTFS-like demodulation for BER comparison demo

    % Reshape received vector back into N×N grid
    grid = reshape(rxSig, N, N);

    % Apply inverse transform (approximation of OTFS detection)
    X_hat = fft(ifft(grid, [], 1), [], 2);

    % Hard decision BPSK detection
    rxBits = real(X_hat(:)) > 0;
end
