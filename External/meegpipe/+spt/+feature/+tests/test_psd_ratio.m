function [status, MEh] = test_psd_ratio()
% test_psd_ratio - Tests psd_ratio feature

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
    spt.feature.psd_ratio; 
    spt.feature.psd_ratio.pwl; 
    spt.feature.psd_ratio.emg; 
    spt.feature.psd_ratio.eog; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% spt.feature.psd_ratio.pwl
try
    
    name = 'spt.feature.psd_ratio.pwl';
    
    X = randn(4, 10000);    
    
    X(2,:) = .20*X(2,:) + sin(2*pi*(1/5)*(1:size(X,2)));
    data = import(physioset.import.matrix, X);
  
    featVal = extract_feature(spt.feature.psd_ratio.pwl, [], data);
   
    [~, I] = max(featVal);
    
    ok( I == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% spt.feature.psd_ratio.eog
try
    
    name = 'spt.feature.psd_ratio.eog';
    
    myFeat = spt.feature.psd_ratio.eog;
    X = randn(4, 10000);    
    data = import(physioset.import.matrix, X);
  
    myFilter = filter.bpfilt('fp', myFeat.TargetBand(1,:)/(data.SamplingRate/2));
    data(2,:) = filter(myFilter, data(2,:));
    
    featVal = extract_feature(myFeat, [], data);
   
    [~, I] = max(featVal);
    
    ok( I == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% spt.feature.psd_ratio.emg
try
    
    name = 'spt.feature.psd_ratio.emg';
    
    myFeat = spt.feature.psd_ratio.emg;
    X = randn(4, 10000);    
    data = import(physioset.import.matrix, X);
  
    myFilter = filter.bpfilt('fp', myFeat.TargetBand(1,:)/(data.SamplingRate/2));
    data(2,:) = filter(myFilter, data(2,:));
    
    featVal = extract_feature(myFeat, [], data);
   
    [~, I] = max(featVal);
    
    ok( I == 2, name);
    
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

