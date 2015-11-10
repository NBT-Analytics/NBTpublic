classdef eeg < sensors.physiology
    % SENSORS.EEG - EEG sensors.class
    %
    % ## Construction:
    %
    % obj = sensors.eeg;
    % obj = sensors.eeg('Cartesian', coord);
    % obj = sensors.eeg('key', value, ...);
    %
    % Where
    %
    % OBJ is a sensors.eeg object
    %
    %
    % ## Accepted key/value pairs:
    %
    %       Cartesian: Kx3 double array. Default: []
    %           Cartesian coordinates of the sensors.
    %
    %       Spherical: A Kx3 double array. Default: []
    %           Spherical coordinates of the sensors.
    %
    %       Polar: Kx3 double array. Default: []
    %           Polar coordinates.
    %
    %       * All key/value pairs accepted by the constructor of class
    %         sensors.physiology
    %
    %
    % ## Notes:
    %
    % * Sensor coordinates might be provided in Cartesian, Polar or
    %   Spherical coordinate systems. However, if more than one type of
    %   coordinates are provided, the Cartesian coordinates will be
    %   preferred over spherical and the spherical over polar.
    %
    %
    % ## Public Interface Synopsis:
    %
    % % Construct from Fieldtrip struct
    % obj = sensors.meg.from_fieldtrip(str);
    %
    % % Construct from EEGLAB struct
    % obj = sensors.meg.from_eeglab(str);
    %
    % str = eeglab(obj)                 % Convert to EEGLAB format
    %
    % str = fieldtrip(obj)              % Convert to Fieldtrip format
    %
    % obj = read(obj, 'sensors.sfp');   % Read locations from file
    %
    % obj = map2surf(obj, surface);     % Map sensors.onto a surface
    %
    %
    % See also: sensors.meg, sensors.
    
    
    
    methods (Access=private)
        
        function obj = check(obj)
            import sensors.eeg;
            import sensors.abstract_sensors
            
            if ~isempty(obj.TransducerType) || ~isempty(obj.PhysDim) || ...
                    ~isempty(obj.Fiducials),
                if isempty(obj.Label)
                    throw(abstract_sensors.InvalidPropValue('Label', ...
                        'Must be unique non-empty labels (strings)'));
                end
            elseif isempty(obj.Label) && ~isempty(obj.Cartesian),
                if isempty(obj.Label)
                    throw(abstract_sensors.InvalidPropValue('Label', ...
                        'Must be unique non-empty labels (strings)'));
                end
            end
            if ~isempty(obj.Label) && length(obj.Label) ~= nb_sensors(obj),
                if isempty(obj.Label)
                    throw(abstract_sensors.InvalidPropValue('Label', ...
                        'Does not match number of sensors'));
                end
            end
        end
        
    end
    
    properties (SetAccess = 'private')
        Cartesian;          % Cartesian coordinates of the EEG sensors.
        Fiducials;          % Hash with the cartesian coordinates of the fiducials
        Extra;              % Hash with additional head surface points
    end
    
    properties (Dependent = true)
        Spherical;
        Polar;
    end
    
    % Get methods
    methods
        function value = get.Spherical(obj)
            if isempty(obj.Cartesian),
                value = [];
            else
                [a, b, c] = cart2sph(obj.Cartesian(:,1), ...
                    obj.Cartesian(:,2), obj.Cartesian(:,3));
                value = [a b c];
            end
        end
        
        function value = get.Polar(obj)
            if isempty(obj.Cartesian),
                value = [];
            else
                [a, b, c] = cart2pol(obj.Cartesian(:,1), ...
                    obj.Cartesian(:,2), obj.Cartesian(:,3));
                value = [a b c];
            end
        end
    end
    
    % Consistency checks (Set methods)
    methods
        
        function obj = set.Cartesian(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.Cartesian = [];
                return;
            end
            
            if ~isnumeric(value) || any(value(:)>=Inf) || ...
                    any(value(:)<=-Inf) ...
                    || size(value,2)~=3,
                throw(InvalidPropValue('Cartesian', ...
                    'Must be a Kx3 matrix'));
            end
            obj.Cartesian = value;
        end
        
        function obj = set.Fiducials(obj, value)
            
            import exceptions.*;
            if isempty(value),
                obj.Fiducials = [];
                return;
            end
            if ~isa(value, 'mjava.hash'),
                throw(InvalidPropValue('Fiducials', ...
                    'Must be a mjava.hash object'));
            end
            
            isValid = cellfun(@(x) isnumeric(x) && isvector(x) && ...
                size(x,2) == 3, values(value));
            
            if ~all(isValid),
                throw(InvalidPropValue('Fiducials', ...
                    sprintf('Invalid coordinates for sensors.%s', ...
                    regexprep(num2str(find(~isValid)), '\s+', ', '))));
            end
            
            obj.Fiducials = value;
        end
        
        function obj = set.Extra(obj, value)
            
            import exceptions.*
            if isempty(value),
                obj.Extra = [];
                return;
            end
            if ~isa(value, 'mjava.hash'),
                throw(InvalidPropValue('Extra', ...
                    'Must be a mjava.hash object'));
            end
            
            isValid = cellfun(@(x) isnumeric(x) && isvector(x) && ...
                size(x,2) == 3, values(value));
            
            if ~all(isValid),
                throw(InvalidPropValue('Extra', ...
                    sprintf('Invalid coordinates for extra points %s', ...
                    regexprep(num2str(find(~isValid)), '\s+', ', '))));
            end
            
            obj.Extra = value;
        end
        
    end
    
    % Implemented by this class
    methods
        
        struct  = eeglab(obj, what);
        struct  = fieldtrip(obj, varargin);
        dist    = euclidean_dist(obj);
        h       = plot(obj, varargin);
        radius  = head_radius(obj, varargin);
        dist    = get_distance(obj, idx);
        [sens, I] = left_hemisphere(obj);
        [sens, I] = right_hemisphere(obj);
        [sens, I] = midline(obj);
        count     = fprintf(fid, obj, varargin);
        
    end
    
    % From sensors.sensors interface (redefinitions)
    methods
        
        sensObj = subset(sensObj, idx);
        xyz     = cartesian_coords(sensObj);
        
    end
    
    % Static contructors
    methods (Static)
        
        obj = from_eeglab(eStr);
        obj = from_fieldtrip(fStr, label);
        obj = from_file(file, varargin);
        obj = from_hash(hashObj);
        obj = from_template(name, varargin);
        obj = guess_from_labels(labels);
        obj = empty(nb);  % For backwards compatibility, use dummy instead
        obj = dummy(nb);  % To replace empty() at some point
        
    end
    
    % Constructor
    methods
        
        function obj = eeg(varargin)
            import misc.process_arguments;
            import misc.cartesian;
            import sensors.abstract_sensors
            import exceptions.InvalidPropValue;
            
            % Call parent constructor
            obj = obj@sensors.physiology(varargin{:});
            
            if nargin < 1, return; end
            
            % Ensure that the labels are valid EEG labels
            isValid = cellfun(...
                @(x) io.edfplus.is_valid_label(x, 'EEG'), ...
                obj.Label);
            if ~all(isValid),
%           
                newLabels = cell(size(obj.Label));
                
                for i = 1:numel(obj.Label),
                    % The EGI net uses E# naming -> EEG #
                    match = regexp(obj.Label{i}, 'E(?<number>\d+)$', 'names');
                    if isempty(match),
                        spec = regexprep(obj.Label{i}, '^Unknown\s+', '');
                        spec = genvarname(spec);
                        if isempty(spec), spec = num2str(i); end
                        
                        newLabels{i} = ['EEG ' spec];
                    else
                        newLabels{i} = ['EEG ' match.number];
                    end
                end
                
                % Ensure that the new labels are unique
                if numel(unique(newLabels)) < numel(newLabels),
                    for i = 1:numel(newLabels),
                        newLabels{i} = [newLabels{i} '_' num2str(i)];
                    end
                end
                
                % Take care of reference channels
                isRef = cellfun(...
                    @(x) ~isempty(strfind(lower(x), 'unknown ref')), ...
                    obj.Label);
                if numel(find(isRef)) > 1,
                    throw(InvalidPropValue('Label', ...
                        'There cannot be multiple REF channels'));
                end
                
                obj.Label = newLabels;
                obj.Label(isRef) = {'EEG REF'};
                
                
            end
            
            % Ensure valid PhysDims
            if isempty(obj.PhysDim),
                % We assume microvolts by default
                obj.PhysDim = repmat({'uV'}, numel(obj.Label), 1);
            end
            
            % Properties specific to EEG sensors.
            opt.Fiducials           = [];
            opt.Extra               = [];
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Cartesian = cartesian(varargin{:});
            obj.Fiducials = opt.Fiducials;
            obj.Extra     = opt.Extra;
            
            % Global consistency check
            obj = check(obj);
            
        end
        
    end
    
end