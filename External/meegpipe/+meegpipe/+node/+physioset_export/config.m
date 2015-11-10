classdef config < meegpipe.node.abstract_config
    % config - Configuration for node physioset_export
    %
    % 
    % See also: physioset_export
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        Exporter = physioset.export.eeglab;
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.Exporter(obj, value)
            
            import exceptions.*;
            import goo.pkgisa;
            
            if isempty(value),
                value = physioset.export.eeglab;
            end
            
            if ~isempty(value) && ...
                    ~pkgisa(value, 'physioset.export.physioset_export'),
                throw(InvalidPropValue('Exporter', ...
                    'Must be a physioset_export object'));
            end
            obj.Exporter = value;
            
        end
        
       
    end
    
        
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            
           
        end
        
    end
    
    
    
end