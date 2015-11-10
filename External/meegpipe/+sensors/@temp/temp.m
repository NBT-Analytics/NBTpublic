classdef temp < sensors.physiology
    
    
   
    methods
       
        function obj = temp(varargin)
            import mperl.join;
            import exceptions.Inconsistent;
            
            % Call parent constructor
            obj = obj@sensors.physiology(varargin{:});
            
            if nargin < 1, return; end
            
            % Ensure the labels are EDF+ compliant
            isValid = cellfun(...
                @(x) io.edfplus.is_valid_label(x, 'Temp'), ...
                obj.Label);
            
            if ~all(isValid),                
              
                warning('sensors:InvalidLabel', ...
                    ['Sensor labels are not EDF+ compatible. \n' ...
                    'Automatically creating compatible Temperature sensor ' ...
                    'labels: Temp 1, Temp 2, ...']);                               
               
                newLabels = cell(size(obj.Label));
                for i = 1:numel(obj.Label),      
                    newLabels{i} = ['Temp ' num2str(i)];
                end
                obj.Label = newLabels;

            end
            
        end
        
    end
    
    
end