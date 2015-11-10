function [status, MEh] = test1()
% TEST1 - Tests demo functionality

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import goo.method_config;

MEh     = [];

initialize(7);

%% Default constructor
try
    
    name = 'default constructor';
    physioset;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Build a method configuration object
try
    
    name = 'method configuration';
    cfg = method_config('fprintf', {'ParseDisp', true, 'SaveBinary', true});
    
    parseDisp  = get_method_config(cfg, 'fprintf', 'ParseDisp');
    saveBinary = get_method_config(cfg, 'fprintf', 'SaveBinary');
    ok(parseDisp{2} & saveBinary{2}, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Alternative construction of a configuration object
try
    
    name = 'alternative config object construction';
    options = mjava.hash;
    options{'ParseDisp', 'SaveBinary'} = {false, false};
    cfg = method_config('fprintf', options);
    parseDisp  = get_method_config(cfg, 'fprintf', 'ParseDisp');
    saveBinary = get_method_config(cfg, 'fprintf', 'SaveBinary');
    ok(~parseDisp{2} & ~saveBinary{2}, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Yet another config construction alternative
try
    
    name = 'another alternative for config object construction';
    cfg = method_config;
    cfg = set_method_config(cfg, 'fprintf', {'ParseDisp', false});
    parseDisp = get_method_config(cfg, 'fprintf', 'ParseDisp');
    ok(~parseDisp{2}, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Construct a dummy physioset and modify its method config
try
    
    name = 'modify method config of physioset';
    warning('off', 'session:NewSession');
    myPset = import(physioset.import.matrix, randn(10,10000));
    warning('on', 'session:NewSession');
    set_method_config(myPset, cfg);
    set_method_config(myPset, 'fprintf', {'ParseDisp', true});
    parseDisp = get_method_config(cfg, 'fprintf', 'ParseDisp');
    ok(parseDisp{2}, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Get all configs as a hash object 
try
    
    name = 'get all config options as hash';
    allCfg = get_method_config(myPset);
    ok(isa(allCfg, 'mjava.hash') & ...
        numel(keys(allCfg)) == 1 & ...
        allCfg('fprintf','ParseDisp'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Get all configs as a config object 
try
    
    name = 'get all config options as object';
    get_method_config(myPset);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


clear myPset;

%% Testing summary
status = finalize();

end