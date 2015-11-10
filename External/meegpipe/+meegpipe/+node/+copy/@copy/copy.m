classdef copy < meegpipe.node.abstract_node
    % COPY - Copies the input data
    %
    % obj2 = copy(obj1)
    % obj2 = copy(obj1, 'key', value, ...)
    %
    %
    % Where
    %
    % OBJ1 is a pset.physioset object
    %
    % OBJ2 is a pset.physioset object that contains the same data as OBJ1 but
    % that is associated to a different memory-mapped disk file. Thus,
    % modifying OBJ2 has no effect on OBJ1 and viceversa.
    %
    %
    % ## Accepted key/value pairs:
    %
    % * All key/value pairs accepted by aar.node.abstract_node and:
    %
    % 'Filename'    : (char) The name of the file that is associated with
    %                 the output pset.physioset object.
    %                 Default: []
    %
    % 'Postfix'     : (char) If the Filename key is not provided, this key
    %                 will lead to an output file whose name is identical
    %                 to the input file name but with the provided postfix
    %                 string.
    %                 Default: '_copy'
    %
    % 'Prefix'      : (char) Behaves like Postfix but as a prefix.
    %                 Default: ''
    %
    % 'Writable'    : (logical) If set to false, the output object's memory
    %                 map will not be writable.
    %                 Default: obj1.Writable
    %
    % 'Temporary'   : (logical) If set to true, the output object will be
    %                 considered to be temporary.
    %                 Default: obj1.Temporary
    %
    %
    % See also: meegpipe.node, pset.physioset
    

    methods (Access = protected)
        
        % We override this to prevent infinite recursion
        function data = save(obj, data)
            
            import mperl.file.spec.catfile;
            
            [~, name, ext] = fileparts(get_datafile(data));
            outputPath = get_full_dir(obj);
            save(data, catfile(outputPath, [name ext]));
            
        end
        
    end
   
    methods
        
        % required by parent meegpipe.node.abstract_node
        [data, dataNew] = process(obj, data)
        
        % reimplementation of meegpipe.node.abstract_node method
        outputFileName = get_output_filename(obj, inputFileName);
        
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class _copy_, make a copy of the input data ' ...
                'into an independent output physioset object. The ' ...
                'node properties determine the naming of the ' ...
                'data file associated with the output physioset object.'];
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = copy(varargin)
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'copy');
            end
            
        end
        
    end
    
    
    
    
end