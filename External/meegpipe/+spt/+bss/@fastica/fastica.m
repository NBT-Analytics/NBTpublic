classdef fastica < spt.abstract_spt
    % FASTICA - FastICA algorithm for Blind Source Separation
    
    
    
    properties
        Approach        = 'symm';
        Nonlinearity    = 'pow3';
        InitGuess       =  @(data) eye(size(data,1));
    end
    
    % Consistency checks
    methods
        
        function obj = set.Approach(obj, value)
            
            import misc.join;
            import exceptions.*
            
            validApproaches = {'symm', 'defl'};
            
            if ~ischar(value) || ~ismember(value, validApproaches),
                throw(InvalidPropValue('Approach', ...
                    sprintf('Must be any of: %s', ...
                    join(', ', validApproaches))));
            end
            
            obj.Approach = value;
            
        end
        
        
        function obj = set.Nonlinearity(obj, value)
            
            import misc.join;
            import exceptions.*
            
            validNonlins = {'pow3', 'tanh', 'gauss', 'skew'};
            
            if ~ischar(value) || ~ismember(value, validNonlins),
                throw(InvalidPropValue('Approach', ...
                    sprintf('Must be any of: %s', ...
                    join(', ', validNonlins))));
            end
            
            obj.Nonlinearity = value;
            
        end
        
    end
    
    
    methods
        obj = learn_basis(obj, data, varargin);
        
        function init = get_init(obj, data)
            
            import misc.isnatural;
            
            init = get_init@spt.abstract_spt(obj, data);
            
            if isempty(init)
                
                if isnumeric(obj.InitGuess)
                    init = obj.InitGuess;
                elseif isa(obj.InitGuess, 'function_handle'),
                    init = obj.InitGuess(data);
                elseif numel(data)==1 && isnatural(data),
                    % data is the dimensionality of the input data
                    init = rand(data);
                elseif isempty(init) || all(isnan(init(:))),
                    init = randi(10*size(data,1)^2, size(data,1));
                end
            end
        end
    end
    
    % Constructor and invariant checks
    methods
        function obj = fastica(varargin)
            import misc.set_properties;
            import misc.split_arguments;            
          
            opt.Approach        = 'symm';
            opt.Nonlinearity    = 'pow3';
            opt.InitGuess       =  @(data) eye(size(data,1));
            [thisArgs, argsParent] = split_arguments(fieldnames(opt), varargin);
            
            obj = obj@spt.abstract_spt(argsParent{:});
            
            obj = set_properties(obj, opt, thisArgs);
            
        end
        
        
    end
    
    
    
end
