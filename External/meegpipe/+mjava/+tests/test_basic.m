function [status, MEh] = test_basic()

import mjava.*;
import test.simple.*;

MEh     = [];

initialize(7);

%% default constructor
try
    name = 'default constructor';
    hash;
    ok(true, name);
    
catch ME
    
    ok(false, name);
    MEh = [MEh ME];
    
end

%% multiple-key constructor
try
    
    name = 'multiple-key constructor';
    A = randn(2,20);
    B = cell(2,3);
    fh = @(x) x.^2;
    for i = 1:numel(B)
        B{i} = randn(4,10);
    end
    obj = hash('key 1', 1, 'key 2', 2, 'key 3', A, ...
        'key 4', B, 'key 5', fh);
    
    ok(true, name);
    
catch ME
    
    ok(false, name);
    MEh = [MEh ME];
    
end


%% modify/delete key
try
    
    name = 'modify/delete key';
    obj('key 6') = fh;
    obj{'key 7', 'key 8'} = {7, fh};
    obj = delete(obj, 'key 1');
    ok(true, name);
    
catch ME
    
    ok(false, name);
    MEh = [MEh ME];ok(false, name);
    
end

%% get key/values
try
    
    name = 'get key/values';
    myKeys = keys(obj);
    values(obj);
    Brec = obj('key 4');
    Brec = cell2mat(Brec);
    B = cell2mat(B);
    fhrec = obj('key 8');
    tmp = randn(1,10);
    failed =  ~all(abs(fhrec(tmp)-fh(tmp))<eps) || ...
        ~all(abs(Brec(:)-B(:))<eps) || ...
        ~isempty(setdiff(myKeys, {'key 2', 'key 2', 'key 3', 'key 4', ...
        'key 5', 'key 6', 'key 7', 'key 8'}));
    ok(~failed, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% nested hashes
try
    name = 'nested hashes';
    
    a = hash('akey', reshape(1:10, 2, 5));
    b = hash('a', a);
    
    ar = b('a');
    
    ok(all(size(ar('akey')) == size(a('akey'))), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end    

%% get_hash_code
try
    name = 'get_hash_code';
    
    a = hash('key1', reshape(1:10, 2, 5));
    b = hash('key2', a);
    
    c = hash('key1', reshape(1:10, 2, 5));
    d = hash('key2', c);
    
    ok(strcmp(get_hash_code(b), get_hash_code(d)), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end    

%% get_hash_code (single key)
try
    name = 'get_hash_code (single key)';
    
    a = hash('key1', reshape(1:10, 2, 5));
    b = hash('key1', reshape(1:10, 2, 5));
    
    ok(strcmp(get_hash_code(a), get_hash_code(b)), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end    
    

%% Testing summary
status = finalize();

end