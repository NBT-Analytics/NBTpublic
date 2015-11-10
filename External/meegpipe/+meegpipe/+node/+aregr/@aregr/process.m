function [data, dataNew] = process(obj, data, varargin)


import misc.eta;
import goo.globals;
import misc.signal2hankel;

dataNew = [];

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

%% Configuration options
filtObj         = get_config(obj, 'Filter');
chopSel         = get_config(obj, 'ChopSelector');
expandBoundary  = get_config(obj, 'ExpandBoundary');
regSel          = get_config(obj, 'Regressor');
measSel         = get_config(obj, 'Measurement');

if isempty(regSel),
    warning('regression:NoRegressors', ...
        'No regressors were selected: nothing done!');
    return;
end

%% Find chop boundaries
if ~isempty(chopSel),
    chopEvents = select(chopSel, get_event(data));
  
    if ~isempty(chopEvents),
        evSample = get(chopEvents, 'Sample');
        evDur    = get(chopEvents, 'Duration');
    end
else
    evSample = 1;
    evDur    = size(data,2);
end

%% Filter + PCA + chopping
select(regSel, data);
regressors = subset(data, 1:size(data,1));

restore_selection(data);

% Use the PCs of the data (to further speed up things)
if ~isempty(measSel),
    select(measSel, data);
end

%% Regress-out every regressor from every channel
if isa(filtObj, 'function_handle'),
    filtObj = filtObj(data.SamplingRate);
end

if verbose,
    tinit = tic;
    clear +misc/eta;
    fprintf([verboseLabel 'Applying %d regressors on %d signals...\n\n'], ...
        size(regressors,1), size(data,1));
end

for segItr = 1:numel(evSample)
    
    if verbose,
        
        fprintf( [verboseLabel ...
            'Filtering epoch %d/%d...'], ...
            segItr, numel(evSample));
        
    end
    
    first = evSample(segItr);
    last  = evSample(segItr)+evDur(segItr)-1;
    
    segLength = last - first + 1;
    
    if expandBoundary,
       
        leftExpand = ceil(0.02*segLength);
        
        if first < leftExpand,
            leftExpand = first - 1;
        end
        
        rightExpand = ceil(0.02*segLength);
        
        if last + rightExpand > size(data,2),
            rightExpand = size(data,2)-last;
        end
        
    else
        
        leftExpand  = 0;
        rightExpand = 0;
        
    end
    
    select(data, [], first-leftExpand:last+rightExpand);
    
    for i = 1:nb_dim(data)
        
        tmp = filter(filtObj, data(i,:), regressors);
        
        data(i, leftExpand+1:end-rightExpand) = ...
            tmp(leftExpand+1:end-rightExpand);
        
        if verbose,
            eta(tinit, size(data,1), i);
        end
        
    end % End of signal iterator
    
    restore_selection(data);
    
    if verbose,
   
      
        fprintf( ['\n\n' verboseLabel, ...
            'done aregr-filtering epoch %d/%d...'], segItr, ...
            numel(evSample));
        
        eta(tinit, numel(evSample), segItr, 'remaintime', true);
        
        fprintf('\n\n');
        
    end
   
end

if ~isempty(measSel),
    restore_selection(data);
end

end