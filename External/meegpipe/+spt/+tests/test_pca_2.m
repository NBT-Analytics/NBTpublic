function [status, MEh] = test_pca_2()
% TEST_PCA_2 - Test functionality of pca class

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

MEh     = [];

% Number of iterations to perform when computing model selection indices.
% Increase for better robustness at the cost of computation time
NB_ITER = 15;

initialize(15);

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


%% learning PCA basis from physioset
try
    
    name = 'learning PCA basis';
    
    data = import(physioset.import.matrix, rand(5,1000));
    myPCA = learn(spt.pca, data);
    
    pcs = proj(myPCA, data);
    
    ok(myPCA.DimOut == 5 & myPCA.DimIn == 5 & ...
        max(max((abs(cov(pcs) - eye(5))))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% learning PCA basis from numeric
try
    
    name = 'learning PCA basis from numeric';
    
    data = rand(5,1000);
    myPCA = learn(spt.pca, data);
    
    pcs = proj(myPCA, data);
    
    ok(myPCA.DimOut == 5 & myPCA.DimIn == 5 & ...
        max(max((abs(cov(pcs') - eye(5))))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reducing dimensionality
try
    
    name = 'reducing dimensionality';
    
    data = import(physioset.import.matrix, rand(5,1000));
    
    myPCA = spt.pca('MaxCard', 3);
    myPCA = learn(myPCA, data);
    
    pcs = proj(myPCA, data);
    
    ok(myPCA.DimOut == 3 & myPCA.DimIn == 5 & ...
        max(max((abs(cov(pcs) - eye(3))))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% backprojecting, restoring sensors
try
    
    name = 'backprojecting, restoring sensors';
    
    mySensors = sensors.eeg.dummy(5);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data = import(myImporter, rand(5,1000));
    
    myPCA = spt.pca('MaxCard', 3);
    myPCA = learn(myPCA, data);
    
    pcs = proj(myPCA, data);
    
    sensPCs = sensors(pcs);
    
    dataR = bproj(myPCA, pcs);
    
    sensR = sensors(dataR);
    
    ok(isa(sensPCs, 'sensors.dummy') & ...
        isa(sensR, 'sensors.eeg'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% RetainedVar
try
    
    name = 'RetainedVar';
    
    mySensors = sensors.eeg.dummy(5);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data = import(myImporter, rand(5,1000));
    
    myPCA = spt.pca('RetainedVar', 50);
    myPCA = learn(myPCA, data);
    
    pcs = proj(myPCA, data);   
    
    ok(size(pcs, 1) < 5, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% RetainedVar overriden by MinCard
try
    
    name = 'RetainedVar overriden by MinCard';
    
    mySensors = sensors.eeg.dummy(5);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data = import(myImporter, rand(5,1000));
    
    myPCA = spt.pca('RetainedVar', 0, 'MinCard', 4);
    myPCA = learn(myPCA, data);
    
    pcs = proj(myPCA, data);   
    
    ok(size(pcs, 1) == 4, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% MaxCard overriden by MinCard
try
    
    name = 'MaxCard overriden by MinCard';
    
    mySensors = sensors.eeg.dummy(5);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data = import(myImporter, rand(5,1000));
    
    myPCA = spt.pca('MaxCard', 2, 'MinCard', 4);
    myPCA = learn(myPCA, data);
    
    pcs = proj(myPCA, data);   
    
    ok(size(pcs, 1) == 4, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% MinSamplesPerParamRatio
try
    
    name = 'MinSamplesPerParamRatio';
    
    mySensors = sensors.eeg.dummy(5);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data = import(myImporter, rand(5,100));
    
    myPCA = spt.pca('MinSamplesPerParamRatio', 10);
    myPCA = learn(myPCA, data);
    
    pcs = proj(myPCA, data);   
    
    ok(size(pcs, 1) == 3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Sphering=false
try
    
    name = 'Sphering=false';
    
    mySensors = sensors.eeg.dummy(5);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data = import(myImporter, rand(5,100));
    
    myPCA = spt.pca('Sphering', false);
    myPCA = learn(myPCA, data);
    
    pcs = proj(myPCA, data);  
    
    pcVars = var(pcs, [], 2);
    
    ok(all(diff(pcVars)<0), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Criterion=mdl
try
    
    name = 'Criterion=mdl';
    
    mySensors = sensors.eeg.dummy(5);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    X = rand(5,3)*rand(3, 10000) + 0.01*randn(5, 10000);    
    
    data = import(myImporter, X);
    
    myPCA = spt.pca('Criterion', 'NONE', 'RetainedVar', 100);
    myPCA = learn(myPCA, data); 
    
    origDim = myPCA.DimOut;

    newDim = nan(1, 5);
    for i = 1:NB_ITER,
        X = rand(5,3)*rand(3, 10000) + 0.01*randn(5, 10000);
        data = import(myImporter, X);
        myPCA = spt.pca('Criterion', 'MDL', 'RetainedVar', 100);
        myPCA = learn(myPCA, data);
        newDim(i) = myPCA.DimOut;
    end
    newDim = median(newDim);
    
    ok(origDim == 5 & newDim == 3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Criterion=aic
try
    
    name = 'Criterion=aic';
    
    mySensors = sensors.eeg.dummy(5);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    X = rand(5,3)*rand(3, 10000) + 0.01*randn(5, 10000);    
    
    data = import(myImporter, X);
    
    myPCA = spt.pca('Criterion', 'NONE', 'RetainedVar', 100);
    myPCA = learn(myPCA, data); 
    
    origDim = myPCA.DimOut;

    newDim = nan(1, 10);
    for i = 1:NB_ITER,
        X = rand(5,3)*rand(3, 10000) + 0.01*randn(5, 10000);
        data = import(myImporter, X);
        myPCA = spt.pca('Criterion', 'AIC', 'RetainedVar', 100);
        myPCA = learn(myPCA, data);
        newDim(i) = myPCA.DimOut;
    end
    newDim = median(newDim);
    
    ok(origDim == 5 & newDim == 3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Criterion=mibs
try
    
    name = 'Criterion=mibs';
    
    mySensors = sensors.eeg.dummy(5);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    X = rand(5,3)*rand(3, 10000) + 0.01*randn(5, 10000);    
    
    data = import(myImporter, X);
    
    myPCA = spt.pca('Criterion', 'NONE', 'RetainedVar', 100);
    myPCA = learn(myPCA, data); 
    
    origDim = myPCA.DimOut;
    
    newDim = nan(1, 10);
    for i = 1:NB_ITER,
        X = rand(5,3)*rand(3, 10000) + 0.01*randn(5, 10000);
        data = import(myImporter, X);
        myPCA = spt.pca('Criterion', 'MIBS', 'RetainedVar', 100);
        myPCA = learn(myPCA, data);
        newDim(i) = myPCA.DimOut;
    end
    newDim = median(newDim);
    
    ok(origDim == 5 & newDim == 3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reverse component sorting
try
    
    name = 'reverse component sorting';
    
    X = rand(5,1000);
    myPCA = learn(spt.pca('Sphering', false), X);
    
    pcs = proj(myPCA, X);
    
    condition = all(diff(var(pcs, [], 2)) < 0);
    
    if condition,
        myPCA = sort(myPCA, 5:-1:1);
        
        pcs = proj(myPCA, X);
        
        condition = all(diff(var(pcs, [], 2)) > 0);
        
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


