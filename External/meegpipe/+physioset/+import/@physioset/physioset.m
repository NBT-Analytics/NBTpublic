classdef physioset < physioset.import.abstract_physioset_import
    % PHYSIOSET - Class for importing .pset files
    %
    % obj = physioset.import.eeglab('key', value, ...)
    %
    %
    % ## Accepted key/value pairs:
    %
    % See help physioset.import.abstract_physioset_import
    %
    %
    %
    % See also: physioset.import.abstract_physioset_import
    
    % Documentation: pkg_physioset.import.txt
    % Description: Imports .pset files
    
    % Exceptions that may thrown by methods of this class
    methods (Static, Access = private)
        function obj = InvalidConcatenate
           obj = MException('physioset.import.physioset:InvalidConcatenate', ...
               'The Concatenate property must be a logical scalar');
        end
        function obj = InvalidInput(msg)
           obj = MException('physioset.import.physioset:InvalidInput', ...
               msg);
        end
    end
    
    % BEGIN PUBLIC INTERFACE ##############################################
    properties 
       Concatenate; 
    end
    
    methods
        function obj = physioset(varargin)
           obj = obj@physioset.import.abstract_physioset_import(varargin{:}); 
        end       
    end
    
    % physioset.import.interface
    methods
        eegset_obj = import(obj, varargin);        
    end
    
    % consistency checks
    methods
        function obj = set.Concatenate(obj, value)
           import physioset.import.physioset;
           if ~isempty(value) && ~islogical(value) || numel(value)~=1,
               throw(physioset.InvalidConcatenate);
           end
           obj.Concatenate = value;
        end
    end
    % END PUBLIC INTERFACE ##############################################
    
    
    
end