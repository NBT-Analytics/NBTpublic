function [status, MEh] = test_eeglab()
% TEST_EEGLAB - Test eeglab exporter

import mperl.file.spec.*;
import physioset.export.eeglab;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

initialize(11);

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


%% default constructor
try
    
    name = 'constructor';
    eeglab;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% contructor with arguments
try
    
    name = 'contructor with arguments';
    obj = eeglab('MemoryMapped', true, 'BadDataPolicy', 'flatten');
    ok(obj.MemoryMapped & strcmp(obj.BadDataPolicy, 'flatten'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% wrong arguments
try
    
    name = 'wrong arguments';
    ME = [];
    try
        eeglab('WrongArg', true, 'BadDataPolicy', 'flatten');
    catch ME
        if strcmp(ME.identifier, 'MATLAB:noPublicFieldForClass')
            ok(true, name);
        else
            rethrow(ME);
        end
    end
    if isempty(ME),
        ok(false, name);
    end
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% wrong argument values
try
    name = 'wrong argument values';
    ME = [];
    try
        eeglab('MemoryMapped', true, 'BadDataPolicy', 'notgood');
    catch ME
        if strcmp(ME.identifier, 'eeglab:set:BadDataPolicy:InvalidPropValue')
            ok(true, name);
        else
            rethrow(ME);
        end
    end
    if isempty(ME),
        ok(false, name);
    end
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% export sample physioset
try
    
    name = 'export sample physioset';
    
    X    = randn(10, 1000);
    data = import(physioset.import.matrix, X);
    
    fName = export(physioset.export.eeglab, data);
    
    ok(exist(fName, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% export multiple physiosets
try
    
    name = 'export multiple physiosets';
    
    data = cell(1, 3);
    for i = 1:3
        X    = randn(10, 1000);
        data{i} = import(physioset.import.matrix, X);
    end
    
    fName = export(physioset.export.eeglab, data);
    
    ok(all(cellfun(@(x) exist(x, 'file') > 0, fName)), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% rejecting bad data
try
    
    name = 'rejecting bad data';
    
    X    = randn(10, 1000);
    data = import(physioset.import.matrix, X);
    
    set_bad_sample(data, 101:200);
    
    set_bad_channel(data, 2:3);
    
    warning('off', 'fieldtrip:Obsolete');
    myExporter = physioset.export.eeglab('BadDataPolicy', 'reject');
    warning('on', 'fieldtrip:Obsolete');
    warning('off', 'deal_with_bad_data:Obsolete');
    fName = export(myExporter, data);
    warning('on', 'deal_with_bad_data:Obsolete');
    
    % Now reimport and see what was actually exporter
    warning('off', 'sensors:InvalidLabel');
    warning('off', 'sensors:MissingPhysDim');
    data2 = import(physioset.import.eeglab, fName);
    warning('on', 'sensors:InvalidLabel');
    warning('on', 'sensors:MissingPhysDim');
    ok(all(size(data2) == [8 900]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% specify generated file name
try
    
    name = 'specify generated file name';
    
    X    = randn(10, 1000);
    data = import(physioset.import.matrix, X);
    
    fName = rel2abs(session.instance.tempname);
    
    fName2 = export(physioset.export.eeglab, data, fName);
   
    fName = strrep(fName, '\', '/');
    ok(exist(fName2, 'file') && strcmp(fName2, [fName '.set'])> 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% specify generated file name in importer object
try
    
    name = 'specify generated file name in importer object';
    
    X    = randn(10, 1000);
    data = import(physioset.import.matrix, X);
    
    fName = rel2abs(session.instance.tempname);
    
    myExporter = physioset.export.eeglab('FileName', fName);
    
    fName2 = export(myExporter, data);
   
    fName = strrep(fName, '\', '/');
    ok(exist(fName2, 'file') && strcmp(fName2, [fName '.set'])> 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data data2;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    rmdir(session.instance.Folder, 's');
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();