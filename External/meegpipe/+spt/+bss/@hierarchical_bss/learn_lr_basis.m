function [bssArray, winBndry] = learn_lr_basis(obj, data, parentBSS, winBndryIn)

import spt.distance;

CHILDREN_DIST_FACTOR = 1.25;

verbLevel    = get_verbose_level(obj);
verboseLabel = get_verbose_label(obj);

maxWindowLength = obj.MaxWindowLength;
if isa(maxWindowLength, 'function_handle'),
    maxWindowLength = maxWindowLength(data.SamplingRate);
end

if diff(winBndryIn) < maxWindowLength
    bssArray = {parentBSS};
    winBndry = winBndryIn;
    return;
end

select(data, [], winBndryIn(1):winBndryIn(2));

childrenDist   = Inf;
overlapCounter = 0;
eyeBSS = spt.bss.matrix(eye(nb_dim(parentBSS)));

prevMinDist = Inf;

while overlapCounter < numel(obj.Overlap) && ...
        childrenDist > CHILDREN_DIST_FACTOR*obj.DistanceThreshold
    
    overlapCounter = overlapCounter + 1;
    
    leftEnd    = floor((1+obj.Overlap(overlapCounter)/100)*size(data,2)/2);
    rightBegin = ceil((1-obj.Overlap(overlapCounter)/100)*size(data,2)/2);
    winBndry   = [...
        winBndryIn(1) winBndryIn(1)+floor(size(data,2)/2);...
        winBndryIn(1)+floor(size(data,2)/2)+1 winBndryIn(2)];
    
    dataLeft  = data(:, 1:leftEnd);
    dataRight = data(:, rightBegin:end);
    
    bssLeft  = cell(1, obj.ChildrenSurrogates);
    bssRight = cell(1, obj.ChildrenSurrogates);
    
    if verbLevel > 0,
        fprintf([verboseLabel ...
            'Learning %s basis from %d surrogates on two windows ' ...
            '(L=%d samples, %d%% overlap) ...'], class(obj.BSS), ...
            obj.ChildrenSurrogates, leftEnd, ...
            round(obj.Overlap(overlapCounter)));
    end
    
    tinit = tic;
    surrogator = obj.Surrogator;
    
    for surrIter = 1:obj.ChildrenSurrogates
        
        surrogator = set_seed(surrogator, get_seed(obj) + surrIter*100);
        dataSurr = surrogate(surrogator, dataLeft);
        bssLeft{surrIter} = learn(parentBSS, dataSurr);
        bssLeft{surrIter} = match_sources(bssLeft{surrIter}, eye(nb_dim(parentBSS)));
        
        dataSurr = surrogate(surrogator, dataRight);
        bssRight{surrIter} = learn(parentBSS, dataSurr);
        bssRight{surrIter}  = match_sources(bssRight{surrIter}, eye(nb_dim(parentBSS)));
        
        if verbLevel > 0
            misc.eta(tinit, obj.ChildrenSurrogates, surrIter);
        end
    end
    
    
    % Eliminate those estimates too far from the centroid
    distValRight = distance({eyeBSS}, bssRight, obj.DistanceMeasure);
    minRightDist = min(distValRight);
    bssRight(distValRight > obj.DistanceThreshold) = [];
    
    distValLeft = distance({eyeBSS}, bssLeft, obj.DistanceMeasure);
    minLeftDist = min(distValLeft);
    bssLeft(distValLeft > obj.DistanceThreshold) = [];
    
    if verbLevel > 0,
        fprintf('[minLeftDist=%.2f, minRightDist=%.2f, threshold=%.2f]\n\n', ...
            minLeftDist, minRightDist, obj.DistanceThreshold);
    end
    
    % Now pick the closest left/right decomposition
    if minRightDist > obj.DistanceThreshold || ...
            minLeftDist > obj.DistanceThreshold,
        childrenDist = Inf;
    else
        distVal = distance(bssLeft, bssRight, obj.DistanceMeasure);
        [childrenDist, I] = min(distVal(:));
        [i,j]  = ind2sub(size(distVal), I);
        bssLeft  = bssLeft{i};
        bssRight = bssRight{j};
        if verbLevel > 0,
            fprintf([verboseLabel 'Mutual distance between children: %2.f\n\n'], ...
                childrenDist);
        end
    end
    
    if min(minLeftDist, minRightDist) > prevMinDist,
        % Seems like increasing the overlap does not make matters better
        break;
    end
    
