function H = mdfilt(obj)
% MDFILT - Conversion to MATLAB's dfilt.?? class
%

if ~isempty(obj.MDFilt),
    H = obj.MDFilt;
    return;
end

if isempty(obj.LpFilter),
    H = [];
    return;
end

H = cell(1, numel(obj.LpFilter));
for bandItr = 1:numel(obj.LpFilter)
   H{bandItr} = parallel(...
       mdfilt(obj.LpFilter{bandItr}), ...
       mdfilt(obj.HpFilter{bandItr}));   
end

H = cascade(H{:});

end