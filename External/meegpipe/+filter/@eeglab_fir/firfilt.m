function data = firfilt(data, b, nFrames, evBndry)

import filter.eeglab_fir;

% Taken from EEGLAB's firfilt


if nargin < 2
    error('Not enough input arguments.');
end
if nargin < 3 || isempty(nFrames)
    nFrames = 1000;
end

% Filter's group delay
if mod(length(b), 2) ~= 1
    error('Filter order is not even.');
end
groupDelay = (length(b) - 1) / 2;

% Find data discontinuities
if ~isempty(evBndry),
    evBndry = eeglab(evBndry);
end
dcArray = [eeglab_fir.findboundaries(evBndry) size(data,2) + 1];

for iDc = 1:(length(dcArray) - 1)
    
    % Pad beginning of data with DC constant and get initial conditions
    ziDataDur = min(groupDelay, dcArray(iDc + 1) - dcArray(iDc));
    [~, zi] = filter(b, 1, double([data(:, ones(1, groupDelay) * dcArray(iDc)) ...
        data(:, dcArray(iDc):(dcArray(iDc) + ziDataDur - 1))]), [], 2);
    
    blockArray = [(dcArray(iDc) + groupDelay):nFrames:(dcArray(iDc + 1) - 1) dcArray(iDc + 1)];
    if length(blockArray) < 2,
        warning('eeglab_fir:TooShortBlock', ...
            ['Data block too short (%d samples) for filter length ' ...
            '(%d samples): skipping block from sample %d to sample %d'], ...
            dcArray(iDc+1)-1-dcArray(iDc), length(b), dcArray(iDc), ...
            dcArray(iDc+1)-1);
    end
        
    for iBlock = 1:(length(blockArray) - 1)
        
        % Filter the data
        [data(:, (blockArray(iBlock) - groupDelay):(blockArray(iBlock + 1) - groupDelay - 1)), zi] = ...
            filter(b, 1, double(data(:, blockArray(iBlock):(blockArray(iBlock + 1) - 1))), zi, 2);

    end

    % Pad end of data with DC constant
    temp = filter(b, 1, double(data(:, ones(1, groupDelay) * (dcArray(iDc + 1) - 1))), zi, 2);
    data(:, (dcArray(iDc + 1) - ziDataDur):(dcArray(iDc + 1) - 1)) = ...
        temp(:, (end - ziDataDur + 1):end);
end

end
