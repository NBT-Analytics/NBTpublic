function y = nn_match(p1, p2)

y = nan(size(p1,1),1);


notMatchedIdxSource = 1:size(p1,1);
notMatchedIdxTarget = 1:size(p2,1);
while numel(notMatchedIdxSource)>0,
    dist = nan(numel(notMatchedIdxSource), 1);
    pos = nan(numel(notMatchedIdxSource), 1);
    for i = 1:numel(notMatchedIdxSource)     
        [dist(i), pos(i)] = min(sum((repmat(p1(notMatchedIdxSource(i),:), ...
            numel(notMatchedIdxTarget), 1) - p2(notMatchedIdxTarget,:)).^2, 2));
        
    end
    [~, minPos] = min(dist);
    y(notMatchedIdxSource(minPos)) = notMatchedIdxTarget(pos(minPos));
    notMatchedIdxTarget(pos(minPos)) = [];
    notMatchedIdxSource(minPos) = [];
end

end