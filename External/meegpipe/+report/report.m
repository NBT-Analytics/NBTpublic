classdef report <  ...
        goo.abstract_configurable_handle & ...
        goo.verbose_handle
    % REPORT - Interface for report classes
    %
    %
    % See also: report.generic.generic
    
    % Description: Interface for report classes
    % Documentation: ifc_report.txt
    
    methods (Abstract)        
  
        obj = childof(obj, parent);
        
        % Print arbitrary text to report
        
        count = fprintf(obj, varargin);
        
        % Same as fprintf but assumes text and breaks lines
        count = print_text(obj, varargin);       
        
        % Remark macros/syntax
        
        count = print_title(obj, title, varargin);        
        
        count = print_parent(obj, parent);
        
        count = print_paragraph(obj, varargin);
        
        count = print_code(obj, code, varargin);
        
        count = print_link(obj, link, varargin);
        
        count = print_ref(obj, target, name);
        
        count = print_file_link(obj, link, varargin);
        
        count = print_gallery(obj, gallery, varargin);        
    
       % set/get report title and associated level
        obj = set_title(obj, title);
        
        obj = set_level(obj, level);
        
        ref         = get_ref(obj);
    
        title       = get_title(obj);
        
        level       = get_level(obj); 
     
        % root dir of the report directory tree
        fPath       = get_rootpath(obj);
        
        fName       = get_filename(obj);
        
        % Prepare generator to run generate(), mostly associate the
        % generator to a valid open file handle
        obj = initialize(obj, data);   
        
        % true if report is already associated with an open file handle
        bool = initialized(obj);        
        
        % Generate report content
        obj = generate(obj, varargin);
        
        % compile the report using Remark
        obj = compile(obj);
    
    end
    
end