function h = set_line(h, varargin)
% SET_LINE - Set filter line properties
%
% % Set all filter lines to red color
% set_line(h, 'Color', 'Red');
%
% % Set only the second line in each figure to blue color
% set_line(h, 2, 'Color', 'Blue');
%
% % Set to black color only the lines whose tag names match the regular
% % expressions 'phasez_' and 'magnitude_'
% set_line(h, {'phasez_', 'magnitude'}, 'Color', 'Black');
%
% See also: fvtool2

% Description: Set filter line properties
% Documentation: class_plotter_fvtool2_fvtool2.txt

import mperl.join;

% Figure selection
idx  = h.Selection;
figH = h.FvtoolHandle;

if isnumeric(varargin{1}) || iscell(varargin{1}),
    lineIdx = varargin{1};
    varargin = varargin(2:end);
else
    lineIdx = [];
end

if iscell(lineIdx), lineIdx = ['(' join('|', lineIdx) ')']; end

for i = 1:numel(idx)
    
    if ischar(lineIdx),       
        
        % Match lines with a matching DisplayName
        thisLines = findall(figH(idx(i)), ...
            'Type',         'Line', ...
            '-regexp', ...
            'DisplayName',  lineIdx);
        
        % And match also those with a matching Tag
        thisLines = [thisLines(:); ...
            findall(figH(idx(i)), ...
            'Type',     'Line', ...
            '-regexp', ...
            'Tag',      lineIdx)];
    else
        
        % We need the Tag rule to ensure that we pick only the main plot
        % lines and not any lines from the legend
        thisLines = findall(figH(idx(i)), ...
            'Type',     'Line', ...
            '-regexp',  'Tag', '_line');              
        
    end
    
    if isempty(thisLines), continue; end
    
    thisLines = sort(thisLines);
    
    if isempty(lineIdx) || ischar(lineIdx),
        set(thisLines, varargin{:});
    else
        set(thisLines(lineIdx), varargin{:});
    end
    
end


end