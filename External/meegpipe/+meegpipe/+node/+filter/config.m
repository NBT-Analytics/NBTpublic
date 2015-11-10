classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node filter
    %
    % ## Usage synopsis:
    %
    % % Create a LASIP filter node with Gamma parameter equal to 10
    %
    % import meegpipe.node.tfilter.*;
    % myConfig = config('Filter', filter.lasip('Gamma', 10));
    % myNode = tfilter(myConfig);
    %
    % % Alternatively:
    % myNode = tfilter('Filter',  filter.lasip('Gamma', 10));
    %
    %
    % ## Accepted key/value pairs:
    %
    %       Filter: A filter.dfilt object. Def: []
    %           The filter that is to be applied to the node input.
    %
    % See also: tfilter
    
    
     %% PUBLIC INTERFACE ...................................................
    
    properties
        
        Filter;
        ExpandBoundary   = [2 2];   % left/right expand in % of segment length
        ChopSelector     = [];      % a pset.event.selector
        ReturnResiduals  = false;
        NbChannelsReport = 10;
        EpochDurReport   = 50;   % In seconds
        ShowDiffReport   = false;
        PCA              = [];
        
    end
    
    % Consistency checks (to be done)
    methods
       
        function set.Filter(obj, value)
            import exceptions.*;
            
            if isempty(value),
                obj.Filter = [];
                return;
            end
            
            if ~isa(value, 'filter.dfilt') && ...
                    ~isa(value, 'function_handle'),
                throw(InvalidPropValue('Filter', ...
                    'Must be a filter.dfilt object or a function_handle'));
            end
         
            obj.Filter = value;
            
        end
        
        function set.ChopSelector(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.ChopSelector = [];
                return;
            end
            
            if ~isa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('ChopSelector', ...
                    'Must be an event selector object'));
            end
            
            obj.ChopSelector = value;
        end
        
        function set.ExpandBoundary(obj, value)
           import exceptions.InvalidPropValue;
           
           if isempty(value),
               obj.ExpandBoundary = [2 2];
               return;
           end
           
           if numel(value) == 1,
               value = repmat(value, 1, 2);
           end
           
           if ~isnumeric(value) || numel(value) ~= 2 || any(value < 0),
               throw(InvalidPropValue('ExpandBoundary', ...
                   'Must be a 1x2 numeric array of percentages'));
           end           
         
           obj.ExpandBoundary = reshape(value, 1, 2);            
            
        end
        
    end
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            
           
        end
        
    end
    
    
    
end