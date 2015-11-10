classdef nbt < physioset.import.abstract_physioset_import
    % NBT - Imports files in NBT format
    %
    % ## Usage synopsis:
    %
    % import physioset.import.nbt;
    % importer = nbt('FileName', 'myOutputFile');
    % data = import(importer, 'My_NBT_file.mat');
    %
    %
    % See also: physioset.import
    
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
        
        % needed by parent import()
        [sens, sr, hdr, ev, startDate, startTime] = ...
            read_file(obj, fileName, psetFileName, verb, verbLabl);
        function ev = read_events(~, varargin)
           % NBT files do not encode events. Or do they?
            ev = [];
        end
        
        
        % Constructor
        function obj = nbt(varargin)
            obj = obj@physioset.import.abstract_physioset_import(varargin{:});
        end
    end
   
    
end