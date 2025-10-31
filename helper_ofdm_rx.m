function rx_symbols = helper_ofdm_rx(rx_sig, Nfft, cpLen)
% helper_ofdm_rx : Remove CP and perform FFT to get frequency-domain symbols
% Inputs:
%   rx_sig : received time-domain signal (with CP)
%   Nfft   : FFT size (subcarriers)
%   cpLen  : cyclic prefix length
% Output:
%   rx_symbols : column vector of frequency-domain symbols (complex)

    if nargin < 3
        error('Usage: helper_ofdm_rx(rx_sig, Nfft, cpLen)');
    end

    rx_sig = rx_sig(:);
    numCols = floor(length(rx_sig) / (Nfft + cpLen));
    if numCols == 0
        rx_symbols = [];
        return;
    end

    rx_matrix = reshape(rx_sig(1:numCols*(Nfft+cpLen)), Nfft+cpLen, numCols);
    rx_no_cp = rx_matrix(cpLen+1:end, :);
    rx_fft = fft(rx_no_cp, Nfft, 1);
    rx_symbols = rx_fft(:);
end
