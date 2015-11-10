function yTicks = get_sensor_labels(obj, idx)

yTicks = yticks_as_cell(obj.Axes);

if nargin < 2 || isempty(idx),
    idx = 1:numel(yTicks);
end

%% Ensure that idx is a numeric array of indices
if iscell(idx),    
    [~, idx] = ismember(idx, yTicks);
elseif ischar(idx),   
    [~, idx] = ismember(idx, yTicks);
elseif isnumeric(idx),
    % do nothing
else
   error(['The IDX argument must be a numeric index, a string ' ...
       '(a channel label), or a cell array of channel labels']); 
end

%% Pick the relevant ticks
yTicks = yTicks(idx);

if numel(yTicks) == 1,
    yTicks = yTicks{1};
end


end



function yTicks = yticks_as_cell(aH)

import misc.strtrim;

%% Put the YTicks as a cell array
tmpTicks = get(aH, 'YTickLabel');
yTicks   = cell(size(tmpTicks,1)-1, 1);

% First tick is meaningless
for i = 2:size(tmpTicks,1)
   thisTick = tmpTicks(i,:);
   if iscell(thisTick), thisTick = thisTick{1}; end
   this = strtrim(thisTick);   
   yTicks{size(tmpTicks,1)-i+1} = this;
end

end