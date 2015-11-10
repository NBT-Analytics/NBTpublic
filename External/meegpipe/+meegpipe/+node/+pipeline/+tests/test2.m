function [status, MEh] = test2()
% TEST2 - Template-based pipelines

import test.simple.*;

MEh     = [];

templates = {...
    'basic', ...
    'bcg_obs' ...
    };    

initialize(numel(templates));


%% default constructors
for i = 1:numel(templates)
    try
        
        name = templates{i};
        feval(['meegpipe.node.pipeline.' templates{i}]);
        ok(true, name);
        
    catch ME
        
        ok(ME, name);
        MEh = [MEh ME]; %#ok<AGROW>
        
    end
end


%% Testing summary
status = finalize();