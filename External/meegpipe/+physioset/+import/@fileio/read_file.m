function [sens, sr, hdr, ev, startDate, startTime, meta] = ...
    read_file(obj, fileName, psetFileName, verbose, verboseLabel)

import physioset.import.fileio;

% Not provided by fieldtrip, at least not in a standard way
startDate = [];
startTime = [];

% To be produced by read_event
ev        = [];

%% Check dependencies
% EEGLAB contains the necessary bits of Fieldtrip
try
    misc.check_dependency('eeglab');
catch ME
    if ~isempty(regexp(ME.identifier, 'MissingDependency$', 'once')),
        misc.check_dependency('fieldtrip');
    else
        rethrow(ME);
    end
end

%% Read header
if verbose,
    fprintf([verboseLabel 'Reading header ...\n\n']);
end

[~, hdr] = evalc( ['ft_read_header(''' fileName ''')'] );

% It seems that sometimes there are more c

% Identify sensor classes based on channel labels
sensorClass = obj.Label2Class(hdr.label);

if verbose,
    fprintf([verboseLabel 'Done reading header ...\n\n'])
end

sr = hdr.Fs;

%% Read signal values
[~, name] = fileparts(psetFileName);
if verbose, fprintf('%sWriting data to %s...', verboseLabel, name); end
tinit = tic;
chunkSize = floor(obj.ChunkSize/(misc.sizeof(obj.Precision)*hdr.nChans)); % in samples
if hdr.nTrials > 1,
    % Chunk size must be an integer number of trials
    chunkSize = floor(chunkSize/(hdr.nSamples))*hdr.nSamples;
end
boundary = 1:chunkSize:(hdr.nSamples*hdr.nTrials);
if length(boundary)<2 || boundary(end) < hdr.nSamples*hdr.nTrials,
    boundary = [boundary,  hdr.nSamples*hdr.nTrials+1];
else
    boundary(end) = boundary(end)+1;
end
nbChunks = length(boundary) - 1;

fid = safefid.new(psetFileName, 'w');
if ~fid.Valid, throw(exceptions.InvalidFID(newFileName)); end

if ~isfield(hdr, 'unit') && isfield(hdr, 'chanunit'),
    hdr.unit = hdr.chanunit;
end

isMeg = ismember(sensorClass, 'meg');
if any(isMeg),
    isGrad = isMeg & fileio.is_gradiometer(hdr.unit(:));
    isMag  = isMeg & ~isGrad;
    gradIdx = find(isGrad(:));
    magIdx  = find(isMag(:));
else
    gradIdx = [];
    magIdx = [];
end

megIdx  = [gradIdx;magIdx];
eegIdx  = find(ismember(sensorClass, 'eeg'));
physIdx = find(ismember(sensorClass, 'physiology'));
triggerIdx = find(ismember(sensorClass, 'trigger'));

triggerData = nan(numel(triggerIdx), hdr.nSamples);

rawChanIndexing = [gradIdx(:); magIdx(:); eegIdx(:); physIdx(:)];
for chunkItr = 1:nbChunks
    begSample = boundary(chunkItr);
    endSample = boundary(chunkItr+1)-1;
    [~, dat] = evalc( ...
        ['ft_read_data(fileName, ' ...
        '''begsample'',        begSample, ' ...
        '''endsample'',        endSample, ' ...
        '''checkboundary'',    false, '...
        '''header'',           hdr)']);
    if ndims(dat) > 2, %#ok<ISMAT>
        dat = reshape(dat, [size(dat,1), round(numel(dat)/size(dat,1))]);
    end
    
    % Trigger data will not be written to the physioset file. Instead
    % trigger data is translated into a train of events
    triggerData(:, begSample:endSample) = dat(triggerIdx,:);
    dat         = dat(rawChanIndexing, :);
    
    % Write the chunk into the output binary file
    fwrite(fid, dat(:), obj.Precision);
    if verbose,
        misc.eta(tinit, nbChunks, chunkItr);
    end
end
fid.fclose;

% Fix the order of the channels in the header
if isfield(hdr, 'grad')
    hdr.grad    = fileio.grad_reorder(hdr.grad, megIdx);
    hdr.grad    = fileio.grad_change_unit(hdr.grad, 'cm');
end
hdr.label   = hdr.label(rawChanIndexing);

if isfield(hdr, 'unit')
    hdr.unit    = hdr.unit(rawChanIndexing);
end

% Fix the channel order in gradIdx, etc.
gradIdx = 1:numel(gradIdx);
magIdx  = numel(gradIdx)+1:numel(gradIdx)+numel(magIdx);
eegIdx  = numel(gradIdx)+numel(magIdx)+1:numel(gradIdx)+...
    numel(magIdx)+numel(eegIdx);
physIdx = numel(gradIdx)+numel(magIdx)+numel(eegIdx)+1:...
    numel(gradIdx)+numel(magIdx)+numel(eegIdx)+numel(physIdx);
if verbose, fprintf('\n\n'); end

% Generate sensors
if isempty(obj.Sensors),
    
    if verbose,
        fprintf([verboseLabel 'Reading sensor information...']);
    end
    eegSensors  = [];
    magSensors  = [];
    gradSensors = [];
    physSensors = [];
    
    if ~isempty(eegIdx),
        eegSensors  = sensors.eeg(...
            'Label', hdr.label(eegIdx));
    end
    
    if ~isempty(megIdx),
        % Sensors for the magnetometers
        % Note that the 'grad' field may be missing when Fieldtrip fails to
        % identify the format of the sensor coordinates in the raw file.
        % See test_fif_angus for an example
        if isfield(hdr, 'grad') && isfield(hdr.grad, 'coilpos'),
            % Old Fieldtrip version
            magCoils    = sensors.coils(...
                'Cartesian',    hdr.grad.coilpos, ...
                'Orientation',  hdr.grad.coilori, ...
                'Weights',      hdr.grad.tra(magIdx, :));
            magSensors  = sensors.meg(...
                'Coils',        magCoils, ...
                'Cartesian',    hdr.grad.chanpos(magIdx,:), ...
                'Orientation',  hdr.grad.chanori(magIdx,:), ...
                'PhysDim',      hdr.unit(magIdx), ...
                'Label',        hdr.label(magIdx));
        elseif isfield(hdr, 'grad') && isfield(hdr.grad, 'pnt'),
            % Old Fieldtrip does not specify coils positions/orientations
            magCoils = sensors.coils('Weights', hdr.grad.tra(magIdx,:));
            magSensors  = sensors.meg(...
                'Coils',        magCoils, ...
                'Cartesian',    hdr.grad.pnt(magIdx,:), ...
                'Orientation',  hdr.grad.ori(magIdx,:), ...
                'PhysDim',      'T', ...
                'Label',        hdr.label(magIdx));
        elseif ~isfield(hdr, 'grad'),
            % Last try at guessing the sensor coordinates
            if isfield(hdr.orig, 'chs') && isfield(hdr.orig.chs, 'loc'),
                coords = nan(3, numel(magIdx));
                for i = 1:numel(magIdx),
                    coords(:,i) = hdr.orig.chs(rawChanIndexing(magIdx(i))).loc(1:3);
                end
                % Head center at 0 and head radius 10 cm: the convention
                % used by EGI's head templates
                coords = coords - repmat(mean(coords, 2), 1, numel(magIdx));
                R = mean(sqrt(sum(coords.^2)));
                coords = (10/R)*coords;
                magSensors  = sensors.meg(...
                    'Cartesian',    coords', ...
                    'PhysDim',      'T', ...
                    'Label',        hdr.label(magIdx));
            else
                warning('read_file:MissingSensorCoords', ...
                    'Could not retrieve magnetometer sensor locations');
                magSensors = sensors.meg.dummy(numel(magIdx));
            end
        else
            error('Invalid Fieldtrip structure');
        end
    end
    
    if ~isempty(gradIdx),
        % Sensors for the gradiometers
        if isfield(hdr, 'grad') && isfield(hdr.grad, 'coilpos'),
            gradCoils    = sensors.coils(...
                'Cartesian',    hdr.grad.coilpos, ...
                'Orientation',  hdr.grad.coilori, ...
                'Weights',      hdr.grad.tra(gradIdx, :));
            gradSensors  = sensors.meg(...
                'Coils',        gradCoils, ...
                'Cartesian',    hdr.grad.chanpos(gradIdx,:), ...
                'Orientation',  hdr.grad.chanori(gradIdx,:), ...
                'PhysDim',      hdr.unit(gradIdx), ...
                'Label',        hdr.label(gradIdx));
        elseif isfield(hdr, 'grad') && isfield(hdr.grad, 'pnt'),
            gradCoils = sensors.coils('Weights', hdr.grad.tra(gradIdx,:));
            gradSensors  = sensors.meg(...
                'Coils',        gradCoils, ...
                'Cartesian',    hdr.grad.pnt(gradIdx,:), ...
                'Orientation',  hdr.grad.ori(gradIdx,:), ...
                'PhysDim',      'T/m', ...
                'Label',        hdr.label(gradIdx));
        elseif ~isfield(hdr, 'grad'),
            % Last try at guessing the sensor coordinates...
            if isfield(hdr.orig, 'chs') && isfield(hdr.orig.chs, 'loc'),
                coords = nan(3, numel(gradIdx));
                for i = 1:numel(gradIdx),
                    coords(:,i) = hdr.orig.chs(rawChanIndexing(gradIdx(i))).loc(1:3);
                end
                % Head center at 0 and head radius 10 cm: the convention
                % used by EGI's head templates
                coords = coords - repmat(mean(coords, 2), 1, numel(gradIdx));
                R = mean(sqrt(sum(coords.^2)));
                coords = (10/R)*coords;
                gradSensors  = sensors.meg(...
                    'Cartesian',    coords', ...
                    'PhysDim',      'T/m', ...
                    'Label',        hdr.label(gradIdx));
            else
                warning('read_file:MissingSensorCoords', ...
                    'Could not retrieve magnetometer sensor locations');
                gradSensors = sensors.meg.dummy(numel(gradIdx));
            end
        else
            error('Invalid Fieldtrip structure');
        end
        
    end
    
    if ~isempty(physIdx),
        physSensors = sensors.physiology('Label', hdr.label(physIdx));
    end
    
    sens = sensors.mixed(gradSensors, magSensors, eegSensors, ...
        physSensors);
    
    if verbose, fprintf('[done]\n\n'); end
else
    if verbose,
        fprintf([verboseLabel ...
            'Sensor information explicity provided by user ...\n\n']);
    end
    sens = obj.Sensors;
    if verbose, fprintf('[done]\n\n'); end
end


meta.raw_chan_indexing = rawChanIndexing;

end