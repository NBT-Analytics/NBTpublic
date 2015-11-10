function y = valid_label(x)

import io.edfplus.is_valid_label;

if ~iscell(x),
    x = {x};
end

isValid = is_valid_label(x);

if any(~isValid),   
    
    uTypes = unique(x(~isValid));
    
    for i = 1:numel(uTypes),
        notValidIdx = find(ismember(x, uTypes{i}));
        
        if numel(notValidIdx) < 2,
            x{notValidIdx} = force_valid(x{notValidIdx});
        else
            tmp = force_valid(x{notValidIdx(1)});
            for j = 1:numel(notValidIdx)
               x{notValidIdx(j)} = [tmp ' ' num2str(j)];
            end
        end
     
    end
  
end

y = x;


end


function y = force_valid(x)

expr = '(?<type>.+)[.]*\s+(?<spec>\w+)$';

type = '';
spec = '';

match = regexp(x, expr, 'names');
if iscell(match), match = match{1}; end
if ~isempty(match)
    type = match.type;
    spec = match.spec;
else
    expr = '(?<type>.+)[.]*-(?<spec>\w+)$';
    match = regexp(x, expr, 'names');
    if iscell(match), match = match{1}; end
    if ~isempty(match)
        type = match.type;
        spec = match.spec;
    end
end

if isempty(type),
    type = x;
end

if ~isempty(regexpi(type, '^resp', 'once')),
    type = 'Resp';    
elseif ~isempty(regexpi(type, '^temp', 'once')),
    type = 'Temp';    
elseif ~isempty(regexpi(type, '^emg', 'once')),
    type = 'EMG';
elseif ~isempty(regexpi(type, '^pos', 'once')),
    type = 'Pos';
elseif strcmpi(x, 'body position'),
    type = 'Pos';
    spec = 'Body';
elseif strcmpi(x, 'unknown'),
    type = x;
else
    spec = type;
    type = 'Unknown';    
end

if isempty(spec),
    y = type;   
else
    y = [type ' ' spec];
end


end