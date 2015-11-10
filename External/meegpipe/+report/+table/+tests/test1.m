function [status, MEh] = test1()
% TEST1 - Tests demo functionality

import mperl.file.spec.*;
import report.table.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;

MEh     = [];

initialize(11);

%% Create a test dir
try
    name = 'create test dir';
    warning('off', 'session:NewSession');
    PATH = catdir(session.instance.Folder, DataHash(randn(1,100)));
    mkdir(PATH);
    warning('on', 'session:NewSession');
    
    FILE = catfile(PATH, 'test.txt');
    
catch ME
    ok(ME, name);
    status = finalize();
    return;
end
ok(true, name);

%% constructor
try
    
    name = 'constructor';
    myTable = table('Title', 'Some table');
    ok(strcmp(get(myTable, 'Title'), 'Some table'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Add table columns
try
    
    name = 'add table columns';
    add_column(myTable, 'Parameter',  'value');
    add_column(myTable, 'Description');
    ok(nb_cols(myTable) == 3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% interleave columns
try
    
    name = 'interleave columns';
    add_column(myTable, 2, 'Type');
    ok(nb_cols(myTable) == 4, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% add a couple of rows
try
    
    name = 'add rows';
    add_row(myTable, 'Name', 'String', 'Useless', '');
    add_row(myTable, 'PCA', 'spt.pca', 'PCA block', ...
        'Prin. Comp. Anal.');
    
    ok(nb_rows(myTable) == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% fetch row
try
    
    name = 'fetch row';
    row = fetch_row(myTable, 2);      
    ok(iscell(row) && ~isempty(row), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

% Delete the 2nd row and the 5th column
try
    
    name = 'delete row/column';
    del_row(myTable, 2);
    del_column(myTable, 4); % OR: del_col(myTable, 'Description')
    ok(nb_cols(myTable) == 3 && nb_rows(myTable) ==  1, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% fetch all rows at once
try
    
    name = 'fetch all rows';
    allRows1 = fetch_row(myTable); %#ok<*NASGU>
    allRows2 = fetch_row(myTable, 1:nb_rows(myTable));
    ok(iscell(allRows1) && iscell(allRows2) && ...
        numel(allRows1) == numel(allRows2) && ...
        all(cellfun(@(x,y) strcmp(x, y), allRows1, allRows2)), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% fetch all columns
try
    
    name = 'fetch all columns';
    allCols1 = fetch_column(myTable);
    allCols2 = fetch_column(myTable, 1:nb_cols(myTable));
    ok(iscell(allCols1) && iscell(allCols2) && ...
        numel(allCols1) == numel(allCols2) && ...
        all(cellfun(@(x,y) strcmp(x, y), allCols1, allCols2)), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% print table
try
    
    name = 'print table to file';
    fid = safefid.fopentmp(FILE, 'w');
    fprintf(fid, myTable);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    name = 'cleanup';
    clear fid myTable;
    rmdir(PATH, 's');
    ok(true, name);
    
catch ME
    ok(ME, name);
end


%% Testing summary
status = finalize();

end