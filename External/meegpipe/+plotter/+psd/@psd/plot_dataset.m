function hF = plot_dataset(hF, data, sr, estimator, windows, varargin)


if ~iscell(data), data = {data}; end

if nargin < 5 || isempty(windows),
    % Use a single analysis window
    windows = [1 size(data,2)];
end

winLength = diff(windows, 1, 2) + 1;

% Define the set of selected time instants
pntIdx = 1:size(data{1}, 2);
pntSel = false(1, size(data{1},2));
for i = 1:size(windows,1)
    pntSel(pntIdx >= windows(i,1) & pntIdx <= windows(i,2)) = true;
end

for i = 1:numel(data),
    data{i} = data{i}(:, pntSel);
    
    data{i}    = data{i} - repmat(mean(data{i}, 2), 1, size(data{i},2));
    
    % We can do this because the windows CAN'T overlap and MUST be sorted
    data{i}    = mat2cell(data{i}, ones(size(data{i},1),1), winLength);
end


if ~isempty(regexpi(class(estimator), '^spectrum2.')),
    
    hpsd = cell(1, numel(data));
    for i = 1:numel(data),
        warning('off', 'spectrum2:minmax:IgnoredChannel');
       
        hpsd{i} = psd(estimator, data{i}{:}, ...
            'Fs',   sr, ...
            'NFFT', min(2^(floor(log2(5*sr))), 3*1024), ...
            varargin{:}); %#ok<*FDEPR>     
       
        warning('on', 'spectrum2:minmax:IgnoredChannel');
    end
    hpsd = hpsd(cellfun(@(x) ~isempty(x), hpsd));
    
    if isempty(hpsd),
        return;
    end
        
    hF = plot(hF, hpsd{:});
    
    if numel(hpsd) > 1,  
        
       psdName =  arrayfun(@(x) sprintf('PSD%d, %d signal(s), %d window(s)', ...
            x, size(data{i},1), size(data{i},2)), 1:10, ...
            'UniformOutput', false);        
       
    else
        
       psdName = sprintf('PSD, %d signal(s), %d window(s)', ...
            size(data{i},1), size(data{i},2));        
        
    end
    
    set_psdname(hF, [], psdName);

elseif ~isempty(regexpi(class(estimator), '^spectrum.')),
    
    dataCount = 0;
    for j = 1:numel(data)
        
        hpsd    = cell(numel(data{j}),1);
        count   = 0;
        for i = 1:numel(data{j})
            thisVar = var(data{j}{i}, [], 2);
            if thisVar < eps,
                fprintf('\n');
                warning('make_psd_lot:IgnoredChannel', ...
                    ['Variance of signal %d is below eps. ' ...
                    'It will be ignored'], i)
                continue;
            end
            count = count + 1;
            hpsd{count} = psd(estimator, data{j}{i}, ...
                'Fs',   sr, ...
                'NFFT', min(2^(floor(log2(5*sr))), 3*1024), ...
                varargin{:}); %#ok<*FDEPR>
        end
        hpsd(count+1:end) = [];
        if isempty(hpsd), hF = []; return; end
        hF = plot(hF, hpsd{:});
        psdNames = mat2cell(num2str((1:numel(data{j}))'), ones(numel(data{j}),1));
        psdNames = cellfun(@(x) ['Signal ' x], psdNames, 'UniformOutput', false);
        set_psdname(hF, dataCount + 1:numel(data{j}), psdNames);
        dataCount = dataCount + numel(data{j});
        
    end
   
else
    error('Argument ESTIMATOR must be of class spectrum?\..+');
end
set_line(hF, [], 'LineWidth', 2);

end