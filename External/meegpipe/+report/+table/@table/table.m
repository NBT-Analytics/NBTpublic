classdef table < goo.printable_handle & goo.abstract_configurable_handle
    % TABLE - Remark table class
    %
    % A convenience class to ease printing Remark tables to reports.
    %
    % 
    % ## Usage synopsis:
    %
    % % Construct a table object
    % import report.table.*;
    % table('Title', 'Some table');
    %
    % % Add two columns to the table
    % add_column(myTable, 'Parameter', 'value');
    %
    % % Add a third column
    % add_column(myTable, 'Description');
    %
    % % Add a column between the first and second columns
    % add_column(myTable, 2, 'Type');
    %
    % % Add a couple of rows
    % add_row(myTable, 'Name', 'String', 'Useless', '');
    % add_row(myTable, 'PCA', 'spt.pca', 'PCA block', 'Prin. Comp. Anal.');
    %
    % % Add a row just before the second row
    % add_row(myTable, 2, 'BSS', 'spt.spt', 'ICA algorithm', '');
    %
    % % Fetch the 2nd row
    % row = fetch_row(myTable, 2);
    %
    % % Delete the 2nd row and the 5th column
    % del_row(myTable, 2);
    % del_column(myTable, 4); % OR: del_col(myTable, 'Description') 
    %
    % % Fetch all rows at once (in two different ways)
    % allRows = fetch_row(myTable);
    % allRows = fetch_row(myTable, 1:nb_rows(myTable));
    %
    % % Fetch all column names (in two different ways)
    % allCols = fetch_column(myTable);
    % allCols = fetch_column(myTable, 1:nb_cols(myTable));
    %
    % % Print the table to an open file
    % fid = fopen('table.txt', 'w');
    % fprintf(fid, myTable);
    % fclose(fid);
    %
    % 
    % See also: config, demo, make_test
    
    % Documentation: class_report_table_table.txt
    % Description: Remark table class
    
    %% IMPLEMENTATION .....................................................
    
    properties (SetAccess = private, GetAccess = private)
       
        Columns     = {};
        Rows        = {};
        RefNames    = {};
        RefTargets  = {};
        
    end
    
    %% PUBLIC INTERFACE ...................................................
    
    methods
       
        % Modifiers
        obj = add_column(obj, varargin);
        
        obj = del_column(obj, idx);
        
        obj = add_row(obj, varargin);
        
        obj = del_row(obj, idx);
        
        obj = add_ref(obj, name, target);
        
        % Accessors
        row = fetch_row(obj, idx);
        
        col = fetch_col(obj, idx);
        
        cellArray = fetch_cell(obj, i, j);
        
        nbCols = nb_cols(obj);
        
        nbRows = nb_rows(obj);
        
        nbRefs = nb_refs(obj);
        
        [name, target] = get_ref(obj, i);
     
        % goo.printable interface
        count = fprintf(fid, obj);
        
    end
    
    % Constructor
    methods
        
        function obj = table(varargin)
            
            obj = obj@goo.abstract_configurable_handle(varargin{:}); 
            
        end
    end
    
    
end