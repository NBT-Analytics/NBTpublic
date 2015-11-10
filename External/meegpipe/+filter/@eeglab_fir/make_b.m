function b = make_b(obj, data)


% This function is a stripped down version of EEGLAB's pop_eegfiltnew

TRANSWIDTHRATIO = 0.25;

if obj.Notch,
    revfilt = 1;
else
    revfilt = 0;
end

if isempty(obj.SamplingRate),
    sr = data.SamplingRate;
else
    sr = obj.SamplingRate;
end

fNyquist = sr / 2;

locutoff = obj.Fp(1);
hicutoff = obj.Fp(2);
if locutoff == 0, locutoff = []; end
if hicutoff == 0, hicutoff = []; end
if isempty(hicutoff) % Convert highpass to inverted lowpass
    hicutoff = locutoff;
    locutoff = [];
    revfilt = ~revfilt;
end
edgeArray = sort([locutoff hicutoff]);

% Max stop-band width
maxTBWArray = edgeArray; % Band-/highpass
if revfilt == 0 % Band-/lowpass
    maxTBWArray(end) = fNyquist - edgeArray(end);
elseif length(edgeArray) == 2 % Bandstop
    maxTBWArray = diff(edgeArray) / 2;
end
maxDf = min(maxTBWArray);

filtorder = obj.Order;

if isempty(filtorder),
    if revfilt == 1 % Highpass and bandstop
        df = min([max([maxDf * TRANSWIDTHRATIO 2]) maxDf]);
    else % Lowpass and bandpass
        df = min([max([edgeArray(1) * TRANSWIDTHRATIO 2]) maxDf]);
    end
    
    filtorder = 3.3 / (df / sr); % Hamming window
    filtorder = ceil(filtorder / 2) * 2; % Filter order must be even.
else
    
    df = 3.3 / filtorder * sr; % Hamming window
    filtorderMin = ceil(3.3 ./ ((maxDf * 2) / sr) / 2) * 2;
    filtorderOpt = ceil(3.3 ./ (maxDf / sr) / 2) * 2;
    if filtorder < filtorderMin
        error('Filter order too low. Minimum required filter order is %d. For better results a minimum filter order of %d is recommended.', filtorderMin, filtorderOpt)
    elseif filtorder < filtorderOpt
        warning('firfilt:filterOrderLow', 'Transition band is wider than maximum stop-band width. For better results a minimum filter order of %d is recommended. Reported might deviate from effective -6dB cutoff frequency.', filtorderOpt)
    end
    
end

dfArray = {df, [-df, df]; -df, [df, -df]};
cutoffArray = edgeArray + dfArray{revfilt + 1, length(edgeArray)} / 2;
winArray = window('hamming', filtorder + 1);

% Filter coefficients
if revfilt == 1
    filterTypeArray = {'high', 'stop'};
    b = firws(filtorder, cutoffArray / fNyquist, filterTypeArray{length(cutoffArray)}, winArray);
else
    b = firws(filtorder, cutoffArray / fNyquist, winArray);
end

end