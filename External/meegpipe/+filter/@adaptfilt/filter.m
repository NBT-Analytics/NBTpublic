function x = filter(obj, x, d, varargin)

import misc.eta;
import spt.pca;


verbose         = is_verbose(obj) && size(x,1) > 10;
verboseLabel 	= get_verbose_label(obj);


if verbose,
    fprintf( [verboseLabel, ...
        '%s regression of %d ref. signals on %d signals...'], ...
        class(obj.Filter), size(d,1), size(x,1));
end

if verbose,
    tinit = tic;
    clear +misc/eta;
end

for i = 1:size(x,1),
    
    % I would think that regressing out every regressor one by one would be
    % the best approach, but experience tell otherwise. The approach below
    % seems to work better in practice.
    
    % Find the regressor(s) that correlate best with this variable
    
    c = zeros(size(d,1),1);
    for j = 1:size(d,1)
        c(j) = max(xcorr(x(i,:), d(j,:), 5, 'coeff'));
    end
    thisReg = d(c>obj.MinCorr, :);
    if isempty(thisReg), continue; end
    
    if size(thisReg,1) > 1,
        pca     = learn(pca('MaxDimOut', 1), thisReg);
        thisReg = proj(pca, thisReg);
    end
    
    filteredRegr = filter(obj.Filter, thisReg, x(i,:));
    if ~any(isnan(filteredRegr)),      
        x(i,:)  = x(i,:) - filteredRegr;
    else
        error('There are NaNs in the filter output');
    end
    if verbose,
        eta(tinit, size(x,1), i, 'remaintime', false);
    end
    
end

if verbose, fprintf('\n\n'); end

end