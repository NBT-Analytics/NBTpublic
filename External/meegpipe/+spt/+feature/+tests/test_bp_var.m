function [status, MEh] = test_bp_var()
% TEST_BP_VAR - Tests bp_var feature

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;

MEh     = [];

initialize(6);

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
    status = finalize();
    return;
    
end


%% default constructors
try
    
    name = 'default constructor';
    spt.feature.bp_var;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sample feature extraction
try
    
    name = 'sample feature extraction';
    
    myImporter = physioset.import.matrix('Sensors', sensors.eeg.dummy(4));
    A = rand(4);
    data = import(myImporter, A*rand(4, 100));
    
    myFeat = spt.feature.bp_var(...
        'DataSelector',     sensor_class('Class', 'EEG'), ...
        'AggregatingStat',  @(x,y) max(x));
    
    
    sptObj = learn(spt.bss.efica, data);
    ics = proj(sptObj, copy(data));
    
    A2 = bprojmat(sptObj);
    
    featVal = extract_feature(myFeat, sptObj, ics, data);
    
    ok(max(abs(featVal - max(A2.^2)')) < 0.0001, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% feature extraction with channel selection
try
    
    name = 'feature extraction with channel selection';
    
    myImporter = physioset.import.matrix('Sensors', sensors.eeg.dummy(4));
    data = import(myImporter, rand(4, 100));
    A = rand(4);
    data = A*data;
    
    myFeat = spt.feature.bp_var(...
        'DataSelector',     sensor_idx(1:3));
    
    sptObj = learn(spt.bss.efica, data);
    ics = proj(sptObj, data);
    
    A2 = bprojmat(sptObj);
    
    featVal = extract_feature(myFeat, sptObj, ics, data);
    
    rawVar = var(data, [], 2);
    featVal2 = nan(size(featVal));
    for i = 1:size(A,2)
        featVal2(i) = spt.feature.bp_var.max_bp_relative_var(A2(1:3,i).^2, rawVar);
    end
    
    ok(max(abs(featVal - featVal2)) < 0.0001, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% another feature extraction
try
    
    name = 'another feature extraction';
    
    myImporter = physioset.import.matrix('Sensors', sensors.eeg.dummy(4));
    A = rand(4);
    data = import(myImporter, A*rand(4, 100));
    
    myFeat = spt.feature.bp_var(...
        'DataSelector',     sensor_class('Class', 'EEG'));
    
    sptObj = learn(spt.bss.efica, data);
    ics = proj(sptObj, copy(data));
    
    A2 = bprojmat(sptObj);
    
    featVal = extract_feature(myFeat, sptObj, ics, data);
    
    rawVar = var(data, [], 2);
    featVal2 = nan(size(featVal));
    for i = 1:size(A,2)
        featVal2(i) = spt.feature.bp_var.max_bp_relative_var(A2(:,i).^2, rawVar);
    end
    
    ok(max(abs(featVal - featVal2)) < 0.0001, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data X;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();

end
