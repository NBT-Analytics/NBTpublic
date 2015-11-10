classdef fieldtrip < physioset.export.abstract_physioset_export
    % FIELDTRIP - Exports to EEGLAB .set file
    %
    % See also: physioset.export
    
    properties
        
        BadDataPolicy = 'donothing'; % or 'flatten' or 'donothing'
        
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
            
            % 'reject' is kept for backwards compatiliby only
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
       
    end
    
    
    % physioset.export.physioset_export interface
    methods
        physObj = export(obj, ifilename, varargin);
    end
    
    % Constructor
    methods
        
        function obj = fieldtrip(varargin)
            obj = set(obj, varargin{:});
        end
        
    end
    
    
end