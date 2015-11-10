function ratios = power_ratios(h, bois, normalized)

import spectrum2.eeg_bands;

if nargin < 3 || isempty(normalized),
    normalized = false;
end


if nargin < 2 || isempty(bois),
    bois = eeg_bands;
end

if isnumeric(bois),
    boisNum = bois;
    bois = mjava.hash;
    for i = 1:size(boisNum,1)
        bois(['Band' num2str(i)]) = boisNum(i,:);
    end
end

if ~strcmp(h.SpectrumType, 'Onesided'),
    error('Only works with Onesided spectra');
end

bands = keys(bois);

ratios = mjava.hash;

for i = 1:numel(bands)
   
    this = bois(bands{i});
    
    if isnumeric(this),
        thisHash = {this, []};
    elseif iscell(this) && numel(this) == 1
        thisHash = [this {[]}];
    else
        thisHash = this;
    end
    
    target = thisHash{1};
    ref    = thisHash{2};
   
    % Bug in MATLAB's Hash table implementation
    if numel(target) == 2,
        target = reshape(target, 1, 2);
    end
    if numel(ref) == 2,
        ref = reshape(ref, 1, 2);
    end
    
    if isempty(ref),
        ref = [h.Frequencies(1) h.Frequencies(end)];
    end
    
    % Compute avg power in reference band
    if ~isempty(ref),
        powerRef = 0;
        deltaRef = 0;
        for j = 1:size(ref, 1)
            powerRef = powerRef + avgpower(h, ref(j,:));
            deltaRef = deltaRef + diff(ref(j,:));
        end
        if normalized,
            powerRef = powerRef/deltaRef;
        end
    end
    
    % Compute power in the target band
    powerTarget = 0;
    deltaTarget = 0;
    for j = 1:size(target, 1)
        powerTarget = powerTarget + avgpower(h, target(j,:));
        deltaTarget = deltaTarget + diff(target(j,:));
    end 
    if normalized,
        powerTarget = powerTarget/deltaTarget;
    end
    
    if isempty(ref),
        ratios(bands{i}) = powerTarget;
    else
        ratios(bands{i}) = powerTarget/powerRef;
    end
    
end


end