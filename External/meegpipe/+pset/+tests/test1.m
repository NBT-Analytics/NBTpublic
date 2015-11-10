function [status, MEh] = test1()
% TEST1 - Test basic package functionality

import mperl.file.spec.*;
import pset.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

initialize(4);

%% Create a new session
try
    
    name = 'create new session';
    warning('off', 'session:NewSession');
    session.instance;
    warning('on', 'session:NewSession');
    hashStr = DataHash(randn(1,100));
    session.subsession(hashStr(1:5));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
   
end

%% Default constructor
try
    
    name = 'default constructor';
    pset;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Static constructors
try
    
    name = 'static constructors';
    pset.pset.ones(5,1000);
    pset.pset.randn(5,1000);
    pset.pset.rand(5, 1000);
    obj = pset.pset.nan(5, 1000);
    ok(size(obj, 2) == 1000, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup';
    clear obj ans;
    pause(1);
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    rmdir(session.instance.Folder, 's');
    ok(true, name);
    
catch ME
    ok(ME, name);
    MEh = [MEh ME];
end


status = finalize();
