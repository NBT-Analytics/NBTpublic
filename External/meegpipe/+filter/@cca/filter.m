function [d, obj] = filter(obj, x, varargin)

import misc.signal2hankel;
import misc.eta;

verbose = is_verbose(obj) && size(x,1) > 5;
verboseLabel = get_verbose_label(obj);

origVerboseLabel = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

cca = obj.CCA;
cca = set_verbose(cca, verbose);

cca = learn(cca, x, varargin{:});
d   = proj(cca, x);

myFilt = obj.CCFilter;
if isa(myFilt, 'function_handle'),
    myFilt = myFilt(x.SamplingRate);
end
if ~isempty(myFilt),
    d = filtfilt(myFilt, d, varargin{:});
end

d   = bproj(cca, d);

goo.globals.set('VerboseLabel', origVerboseLabel);

end