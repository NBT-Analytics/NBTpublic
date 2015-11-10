function obj = from_template(name, varargin)
% FROM_TEMPLATE - Predefined EEG sensor arrays
%
% obj = sensors.eeg.from_template(name)
%
% Where
%
% NAME is the name of the template (a string). 
%
% OBJ is a sensors.eeg object
%
%
% See also: from_eeglab, from_fieldtrip, from_file

import misc.is_string;
import misc.set_warning_status;
import sensors.abstract_sensors
import sensors.root_path;
import mperl.file.spec.catfile;

if isempty(name),
    obj = sensors.eeg;
    return;
end

if ~is_string(name),
    throw(abstract_sensors.InvalidArgValue('Name', ...
        'Must be a string'));
end

% Remove file extension, if it was provided
name = regexprep(name, '.hpts$', '');

switch lower(name)
    
    case {'hydrocel gsn 256 1.0', 'hydrocelgsn25610x2e0', 'hydrocel256', ...
            'egi256'},
        % EGI's HydroCel GSN 256 1.0        
        file     = catfile(root_path, 'templates/hydrocelgsn25610x2e0.hpts');
        
       
    otherwise
        file = [];
end

if isempty(file),
    obj = [];
else
    
    id = {'sensors:MissingPhysDim', 'sensors:InvalidLabel'};
    origStatus = set_warning_status(id, 'off');
    obj = sensors.eeg.from_file(file, varargin{:});   
    set_warning_status(id, origStatus);
    
end


end