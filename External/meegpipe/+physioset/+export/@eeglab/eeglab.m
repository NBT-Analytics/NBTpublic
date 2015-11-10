classdef eeglab < physioset.export.abstract_physioset_export
    % eeglab - Exports to EEGLAB .set file
    %
    % See also: physioset.export
    
    properties
        
        BadDataPolicy = 'donothing'; % or 'flatten' or 'donothing'
        MemoryMapped  =  false;
        
    end
    
    methods
        
        function obj = set.BadDataPolicy(obj, value)
            import exceptions.InvalidPropValue;
            import misc.isstring;
            import misc.join;
            
            if isempty(value),
                obj.BadDataPolicy = 'donothing';
                return;
            end
            
            validPolicies = {'reject', 'donothing', 'flatten'};
            
            if ~isstring(value) || ...
                    ~ismember(lower(value), lower(validPolicies)),
                throw(InvalidPropValue('BadDataPolicy', ...
                    sprintf('Must be one of the strings: %s', ...
                    join(',', validPolicies))));
            end
            
            if strcmpi(value, 'reject'),
                warning('fieldtrip:Obsolete', ...
                    'The ''reject'' data policy has been deprecated');
            end
            
            obj.BadDataPolicy = value;
            
        end
        
        function obj = set.MemoryMapped(obj, value)
           import exceptions.InvalidPropValue;
           
           if isempty(value),
               obj.MemoryMapped = false;
               return;
           end
           
           if numel(value) ~= 1 || ~islogical(value),
               throw(InvalidPropValue('MemoryMapped', ...
                   'Must be a logical scalar'));
           end
           obj.MemoryMapped = lower(value);           
            
        end
        
    end
    
    
    % physioset.export.physioset_export interface
    methods
        physObj = export(obj, ifilename, varargin);
    end
    
    % Constructor
    methods
        
        function obj = eeglab(varargin)
            obj = set(obj, varargin{:});
        end
        
    end
    
    
end