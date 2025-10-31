function [tx_sig, tx_ifft, tx_with_cp] = helper_ofdm_tx(mod_symbols, Nfft, cpLen)
% helper_ofdm_tx : Perform OFDM modulation with cyclic prefix
% Inputs:
%   mod_symbols : column vector of frequency-domain symbols (complex)
%   Nfft        : FFT size (subcarriers)
%   cpLen       : cyclic prefix length
% Outputs:
%   tx_sig      : serialized transmit signal (with CP)
%   tx_ifft     : IFFT output (no CP) as [Nfft x numSymbols]
%   tx_with_cp  : IFFT output with CP as [Nfft+cpLen x numSymbols]

    if nargin < 3
        error('Usage: helper_ofdm_tx(mod_symbols, Nfft, cpLen)');
    end

    mod_symbols = mod_symbols(:);
    numSymbols = ceil(length(mod_symbols) / Nfft);
    pad_len = numSymbols * Nfft - length(mod_symbols);
    mod_symbols_padded = [mod_symbols; zeros(pad_len,1)];
    mod_matrix = reshape(mod_symbols_padded, Nfft, numSymbols);

    % IFFT per column
    tx_ifft = ifft(mod_matrix, Nfft, 1);

    % Add cyclic prefix
    cp = tx_ifft(end-cpLen+1:end, :);
    tx_with_cp = [cp; tx_ifft];

    % Serialize
    tx_sig = tx_with_cp(:);
end
