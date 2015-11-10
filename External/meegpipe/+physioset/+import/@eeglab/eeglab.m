classdef eeglab < physioset.import.abstract_physioset_import
    % EEGLAB - Imports EEGLAB's .set files
    %
    % ## Usage synopsis:
    %
    % import physioset.import.eeglab;
    % importer = eeglab('FileName', 'myOutputFile');
    % data = import(importer, 'myMFFfile.set');
    %
    % ## Accepted (optional) construction arguments (as key/values):
    %
    % * All key/values accepted by abstract_physioset_import constructor
    %
    % See also: abstract_physioset_import
    
    properties
        
        SensorClass;
        
    end
    
    methods
        
        function obj = set.SensorClass(obj, value)
            import exceptions.*;
            
            if isempty(value),
                obj.SensorClass = [];
                return;
            end
            
            if ~iscell(value) || ~all(cellfun(@(x) ischar(x), value)),
                throw(InvalidPropValue('SensorClass', ...
                    'Must be a cell array of strings'));
            end
            
            for i = 1:numel(value),
                
                try
                    evalc(['sensors.' value{i}]);
                catch ME
                    if strcmp(ME.identifier, 'MATLAB:undefinedVarOrClass'),
                        msg = sprintf(['''%s'' is not a valid class within the '  ...
                            'sensors package'], value{i});
                        throw(InvalidPropValue('SensorClass', msg));
                    else
                        rethrow(ME);
                    end
                end
            end
            
            obj.SensorClass = value;
            
            
        end
        
    end
    
    
    % physioset.import.import interface
    methods
        physObj = import(obj, ifilename, varargin);
    end
    
    % Constructor
    methods
        
        function obj = eeglab(varargin)
            obj = obj@physioset.import.abstract_physioset_import(varargin{:});
        end
        
    end
    
    
end