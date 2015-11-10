
import mperl.file.spec.*;

nTests = 7;
ok = false(1, nTests);

% TEST 1: catdir, updir, abs2rel, canonpath
fprintf('(make_tests) Test 1/%d...........', nTests);
try
    thisFile    = mfilename('fullpath');
    path        = fileparts(thisFile);
    upPath      = catdir(path, updir(), updir());
    upRelPath   = abs2rel(upPath);
    upCanonPath = canonpath(upRelPath);
    upAbsPath   = rel2abs(upCanonPath);    
    
    ok(1) = strcmpi(upPath, upAbsPath);
    if ok(1),
        fprintf('[OK]\n');
    else
        fprintf('[not OK]\n');
    end
catch ME
    fprintf('[not OK]\n');
end

% TEST 2: rootdir
fprintf('(make_tests) Test 2/%d...........', nTests);
try 
    ok(2) = strcmpi(rootdir, catdir(rootdir, updir));
    if ok(1),
        fprintf('[OK]\n');
    else
        fprintf('[not OK]\n');
    end
catch ME
    fprintf('[not OK]\n');
end

% TEST 3: splitpath, catdir
fprintf('(make_tests) Test 3/%d...........', nTests);
try 
    thisFile    = mfilename('fullpath');    
    path        = fileparts(thisFile);
    [vol, dirs, file] = splitpath(thisFile);
    ok(3) = strcmpi(rel2abs(catdir(vol, dirs)), path);    
    if ok(3),
        fprintf('[OK]\n');
    else
        fprintf('[not OK]\n');
    end
catch ME
    fprintf('[not OK]\n');
end

% TEST 4: no_upwards
fprintf('(make_tests) Test 4/%d...........', nTests);
try     
    ok(4) = strcmpi(no_upwards(updir(),pwd,updir()), pwd);    
    if ok(4),
        fprintf('[OK]\n');
    else
        fprintf('[not OK]\n');
    end
catch ME
    fprintf('[not OK]\n');
end

% TEST 5: catpath
fprintf('(make_tests) Test 5/%d...........', nTests);
try     
    thisFile    = mfilename('fullpath');    
    [vol, dirs, file] = splitpath(thisFile);
    ok(5) = strcmpi(rel2abs(catpath(vol, dirs,file)), thisFile);    
    if ok(5),
        fprintf('[OK]\n');
    else
        fprintf('[not OK]\n');
    end
catch ME
    fprintf('[not OK]\n');
end

% TEST 6: splitdir, catdir, catfile
fprintf('(make_tests) Test 6/%d...........', nTests);
try     
    thisFile    = mfilename('fullpath');    
    [path, name]= fileparts(thisFile);
    dirs        = splitdir(path);    
    ok(6) = strcmpi(rel2abs(catfile(catdir(dirs{:}), name)), thisFile);    
    if ok(6),
        fprintf('[OK]\n');
    else
        fprintf('[not OK]\n');
    end
catch ME
    fprintf('[not OK]\n');
end


% TEST 7: case_tolerant
fprintf('(make_tests) Test 7/%d...........', nTests);
try
    if isunix,
        ok(7) = ~case_tolerant;
    elseif ispc,
        ok(7) = case_tolerant;
    else
        ok(7) = false;
    end   
    if ok(7),
        fprintf('[OK]\n');
    else
        fprintf('[not OK]\n');
    end
catch ME
    fprintf('[not OK]\n');
end

