function chOut = get_ch_handles(graphObj)

import plotter.get_ch_handles;

ch = get(graphObj, 'Children');

if isempty(ch),
    chOut = [];
    return;
end

% For some reason MATLAB under Linux returns in ch all children, including
% those whose HandleVisibility property is set to off (mostly UI elements).
% We need to get rid of those to ensure a consistent behavior between Linux
% and Windows. Is this a MATLAB bug?
hVisibility = get(ch, 'HandleVisibility');
ch(~ismember(hVisibility, 'on')) = [];

chOut = ch;
for i = 1:numel(ch)    
   chOut = [chOut; get_ch_handles(ch(i))]; %#ok<AGROW>
end


end