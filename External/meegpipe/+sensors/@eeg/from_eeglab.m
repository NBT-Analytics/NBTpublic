function obj = from_eeglab(eStr)
% FROM_EEGLAB - Converts a EEGLAB struct into a sensors.eeg object
%
% obj = sensors.eeg.from_eeglab(eeglabStr)
%
% Where
%
% EEGLABSTR is a EEGLAB struct with EEG electrodes/channels information
%
% OBJ is the generated sensors.eeg object
% 
%
% See also: from_fieldtrip, from_file


xyz = nan(numel(eStr),3);
for i = 1:numel(eStr)
   if ~isfield(eStr(i), 'X') || isempty(eStr(i).X), continue; end
    % For some reason readlocs produces the inverse transformation when
    % reading from a .xyz file. It is not clear to me why as the
    % documentation of readlocs states that the .xyz format is for EEGLAB
    % cartesian coordinates. 
    xyz(i,:) = [-eStr(i).Y eStr(i).X eStr(i).Z];
end

label = cell(numel(eStr), 1);
for i = 1:numel(label)
    label{i} = eStr(i).labels;
end

obj = sensors.eeg('Cartesian', xyz, 'OrigLabel', label);

end