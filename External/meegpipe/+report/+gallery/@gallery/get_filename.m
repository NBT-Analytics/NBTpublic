function fileName = get_filename(obj, idx)

if nargin < 2 || isempty(idx),
    idx = 1:nb_figures(obj);
end

if numel(idx) > 1, 
    fileName = obj.Files(idx);
else
    fileName = obj.Files{idx};
end

end