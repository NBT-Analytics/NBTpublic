function ref = get_ref(obj, idx)

if nargin < 2 || isempty(idx),
    idx = 1:nb_figures(obj);
end

if numel(idx) > 1,
    ref = cell(numel(idx),1);
    for i = 1:numel(idx),
        ref{i} = get_ref(obj, idx(i));
    end
    return;
    
end

ref = obj.Files{idx};
ref = regexprep(ref, '\s+', '-');
ref = regexprep(ref, '[/\\:.]', '_');

end