end
restore_selection(data);

if childrenDist > CHILDREN_DIST_FACTOR*obj.DistanceThreshold,
    % Could not find two similar-enough decompositions: use parent
    if verbLevel > 0,
        fprintf([verboseLabel 'Children mutual distance (%.2f) is ' ...
            'greater than %.2f: using parent BSS\n\n'], ...
            childrenDist, CHILDREN_DIST_FACTOR*obj.DistanceThreshold);
    end
    winBndry = winBndryIn;
    bssArray = {parentBSS};
else
    if verbLevel > 0,
        fprintf([verboseLabel 'Children mutual distance (%.2f) is ' ...
            'smaller than %.2f: using children BSS\n\n'], ...
            childrenDist, CHILDREN_DIST_FACTOR*obj.DistanceThreshold);
    end
    
    % bssLeft must be obtained using only left-data. So we pick the
    % left-data-only BSS that is closest to bssLeft
    select(data, [], winBndry(1,1):winBndry(1,2));
    proj(bssLeft, data);
    bssLeftNew = pick_closest_bss(obj, data);
    if ~isempty(bssLeftNew)
        bssLeft = cascade(bssLeft, bssLeftNew);
    end
    restore_selection(data);
    
    select(data, [], winBndry(2,1):winBndry(2,2));
    proj(bssRight, data);
    bssRightNew = pick_closest_bss(obj, data);
    if ~isempty(bssRightNew)
        bssRight = cascade(bssRight, bssRightNew);
    end
    restore_selection(data);
    
    % Recursively call on learn_lr_basis
    [bssLeftNew, winLeft]  = learn_lr_basis(obj, data, bssLeft, winBndry(1,:));
    
    if numel(bssLeftNew) > 1,
        for i = 1:numel(bssLeftNew),
            bssLeftNew{i} = cascade(bssLeft, bssLeftNew{i});
        end
    end
    
    [bssRightNew, winRight] = learn_lr_basis(obj, data, bssRight, winBndry(2,:));
    
    if numel(bssRightNew) > 1,
        for i = 1:numel(bssRightNew),
            bssRightNew{i} = cascade(bssRight, bssRightNew{i});
        end
    end
    
    bssArray = [bssLeftNew, bssRightNew];
    winBndry = [winLeft;winRight];
    
    
end

end


function [bssLeft, minDist] = pick_closest_bss(obj, data)
import misc.eta;
import spt.centroid_spt;
import spt.distance;

verbLevel    = get_verbose_level(obj);
verboseLabel = get_verbose_label(obj);


if verbLevel > 0,
    fprintf([verboseLabel ...
        'Re-learning children basis from %d side-only surrogates ...'], ...
        obj.ParentSurrogates);
end

eyeBSS = spt.bss.matrix(eye(size(data,1)));

surrogator = obj.Surrogator;
bssLeftNew = cell(1, obj.ParentSurrogates);
tinit = tic;
for surrIter = 1:obj.ParentSurrogates
    surrogator = set_seed(surrogator, get_seed(obj) + surrIter*100);
    dataSurr = surrogate(surrogator, data(:,:));
    
    bssLeftNew{surrIter} = learn_basis(obj.BSS, dataSurr);
    
    if verbLevel > 0
        misc.eta(tinit, obj.ParentSurrogates, surrIter);
    end
end
if verbLevel > 0,
    fprintf('\n\n');
end

distVal = distance({eyeBSS}, bssLeftNew, obj.DistanceMeasure);
[minDist, minI] = min(distVal);

bssLeft = match_sources(bssLeftNew{minI}, eye(size(data,1)));

if verbLevel > 0,
    fprintf([verboseLabel ...
        'Nearest side-data-only BSS at distance %.2f\n\n'], ...
        minDist);
   
end


if minDist > obj.DistanceThreshold
    if verbLevel > 0,
        fprintf([verboseLabel ...
            '%.2f > %.2f : Discarding side-data-only BSS\n\n'], ...
            minDist, obj.DistanceThreshold);
        
    end
    bssLeft = [];
end

end