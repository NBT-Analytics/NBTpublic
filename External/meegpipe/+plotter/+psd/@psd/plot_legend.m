function plot_legend(obj, ~, ~)

confint = get_config(obj, 'ConfIntLegend');

legItemText   = [];
legItemHandle = [];
for i = 1:size(obj.Line,1)
    if strcmpi(get_line(obj, i, 'Visible'), 'off'), continue; end
    
    legItemHandle = [legItemHandle; obj.Line{i, 1}];
    legItemText   = [legItemText; obj.Name(i,1)];
    
    if confint && ~isempty(obj.Line{i, 2}) && ...
            strcmpi(get_shadow(obj, i, 'Visible'), 'on') %#ok<*AGROW>
        legItemHandle = [legItemHandle; obj.Line{i, 2}];
        legItemText = [legItemText; obj.Name(i,2)];
    end
end

if ~isempty(obj.Legend),
    tmp = obj.Legend;
    delete(tmp);
end

% Legend properties
args = {};
if ~isempty(obj.LegendProps),
    propNames = fieldnames(obj.LegendProps);
    propVals  = struct2cell(obj.LegendProps);
    args = [propNames(:) propVals(:)]';
    args = args(:);
end

if ~isempty(legItemHandle)
    obj.Legend = legend(legItemHandle, legItemText, args{:});
else
    obj.Legend      = [];
end

% Some properties still need to be re-applied
idx = find(ismember(lower(args(1:2:end)),'visible'));
if ~isempty(idx),
    idx = idx(end);
    set(obj.Legend, 'Visible', args{idx*2});
end


end