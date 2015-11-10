classdef light < sensors.physiology
    
    
   
    methods
       
        function obj = light(varargin)
            import exceptions.Inconsistent;
            import misc.any2str;
            
            % Call parent constructor
            obj = obj@sensors.physiology(varargin{:});
            
            if nargin < 1, return; end
            
            % Ensure the labels are EDF+ compliant
            isValid = cellfun(...
                @(x) io.edfplus.is_valid_label(x, 'Light'), ...
                obj.Label);
            
            if ~all(isValid),
                
                newLabels = cell(size(obj.Label));
                if numel(unique(obj.Label)) == numel(obj.Label),
                    % All labels are unique so we may use them to generate
                    % valid light sensor labels
                    for i = 1:numel(obj.Label)
                       thisLabel = regexprep(obj.Label{i}, 'Unknown\s+', '');
                       thisLabel = regexprep(thisLabel, '\s+', '_'); 
                       newLabels{i} = ['Light '  thisLabel];
                    end
                else
                    % Simply use 1,2,3,...
                    for i = 1:numel(obj.Label),
                        newLabels{i} = ['Light ' num2str(i)];
                    end                    
                end
                
                obj.Label = newLabels;
                
                warning('sensors:InvalidLabel', ...
                    ['Sensor labels are not EDF+ compatible. \n' ...
                    'Automatically creating compatible Light sensor ' ...
                    'labels: %s'], any2str(obj.Label, 30));
                
            end
            
        end
        
    end
    
    
end