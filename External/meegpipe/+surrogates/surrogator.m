classdef surrogator
    % SURROGATOR - Interface for data surrogates generators
    
    properties (SetAccess = private, GetAccess = private)
        % Handling random state and random initialization
        RandState_;
        Init_;  
    end
    
    methods (Abstract)
        
        [dataSurr, obj] = surrogate(obj, data, varargin);
        
    end
    
    methods

        function obj  = clear_state(obj)
            
            obj.Init_      = [];
            obj.RandState_ = [];
            
        end
        
        function seed = get_seed(obj)
            
            import misc.isnatural;
            
            if isempty(obj.RandState_) || ~isnatural(obj.RandState_),
                seed = randi(1e9);
            else
                seed = obj.RandState_;
            end
            
        end
        
        function obj  = set_seed(obj, value)
            
            obj.RandState_ = value;
            
        end
        
        function obj = apply_seed(obj)
            randSeed = get_seed(obj);
            warning('off', 'MATLAB:RandStream:ActivatingLegacyGenerators');
            rand('state',  randSeed); %#ok<RAND>
            randn('state', randSeed); %#ok<RAND>
            warning('on', 'MATLAB:RandStream:ActivatingLegacyGenerators');
            obj = set_seed(obj, randSeed);
        end
        
        
    end
    
    
end