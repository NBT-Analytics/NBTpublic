classdef coils < goo.abstract_setget
    % SENSORS.COILS - Coil array description
    %
    % ## Construction
    %
    % obj = sensors.coils('key', value, ...)
    %
    % Where
    %
    % OBJ is a sensors.coils object
    %
    %
    % ## Accepted key/value pairs:
    %
    % 'Cartesian'    :  (double) An Mx3 matrix with the cartesian
    %                   coordinates of each coil.
    %                   Default: []
    %
    % 'Polar'        :  (double) Same as Cartesian but in Polar form.
    %                   Default: []
    %
    % 'Spherical'    :  (double) Same as Cartesian but in Spherical form.
    %                   Default: []
    %
    % 'Orientation'  :  (double) An Mx3 matrix with the orientations of each
    %                   coil.
    %                   Default: obj.Cartesian
    %
    % 'Weights'      : (double) An NxM matrix with the weight of each coil
    %                  into each channel.
    %                  Default: eye(M)
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
    % ## Usage examples:
    %
    % % Create an array of empty sensors.coils objects:
    % myArray = repmat(sensors.coils, 1, 100)
    %
    % % Create a fully qualified sensors.coils object:
    % myCoils = sensors.coils('Cartesian', M, 'Orientation', V, ...
    %    'Weights', W);
    %
    % % It is very unlikely that you may want to construct an instance of
    % % this class in other way than the two examples shown above.
    %
    %
    % See also: sensors.meg, sensors.
    
    properties (SetAccess = 'private')
        Cartesian;
        Orientation;
        Weights;
    end
    
    % Exceptions that may be thrown by this class of objects
    methods (Static, Access = private)
        function obj = InvalidOrientation
            obj = MException(...
                'sensors.coils:InvalidOrientation', ...
                'Invalid coils orientations');
        end
        
        function obj = InvalidCoordinates
            obj = MException(...
                'sensors.coils:InvalidCoordinates', ...
                'Invalid coils coordinates');
        end
        
        function obj = InvalidWeights
            obj = MException(...
                'sensors.coils:InvalidWeights', ...
                'Invalid sensor weights');
        end
        
        function obj = MissingCoordinates
            obj = MException(...
                'sensors.coils:MissingCoordinates', ...
                'Missing coils coordinates');
        end
        
        function obj = MissingOrientation
            obj = MException(...
                'sensors.coils:MissingOrientations', ...
                'Missing coils orientations');
        end
    end
    
    methods (Access = private)
        function obj = check(obj)
            import sensors.coils;
            
            if ~isempty(obj.Cartesian) && isempty(obj.Orientation),
                throw(coils.MissingOrientation);
            end
            if ~isempty(obj.Orientation) && isempty(obj.Cartesian),
                throw(coils.MissingCoordinates);
            end
            if ~isempty(obj.Orientation) && size(obj.Orientation, 2) ~= 3,
                throw(coils.InvalidOrientation);
            end
            if ~isempty(obj.Cartesian) && size(obj.Cartesian, 2) ~= 3,
                throw(coils.InvalidCoordinates);
            end
            if size(obj.Cartesian,1) ~= size(obj.Orientation,1),
                throw(coils.InvalidOrientation);
            end
            if size(obj.Weights,1) ~= obj.NbSensors,
                throw(coils.InvalidWeights);
            end
            
        end
    end
    
    
    
    % Public interface ....................................................
    properties (Dependent = true)
        Spherical;
        Polar;
        NbSensors;
    end
    
    % Get methods
    methods
          function value = get.Spherical(obj)
            if isempty(obj),
                value = [];
            else
                [a, b, c] = cart2sph(obj.Cartesian(:,1), ...
                    obj.Cartesian(:,2), obj.Cartesian(:,3));
                value = [a b c];
            end
        end
        
        function value = get.Polar(obj)
            if isempty(obj),
                value = [];
            else
                [a, b, c] = cart2pol(obj.Cartesian(:,1), ...
                    obj.Cartesian(:,2), obj.Cartesian(:,3));
                value = [a b c];
            end
        end
        
        function value = get.NbSensors(obj)
            value = size(obj.Weights,1);
        end        
        
    end
    
    % Consistency checks
    methods
        % Set/Get methods
        function obj = set.Cartesian(obj, value)
            import exceptions.*;
            
            if (~isnumeric(value) || any(value(:)>=Inf) || ...
                    any(value(:)<=-Inf)) ...
                    || (~isempty(value) && size(value,2)~=3),
                throw(InvalidPropValue('Cartesian', ...
                    'Must be a Kx3 matrix'));
            end
            obj.Cartesian = value;
        end     
    end
    
    % So that method subset works for sensors.of class sensors.meg
    methods
        obj = subset(obj, idx);
    end
    
    % Constructor
    methods        
        function obj = coils(varargin)
            import misc.process_arguments;
            import misc.cartesian;            
                       
            if nargin < 1, return; end
            
            opt.cartesian    = [];
            opt.spherical    = [];
            opt.polar        = [];
            opt.orientation  = [];
            opt.weights      = [];
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Cartesian = cartesian(...
                'Cartesian',    opt.cartesian, ...
                'Polar',        opt.polar, ...
                'Spherical',    opt.spherical);
            
            if isempty(opt.weights),
                opt.weights = eye(size(obj.Cartesian,1));
            end
            
            obj.Orientation = opt.orientation;
            
            obj.Weights = opt.weights;
            
            % Global consistency check
            obj = check(obj);
            
            
            
        end
    end
    
end