function [origData, dataNew] = process(obj, data, varargin)

import physioset.plotter.snapshots.snapshots;
import misc.eta;
import misc.epoch_get;
import spt.fast_pca;

dataNew = [];

verboseLabel = get_verbose_label(obj);
verbose      = is_verbose(obj);

% Configuration options
trDur    = get_config(obj, 'TR');
trDur    = trDur*1e-3; % Now it's in seconds

nbSlices = get_config(obj, 'NbSlices');
nn       = get_config(obj, 'NN');
templf   = get_config(obj, 'TemplateFunc');
win      = get_config(obj, 'SearchWindow');
lpf      = get_config(obj, 'LPF');

% Locations of the TR events
if verbose,
    fprintf([verboseLabel 'Selecting TR events...']);
end
evSel    = get_config(obj, 'EventSelector');
trEvents = select(evSel, get_event(data));
if verbose,
    fprintf('[%d selected]\n\n', numel(trEvents));
end

if isempty(trEvents),
    error('mra:NoTREvents', ...
        'I found no TR events: MR correction cannot be performed');
end

tr  = get_sample(trEvents);

trDurSampl = round(trDur*data.SamplingRate);
if median(diff(tr)) ~= trDurSampl,
    error(['The timing of the TR events is not consistent with ' ...
        'TR=%1.3f secs'], trDur);
end

% Boundaries between slices
slice = round(linspace(0, trDurSampl, nbSlices+1));%trDurSampl-1
slice = slice(2:end);

tr(tr <= max(slice)) = [];


% Starting points of all slices
sliceBegin = repmat(tr, 1, numel(slice)) - repmat(slice, numel(tr), 1);
sliceBegin = fliplr(sliceBegin);

% Slice durations for each slice
sliceDur = fliplr(diff([0 slice]));
sliceDur = repmat(sliceDur, size(sliceBegin,1),1);
sliceDur(1:end-1,end) = sliceBegin(2:end,1)-sliceBegin(1:end-1,end);

% We need this just in case the scanning was not continuous
sliceDur(sliceDur > median(sliceDur(:)) + 10*mad(sliceDur(:))) = ...
    median(sliceDur(:));

% Post-processing filter
myFilter = filter.lpfilt('fc', lpf/(data.SamplingRate/2));
myFilter = set_verbose(myFilter, false);

% Loop across channels
tinit1 = tic;
%boundaryDiscard = ceil(0.1*mean(sliceDur));
sensLabels = labels(sensors(data));
origData = data;

for i = 1:size(origData,1)
    if verbose,
        fprintf([verboseLabel 'Processing channel %d/%d (%s)...\n\n'], ...
            i, size(origData,1), sensLabels{i});
    end
    % Pre-load the channel into memory, which may speed up computations
    data = origData(i,:);
    this = zeros(max(sliceDur(:)), numel(sliceBegin));
    count = 1;
    if verbose,
        fprintf([verboseLabel, 'Extracting slice artifacts...']);
    end
    tinit2 = tic;
    jby100 = floor(size(sliceBegin,1)/101);
    for j = 1:size(sliceBegin, 1)
        for k = 1:size(sliceBegin, 2)
            m = mean(data(1, sliceBegin(j, k):sliceBegin(j,k)+sliceDur(j,k)-1));
            data(1, sliceBegin(j, k):sliceBegin(j,k)+sliceDur(j,k)-1) = ...
                data(1, sliceBegin(j, k):sliceBegin(j,k)+sliceDur(j,k)-1) - m;
            this(1:sliceDur(j,k), count) = ...
                data(1, sliceBegin(j, k):sliceBegin(j,k)+sliceDur(j,k)-1);
            count = count + 1;
        end
        if ~mod(j, jby100) && verbose,
            eta(tinit2, size(sliceBegin,1), j);
        end
    end   
    % Careful with NaNs/Infs here
    this = this./repmat(sqrt(var(this)), size(this,1), 1);
    this(:, any(isnan(this)) | any(isinf(this))) = 0;
    if verbose, 
        fprintf('\n\n'); 
        clear +misc/eta;
    end
    
    if verbose,
        fprintf([verboseLabel, ...
            'Estimating MR artifact using nearest neighbors...']);
    end
    tinit3 = tic;
    jby100 = floor(size(this,2)/101);
    newThis = zeros(size(this));
  
    j = 1;
    isMissing = false(1, size(data,2));
    for m = 1:size(sliceBegin, 1)
        for k = 1:size(sliceBegin, 2)        
           
            % Find the NN nearest neighbors
            notThisIdx = [max(1, j-win(1)):j-1 j+1:min(size(this,2), j+win(2))];
            
            if ~any(this(:,j)>eps),
                j = j+1;
                continue;
            end
       
            p = this(:, j)'*this(:, notThisIdx);
            [~, idx] = sort(abs(p), 'descend');
            
            idx = notThisIdx(idx(1:nn));
            M = this(:, idx);
            
            try
                Mb = templf(M);
            catch ME
                % Just in case ...
                if strcmp(ME.identifier, 'MATLAB:eig:matrixWithNaNInf'),
                    Mb = templf(M(:, ~any(isnan(M) | isinf(M))));
                else
                    rethrow(ME);
                end
            end           
           
            thisSlice = sliceBegin(m, k):sliceBegin(m,k)+sliceDur(m,k)-1;
            oldData   = data(1, thisSlice);
            oldData   = oldData - mean(oldData);

            thisMb = Mb(1:sliceDur(m,k), :);
            thisMb = thisMb(:, ~any(isnan(thisMb)) & ~any(isinf(thisMb)));
            
            if isempty(thisMb),
                warning('mra:NaNOrInf', ...
                    'Something is wrong with channel %d at TR %d', ...
                    i, m);
                continue;
            end               
            
            b = pinv(thisMb)*oldData'; 
            
            newData = oldData - (thisMb*b)';
         
            th = median(newData) + 10*mad(newData);
            isTooLarge = abs(newData) > th | abs(newData) > 500;
        
            % Kind of weak this thing but
            newData(isTooLarge) = 0; 
            
            isMissing(thisSlice(isTooLarge)) = true;            

            data(1, thisSlice) = newData;
            
            if ~mod(j, jby100) && verbose,
                eta(tinit3, size(newThis,2), j);
            end
            j = j + 1;
            
        end
    end
    if verbose,
        fprintf('\n\n');
        clear +misc/eta;
    end
       
    % Post-process
    if verbose,
        fprintf([verboseLabel 'Post-processing channel %d/%d (%s)...'], ...
            i, size(origData,1), sensLabels{i});
    end
    data(1, 1:sliceBegin(1)-1) = 0;
    data(1, sliceBegin(end)+sliceDur(end):end) = 0;
    
    % Interpolate missing values
    sampl = 1:numel(data);
    data(isMissing) = interp1(sampl(~isMissing), data(~isMissing), ...
        sampl(isMissing));
    
    data(1, :) = medfilt1(data(1,:), 4);
    data(1, :) = filtfilt(myFilter, data(1,:));
    if verbose, fprintf('\n\n'); end

    origData(i, :) = data;
    
    if verbose,
        fprintf([verboseLabel ...
            'Finished processing channel %d/%d (%s)...'], ...
            i, size(origData,1), sensLabels{i});
        eta(tinit1, size(origData,1), i, 'RemainTime', true);
        fprintf('\n\n\n');
        clear +misc/eta;
    end
    
end


end