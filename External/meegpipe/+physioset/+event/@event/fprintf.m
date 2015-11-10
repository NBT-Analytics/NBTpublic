function count = fprintf(fid, ev, varargin)

import misc.process_arguments;
import mperl.join;

if isempty(ev),
    count = 0;
    return;
end

opt.SummaryOnly = false;
opt.AsTable     = true;
[~, opt] = process_arguments(opt, varargin);

count = 0;

if opt.SummaryOnly,

    uTypes = unique(ev);
    if ~iscell(uTypes),
        uTypes = {uTypes};
    end
    count = count +  fprintf(fid, '%d events of %d type(s)\n\n', ...
        numel(ev), numel(uTypes));
    
    if numel(uTypes) < 20,
        count = count + fprintf(fid, '%-40s|%-20s\n', ...
            'Event Type', '# events');
        str = repmat('-', 1, 50);
        count = count + fprintf(fid, '%40s|%20s\n', str, str);
        for i = 1:numel(uTypes)
            nbEv = numel(select(ev, 'Type', uTypes{i}));
            
            count = count + ...
                fprintf(fid, '%40s|%20d\n', uTypes{i}, nbEv);
        end
        fprintf(fid, '\n\n');
    end
    
elseif opt.AsTable,
    % We need to find out all the column names. Since events may have
    % non-standard meta-properties, we need to go through all of them first
    stdNames  = fieldnames(ev(1));
    metaNames = {};
    for i = 1:numel(ev)
        metaNames = union(metaNames, fieldnames(get_meta(ev(i))));
    end
    allColNames = [stdNames(:);metaNames(:)];
    count = count + fprintf(fid, '%s\n', join(',', allColNames));
    for i = 1:numel(ev)
        stdVals = get(ev(i), stdNames{:});
        stdVals = cellfun(@(x) misc.any2str(x, 100, true), stdVals, ...
            'UniformOutput', false);
        count = count + fprintf(fid, '%s', join(',', stdVals));
        if isempty(metaNames),
            fprintf(fid, '\n');
            continue;
        elseif numel(metaNames) < 2,
            metaVals = {get_meta(ev(i), metaNames{1})};
        else
            metaVals = get_meta(ev(i), metaNames{:});
        end        
        metaVals = cellfun(@(x) misc.any2str(x, 100, true), metaVals, ...
            'UniformOutput', false);
        count = count + fprintf(fid, ',%s\n', join(',', metaVals));
    end
else
    for i = 1:numel(ev)
        
        str = event2str(ev(i));
        count = count + fprintf(fid, str);
        count = count + fprintf(fid, '\n');
        
    end
end


end