function obj = set_line_color(obj, idx, color)

% Deal with multiple selections using recursion
if numel(obj.Selection) > 1,
    selection = obj.Selection;
    deselect(obj, []);
    for i = 1:numel(selection),
        select(obj, selection(i));
        obj = set_line_color(obj, idx, color);
    end
    select(obj, selection);
    return;
end

if nargin < 2, idx = []; end

if isempty(idx), idx = 1:numel(obj.Line{obj.Selection}); end

if isempty(idx), return; end

if isempty(color), return; end

if size(color,2) ~= 3,
    error('The COLOR argument must have three columns (R, G, B components)');
end

if size(color, 1) == 1 && numel(idx) > 1,
    color = repmat(color, numel(idx), 1);
elseif size(color, 1) ~= numel(idx),
    error('Number of plot indices does not match the number of provided colors');
end

if islogical(idx), idx = find(idx); end

for i = 1:numel(idx)
   set_line(obj, idx(i), 'Color', color(i,:));    
end


end