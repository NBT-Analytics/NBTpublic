function [status, MEh] = test_psd_peak()
% test_psd_peak - Tests psd_peak feature

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;

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
    status = finalize();
    return;
    
end


%% default constructors
try
    
    name = 'constructor(s)';
    
    spt.feature.psd_peak.alpha;    
    spt.feature.psd_peak.pwl;    
    myFeat = spt.feature.psd_peak('TargetBand', [8 10]); 
    ok(all(myFeat.TargetBand == [8 10]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% characterize 50Hz peak
try
    
    name = 'characterize 50Hz peak';
    
    X = randn(4, 10000);    
    
    X(2,:) = .20*X(2,:) + sin(2*pi*(1/5)*(1:size(X,2)));
    data = import(physioset.import.matrix, X);
  
    featVal = extract_feature(spt.feature.psd_peak.pwl, [], data);
   
    [~, I] = max(featVal(1,:));
    
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

