function check_dependency(name)
% CHECK_DEPENDENCY - Checks whether certain third-party toolbox is found
%
% check_dependency(depName)
%
% Where
%
% DEPNAME is the name of the third-party toolbox.
%
% ## Available dependency checks:
%
%   EEGLAB : http://sccn.ucsd.edu/eeglab/
%
%   Fieldtrip: http://fieldtrip.fcdonders.nl/
%
%
% See also: misc


import misc.caller_id;

caller = caller_id(dbstack('-completenames'));


switch lower(name)
    case 'eeglab',
        if ~exist('eeglab', 'file') || ~exist('readlocs', 'file'),
            ME = MException([caller ':MissingDependency'], ...
                ['The EEGLAB toolbox is required \n', ...
                'You can get EEGLAB from: http://sccn.ucsd.edu/eeglab/']);
            throw(ME);
        end
        
    case 'fieldtrip',
        if ~exist('ft_definetrial', 'file') || ~exist('ft_preprocessing', 'file'),
            ME = MException([caller ':MissingDependency'], ...
                ['The Fieldtrip toolbox is required \n', ...
                'You can get Fieldtrip from: http://fieldtrip.fcdonders.nl']);
            throw(ME);
        end
        
        
    otherwise
        error('Unknown toolbox ''%s''', name);
end

end
