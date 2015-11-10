function figh = attach_figure(obj, figh)

visible = meegpipe.node.globals.get.VisibleFigures;

if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

if nargin < 2 || isempty(figh),
    figh = figure('Visible', visibleStr, 'Name', get_hash_code(obj));
end


end