function myCrit = eog_egi256_hcgsn1(varargin)

% 241 244 248 252 253 67 61 54 
sensorsNumLeft = [...
    46 37 32, ...
    47 38 33];

% 238 234 230 226 225 219 220 1
sensorsNumRight = [...
    10 18 25, ...
    2 11 19];

sensorsNumMid = {'EEG 31', 'EEG 26'}; 

sensorsNumLeft = arrayfun(@(x) ['EEG ' num2str(x)], sensorsNumLeft, ...
    'UniformOutput', false);
    
sensorsNumRight = arrayfun(@(x) ['EEG ' num2str(x)], sensorsNumRight, ...
    'UniformOutput', false);
    
allSensors = sensors.eeg.from_template('egi256');

isNumL = match_label_regex(allSensors, sensorsNumLeft);
isNumR = match_label_regex(allSensors, sensorsNumRight);
isNum = isNumL | isNumR;

% Approximate distance between sensors
dist = euclidean_dist(allSensors);

% Rank all sensors based on their distance to the numerator sensors
rank = min(dist(isNum, ~isNum));
denIdx = find(~isNum);
[~, order] = sort(rank, 'descend');

% Pick the farthest sensors
sensorsNumLabels = [sensorsNumLeft(:);sensorsNumRight(:);sensorsNumMid(:)];
maxSensors = allSensors.NbSensors - max(2*numel(sensorsNumLabels), 70);
maxSensors = max(10, maxSensors);
denIdx = denIdx(order(1:maxSensors));

sensorsDen = subset(allSensors, sort(denIdx));
myCrit = spt.feature.topo_ratio(...
    'SensorsDen',       labels(sensorsDen), ...
    'SensorsNumLeft',   sensorsNumLeft, ...
    'SensorsNumRight',  sensorsNumRight, ...
    'SensorsNumMid',    sensorsNumMid, ...
    'FunctionDen',      @(x) prctile(x.^2, 75), ...
    'FunctionNum',      @(x) prctile(x.^2, 75), ...
    'Symmetrical',      true, ...
    varargin{:});


end