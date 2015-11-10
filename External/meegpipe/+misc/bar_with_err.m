function bar_with_err(error, varargin)

import external.barwitherr.barwitherr;

FONTSIZE = 20;

barwitherr(error, varargin{:});
hAxes = gca;
hFig  = gcf;

% Modify axes properties
set(hAxes, ...
    'Color',     'Black', ...
    'XColor',    'White', ...
    'YColor',    'White', ...
    'ZColor',    'White', ...
    'Box',       'off', ...
    'FontSize',  FONTSIZE, ...
    'LineWidth',   2, ...
    'FontWeight','Demi', ...
    'TickDir',   'out');

children = get(hAxes, 'Children');
for i = 1:numel(children)
    props = get(children(i));
    if isfield(props, 'EdgeColor'),
        set(children(i), 'EdgeColor', 'none');
    end
    if isfield(props, 'Color'),
        set(children(i), 'Color', 'White');
    end
    if isfield(props, 'LineWidth'),
        set(children(i), 'LineWidth', 3);
    end
    if isfield(props, 'Marker'),
        set(children(i), 'Marker', 'none');
    end
    if isfield(props, 'ShowBaseLine'),
        set(children(i), 'ShowBaseLine', 'off');
    end
    if isfield(props, 'Children')
        subChildren = get(children(i), 'Children');
        for j = 1:numel(subChildren)
            subProps = get(subChildren(j));
            if isfield(subProps, 'EdgeColor'),
                set(subChildren(j), 'EdgeColor', 'none');
            end
            if isfield(subProps, 'ShowBaseLine'),
                set(subChildren(j), 'ShowBaseLine', false);
            end

        end
    end
end

set(hAxes, 'Box', 'on');
set(hAxes, 'FontSize', FONTSIZE);
% Modify figure properties
set(hFig, ...
    'Color',            'Black', ...
    'InvertHardCopy',   'off');

box off;

end