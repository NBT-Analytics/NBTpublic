classdef accelerometer < sensors.physiology
    
    
    
    methods
        
        function obj = accelerometer(varargin)
            import misc.any2str;
            import exceptions.Inconsistent;
            
            % Call parent constructor
            obj = obj@sensors.physiology(varargin{:});
            
            if nargin < 1, return; end
            
            % Ensure the labels are EDF+ compliant
            isValid = cellfun(...
                @(x) io.edfplus.is_valid_label(x, 'Acc'), ...
                obj.Label);
            
            if ~all(isValid),
                
                newLabels = cell(size(obj.Label));
                if numel(obj.Label) == 3,
                    
                    newLabels = {'Acc X', 'Acc Y', 'Acc Z'};
                    
                elseif numel(obj.Label) == numel(unique(obj.Label)),
                    
                    % All labels are unique so we may use them to generate
                    % valid light sensor labels
                    for i = 1:numel(obj.Label)
                        thisLabel = regexprep(obj.Label{i}, 'Unknown\s+', '');
                        thisLabel = regexprep(thisLabel, '\s+', '_');
                        newLabels{i} = ['Acc '  thisLabel];
                    end
                    
                else
                    % Simply use 1,2,3,...
                    for i = 1:numel(obj.Label),
                        newLabels{i} = ['Acc ' num2str(i)];
                    end
                    
                end
                
                obj.Label = newLabels;
                
                warning('sensors:InvalidLabel', ...
                    ['Sensor labels are not EDF+ compatible. \n' ...
                    'Automatically creating compatible Acceleration ' ...
                    'labels: %s'], any2str(obj.Label, 30));
                
                
            end
            
        end
        
    end
    
    
end