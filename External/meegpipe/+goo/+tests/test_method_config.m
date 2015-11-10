function [status, MEh] = test_method_config()
% test_method_config - Test method_config class

import test.simple.*;
import goo.method_config;

MEh     = [];

initialize(4);

%% Default constructor
try
    
    name = 'default constructor';
    method_config;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Set config during construction using cell array
try
    
    name = 'set config of single method';
    obj = method_config('fprintf', 'ParseDisp', true, 'Save', false);
    
    cfg1 = get_method_config(obj, 'fprintf', 'ParseDisp');
    cfg2 = get_method_config(obj, 'fprintf', 'Save');
    
    ok(...
        numel(cfg1) == 2 && numel(cfg2) == 2 && ...
        strcmp(cfg1{1}, 'ParseDisp') && ...
        strcmp(cfg2{1}, 'Save') && ...
        cfg1{2} == true && ...
        cfg2{2} == false, ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Modify method configuration after construction
try
    name = 'Modify method configuration after construction';
    obj = method_config('fprintf', 'ParseDisp', true, 'Save', false);
    
    obj = set_method_config(obj, 'fprintf', 'ParseDisp', false);
    
    cfg = get_method_config(obj, 'fprintf', 'ParseDisp');
    
    ok(cfg{2} == false, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Config for multiple methods
try
    name = 'Overwrite method config';
    obj = method_config(...
        'fprintf', {'ParseDisp', true, 'Save', false}, ...
        'methodx', {'arg1', 10, 'arg2', 1:3});
    
  
    cfg = get_method_config(obj, 'methodx');
    
    ok(numel(cfg) == 4 && all(cfg{2} == 1:3), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

status = finalize();