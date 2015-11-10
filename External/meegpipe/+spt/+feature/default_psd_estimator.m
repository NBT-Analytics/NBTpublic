function [h, freqs] = default_psd_estimator(x, sr)

[h, freqs] = pwelch(x,  min(ceil(numel(x)/5),sr*3), ...
            [], [], sr);

end