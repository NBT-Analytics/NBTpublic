classdef (Sealed) tr < physioset.event.event
    
     methods
        
        function obj = tr(pos, varargin)
     
            if nargin < 1 || isempty(pos), 
                obj.Type = '__TR';
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
                pos = pos.Sample;
            end
          
            obj = repmat(obj, size(pos));
            
            varargin = ['Type', '__TR', varargin];
            
            for i = 1:numel(obj)
                
                obj(i).Sample = pos(i);
                
                obj(i) = set(obj(i), varargin{:});
                
            end
            
        end
        
    end
    
end