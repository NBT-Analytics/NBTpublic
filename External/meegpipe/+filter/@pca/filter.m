function [pcs, obj] = filter(obj, x, varargin)

import misc.signal2hankel;
import misc.eta;

d = [];
if nargin > 2 && isnumeric(varargin{1}),
    d = varargin{1};
    varargin = varargin(2:end);
end

verbose = is_verbose(obj) && size(x,1) > 5;
verboseLabel = get_verbose_label(obj);

origVerboseLabel = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

pca = obj.PCA;
pca = set_verbose(pca, verbose);

pca = learn(pca, x);
pcs = proj(pca, x);

if ~isempty(d),
    % To make it work with regression filters
    pcaD = learn(pca, d);
    pcsD = proj(pcaD, d);
end

if ~isempty(obj.PCFilter),
    if verbose,
        fprintf([verboseLabel 'Filtering PCs using %s ...\n\n'], ...
            class(obj.PCFilter));
    end
    if isempty(d),
        pcs   = filtfilt(obj.PCFilter, pcs, varargin{:});
    else
        pcs   = filtfilt(obj.PCFilter, pcs, pcsD, varargin{:});
    end
end
pcs   = bproj(pca, pcs);

goo.globals.set('VerboseLabel', origVerboseLabel);

end