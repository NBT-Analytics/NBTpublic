function [sensors, fiducials, extra] = read_sensors(filename)

import mperl.config.inifiles.inifile;
import mperl.file.spec.catfile;
import sensors.root_path;

% might replace parse_sensor_info

[orig, name] = parse_sensor(filename);

% Open configuration file
cfgFile = catfile(root_path, 'templates', [lower(genvarname(name)) '.ini']);
if exist(cfgFile, 'file'),
    cfg = inifile(cfgFile);
else
    cfg = [];
end

sensorCount = 0;
label   = cell(numel(orig), 1);
loc     = nan(numel(orig), 3);

% Fiducials info
fidLabel    = cell(numel(orig), 1);
fidLoc      = nan(numel(orig), 3);
fidCount    = 0;

% Extra (interesting) points info
extraLabel    = cell(numel(orig), 1);
extraLoc      = nan(numel(orig), 3);
extraCount  = 0;

count = 0;

mappingMatrix = [];
if ~isempty(cfg),
    try
        mappingMatrix = eval(val(cfg, 'mapping', 'matrix'));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:m_missing_operator'),
            mappingMatrix = [];
            [~, fileName] = fileparts(cfg.File);
            warning('io:mff:parse_sensor_info:MissingMappingMatrix', ...
                ['I could not read the sensors mapping matrix from %s. ' ...
                'Channel locations may be wrong!'], ...
                [fileName ext]);
        else
            rethrow(ME);
        end
    end
end

% Standard and fiducial locations
if ~isempty(cfg),
    stdLocs = parameters(cfg, 'standard-locs');
    fidLocs = parameters(cfg, 'fiducials');
else
    stdLocs = [];
    fidLocs = [];
end

for i = 1:numel(orig)
    sensorItr = orig(i);
    count = count + 1;
    thisLoc = [...
        str2double(sensorItr.x), ...
        str2double(sensorItr.y), ...
        str2double(sensorItr.z)];
    
    if ~isempty(mappingMatrix),
        thisLoc = thisLoc*mappingMatrix';
    end
    
    % Is this sensor location standard or a fiducial?
    stdName = [];
    fidName = [];
    
    switch sensorItr.type,
        
        case '0',
            % Regular sensors
            sensorCount = sensorCount+1;
            label{sensorCount}  = ['E' sensorItr.number];
            
            loc(sensorCount, :) = thisLoc;
            
            if ~isempty(cfg),
                % Some sensors are special, i.e. correspond to standard
                % 10-20 locations
                if ismember(sensorItr.number, stdLocs)
                    stdName = val(cfg, 'standard-locs', sensorItr.number);
                end
                if ~isempty(stdName),
                    extraCount = extraCount + 1;
                    extraLabel{extraCount}      = stdName;
                    extraLoc(extraCount, :)     = thisLoc;
                end
                
            end
            
        case '1',
            % Reference
            sensorCount = sensorCount+1;
            label{sensorCount} = 'REF';
            loc(sensorCount, :) = thisLoc;
            
            if ~isempty(cfg),
                % The reference will typically be in a standard location, 
                % e.g. the Vertex
                if ismember(sensorItr.number, stdLocs)
                    stdName = val(cfg, 'standard-locs', sensorItr.number);
                end
                if ~isempty(stdName),
                    extraCount = extraCount + 1;
                    extraLabel{extraCount}      = stdName;
                    extraLoc(extraCount, :)     = thisLoc;
                end
                
            end
            
        case '2',
            % Fiducials
            if ismember(sensorItr.number, fidLocs),
                fidName = val(cfg, 'fiducials', sensorItr.number);
            end
            if ~isempty(fidName),
                fidCount = fidCount + 1;
                fidLabel{fidCount}      = fidName;
                fidLoc(fidCount, :)     = thisLoc;
            end
            
            
        otherwise
            error('Unknown sensor type ''%s''', sensorItr.type);
            
    end
    
end
label(sensorCount+1:end)        = [];
loc(sensorCount+1:end,:)        = [];

fidLabel(fidCount+1:end)        = [];
fidLoc(fidCount+1:end,:)        = [];

extraLabel(extraCount+1:end)    = [];
extraLoc(extraCount+1:end,:)    = [];

sensors.label  = label;
sensors.loc    = loc;

fiducials.label  = fidLabel;
fiducials.loc    = fidLoc;

extra.label  = extraLabel;
extra.loc    = extraLoc;

end




