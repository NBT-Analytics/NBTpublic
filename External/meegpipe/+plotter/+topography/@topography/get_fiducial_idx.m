function idx = get_fiducial_idx(obj, label)

idx = find(ismember(obj.Fiducials(:,2), label));

end