function [status, MEh] = test1()
% TEST1 - Tests demo functionality

import mperl.file.spec.*;
import plotter.eegplot.*;
import test.simple.*;

MEh     = [];

initialize(5);

%% Define plotter configuration
try
    
    name = 'build plotter config';
    myConfig = config('SamplingRate', 100);
    ok(get(myConfig, 'SamplingRate') == 100, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end


%% Construction
try
    
    name = 'construction';
    h = eegplot(myConfig);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% Create sample sensors
try
    
    name = 'sample sensors';
    warning('off', 'sensors:MissingPhysDim');
    warning('off', 'sensors:InvalidLabel');
    sensorsObj = sensors.eeg.from_template('egi256');
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
    ok(nb_sensors(sensorsObj) == 257, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end
    

%% plot random data
try
    
    name = 'plot random data';
    if exist('physioset.event.event', 'class')
        myEvent   = physioset.event.event(50, 'Type', 'myEvent');
    else
        myEvent = [];
    end
    d1        = randn(10, 100);
    d2        = randn(10, 100);
    d3        = randn(10, 100);
    h = plot(h, d1, d2, d3, 'Events', myEvent);
    set_sensor_labels(h, labels(subset(sensorsObj, 1:10)));
    ok(nb_sensors(sensorsObj) == 257, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% clone (not implemented yet for class plotter.eegplot
% try
%     
%     name = 'method clone()';
%     clone(h);    
%     
% catch ME
%     
%     ok(ME, name);
%     MEh = [MEh ME];
% end

%% Use a black background
try
    
    name = 'method blackbg()';
    blackbg(h);
    ok(sum(get(gcf, 'Color'))<eps, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end


%% Testing summary
status = finalize();
