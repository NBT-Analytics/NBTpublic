classdef (Sealed) sleep_score < physioset.event.event
    
    
    methods
        
        function obj = sleep_score(pos, varargin)
            import misc.split_arguments;
            
            if nargin < 1 || isempty(pos),
                obj.Type = '__SleepScore';
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
                    'Dims',     pos.Dims, ...
                    'Scorer',   get_meta(pos, 'Scorer'), ...
                    'Score',    get_meta(pos, 'Score'), ...
                    };
                pos = pos.Sample;
            end
            
            obj = repmat(obj, size(pos));
            
            varargin = ['Type', '__SleepScore', varargin];
            
            metaProps = {'Scorer', 'Score'};
            
            [metaArgs, varargin] = split_arguments(metaProps, varargin);
            
            for i = 1:numel(obj)
                
                obj(i).Sample = pos(i);
                
                obj(i) = set(obj(i), varargin{:});
                
            end
            
            for i = 1:numel(obj)
                
                obj(1) = set_meta(obj(i), metaArgs{:});
            end
            
        end
        
    end
    
    
end