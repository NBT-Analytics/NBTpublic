% DEMO - Demonstrates functionality of package report.table
%
%
% See also: table

% Documentation: pkg_report_table.txt
% Description: Demonstrates package functionality

import meegpipe.root_path;
import mperl.file.spec.catfile;
import safefid.safefid;

if ~exist('INTERACTIVE', 'var') || isempty(INTERACTIVE),
    INTERACTIVE = true;
end

if ~exist('FILE', 'var') || isempty(FILE),
    FILE = catfile(root_path, '+report/+table', 'test.txt');
end

if INTERACTIVE, echo on; close all; clc; end

% Construct a table object
import report.table.*;
myTable = table('Title', 'Some table');
if INTERACTIVE, pause; clc; end

% Add two columns to the table
add_column(myTable, 'Parameter', 'value');
if INTERACTIVE, pause; clc; end

% Add a third column
add_column(myTable, 'Description');
if INTERACTIVE, pause; clc; end

% Add a column between the first and second columns
add_column(myTable, 2, 'Type');
if INTERACTIVE, pause; clc; end

% Add a couple of rows
add_row(myTable, 'Name', 'String', 'Useless', '');
add_row(myTable, 'PCA', 'spt.pca', 'PCA block', ...
    'Prin. Comp. Anal.');
if INTERACTIVE, pause; clc; end

% Add a row just before the second row
add_row(myTable, 2, 'BSS', 'spt.spt', 'ICA algorithm', '');
if INTERACTIVE, pause; clc; end

% Fetch the 2nd row
row = fetch_row(myTable, 2);
if INTERACTIVE, pause; clc; end

% Delete the 2nd row and the 5th column
del_row(myTable, 2);
del_column(myTable, 4); % OR: del_col(myTable, 'Description')
if INTERACTIVE, pause; clc; end

% Fetch all rows at once (in two different ways)
allRows = fetch_row(myTable); %#ok<*NASGU>
allRows = fetch_row(myTable, 1:nb_rows(myTable));
if INTERACTIVE, pause; clc; end

% Fetch all column names (in two different ways)
allCols = fetch_column(myTable);
allCols = fetch_column(myTable, 1:nb_cols(myTable));
if INTERACTIVE, pause; clc; end

% Print the table to an open file
fid = safefid.fopentmp(FILE, 'w');
fprintf(fid, myTable);
if INTERACTIVE, pause; clc; end

clear fid; % Will also close and delete the file
