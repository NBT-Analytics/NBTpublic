function [status, MEh] = test_surrogates_bss()
% TEST_SURROGATES_BSS - Test surrogates_bss algorithm

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;
import spt.amari_index;

MEh     = [];

initialize(7);

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

%% bss_surrogates + efica
try
    
    name = 'bss_surrogates + efica';
    
    data = sample_data;
    
    myBSS = spt.bss.efica;
    
    myBSS = learn(myBSS, data);
    
    errorEfica = amari_index(projmat(myBSS)*eye(size(data,1)), 'range', [0 100]);
    
    myBSS = spt.bss.surrogates_bss(myBSS, 'Verbose', false);
    
    myBSS = learn(myBSS, data);
    
    errorSurr = amari_index(projmat(myBSS)*eye(size(data,1)), 'range', [0 100]);
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(errorEfica))) < 5 & ...
        max(max(abs(errorSurr))) < 5, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% reproducibility of bss_surrogates + efica
try
    
    name = 'reproducibility of bss_surrogates + efica';
    
    X = rand(3, 15000);
    
    isCool = true;
    for i = 1:10,
        
        obj = spt.bss.surrogates_bss(spt.bss.efica, 'Verbose', false);
        
        obj = learn(obj, X);
        
        W  = projmat(obj);
        
        A  = bprojmat(learn(obj, X));
        
        obj = clear_state(obj);
        
        A2  = bprojmat(learn(obj, X));
        
        isCool = isCool & rcond(W*A) > rcond(W*A2) & ...
            max(max(abs(W*A-eye(size(X,1))))) < 0.01;
        
    end
    
    ok(isCool, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% robustness to noise
try
    
    name = 'robustness to noise';
    
    data = sample_data(10);
    
    data(:,1:1000) = data(:,1:1000) + randn(size(data,1), 1000);
    
    errorEfica = nan(1, 10);
    errorSurr  = nan(1, 10);
    for i = 1:10
        myBSS = spt.bss.efica;
        
        myBSS = learn(myBSS, data);
        
        errorEfica(i) = amari_index(projmat(myBSS)*eye(size(data,1)), 'range', [0 100]);
        
        myBSS = spt.bss.surrogates_bss(myBSS, ...
            'Verbose',      false, ...
            'Surrogator',   surrogates.shuffle('NbPoints', 1000), ...
            'NbSurrogates', 100);
        
        myBSS = learn(myBSS, data);
        
        errorSurr(i) = amari_index(projmat(myBSS)*eye(size(data,1)), 'range', [0 100]);
    end
    
    
    ok(...        
        mean(errorEfica) > mean(errorSurr) & ...
        min(errorSurr) < 50, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% bss_surrogates + efica + jade
try
    
    name = 'bss_surrogates + efica + jade';
    
    data = sample_data;
    
    myBSS = spt.bss.efica;
    
    myBSS = learn(myBSS, data);
    
    errorEfica = amari_index(projmat(myBSS)*eye(size(data,1)), 'range', [0 100]);
    
    myBSS = spt.bss.surrogates_bss(myBSS, spt.bss.jade, 'Verbose', false);
    
    myBSS = learn(myBSS, data);
    
    errorSurr = amari_index(projmat(myBSS)*eye(size(data,1)), 'range', [0 100]);
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(errorEfica))) < 5 & ...
        max(max(abs(errorSurr))) < 5, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% robustness to noise of efica+jade
try
    
    name = 'robustness to noise of efica+jade';
    
    data = sample_data(10);
    
    data(:,1:1000) = data(:,1:1000) + randn(size(data,1), 1000);
    
    errorEfica = nan(1, 10);
    errorSurr  = nan(1, 10);
    
    for i = 1:10
        myBSS = spt.bss.efica;
        
        myBSS = learn(myBSS, data);
        
        errorEfica(i) = amari_index(projmat(myBSS)*eye(size(data,1)), ...
            'range', [0 100]);
        
        myBSS = spt.bss.surrogates_bss(myBSS, spt.bss.jade, ...
            'Verbose',      false, ...
            'Surrogator',   surrogates.shuffle('NbPoints', 1000), ...
            'NbSurrogates', 100);
        
        myBSS = learn(myBSS, data);
        
        errorSurr(i) = amari_index(projmat(myBSS)*eye(size(data,1)), ...
            'range', [0 100]);
    end
    
    
    ok(...        
        mean(errorEfica) > mean(errorSurr) & ...
        min(errorSurr) < 50, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% Cleanup
try
    
    name = 'cleanup';
    clear data ans;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Testing summary
status = finalize();

end


function data = sample_data(d)

if nargin < 1 || isempty(d), d = 5; end

mySensors = subset(sensors.eeg.from_template('egi256'), 1:d);
myImporter = physioset.import.matrix('Sensors', mySensors);
data =  import(myImporter, rand(d, 20000));

end