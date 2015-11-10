function set_boi(obj, ~, ~)


if isempty(obj.Data),
    return;
end

boi             = get_config(obj, 'BOI');
isTransparent   = get_config(obj, 'Transparent');

if isempty(boi),
   return;
end

boiBands = sort(boi, @(x) x{1}(1));

% Calculate energy ratios in each band
ratios = band_power_ratio(obj);

yLim = get(obj.Axes, 'YLim');
yMin = yLim(1);
yMax = yLim(2);

bandColors = repmat([0.4 0.4 0.4; 0.1 0.1 0.1], ceil(numel(boiBands)/2), 1);

% Remove existing patches
h = findobj(obj.Axes, 'Tag', 'boi_patch');
if ~isempty(h), delete(h); end

h = findobj(obj.Axes, 'Tag', 'boi_line');
if ~isempty(h), delete(h); end

h = findobj(obj.Axes, 'Tag', 'boi_label');
if ~isempty(h), delete(h); end


for i = 1:numel(boiBands)
    
    thisBand = boi(boiBands{i});   
    if iscell(thisBand),
        thisBand = thisBand{1};
        if numel(thisBand) == 2,
            % MATLAB bug storing cells of vectors in a Hash Table
            thisBand = thisBand';
        else
            thisBand = thisBand{1}(1,:);
        end
    end
    thisRatio = ratios(boiBands{i});
    
    X = [thisBand(1) thisBand(2) thisBand(2) thisBand(1)];
    Y = [yMin, yMin, yMax, yMax];
    
    
    if isTransparent,
        
       hP = patch(X, Y, bandColors(i,:), 'EdgeColor', 'none', ...
        'Tag', 'boi_patch'); 
       set(hP, 'FaceAlpha', 0.3);       
  
    end
    
    hl(1) = line([thisBand(1) thisBand(1)], ...
        [yLim(1) yLim(2)]);
    
    hl(2) = line([thisBand(2) thisBand(2)], ...
        [yLim(1) yLim(2)]);
    
    set(hl, 'Color', 'm', 'LineStyle', '-', 'Tag', 'boi_line', ...
        'LineWidth', 1.25);
    
    uistack(hl, 'bottom');
    
    y = yMin + diff(yLim)*0.1;
    x = thisBand(1) + diff(thisBand)/2;
    
    if ismember(boiBands{i}, {'alpha', 'beta', 'gamma', 'theta', ...
            'beta', 'delta'}),
        hT = text(x, y, ['\' boiBands{i}]);
    else
         hT = text(x, y, boiBands{i});
    end
    
    set(hT, ...
        'FontWeight',   'bold',  ...
        'Rotation',     90, ...
        'FontSize',     16, ...
        'Tag',          'boi_label');
    
    
    str = sprintf('%2.0f%%', round(thisRatio(1)*100));
    y = yMin + diff(yLim)*0.5;
    text(x, y, str, ...
        'Rotation',     90, ...
        'FontSize',     10, ...
        'Tag',          'boi_label', ...
        'Color',        get_line(obj, 1, 'Color'), ...
        'FontWeight',   'Bold');
  
    
    for j = 2:numel(thisRatio)
        y = y + 0.1*diff(yLim);
        str = sprintf('%2.0f%%', round(thisRatio(j)*100));
        text(x, y, str, ...
            'Rotation',     90, ...
            'FontSize',     10, ...
            'Tag',          'boi_label', ...
            'Color',        get_line(obj, j, 'Color'));
    end
    
    
end



end