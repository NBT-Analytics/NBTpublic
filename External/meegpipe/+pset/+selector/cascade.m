classdef cascade < pset.selector.abstract_selector
    % CASCADE - A cascade of data selectors
    %
    % ## Usage synopsis:
    %
    % import pset.*;
    %
    % % Create a data selector that will select only the good data from
    % % sensors groups 2 and 3:
    % mySel1 = selector.sensor_group_idx(2,3);
    % mySel2 = selector.good_data;
    % mySel  = selector.cascade(mySel1, mySel2);
    %
    % % Alternatively, you could have done simply this:
    % mySel = mySel1 & mySel2;
    %
    % % Test the selector with some sample data:
    % X = randn(15, 1000);
    % import sensors.*;
    % mySensors = mixed(dummy(5), dummy(5), dummy(5));
    % data = import(pset.import.matrix, X, 'sensors', mySensors);
    %
    % % Select good data from sensor groups 2 and 3
    % select(mySel, data);
    %
    % % Must be OK
    % import test.simple.ok;
    % X = X(6:end,:);
    % ok(size(data,1) == 10 && max(abs(data(:) - X(:))) < 1e-3);
    %
    % See also: selector
    
    
    %% PUBLIC INTERFACE ...................................................

    properties
        
        SelectorList    = {};
        Negated         = false;
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.SelectorList(obj, value)
            import exceptions.*;
            if isempty(value),
                obj.SelectorList = {};
                return;
            end
            
            if ~iscell(value), value = {value}; end
            
            if ~all(cellfun(@(x) isa(x, 'pset.selector.selector'), value))
                throw(InvalidPropValue('SelectorList', ...
                    'Must be a cell array of selector objects'));
            end
            
            obj.SelectorList = value;
            
        end
        
    end
    
    
    % pset.selector.selector interface
    methods
        
        function obj = not(obj)
            
            obj.Negated = ~obj.Negated;
            
        end
        
        function [data, emptySel, arg] = select(obj, data, inRemember)
            
            if nargin < 3 || isempty(inRemember),
                inRemember = true;
            end
            
            allArgs = {};
            for i = 1:numel(obj.SelectorList)
                if i < 2,
                    remember = inRemember;
                else
                    remember = false;
                end
                [~, emptySel, arg] = select(obj.SelectorList{i}, data, ...
                    remember);
                allArgs = [allArgs;{arg}]; %#ok<AGROW>
                if emptySel,
                    % roll back the selections that were done
                    for j = (i-1):-1:1
                        restore_selection(data);
                    end
                    return;
                end
            end
            
            if obj.Negated,
                invert_selection(data, false);
            end
            
        end
        
        function str = struct(obj)
            
            str.Negated = obj.Negated;
            str.SelectorList = cell(1, numel(obj.SelectorList));
            
            for i = 1:numel(obj.SelectorList)
                warning('off', 'MATLAB:structOnObject');
                str.SelectorList{i} = builtin('struct', obj.SelectorList{i});
                warning('on', 'MATLAB:structOnObject');
            end
            
        end
        
        
    end
    
    % Public methods declared and defined here
    
    methods
        
        function disp(obj)
            
            import goo.disp_class_info;
            import misc.any2str;
            
            disp_class_info(obj);
            
            fprintf('%20s : %s\n', 'SelectorList', ...
                any2str(obj.SelectorList));
            
            if obj.Negated,
                fprintf('%20s : yes\n', 'Negated');
            else
                fprintf('%20s : no\n', 'Negated');
            end
            
        end
        
    end
    
    % Constructor
    
    methods
        
        function obj = cascade(varargin)
            
            obj = obj@pset.selector.abstract_selector(varargin{:});
            
            if nargin < 1, return; end
            
            obj.SelectorList = varargin;
            
        end
        
        
    end
    
    
end