function [status, MEh] = test1()
% TEST1 - Tests demo functionality

import mperl.file.spec.*;
import test.simple.*;
import plotter.topography.*;

MEh     = [];

initialize(3);


%% Load sample data

%% constructor
try
    
    name = 'constructor';
    cfg = config('Fiducials', 'off');
    obj = topography(cfg);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% plot topography
try
    
    name = 'plot topography';
    warning('off', 'sensors:MissingPhysDim');
    warning('off', 'sensors:InvalidLabel');
    sensorsObj = sensors.eeg.from_template('egi256');
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
    h = plot(obj, sensorsObj, rand(nb_sensors(sensorsObj),1));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% modify fig properties
try
    
    name = 'modify fig properties';
    set_ears_and_nose(h, 'Visible', 'off');
    set_colorbar(h, 'Visible', 'off');
    set_sensor_labels(h, 'Visible', 'on', 'FontSize', 6);
    labels2numbers(h);
    blackbg(h);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% Testing summary
status = finalize();


end



