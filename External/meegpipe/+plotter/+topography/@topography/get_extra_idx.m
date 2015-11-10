function idx = get_extra_idx(obj, label)

idx = find(ismember(obj.Extra(:,2), label));

end