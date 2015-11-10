function obj = guess_from_labels(inputLabels)
% GUESS_FROM_LABELS - Attempt to build sensor array from sensor labels
%
% obj = sensors.eeg.guess_from_labels(inputLabels)
%
% Where
%
% INPUTLABELS is a cell array of sensor labels.
%
% ## Notes:
%
% * Construction of a fully qualified sensor array object using only sensor
%   labels is a severely underdetermined problem. This function will try to
%   guess the right solution based on simple heuristics. The produced
%   sensor array should be used with caution. However, this may work well
%   and become very handy when only a few EEG setups are used within a lab. 
%
% * This static constructor will scan all the templates available within
%   the templates directory and pick the first template: (1) whose number
%   of EEG sensors.matches the number of provided labels, and (2) whose
%   sensor labels approximately match the provided labels.
%
%
% See also: sensors.eeg, sensors.eeg.from_template

import misc.dir;
import mperl.file.spec.catdir;
import sensors.root_path;
import sensors.eeg;

if isempty(inputLabels),
    obj = [];
    return;
end

% List of available templates
templList = dir(catdir(root_path, 'templates'), '.hpts$');



for i = 1:numel(templList)  
    
    thisTempl = eeg.from_template(templList{i});

    
    if isa_match(labels(thisTempl), inputLabels),
        obj = thisTempl;
        return;
    end
    
end

obj = sensors.eeg('Label', inputLabels);

end



function bool = isa_match(templLabels, inputLabels)

if numel(templLabels) ~= numel(inputLabels),
    bool = false;
    return;
end


% try something smarter later on...

bool = true;

end