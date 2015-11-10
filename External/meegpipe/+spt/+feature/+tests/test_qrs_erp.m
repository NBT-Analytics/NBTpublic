function [status, MEh] = test_qrs_erp()
% TEST_QRS_ERP - Tests qrs_erp feature

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;
import mperl.file.spec.catfile;

MEh     = [];

initialize(8);

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
    spt.feature.qrs_erp;   
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% construction arguments
try
    
    name = 'construction arguments';
    myFeat = spt.feature.qrs_erp('Duration', 2, 'Offset', 5);   
    ok(myFeat.Duration == 2 & myFeat.Offset == 5, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% feature extraction from random data
try
    
    name = 'feature extraction from random data';
    
    tSeries = import(physioset.import.matrix, randn(4, 15000));
    myFeat = spt.feature.qrs_erp;
    featVal = extract_feature(myFeat, [], tSeries);        

    ok( numel(featVal) == 4 & all(featVal<0.5), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sample feature extraction from long physioset
try
    
    name = 'sample feature extraction from long physioset';
    
    myFeat = spt.feature.qrs_erp;
    
    data = import(physioset.import.matrix, randn(4,150000));
    
    dataOrig = data(:,:);
    
    featVal = extract_feature(myFeat, [], data);        

    ok( numel(featVal) == 4 & all(featVal<0.5) & all(featVal >=0) & ...
        max(abs(data(1,:)-dataOrig(1,:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% pre-filtering
try
    
    name = 'pre-filtering';
    
    tmp = load(catfile(meegpipe.data.root_path, 'ecg.mat'));
    ecg = tmp.ecg;
    data = import(physioset.import.matrix, randn(4,size(ecg,2)));
    ecg = ecg -mean(ecg);
    ecg = ecg./sqrt(var(ecg));
    data(2,:) = ecg;
    
    myFilt = @(sr) filter.lpfilt('fc', 40/(sr/2));
    myFeat = spt.feature.qrs_erp('Filter', myFilt);
    featVal = extract_feature(myFeat, [], data);        

    [~, I] = max(featVal);
    
    ok( I == 2 & featVal(I) > 0.75 & ...
        all(featVal(setdiff(1:4, I)) < 0.5), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% identifying ECG component
try
    
    name = 'identifying ECG component';
    
    tmp = load(catfile(meegpipe.data.root_path, 'ecg.mat'));
    ecg = tmp.ecg;
    data = import(physioset.import.matrix, randn(4,size(ecg,2)));
    data(2,:) = ecg;
    
    myFeat = spt.feature.qrs_erp;
    featVal = extract_feature(myFeat, [], data);        

    [~, I] = max(featVal);
    
    ok( I == 2 & featVal(I) > 0.75 & ...
        all(featVal(setdiff(1:4, I)) < 0.5), name);
    
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

