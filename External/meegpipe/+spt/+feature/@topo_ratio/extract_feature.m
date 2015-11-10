function [featVal, featName] = extract_feature(obj, sptObj, tSeries, data, varargin)

import misc.peakdet;
import misc.eta;
import goo.pkgisa;
NB_NEAREST = 4;

featName = [];

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

sensNumL    = obj.SensorsNumLeft;
sensNumR    = obj.SensorsNumRight;
sensNumMid  = obj.SensorsNumMid;
sensDen     = obj.SensorsDen;
funcDen     = obj.FunctionDen;
funcNum     = obj.FunctionNum;
symm        = obj.Symmetrical;

Mraw = bprojmat(sptObj);

sens = sensors(data);
if size(data,1) > 30 && has_coords(sens),
    dist = euclidean_dist(sens);
    Mf = nan(size(Mraw));
    for i = 1:size(Mraw,2)
        for j = 1:size(Mraw,1)
            thisDist = dist(j, :);
            [~, idx] = sort(thisDist, 'ascend');
            nearestIdx = idx(1:min(NB_NEAREST, numel(idx)));
            Mf(j, i) = median(Mraw(nearestIdx, i));
        end
    end
    M = Mf;
else
    M = Mraw;
end

if isa(sensNumL, 'function_handle'),
    sensNumL = sensNumL(sens);
end

if isa(sensNumR, 'function_handle'),
    sensNumR = sensNumR(sens);
end

if isa(sensDen, 'function_handle')
    sensDen = sensDen(sens);
end

if isempty(sensNumL),
    numSetL = [];
else
    [~, numSetL] = ismember(sens, sensNumL);
end
if isempty(sensNumR),
    numSetR = [];
else
    [~, numSetR] = ismember(sens, sensNumR);
end
if isempty(sensNumMid),
    numSetM = [];
else
    [~, numSetM] = ismember(sens, sensNumMid);
    numSetM = numSetM(numSetM > 0);
end

if symm,
    isMissingNum = (numSetL < 1 | numSetR < 1);
    numSetL = numSetL(~isMissingNum);
    numSetR = numSetR(~isMissingNum);
else
    numSetL(numSetL < 1) = [];
    numSetR(numSetR < 1) = [];
end

numSet  = unique([numSetL;numSetR;numSetM]);

if isempty(sensDen),
    denSet = true(sens.NbSensors, 1);
else
    denSet = match_label_regex(sens, sensDen);
end

if isempty(numSet),
    warning('topo_ratio:EmptyNumSet', ...
        'No sensor labels match the numerator regex');
    featVal = ones(size(tSeries,1), 1);
    return;
end
if ~any(denSet),
    warning('topo_ratio:EmptyDenSet', ...
        'No sensor labels match the denominator regex');
    featVal = ones(size(tSeries,1), 1);
    return;
end

featVal = zeros(size(tSeries,1), 1);
asymFactor = ones(1, size(tSeries,1));
if symm && ~isempty(numSetL),
    if verbose,
        fprintf([verboseLabel 'Computing asymmetry coefficients ...']);
    end
    tinit = tic;
    
    for sigIter = 1:size(tSeries, 1)
        
%         asym = abs(abs(Mraw(numSetL, sigIter)) - abs(Mraw(numSetR, sigIter)))./...
%             max(abs([Mraw(numSetL, sigIter) Mraw(numSetR, sigIter)]), [], 2);
%         asymFactor(sigIter) = min(1-asym).^2; 
        asymFactor(sigIter) = ...
            abs(mean(abs(Mraw(numSetL, sigIter)))-mean(abs(Mraw(numSetR, sigIter))))./...
            median(abs(M([numSetL;numSetR], sigIter)));
        
        if verbose,
            eta(tinit, size(tSeries, 1), sigIter, 'remaintime', false);
        end
        
    end
    if verbose, fprintf('\n\n'); end
elseif symm
    warning('topo_ratio:MissingLRInfo',...
        'Cannot use symmetry if no Left/Right channels are provided');
end

if verbose,
    fprintf([verboseLabel 'Computing ratios ...']);
end

tinit = tic;
for sigIter = 1:size(tSeries, 1)
    
    num = funcNum(M(numSet, sigIter));
    
    den = funcDen(Mraw(denSet, sigIter));
    featVal(sigIter) = num/den;
    
    if verbose,
        eta(tinit, size(tSeries, 1), sigIter, 'remaintime', false);
    end
    
end
if verbose, fprintf('\n\n'); end

if symm,
    featVal = featVal(:).*(1./asymFactor(:));
end

end
