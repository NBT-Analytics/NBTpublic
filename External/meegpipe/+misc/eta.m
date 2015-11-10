function msg = eta(tinit,nbmcruns,i, varargin)
% ETA - Displays the estimated time that is left to finnish the simulation.
%
% ````matlab
% eta(t0, nbruns, i)
% eta(t0, nbruns, i, 'remaintime', true)
% ````
%
% Where
%
% `t0` is the time at which the simulation started
%
% `nbruns` are the number of iterations
%
% `i` is the current iteration index
%
% 
% Notes:
%
% Set `remaintime` option to true if you want an estimate of the remaining
% time to be displayed.
%
%
% See also: misc

import misc.process_arguments;
import misc.toc4humans;

opt.remaintime = false;

[~, opt] = process_arguments(opt, varargin);

persistent prevmsg;


if opt.remaintime,
    ttoc = toc(tinit);
    tdiff = (ttoc/i)*(nbmcruns-i);
    
    timeleft = toc4humans(tdiff);
    msg = sprintf('%2.0f%%%% (%s remaining)', round(i/nbmcruns*100), timeleft);
else
    msg = sprintf('%2.0f%%%%', round(i/nbmcruns*100));
end
if i > 1 && exist('prevmsg', 'var') && numel(prevmsg) > 1 && nargout < 1,
    fprintf(repmat('\b', 1, numel(sprintf(prevmsg))));
end
if nargout < 1,
    fprintf(msg);
end

if i == nbmcruns,
    prevmsg = '';
else
    prevmsg = msg;
end
pause(.01);


