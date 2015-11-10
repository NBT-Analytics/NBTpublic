classdef physiology < sensors.abstract_sensors
    % PHYSIOLOGY - Physiological sensors.class
    %
    % ## Construction
    %
    % obj = sensors.physiology
    % obj = sensors.physiology('Label', sensLabels);
    % obj = sensors.physiology('key', value, ...)
    %
    % Where
    %
    % OBJ is a sensors.physiology
    %
    % SENSLABELS is a cell array with sensor labels
    %
    %
    % ## Accepted key/value pairs:
    %
    %       Label: A cell array of strings. Default: MEG 1, MEG 2, ...
    %           Labels of the MEG sensors. These labels must follow the
    %           EDF+ guidelines [1].
    %
    %       PhysDim: A cell array of strings or a string. Default: []
    %           The physical dimensions recorded by each sensor. These
    %           texts must also be according to EDF+ guidelines [1]. If
    %           PhysDim is a string rather than a cell array of strings,
    %           the same physical dimension will be assumed for all sensors.
    %
    %       TransducerType: A cell array of strings. Default: []
    %           The type of transducer for each sensor.
    %
    %
    %
    % ## References:
    %
    %   [1] Standard EDF+ texts:
    %       http://www.edfplus.info/specs/edftexts.html
    %
    %
    % See also: sensors
    
    
    properties (GetAccess = private, SetAccess = private)
        OrigLabel = []; % Original labels (e.g. as read from a disk file)
    end
    
    properties (SetAccess = protected)
        Name            = [];   % Manufacturer name for the sensor array
        TransducerType  = [];   % Transduce type
        Label           = [];   % Sensor/Signal label
        PhysDim         = [];   % Physical dimensions
        SensorVariance  = [];   % The variance of each sensor
    end
    
    % Global consistency check
    methods (Access = private)
        function check(obj)
            import exceptions.*
            import io.edfplus.is_valid_dim;
            
            if numel(obj.TransducerType)~= obj.NbSensors,
                throw(InvalidPropValue('TransducerType', ...
                    'Must match number of sensors'));
            end
            
            if numel(obj.PhysDim)~= obj.NbSensors,
                throw(InvalidPropValue('PhysDim', ...
                    'Must match the number of sensors'));
            end
            
            isValid = is_valid_dim(obj.Type, opt.physdim);
            
            if ~all(isValid),
                throw(InvalidPropValue('PhysDim', ...
                    sprintf('Invalid physical dimensions: %s', ...
                    mperl.join(', ', opt.physdim(~isValid)))));
            end
        end
        
    end
  
    properties (Dependent)
        Type;               % Signal type, e.g. EEG, Resp, ...
        Specification;      % Signal specifation, e.g. 246, abdomen, ...
        NbSensors;          % Number of sensors.signals
    end
    
    % Dependent properties
    methods
        function type   = get.Type(obj)
            if isempty(obj.Label),
                type = [];
                return;
            end
            type = cell(obj.NbSensors,1);
            
            for i = 1:obj.NbSensors,
                tmp = regexpi(obj.Label{i}, '^\w+', 'match');
                if ~isempty(tmp),
                    type{i} = tmp{1};
                end
            end
        end
        
        function spec   = get.Specification(obj)
            if isempty(obj.Label),
                spec = [];
                return;
            end
            spec = cell(obj.NbSensors,1);
            
            for i = 1:obj.NbSensors,
                tmp = regexpi(obj.Label{i}, '^\w+\s+(?<spec>.+$)', 'names');
                if ~isempty(tmp),
                    spec{i} = tmp.spec;
                end
            end
        end
        
        function value  = get.NbSensors(obj)
            value = numel(obj.Label);
        end
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.Label(obj, value)
            
            import io.edfplus.valid_label;
            import exceptions.*
            if ischar(value) && isvector(value), value = {value(:)'}; end
            if isempty(value) || ~iscell(value) || ...
                    ~all(cellfun(@(x) ischar(x), value)),
                throw(InvalidPropValue('Label', ...
                    'Must be a cell array of strings'));
            end
            
            if numel(unique(value)) ~= numel(value),
                throw(InvalidPropValue('Label', ...
                    'Must be unique'));
            end
            
            % Ensure labels are valid and EDF+ compatible
            obj.Label = valid_label(value);
            
        end
        
        function obj = set.OrigLabel(obj, value)
            
            import exceptions.*
            if isempty(value),
                obj.OrigLabel = [];
                return;
            end
            if ischar(value) && isvector(value), value = {value(:)'}; end            
            if ~iscell(value) || ~all(cellfun(@(x) ischar(x), value)),
                throw(InvalidPropValue('OrigLabel', ...
                    'Must be a cell array of strings'));
            end
            
            if numel(unique(value)) ~= numel(value),
                throw(InvalidPropValue('OrigLabel', ...
                    'Must be unique'));
            end
            
            obj.OrigLabel = value;
            
        end
        
        function obj = set.TransducerType(obj, value)
            
            import exceptions.*
            if isempty(value),
                obj.TransducerType = [];
                return;
            end
            if ischar(value),
                value = {value};
            end
            if ~iscell(value) || ~all(cellfun(@(x) ischar(x), value)),
                throw(InvalidPropValue('TransducerType', ...
                    'Must be a cell array of strings'));
            end
            obj.TransducerType = value;
            
        end
        
        function obj = set.PhysDim(obj, value)
            
            import exceptions.*
            if isempty(value),
                obj.PhysDim = [];
                return;
                
            end
            if ischar(value),
                value = {value};
            end
            if ~iscell(value) || ~all(cellfun(@(x) ischar(x), value)),
                throw(InvalidPropValue('TransducerType', ...
                    'Must be a cell array of strings'));
            end
            obj.PhysDim = value;
            
        end
    end
    
    % sensors.sensorsinterface
    methods
        function labelsArray = labels(obj)
            labelsArray = obj.Label(:);
        end
        
        function nbSensors = nb_sensors(obj)
            nbSensors = obj.NbSensors;
        end
        
        function type = types(obj)
            type = obj.Type;
        end
        
        function [sensorArray, idx] = sensor_groups(obj)
            sensorArray = {obj};
            idx = {1:nb_sensors(obj)};
        end
        
        function labelsArray = orig_labels(obj)
            if ~isempty(obj.OrigLabel),
                labelsArray = obj.OrigLabel;
            else
                labelsArray = obj.Label;
            end
        end
        
        function weights = get_eqweights(obj)
            if ~isempty(obj.EqWeights),
                weights = obj.EqWeights;
            else
                weights = eye(nb_sensors(obj));
            end
        end
        
        function type = get_physdim(obj)
            type = obj.PhysDim;
            if isempty(type) && obj.NbSensors > 0,
                type = repmat({''}, obj.NbSensors, 1);
            end
        end
        
        function obj = set_physdim(obj, value)
            obj.PhysDim = value;
        end
        
        sensObj = subset(sensObj, idx);
    end
    
    % Static constructors
    methods (Static)
        obj = from_fieldtrip(ftripStr);
        obj = from_eeglab(eeglabStr);
        obj = empty(nb);
    end
    
    % Constructor
    methods
        function obj = physiology(varargin)
            import exceptions.*
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            opt.Name            = [];
            opt.TransducerType  = [];
            opt.Label           = [];
            opt.OrigLabel       = [];
            opt.PhysDim         = [];
            [~, opt] = process_arguments(opt, varargin);
            
            if isempty(opt.Label), opt.Label = opt.OrigLabel; end
            
            fNames = fieldnames(opt);
            for i = 1:numel(fNames),
                obj.(fNames{i}) = opt.(fNames{i});
            end
            
            % Ensure there are as many transducers as labels
            if iscell(obj.TransducerType) && ...
                    numel(obj.TransducerType) == 1
                obj.TransducerType = repmat(obj.TransducerType, ...
                    obj.NbSensors, 1);
            end
            
            % Ensure there are are also as many physdims
            if iscell(obj.PhysDim) && numel(obj.PhysDim) == 1
                obj.PhysDim = repmat(obj.PhysDim, obj.NbSensors, 1);
            end
            
            if isempty(obj.PhysDim),
                obj.PhysDim = repmat('', obj.NbSensors, 1);
            end
            
        end
    end
end


