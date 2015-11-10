function [dataOut, corrCoeff, shiftVal] = epoch_align(data, maxLag, verbose)
% epoch_align - Aligns a set of epochs
%
%   dataOut = epoch_align(DATA_IN) where DATA_IN is a cell array or a
%   numeric array containing data epochs. dataOut is a numeric array that
%   has an aligned epoch in each row.
%
% See also: misc/epoch_template

import misc.find_shift;
import misc.epoch_align;
import misc.eta;

if nargin < 3 ||  isempty(verbose), verbose = true; end

if nargin < 2,
    maxLag = [];
end

if iscell(data),
    
    % Duration of each epoch
    dur = nan(length(data),1);
    for i = 1:length(data),
        dur(i) = size(data{i},2);
        if size(data{i},1) ~= size(data{i}, 1),
            error('misc:epoch_align:invalidDim', ...
                'Cannot align epochs with different dimensionality.');
        end
    end
    
    % The longest epoch will be used as reference
    if all(abs(diff(dur)) < eps),
        
        template = sum(cell2mat(data));
        idxIn = [];
        idxOut = 1:numel(data);
        maxDur = dur(1);
        
    else
        
        [maxDur, idxIn] = max(dur);
        idxOut = setdiff(1:numel(data), idxIn);
        template = data{idxIn};
        
    end
    
    % Update maxLag
    if isempty(maxLag),
        factor = 50/100;
        maxLag = round(factor*maxDur);
    end
    
    dataOut = nan(size(template,1), size(template,2), numel(data));
    
    corrCoeff = zeros(numel(data), 1);
    
    % Build the template   
    maxCount = numel(idxOut);
    by100 = max(1, floor(maxCount/100));
    counter = 0;
    
    if verbose,
        tinit = tic;
        clear +misc/eta;
    end
    shiftVal = zeros(1, numel(data));
    while ~isempty(idxOut)
        
        [ccoef, lag] = find_shift(template, data(idxOut), maxLag);
        [~, maxIdx] = max(ccoef);
        
        % Remove the selected epoch from the pool of epochs
        idxIn = union(idxIn, idxOut(maxIdx));
        shiftVal(idxOut(maxIdx)) = lag(maxIdx);
        first = lag(maxIdx)+1;
        last  = first+size(data{idxOut(maxIdx)},2)-1;
        idx   = intersect(first:last, 1:size(template,2));
        
        dataOut(:, idx, idxOut(maxIdx)) = ...
            data{idxOut(maxIdx)}(:, idx-lag(maxIdx));
        
        % Update the template
        %template = nanmean(dataOut(:,:,idxIn),3);
        %template(isnan(template)) = 0;
        corrCoeff(idxOut(maxIdx)) = ccoef(maxIdx);
        idxOut(maxIdx) = [];
        
        counter = counter +1;
        if verbose && ~mod(counter, by100),
            eta(tinit, maxCount, counter);
        end
        
    end
  
elseif isnumeric(data),
    
    data = mat2cell(data, ones(size(data,1),1), size(data,2));
    [dataOut, corrCoeff, shiftVal] = epoch_align(data, maxLag, verbose);
    
else
    
    error('misc:epoch_align:invalidInput',...
        'The input argument must be a cell array or a numeric array.');
    
end

end

