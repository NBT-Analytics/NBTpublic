function [status, MEh] = test_erp()
% TEST_ERP - Tests erp feature

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;
import mperl.file.spec.catfile;

MEh     = [];

initialize(10);

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
    spt.feature.erp;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% construction arguments
try
    
    name = 'construction arguments';
    myFeat = spt.feature.erp('Duration', 2, 'Offset', 5);
    ok(myFeat.Duration == 2 & myFeat.Offset == 5, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% invalid Filter
try
    
    name = 'invalid Filter';
    myFilt = @(sr) sr; % Does not evaluate to a filter.dfilt object
    
    try
        myFeat = spt.feature.erp('Filter', myFilt, 'Offset', 5);
        condition = false;
    catch ME
        if strcmp(ME.identifier, 'erp:set:Filter:InvalidPropValue'),
            condition = true;
        else
            rethrow(ME);
        end
    end
    ok(condition & myFeat.Offset == 5, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% valid Filter
try
    
    name = 'valid Filter';
    myFilt = @(sr) filter.lpfilt('fc', 5/(sr/2)); 
    
    myFeat = spt.feature.erp('Filter', myFilt, 'Offset', 5);    
    ok(myFeat.Offset == 5, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% no events
try
    
    name = 'no events';
    
    tSeries = import(physioset.import.matrix, randn(4, 15000));
    myFeat  = spt.feature.erp;
    warning('off', 'feature:erp:NoEvents');
    featVal = extract_feature(myFeat, [], tSeries);
    warning('off', 'feature:erp:NoEvents');
    
    [~, id] = lastwarn;
    
    ok( numel(featVal) == 4 & all(featVal == 0) & ...
        strcmp(id, 'feature:erp:NoEvents'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% random data
try
    
    name = 'random data';
    
    data = import(physioset.import.matrix, randn(4,15000));
    
    evArray = physioset.event.std.epoch_begin(1:300:14000, 'Duration', 250);
    
    add_event(data, evArray);
    
    dataOrig = data(:,:);
    
    mySel = physioset.event.class_selector('Class', 'epoch_begin');
    myFeat = spt.feature.erp('EventSelector', mySel);
    
    featVal = extract_feature(myFeat, [], data);
    
    ok( numel(featVal) == 4 & all(featVal<0.5) & all(featVal >=0) & ...
        max(abs(data(1,:)-dataOrig(1,:))) < 0.01, name);
    
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
    
    peakLoc = fmrib.my_fmrib_qrsdetect(ecg, 250, false);
    evArray = physioset.event.std.epoch_begin(peakLoc);
    add_event(data, evArray);
    
    mySel = physioset.event.class_selector('Class', 'epoch_begin');
    myFeat = spt.feature.erp('EventSelector', mySel, ...
        'Duration', 0.8, 'Offset', -0.2);
    featVal = extract_feature(myFeat, [], data);
    
    [~, I] = max(featVal);
    
    ok( I == 2 & featVal(I) > 0.75 & ...
        all(featVal(setdiff(1:4, I)) < 0.5), name);
    
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
    data(2,:) = ecg;
    
    peakLoc = fmrib.my_fmrib_qrsdetect(ecg, 250, false);
    evArray = physioset.event.std.epoch_begin(peakLoc);
    add_event(data, evArray);
    
    mySel = physioset.event.class_selector('Class', 'epoch_begin');
    myFeat = spt.feature.erp(...
        'EventSelector',    mySel, ...
        'Duration',         0.8, ...
        'Offset',           -0.2, ...
        'Filter',           @(sr) filter.lpfilt('fc', 40/(sr/2)));
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

