function chanType = parse_channel_types(chanType)

if ischar(chanType),
    chanType = {chanType};
end

DICT = {...
    'ecg', 'physiology'; ...
    'eog', 'eeg'; ...
    'meg', 'meg'; ...
    '.*',  'unknown' ...
    };

for i = 1:numel(chanType)   
   for j = 1:size(DICT,1)
      
       if ~isempty(regexp(chanType{i}, DICT{j,1}, 'once')),
           chanType{i} = DICT{j,2};
           break;
       end
       
   end
    
end



end