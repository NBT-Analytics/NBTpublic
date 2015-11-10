function maxtab = peak_find(x, varargin)
% PEAK_FIND - A simple (but fast) function to find local maxima

import misc.process_varargin;
import misc.peakdet;
THIS_OPTIONS = {'delta', 'meandist', 'madth','type'};

delta = 2;
madth = 0.1;
meandist = [];
type = 'both';

eval(process_varargin(THIS_OPTIONS, varargin));

maxtab = [];
while isempty(maxtab),
    [maxtab, mintab] = peakdet(x, delta);
    
    if strcmpi(type, 'both'),
        maxtab = [maxtab;mintab];
    elseif strcmpi(type, 'min'),
        maxtab = mintab;
    end
    delta = .9*delta;
    
end


[~, idx] = sort(maxtab(:,1),'ascend');
maxtab = maxtab(idx, :);

% Remove extrema until the inter-extrema distances are the expected ones 
if ~isempty(meandist)  
    factor = madth; 
    distances = diff(sort(maxtab(:,1),'ascend'));        
    while  median(distances) > meandist*(1+madth) || ...
            median(distances) < meandist*(1-madth)
        
        % remove local maxima that are too close each other
        [~, idx] = sort(maxtab(:,2), 'descend'); 
        mindist = factor*meandist;
        val = maxtab(idx,1);
        
        i = 1;
        while i < length(idx)
            this_idx = setdiff(1:length(idx), i);
            remove_idx = this_idx(abs(val(this_idx) - val(i))<=mindist);
            val(remove_idx) = [];
            idx(remove_idx) = [];
            i = i + 1;
        end
        maxtab = maxtab(idx,:);   
        
        factor = sqrt(factor);
        distances = diff(sort(maxtab(:,1),'ascend'));        
    end
    % Find the longest continuous train of equidistant extrema
    distances = [meandist;distances];
    idx = find(distances > meandist*(1+madth) | ...
        distances < meandist*(1-madth));
    train_duration = [1;diff(idx)];
    [~, idx_max] = max(train_duration);
    if idx_max>1,
        first = idx(idx_max-1)+1;
    else
        first = idx(1)+1; 
    end
    if length(idx) >= idx_max,  
        last = max(1,idx(idx_max)-1);
    else
        last = size(maxtab,1);
    end
    idx = last+1;
    remove_flag = false(size(maxtab,1),1);
    while idx <= size(maxtab,1)
        if maxtab(idx,1) - maxtab(last,1) <  meandist*(1-madth),
            maxtab(idx,:) = [];
        else
            last = idx;
            idx = idx+1;
        end        
    end
    idx = first-1;
    while idx >= 1
        if maxtab(first,1)-maxtab(idx,1) <  meandist*(1-madth),
            maxtab(idx,:) = [];
        else
            first = idx;
            idx = idx-1;
        end
       
    end
    %maxtab(remove_flag,:) = []; 
        
    
end