classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of merge nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.merge.config')">misc.md_help(''meegpipe.node.merge.config'')</a>
    
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        Importer = {};
    end
    
    % Consistency checks
    methods
       
        function obj = set.Importer(obj, value)
           
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Importer = {};
                return;
            end
            
            if isa(value, 'physioset.import.physioset_import'),
                value = {value};
            end
            
            if ~iscell(value) || ~all(cellfun(@(x) ...
                    isa(x, 'physioset.import.physioset_import'), value))
                throw(InvalidPropValue('Importer', ...
                    'Must be a cell array of importer objects'));
            end
            
            obj.Importer = value;
            
            
        end
        
    end
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end