classdef sensor_label < pset.selector.abstract_selector
    % SENSOR_LABEL - Selects data channels by label
    %
    % ## Usage synopsis:
    %
    % import pset.selector.sensor_label;
    % selObj = sensor_label(regex)
    % selObj = sensor_label(regex1, regex2, ...)
    %
    % Where:
    %
    % REGEX is a regular expression that will be matched against the
    % channel labels. Only those channels matching the expression will be
    % selected. For instance, the regex 'EEG\s+(1..120,130..140)'  can be
    % used to select only the EEG channels with an index in the range 1 to
    % 120 and 130 to 140.
    %
    % REGEX1, REGEX2, ... is a list of regular expressions. Channels that
    % match ANY of such regular expressions will be selected.
    %
    %
    % See also: selector
    
    
    properties (SetAccess = private, GetAccess = private)
        
        Regex   = {'.+'};
        Negated = false;
        
    end
    
    % Consistency checks
    methods
       
        function obj = set.Regex(obj, value)
            
            import mperl.join;
            import exceptions.InvalidPropValue;
            
            if isempty(value), 
                value = {'.+'};
            end            
           
            if ~iscell(value),
                value = {value};
            end
            
            if ~iscell(value) || ~all(cellfun(@(x) ischar(x) || ...
                    isa(x, 'function_handle'), value)),
                throw(InvalidPropValue('Regex', ...
                    'Must be a (cell array of) regex(es)'));
            end
            
            obj.Regex = value;
            
        end
        
    end
    
    methods
        
        function obj = not(obj)
            
            obj.Negated = true;
            
        end
        
        function [data, emptySel, arg] = select(obj, data, remember)
            import misc.any2str;
            
            arg = [];
            
            if nargin < 3 || isempty(remember),
                remember = true;
            end
            
            sensLabels = labels(sensors(data));
            
            if ~iscell(sensLabels), sensLabels = {sensLabels}; end
            
            isSelected = false(numel(sensLabels), 1);
            
            for i = 1:numel(obj.Regex),
                if isa(obj.Regex{i}, 'function_handle'),
                    thisRegex = obj.Regex{i}(data);
                else
                    thisRegex = obj.Regex{i};
                end
                isSelected = isSelected | cellfun(...
                    @(x) ~isempty(regexp(x, thisRegex, 'once')), ...
                    sensLabels(:));
            end
            
            if obj.Negated,
                isSelected = ~isSelected;
            end
            
            if ~any(isSelected),
                
                emptySel = true;
                return;
                
            else
                emptySel = false;
                
            end
            
            select(data, find(isSelected), [], remember);
            
        end
        
        function disp(obj)
            
            import goo.disp_class_info;
            import mperl.join;
            import misc.cell2str;
            
            disp_class_info(obj);
            
            if isempty(obj.Regex),
                fprintf('%20s : all groups\n',  'SensorIdx');
            else
                fprintf('%20s : %s\n', 'Regex', cell2str(obj.Regex));
            end
            
            if obj.Negated,
                fprintf('%20s : yes\n', 'Negated');
            else
                fprintf('%20s : no\n', 'Negated');
            end
            
        end
        
    end
    
    % constructor
    methods
        
        function obj = sensor_label(varargin)
            
            if nargin < 1, return; end
            
            if nargin == 1,
                obj.Regex = varargin{1};
            else
                obj.Regex = varargin;
            end
            
        end
        
        
    end
    
    
end
