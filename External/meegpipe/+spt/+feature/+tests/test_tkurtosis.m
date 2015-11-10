function [status, MEh] = test_tkurtosis()
% test_tkurtosis - Tests tkurtosis feature

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;

MEh     = [];

initialize(5);

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
    spt.feature.tkurtosis;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Sample feature extraction
try
    
    name = 'Sample feature extraction';
    
    myFeat = spt.feature.tkurtosis(...
        'Nonlinearity', @(x) x, 'MedFiltOrder', 10);
    
    featVal = extract_feature(myFeat, [], randn(4,150000));
    
    ok( numel(featVal) == 4 & all(featVal>2.5) & all(featVal<3.5), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Sample feature extraction from physioset
try
    
    name = 'Sample feature extraction from physioset';
    
    myFeat = spt.feature.tkurtosis(...
        'Nonlinearity', @(x) x, 'MedFiltOrder', 10);
    
    data = import(physioset.import.matrix, randn(4,150000));
    
    dataOrig = data(:,:);
    
    featVal = extract_feature(myFeat, [], data);
    
    ok( numel(featVal) == 4 & all(featVal>2.5) & all(featVal<3.5) & ...
        max(abs(data(1,:) - dataOrig(1,:))) < 0.01, name);
    
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

