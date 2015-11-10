function set_transparency(obj, ~, ~)

% This function is just a copy of shadedErrorBar, by Rob Campbell, which is
% available at MATLAB central

transp          = get_config(obj, 'Transparent');
patchSaturation = get_config(obj, 'PatchSaturation');

% For some reason we need to hide the legend before changing patch
% properties or the legend sometimes ends messed up. No idea why this is
% happening but might be due to a MATLAB bug (R2010a)
if strcmpi(get_legend(obj, 'Visible'), 'on'),
    mustSetOn = true;
    set_legend(obj, 'Visible', 'off');
else
    mustSetOn = false;
end
for i = 1:size(obj.Line,1)
    if isempty(obj.Line{i, 2}), continue; end
    col             = get(obj.Line{i,1}, 'Color');
    edgeColor       = col+(1-col)*0.55;
    if transp,
        faceAlpha  = patchSaturation;
        patchColor = col;
        set(gcf, 'renderer', 'openGL');
    else
        faceAlpha=1;
        patchColor=col+(1-col)*(1-patchSaturation);
        set(gcf,'renderer','painters')
    end
    
    if isempty(obj.Line{i,2}), continue; end
    
    set(obj.Line{i, 2}, ...
        'FaceColor', patchColor, ...
        'EdgeColor', 'none', ...
        'FaceAlpha', faceAlpha);
    
    % Put the patch below the main lines
    parent      = get(obj.Line{i, 2}, 'Parent');
    children    = get(parent, 'Children');
    isPatch     = (children == obj.Line{i,2});
    childrenNew = children;
    childrenNew(isPatch) = [];
    childrenNew = [childrenNew(:);children(isPatch)];
    set(parent, 'Children', childrenNew);
    
    %Make nice edges around the patch.
    set(obj.Line{i, 3}(1), 'LineStyle', '-', 'Color', edgeColor);
    set(obj.Line{i, 3}(2), 'LineStyle', '-','color', edgeColor);
end

if mustSetOn,
    set_legend(obj, 'Visible', 'on');
end

% Remake the BOIs 
set_boi(obj);

end



