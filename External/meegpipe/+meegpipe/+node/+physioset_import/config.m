classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node physioset_import
    %
    % ## Usage synopsis:
    %
    % % Create a physioset_import node with a custom Importer
    % import meegpipe.node.physioset_import.*;
    % myConfig = config('Importer', physioset.import.mff);
    % myNode   = physioset_import(myConfig);
    %
    % % Alternatively:
    % myNode = physioset_import(myConfig);
    %
    % ## Accepted configuration options (as key/value pairs):
    % 
    %       Importer : A physioset_importer object.         
    %           Default: physioset.import.fileio
    %           The low-level data importer to be used by the node. 
    %
    % See also: physioset_import
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        Importer = physioset.import.matrix;
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.Importer(obj, value)
            
            import exceptions.*;
            import goo.pkgisa;
            
            if isempty(value),
                value = physioset.import.matrix;
            end
            
            if ~isempty(value) && ...
                    ~pkgisa(value, 'physioset.import.physioset_import'),
                throw(InvalidPropValue('Importer', ...
                    'Must be a physioset_import object'));
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