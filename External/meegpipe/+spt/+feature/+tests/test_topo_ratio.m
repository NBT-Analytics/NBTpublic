function [status, MEh] = test_topo_ratio()
% test_topo_ratio - Tests topo_ratio criterion

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;

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
    spt.feature.topo_ratio;
    spt.feature.topo_ratio.eog_egi256_hcgsn1;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Right construction arguments
try
    
    name = 'construction arguments';
    
    % A string (i.e. a regex)
    spt.feature.topo_ratio('SensorsDen', 'EEG\s+\d+');
    
    % A cell array of strings
    spt.feature.topo_ratio('SensorsDen', {'EEG 1','EEG 2'});
    
    ok( true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% spatial smoothing (dim>30 and has_coords)
try
    
    name = 'spatial smoothing (dim>30 and has_coords)';
    
    mySens = sensors.eeg.from_template('egi256');
    myImporter = physioset.import.matrix('Sensors', mySens);
    
    X = rand(257, 10)*randn(10, 1000);
    data = import(myImporter, X);
    
    sptObj = learn(spt.pca('RetainedVar', 99.99), data);
    
    myFeat = spt.feature.topo_ratio.eog_egi256_hcgsn1;
    extract_feature(myFeat, sptObj, randn(10, 1000), data);
    
    ok( true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Wrong construction arguments
try
    name = 'wrong construction arguments';
    
    warning('off', 'process_arguments:UnknownOption');
    spt.feature.topo_ratio('SensorsDendd', 'a');
    warning('on', 'process_arguments:UnknownOption');
    [~, id] = lastwarn;
    
    condition = strcmp(id, 'process_arguments:UnknownOption');
    
    try 
        spt.feature.topo_ratio('SensorsDen', 5);
        spt.feature.topo_ratio('SensorsDen', {'aa', 5});
        spt.feature.topo_ratio('SensorsDen', {{'a', 5}, 'b'});
        condition = false;
    catch ME
        if ~strcmp(ME.identifier, 'topo_ratio:set:SensorsDen:InvalidPropValue')
            rethrow(ME);
        end
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Sample selection
try
    
    name = 'sample selection';
    
    [data, A] = sample_data();
    
    myFeat = spt.feature.topo_ratio(...
        'SensorsNumLeft', {'1', '2'});

    sptObj = learn(spt.bss.efica, data);
    sptObj = match_sources(sptObj, A);
    ics = proj(sptObj, data);
    
    feat = extract_feature(myFeat, sptObj, ics, data);        
    
    [~, I] = sort(feat);
    
    ok(all(ismember(I(end-1:end), [1 2])), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% empty channel selection
try
    
    name = 'empty channel selection';
    
    [data, A] = sample_data();
    
    myFeat = spt.feature.topo_ratio(...
        'SensorsNumLeft', 'XXXX (1|2)$');

    sptObj = learn(spt.bss.efica, data);
    sptObj = match_sources(sptObj, A);
    ics = proj(sptObj, data);
    
    warning('off', 'topo_ratio:EmptyNumSet');
    feat = extract_feature(myFeat, sptObj, ics, data);        
    warning('on', 'topo_ratio:EmptyNumSet');
    
    [~, id] = lastwarn;
    
    [~, I] = sort(feat);
    
    ok( strcmp(id, 'topo_ratio:EmptyNumSet') & ...
        all(I(1:2)' == 1:2), name);
    
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

function [data, A] = sample_data()


X = rand(10, 1000);

sensObj = subset(sensors.eeg.from_template('egi256'), 1:10);

A = misc.unit_norm(rand(10));

A = A + diag(10*max(A(:))*ones(1, size(A,1)));

data = import(physioset.import.matrix('Sensors', sensObj), A*X);


end