function [status, MEh] = test_brainloc()
% TEST_BRAINLOC - Tests brainloc feature

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;

MEh     = [];

initialize(3);

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


%% sample feature extraction
try

    name = 'sample feature extraction';

    % Create sample BSS decomposition
    X = rand(10, 15000);
    A = rand(10);
    A(:,2) = zeros(10,1);
    A(2,2) = 1;
    myBSS = learn(spt.bss.efica, A*X);
    myBSS = match_sources(myBSS, A);

    mySensors = subset(sensors.eeg.from_template('egi256'), 1:20:200);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data = import(myImporter, X);

    % Select sparse components
    [featVal, featName] = extract_feature(spt.feature.brainloc, myBSS, [], data);

    ok( all(size(featVal) == [3 10]) && numel(featName) == 3, name);

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
