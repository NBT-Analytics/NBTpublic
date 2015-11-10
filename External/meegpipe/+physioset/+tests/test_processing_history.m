function [status, MEh] = test_processing_history()
% TEST_PROCESSING_HISTORY - Adding and searching processing history

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

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
    MEh = [MEh ME];
    
end

%% Run pipeline and ensure history looks OK
try
    
    name = 'run pipeline and ensure history looks OK';
    data = import(physioset.import.matrix, rand(5, 100));
    
    save(data);
    
    fileName = get_hdrfile(data);
    
    myPipe = pipeline.new(...
        physioset_import.new('Importer', physioset.import.physioset), ...
        filter.new('Filter', filter.fieldtrip_butter([0 0.1])));
    
    data = run(myPipe, fileName);
    
    procH = get_processing_history(data);

    ok(...
        numel(procH) == 3 & ...
        ischar(procH{1}) & ...
        isa(procH{3}, 'meegpipe.node.filter.filter') & ...
        isa(get_config(procH{3}, 'Filter'), 'filter.fieldtrip_butter'), name);
    
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


