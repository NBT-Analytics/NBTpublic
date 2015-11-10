function idx = resolve_idx(h, idx)

import plotter.psd.psd;

if isempty(idx), idx = 1:size(h.Name,1); end

if ischar(idx),
    idx = {idx};
end

if iscell(idx),
    newIdx = find(ismember(h.Name(:,1), idx));
    if numel(newIdx) ~= numel(idx),
        msg = sprintf('Invalid PSD indices: %s', ...
            num2str(setdiff(newIdx, idx)));
        throw(psd.InvalidPSDIndex(msg));
    end
    idx = newIdx;
end

validIndices = 1:size(h.Line,1);
if ~all(ismember(idx, validIndices)),
    msg = sprintf('Invalid PSD indices: %s', ...
        num2str(setdiff(idx, validIndices)));
    throw(psd.InvalidPSDIndex(msg));
end

end