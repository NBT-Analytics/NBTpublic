classdef (Sealed) ecg_ann < physioset.event.event
    
    
    properties
        SubType = '';
    end
    
    % Consistency checks
    methods
        function obj = set.SubType(obj, value)
           
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.SubType = 0;
                return;
            end
            
            if ~isnumeric(value) || numel(value) ~= 1,
                throw(InvalidPropValue('SubType', ...
                    'Must be a numeric scalar'));
            end
            obj.SubType = value;
            
        end
    end
    
    methods
        
        function obj = ecg_ann(pos, varargin)
            
            if nargin < 1 || isempty(pos),
                obj.Type = '__ECGAnn';
                return;
            end
            
            if nargin == 1 && isa(pos, 'physioset.event.event'),
                % Copy constructor
                varargin = {...
                    'Type',     pos.Type, ...
                    'Time',     pos.Time, ...
                    'Value',    pos.Value, ...
                    'Offset',   pos.Offset, ...
                    'Duration', pos.Duration, ...
                    'Dims',     pos.Dims ...
                    };
                if isa(pos, 'physioset.event.std.ecg_ann'),
                    varargin = [ ...
                        varargin, ...
                        {'SubType', pos.SubType} ...
                        ];
                end
                pos = pos.Sample;
            end
            
            obj = repmat(obj, size(pos));
            
            varargin = ['Type', '__QRSComplex', varargin];
            
            for i = 1:numel(obj)
                
                obj(i).Sample = pos(i);
                
                obj(i) = set(obj(i), varargin{:});
                
            end
            
        end
        
    end
    
end