function obj = write(obj, filename)
% WRITE - Writes EEG sensors.information to a file
%
% obj = write(obj, filename)
%
% where
%
% OBJ is a eeg.sensors.object
%
% FILENAME is a full path name (with file extension .hpts or .sfp)
%
%
% See also: sensors.eeg

% Documentation: class_sensors.eeg.txt
% Description: Writes sensors.information to a file

[~, ~, ext] = fileparts(filename);

InvalidFormat = MException('sensors.eeg:read:InvalidFormat', ...
    'Format %s is not supported', ext);

switch lower(ext)
    case '.sfp',
        throw(InvalidFormat);

    case '.hpts', 
        % Fiducial points
        if ~isempty(obj.Fiducials),
            fidIDs      = keys(obj.Fiducials)';
            fidCoord    = cell2mat(values(obj.Fiducials)');
        else
            fidIDs      = [];
            fidCoord    = [];
        end    
        
        % Extra points
        if ~isempty(obj.Extra),
            extraIDs      = keys(obj.Extra)';
            extraCoord    = cell2mat(values(obj.Extra)');
        else
            extraIDs      = [];
            extraCoord    = [];
        end    
        
        fidCat      = repmat({'cardinal'}, numel(fidIDs), 1);
        eegCat      = repmat({'eeg'},      nb_sensors(obj), 1);
        extraCat    = repmat({'extra'},    numel(extraIDs), 1);
        io.hpts.write(filename, ...
            [fidCoord; obj.Cartesian; extraCoord], ...
            'id',           [fidIDs; orig_labels(obj); extraIDs], ...
            'category',     [fidCat; eegCat; extraCat]); 

        
    otherwise
        throw(InvalidFormat);
    
end

end