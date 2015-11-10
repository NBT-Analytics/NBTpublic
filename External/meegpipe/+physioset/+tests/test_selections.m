function [status, MEh] = test_selections()
% TEST_SELECTIONS - Test data selections

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

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
    MEh = [MEh ME];
    
end

%% relative_dim_selection
try
    
    name = 'relative_dim_selection';
    data = import(physioset.import.matrix, rand(5, 100));   
    
    select(data, [1 3 5]);
    relSel1 = relative_dim_selection(data);
    select(data, 2);
    relSel2 = relative_dim_selection(data);

    ok(...
        numel(relSel1) == 3 & all(relSel1 == [1 3 5]) ...
        & numel(relSel2) == 1 & relSel2 == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% relative_pnt_selection
try
    
    name = 'relative_pnt_selection';
    data = import(physioset.import.matrix, rand(5, 100));   
    
    select(data, [], [1 3 5]);
    relSel1 = relative_pnt_selection(data);
    select(data, [], 2);
    relSel2 = relative_pnt_selection(data);

    ok(...
        numel(relSel1) == 3 & all(relSel1 == [1 3 5]) ...
        & numel(relSel2) == 1 & relSel2 == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% relative_dim_selection & relative_pnt_selection
try
    
    name = 'relative_dim_selection & relative_pnt_selection';
    data = import(physioset.import.matrix, rand(5, 100));   
    
    select(data, [1 3 5], [1 3 5]);
    relSelPnt1 = relative_pnt_selection(data);
    relSelDim1 = relative_dim_selection(data);
    select(data, 2, 2);
    relSelPnt2 = relative_pnt_selection(data);
    relSelDim2 = relative_dim_selection(data);
    
    ok(...
        numel(relSelPnt1) == 3 & all(relSelPnt1 == [1 3 5]) ...
        & numel(relSelPnt2) == 1 & relSelPnt2 == 2 & ...
        numel(relSelDim1) == 3 & all(relSelDim1 == [1 3 5]) ...
        & numel(relSelDim2) == 1 & relSelDim2 == 2, ...
        name);
    
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


