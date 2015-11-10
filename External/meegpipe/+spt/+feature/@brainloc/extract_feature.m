function [featVal, featName] = extract_feature(obj, sptObj, ~, raw, rep, varargin)

if nargin < 5, rep = []; end

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

myHead = obj.HeadModel;

M = bprojmat(sptObj);
if obj.CoordinatesOnly,
    featName = {'x', 'y', 'z'};
    featVal  = nan(3, size(M, 2));
else
    featName = {'x', 'y', 'z', 'mx', 'my', 'mz'};
    featVal  = nan(6, size(M, 2));
end

if verbose,
    fprintf([verboseLabel 'Computing inverse solution for %d sources ...'], ...
        size(M,2));
    tinit = tic;
end

mySensLabels = labels(sensors(raw));
[~, sensIdx] = ismember(mySensLabels, labels(myHead.Sensors));
myHead = select_sensor(myHead, sensIdx);

for i = 1:size(M, 2)
   
    myHead = inverse_solution(myHead, 'potentials', M(:,i), ...
        'method', obj.InverseSolver);
    [coords, m] = get_inverse_solution_centroid(myHead);
    if obj.CoordinatesOnly
        featVal(:, i) = coords(:); 
    else
        featVal(:, i) = [coords(:);m(:)];
    end
    
    if verbose,
        misc.eta(tinit, size(M,2), i);
    end        
    
end

if verbose, fprintf('\n\n'); end

% Generate a report
if isempty(rep), return; end

myHead = set_method_config(myHead, 'fprintf', 'ParseDisp', false, 'SaveBinary', true);
fprintf(rep, myHead);


end