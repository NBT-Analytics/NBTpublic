function value = get_line_color(obj, idx)

if nargin < 2, idx = []; end

if isempty(obj.Line), 
    value = [];
    return; 
end

if isempty(idx), idx = 1:numel(obj.Line{1}); end

if isempty(idx), return; end

% Deal with multiple selections using recursion
if numel(obj.Selection) > 1,
    selection = obj.Selection;
    deselect(obj, []);    
    value = cell(numel(selection), 1);
    for i = 1:numel(selection),
        select(obj, selection(i));
        value{i} = get_line_color(obj, idx);
    end
    select(obj, selection);
    return;
end

if islogical(idx), idx = find(idx); end

value = nan(numel(idx), 3);
for i = 1:numel(idx)
   value(i,:) = get(obj.Line{obj.Selection}(idx(i)), 'Color'); 
end

end