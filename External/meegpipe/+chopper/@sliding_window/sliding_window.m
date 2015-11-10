classdef sliding_window < chopper.abstract_chopper & goo.reportable
    % sliding_window - Chop data into non-overlapping sliding windows
    properties
        
        WindowLength;    % In data samples
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.WindowLength(obj, value)
            import exceptions.InvalidPropValue;
            import misc.isnatural;
            import goo.from_constructor;
            
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('WindowLength', ...
                    'Must be a natural scalar'));
            end
            
            obj.WindowLength = value;
            
        end
        
    end
    
    
    methods
        
        % chopper.chopper interface
        [bndy, index] = chop(obj, data, varargin);
        
        % report.reportable interface
        [pName, pVal, pDescr] = report_info(obj);
        
        function str = whatfor(~)
            
            str = ['Chops input data into a series of correlative ' ...
                '(possibly overlapping) windows'];
            
        end
        
        % Constructor
        function obj = sliding_window(varargin)
            
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            opt.WindowLength  = [];

            [~, opt] = process_arguments(opt, varargin, [], true);
            
            obj.WindowLength  = opt.WindowLength;
  
        end
        
        
    end
    
end

