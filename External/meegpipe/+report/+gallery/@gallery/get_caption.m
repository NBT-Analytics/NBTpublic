function fileName = get_caption(obj, idx)

if nargin < 2 || isempty(idx),
    idx = 1:nb_figures(obj);
end

if numel(idx) > 1, 
    fileName = obj.Captions(idx);
else
    fileName = obj.Captions{idx};
end

end