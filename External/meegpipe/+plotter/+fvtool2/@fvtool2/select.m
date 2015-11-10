function h = select(h, idx)

if nargin < 1 || isempty(idx),
    idx = 1:nb_plots(h);
end

h.Selection = idx;

end