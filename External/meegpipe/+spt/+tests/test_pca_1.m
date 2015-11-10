function [status, MEh] = test_pca_1()
% TEST_PCA_1 - Test setters/getters for pca class

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

MEh     = [];

initialize(17);

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


%% default constructor
try
    
    name = 'default constructor';
    
    myPCA = spt.pca;
    
    ok(isa(myPCA, 'spt.pca'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with arguments
try
    
    name = 'constructor with arguments';
    
    myPCA = spt.pca(...
        'RetainedVar',   50, ...
        'MaxCard',       5, ...
        'MinCard',       2, ...
        'Criterion',     'aic', ...
        'Sphering',      false, ...
        'MaxCond',       1000);
    
    ok(...
        myPCA.RetainedVar == 50 & ...
        myPCA.MaxCard     == 5 & ...
        myPCA.MinCard     == 2 & ...
        strcmp(myPCA.Criterion, 'AIC') & ...
        ~myPCA.Sphering & ...
        myPCA.MaxCond == 1000, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting invalid RetainedVar
try
    
    name = 'setting invalid RetainedVar';
    
    myPCA = spt.pca;
    try
        myPCA.RetainedVar = 200;
        condition = false;
    catch ME
        condition = strcmp(ME.identifier, ...
            'pca:set:RetainedVar:InvalidPropValue');
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting invalid RetainedVar (cont'd)
try
    
    name = 'setting invalid RetainedVar (cont''d)';
    
    myPCA = spt.pca;
    try
        myPCA.RetainedVar = @(x) -x;
        condition = false;
    catch ME
        condition = strcmp(ME.identifier, ...
            'pca:set:RetainedVar:InvalidPropValue');
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting valid RetainedVar function_handle
try
    
    name = 'setting valid RetainedVar function_handle';
    
    myPCA = spt.pca;
    try
        myPCA.RetainedVar = @(x) 100*x(1)/sum(x);
        condition = true;
    catch ME
        if strcmp(ME.identifier, ...
                'pca:set:Retained:InvalidPropValue'),
            condition = false;
        else
            rethrow(ME);
        end
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting invalid criterion
try
    
    name = 'setting invalid criterion';
    
    myPCA = spt.pca;
    try
        myPCA.Criterion = 'caca';
        condition = false;
    catch ME
        condition = strcmp(ME.identifier, ...
            'pca:set:Criterion:InvalidPropValue');
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting valid alternative criterion
try
    
    name = 'setting valid alternative criterion';
    
    myPCA = spt.pca;
    try
        myPCA.Criterion = 'MIBS';
        condition = true;
    catch ME
        if strcmp(ME.identifier, ...
                'pca:set:Criterion:InvalidPropValue'),
            condition = false;
        else
            rethrow(ME);
        end
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting invalid MinCard
try
    
    name = 'setting invalid MinCard';
    
    myPCA = spt.pca;
    try
        myPCA.MinCard = 'a';
        condition = false;
    catch ME
        condition = strcmp(ME.identifier, ...
            'pca:set:MinCard:InvalidPropValue');
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting MinCard function_handle
try
    
    name = 'setting MaxCard function_handle';
    
    myPCA = spt.pca;
    try
        myPCA.MinCard = @(x) ceil(0.5*numel(x));
        condition = true;
    catch ME
        if strcmp(ME.identifier, ...
                'pca:set:MinCard:InvalidPropValue'),
            condition = false;
        else
            rethrow(ME);
        end
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% setting invalid MaxCard
try
    
    name = 'setting invalid MaxCard';
    
    myPCA = spt.pca;
    try
        myPCA.MaxCard = 'b';
        condition = false;
    catch ME
        condition = strcmp(ME.identifier, ...
            'pca:set:MaxCard:InvalidPropValue');
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting MaxCard function_handle
try
    
    name = 'setting MaxCard function_handle';
    
    myPCA = spt.pca;
    try
        myPCA.MaxCard = @(x) ceil(0.5*numel(x));
        condition = true;
    catch ME
        if strcmp(ME.identifier, ...
                'pca:set:MaxCard:InvalidPropValue'),
            condition = false;
        else
            rethrow(ME);
        end
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting invalid Sphering
try
    
    name = 'setting invalid MaxCard';
    
    myPCA = spt.pca;
    try
        myPCA.Sphering = 5;
        condition = false;
    catch ME
        condition = strcmp(ME.identifier, ...
            'pca:set:Sphering:InvalidPropValue');
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting invalid MaxCond
try
    
    name = 'setting invalid MaxCond';
    
    myPCA = spt.pca;
    try
        myPCA.MaxCond = 0;
        condition = false;
    catch ME
        condition = strcmp(ME.identifier, ...
            'pca:set:MaxCond:InvalidPropValue');
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting invalid MinSamplesPerParamRatio
try
    
    name = 'setting invalid MinSamplesPerParamRatio';
    
    myPCA = spt.pca;
    try
        myPCA.MinSamplesPerParamRatio = -1;
        condition = false;
    catch ME
        condition = strcmp(ME.identifier, ...
            'pca:set:MinSamplesPerParamRatio:InvalidPropValue');
    end
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setting alternative MinSamplesPerParamRatio
try
    
    name = 'setting alternative MinSamplesPerParamRatio';
    
    myPCA = spt.pca;
    try
        myPCA.MinSamplesPerParamRatio = 100;
        condition = true;
    catch ME
        if strcmp(ME.identifier, ...
                'pca:set:MinSamplesPerParamRatio:InvalidPropValue'),
            condition = false;
        else
            rethrow(ME);
        end
    end
    
    ok(condition, name);
    
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

