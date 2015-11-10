classdef shuffle < surrogates.surrogator
    
    
    properties        
        NbPoints = Inf;        
    end
    
    methods
       
        function [dataSurr, obj] = surrogate(obj, data)
            
            if isempty(obj.NbPoints),
                nbPoints = size(data,2);
            elseif isa(obj.NbPoints, 'function_handle')
                nbPoints = obj.NbPoints(data);
            else
                nbPoints = obj.NbPoints;
            end
            
            obj = apply_seed(obj);
            
            nbPoints = min(size(data,2), nbPoints);
            idx = randperm(size(data,2), nbPoints);
            idx = sort(idx, 'ascend');
            
            if isa(data, 'pset.mmappset'),
                dataSurr = select(data, [], idx); 
            else
                dataSurr = data(:, idx);
            end            
            
        end
        
        % Constructor
        function obj = shuffle(varargin)
           
            import misc.process_arguments;
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.NbPoints = Inf;
            [~, opt] = process_arguments(opt, varargin);
            
            obj = set_properties(obj, opt);
            
        end
    end
    
    
end