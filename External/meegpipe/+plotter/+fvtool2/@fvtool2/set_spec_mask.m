function h = set_spec_mask(h, varargin)
 
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
        
        thisLines = findall(figH(idx(i)), ...
            'Type',         'Line', ...
            'Tag',          'specification_mask', ...
            '-regexp',  ...
            'DisplayName',  lineIdx);
       
    else
        thisLines = findall(figH(idx(i)), ...           
            'Tag',      'specification_mask');
        
    end
    
    if isempty(thisLines), continue; end
    
    if isempty(lineIdx) || ischar(lineIdx),
        set(thisLines, varargin{:});
    else
        set(thisLines(lineIdx), varargin{:});
    end
    
end

end