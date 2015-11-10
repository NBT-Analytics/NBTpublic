function obj = set_matchscale(obj, ~, ~)


if numel(obj.Data) < 2,
    return;
end

matchScale = get_config(obj, 'MatchScale');

if isempty(matchScale),
    return;
else
    band = matchScale;
end

freq = obj.Data(1).Frequencies;

data = [];
for bandItr = 1:size(band,1)
    idx = find(freq > band(bandItr,1) & freq < band(bandItr,2));
    thisData = nan(numel(obj.Data)-1, numel(idx));
    for i = 1:size(obj.Line,1)
        yData = get(obj.Line{i,1}, 'YData');    
        thisData(i, :) = yData(idx);     
    end
    data = [data thisData]; %#ok<AGROW>
end

for i = 2:numel(obj.Data)
    factor = data(1, :)/data(i,:);
    yData = get(obj.Line{i,1}, 'YData');    
    set(obj.Line{i,1}, 'YData', yData*factor);
    % Take care also of the patch and egdes, if any
    if ~isempty(obj.Line{i,2}),
        yData = get(obj.Line{i,2}, 'YData');        
        xData = get(obj.Line{i,2}, 'XData');
        delete(obj.Line{i,2});
        obj.Line{i,2} = patch(xData, yData*factor,1); 
        yData = get(obj.Line{i,3}(1), 'YData');
        set(obj.Line{i,3}(1), 'YData', yData*factor);
        yData = get(obj.Line{i,3}(2), 'YData');
        set(obj.Line{i,3}(2), 'YData', yData*factor);
        set_transparency(obj);
    end
end


end
