function [status, MEh] = test_operators()
% TEST_OPERATORS - Test basic mathematic operators

import mperl.file.spec.*;
import pset.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

initialize(12);

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

%% abs()
try
    name = 'abs()';
    data = pset.pset.randn(2,3000);
    orig = data(:,:);
    abs(data);    
   
    ok(all(data(:) == abs(orig(:))), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% unary_operator()
try
    
    name = 'unary_operator()';
    data = pset.pset.randn(2,3000);
    orig = data(:,:);
    abs(data);    
   
    ok(all(data(:) == abs(orig(:))), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% mtimes()
try
    
    name = 'mtimes()';
    data = pset.pset.randn(2,3000);
    A = rand(2);
    origData = data(:,:);
    dataNew = A*data;
    condition = max(abs(dataNew(:) - data(:))) < 0.01 & ...
        max(max(abs(A*origData - data(:,:)))) < 0.01;
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% A*B'
try
    
    name = 'A*B''';
    data1 = pset.pset.randn(2, 3000);
    data2 = pset.pset.randn(2, 3000);
    origData1 = data1(:,:);
    origData2 = data2(:,:);
    
    dataNew = data1*transpose(data2);
    
    transpose(data2);
    
    condition = ...
        max(abs(origData1(:) - data1(:))) < 0.01 & ...
        max(abs(origData2(:) - data2(:))) < 0.01 & ...
        max(max(abs(dataNew(:,:) - origData1*origData2'))) < 0.01 & ...
        size(dataNew,1) == size(data1, 1) & ...
        size(dataNew,2) == size(data2, 1);

    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% pow()
try
    
    name = 'pow()';
    data = pset.pset.randn(2,3000);
    origData = data(:,:);
    dataNew = data.^2;
    condition = max(abs(dataNew(:) - data(:))) < 0.01 & ...
        max(abs(origData(:).^2 - data(:))) < 0.01;
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% var()
try
    
    name = 'var()';
    data = 5+pset.pset.randn(5,3000);
    
    origData = data(:,:);
    trueVar = var(data(:,:), [], 2);
    psetVar = var(data, [], 2);
    
    ok(max(abs(trueVar-psetVar)) < 0.1 & ...
        max(abs(origData(:)-data(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% plus()
try
    
    name = 'plus()';
    data1 = pset.pset.randn(5,3000);
    data2 = pset.pset.randn(5,3000);
    sumVal = data1(:,:) + data2(:,:);
    
    data1 = data1 + data2;
    
    ok(max(abs(data1(:)-sumVal(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% plus() with selections
try
    
    name = 'plus() with selections';
    data1 = pset.pset.randn(5,3000);
    data2 = pset.pset.randn(5,3000);
    sumVal = data1(1:2,:) + data2(4:5,:);
    
    select(data1, 1:2);
    select(data2, 4:5);
    data1 = data1 + data2;
    
    ok(max(abs(data1(:)-sumVal(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% assign_values
try
    
    name = 'assign_values';
    data1 = pset.pset.randn(5,3000);
    data2 = pset.pset.randn(5,3000);
    data1 = assign_values(data1, data2);
    ok(max(abs(data1(:)-data2(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% assign_values with selections
try
    
    name = 'assign_values with selections';
    data1 = pset.pset.randn(5,3000);
    data2 = pset.pset.randn(5,3000);
    select(data1, 1:2);
    select(data2, 4:5);
    data1 = assign_values(data1, data2);
    clear_selection(data1);
    clear_selection(data2);
    ok(max(max(abs(data1(1:2,:)-data2(4:5,:)))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup';
    clear obj ans;
    pause(1);
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    rmdir(session.instance.Folder, 's');
    ok(true, name);
    
catch ME
    ok(ME, name);
    MEh = [MEh ME];
end


status = finalize();
