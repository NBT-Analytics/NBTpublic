function tabcomplete(operation)
% TABCOMPLETE - Tunes MATLAB tab-completions features
%
%
% pset.tabcomplete;
% pset.tabcomplete('remove');
%
%
% The two commands above can be used, respectively, to add/remove several
% some useful entries to MATLAB's file [matlabroot '/toolbox/local/TC.xml']
%
% As a result MATLAB's tab-completion features will work seamlessly with 
% several functions included in this package. Note however that tuning
% MATLAB tab-completion features requires that you are the ownwer of the
% TC.xml file. This function uses [1].
%
%
%
% See also: external.tabcomplete

% Documentation: pkg_sensors.txt
% Description: Sets up MATLAB tab completion

import external.tabcomplete.tabcomplete;

if nargin < 1 || isempty(operation),
    operation = 'add';
end

if ~ischar(operation),
    error('The ''operation'' argument must be a char array');
end



switch lower(operation),
    
    case 'add',
        tabcomplete('read', 'file');
        
    case 'remove',
        tabcomplete('read', '');
        
    otherwise
        error('pset:tabcomplete:InvalidOperation', ...
            'Only the ''add'' and ''remove'' operations are supported');
end

end

