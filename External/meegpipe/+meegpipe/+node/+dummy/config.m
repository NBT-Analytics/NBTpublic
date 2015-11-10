classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node center
    %
    % This is a dummy class. Use this class as an illustration on how to
    % define your own processing nodes.
    %
    % See also: center
    
    methods (Access = private)
       
        % This is a global consistency check that ensures that the values
        % of the two options are consistent with each other
        function global_check(obj)
            import exceptions.Inconsistent;           
            
            % Class dummy requires (this is of course a completely 
            % imaginary requirement) that either both ConfigOpt1 and
            % ConfigOpt2 are non-empty or none are empty. Otherwise, an
            % exception should be thrown
            if xor(isempty(obj.ConfigOpt1), isempty(obj.ConfigOpt2)),
                
                throw(Inconsistent('Cannot have only one empty property'));
                                
            end                
            
        end
        
    end
    
    properties
       
        % Add here as many configuration options as your node may have
        ConfigOpt1 = [];
        ConfigOpt2 = '';
        
    end
    
    % Consistency checks (set methods)
    methods 
    
        function obj = set.ConfigOpt1(obj, value)
            % ConfigOpt1 must be numeric -> make sure it is or throw 
            % exception!
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if ~isnumeric(value),
                throw(InvalidPropValue('ConfigOpt1', ...
                    'Must be numeric'));
            end
            
            obj.ConfigOpt1 = value;
            
            if ~from_constructor(obj),
                % A global check should never be run before the config
                % object has been fully constructed. So perform the global 
                % only if the property has been set anywhere else than the
                % constructor of this class
                global_check(obj);
            end
       
        end
        
        function obj = set.ConfigOpt2(obj, value)
            % ConfigOpt2 must be a char -> make sure it is or throw
            % exception!
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if ~ischar(value),
                throw(InvalidPropValue('ConfigOpt2', ...
                    'Must be char'));
            end
            
            obj.ConfigOpt2 = value;
            
            if ~from_constructor(obj),
                global_check(obj);
            end
         
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            % Typically, you will not want to use exactly this constructor
            % for all your config classes. So just copy an paste this 
            % function into your own config class.
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});  
            
            % This may not necessary for your own node's configuration
            global_check(obj);
           
        end
        
    end
    
    
    
end