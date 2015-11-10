classdef polyfit < ...
        filter.dfilt                & ...   
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    
    properties
        
        Order;
        Decimation;
        ExpandBoundary = 2;     % In percentage
        InterpMethod;
        GetNoise       = true;
       
    end
    
    % Consistency checks to be done later
    methods
       
        function obj = set.GetNoise(obj, value)
           
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.GetNoise = true;
                return;
            end
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('GetNoise', ...
                    'Must be a logical scalar'));
            end
            
            obj.GetNoise = value;            
            
        end
        
    end
    
    % filter.interface
    methods
        [y, obj] = filter(obj, x, varargin);
        
        function [y, obj] = filtfilt(obj, varargin)
           
            [y, obj] = filter(obj, varargin{:});
            
        end
    end    
    
    % Constructor
    methods
        function obj = polyfit(varargin)
            import misc.process_arguments;
            
            opt.Order            = 10;
            opt.Decimation       = 10;         
            opt.ExpandBoundary   = 2;
            opt.GetNoise         = true;
            opt.Verbose          = false;
            opt.Name             = 'polyfit';
            [~, opt] = process_arguments(opt, varargin);
            
            fNames = setdiff(fieldnames(opt), {'Verbose', 'Name'});
            for i = 1:numel(fNames)
                obj.(fNames{i}) = opt.(fNames{i});
            end
            
            obj = set_verbose(obj, opt.Verbose);
            obj = set_name(obj, opt.Name);            
            
        end
        
    end
    
    
end