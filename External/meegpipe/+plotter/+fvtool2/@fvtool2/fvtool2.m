classdef fvtool2 < plotter.plotter & goo.abstract_configurable_handle
    % FVTOOL2 - An wrapper for MATLAB's fvtool
    %
    %
    %
    % See also: demo, make_test

    
    %% IMPLEMENTATION .....................................................
    
    properties (SetAccess = private, GetAccess = private)
        
        FvtoolHandle; % A handle to a MATLAB's built-in fvtool handle
        Selection;    % Selection of figures to which methods will be applied       
        
    end
    
    % Consistency checks
    methods
        
        function set.Selection(obj, idx)
            import plotter.fvtool2.fvtool2;
            
            obj.Selection = sort(idx);
        end
    end
    
    
    methods (Static, Access = private)
        
        out = process_filt_array(varargin)
        
    end
    
    
    %% PUBLIC INTERFACE ...................................................
    
    % Interface of MATLAB's built-in fvtool
    methods
        
        function h = set(h, varargin)
            for i = 1:numel(h.Selection),
                set(h.FvtoolHandle(h.Selection(i)), varargin{:});
            end
        end
        
        function val = get(h, varargin)
            val = cell(1, numel(h.Selection));
            for i = 1:numel(h.Selection),
                val = get(h.FvtoolHandle(h.Selection(i)), varargin{:});
            end
            if numel(val) == 1, val = val{1}; end
        end
        
        function h = delete_filter(h, index)
            for i = 1:numel(h.Selection),
                deletefilter(h.FvtoolHandle(h.Selection(i)), index);
            end
        end
        
        function h = legend(h, varargin)
            for i = 1:numel(h.Selection),
                legend(h.FvtoolHandle(h.Selection(i)), varargin{:});
            end
        end
        
        function h = addfilter(h, varargin)
            
            import plotter.fvtool2.*;
            
            varargin = fvtool2.process_filt_array(varargin{:});
            for i = 1:numel(h.Selection),
                addfilter(h.FvtoolHandle(h.Selection(i)), varargin{:});
            end
            
        end
        
        function h = setfilter(h, varargin)
            
            import plotter.fvtool2.fvtool2;
            
            varargin = fvtool2.process_filt_array(varargin{:});
            
            for i = 1:numel(h.Selection),
                setfilter(h.FvtoolHandle(h.Selection(i)), varargin{:});
            end
            
            
        end
    end
    
    % plotter.plotter interface
    methods
        
        obj = clone(obj);
        
        obj = plot(obj, varargin);
        
        obj = blackbg(obj, varargin);
        
    end
    
    % Methods defined by fvtool2
    methods
        
        h = overlay(h, varargin);
        
        h = select(h, idx);
        
        h = set_axes(h, varargin);
        
        h = set_legend(h, varargin);
        
        h = set_title(h, varargin);
        
        h = set_xlabel(h, varargin);
        
        h = set_ylabel(h, varargin);
        
        h = set_line(h, filtIdx, varargin);
        
        h = set_spec_mask(h, filtIdx, varargin);
        
        h = set_figure(h, varargin);
        
        set_fvtool_looks(h);
        
        val = get_axes(h,   varargin);
        
        val = get_legend(h, varargin);
        
        val = get_title(h,  varargin);
        
        val = get_xlabel(h, varargin);
        
        val = get_ylabel(h, varargin);
        
        val = get_line(h,   filtIdx, varargin);
        
        val = get_figure(h, varargin);
        
        val = nb_plots(h);
        
        hF  = get_figure_handle(h);
        
    end
    
    % Constructor/ Destructor
    methods
        
        function obj = fvtool2(varargin)
            import plotter.fvtool2.*;
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            % Convert all filter.dfilt objects to dfilt objects
            needsConversion = cellfun(@(x) isa(x, 'filter.dfilt'), ...
                varargin);
            if any(needsConversion),
                varargin(needsConversion) = ...
                    cellfun(@(x) x.H, varargin(needsConversion), ...
                    'UniformOutput', false);
            end
            
            % Options to be processed here
            count = 1;
            while count <= nargin && (iscell(varargin{count}) || ...
                    ~isempty(regexpi(class(varargin{count}), '^dfilt\.')))
                count = count + 1;
            end
            
            fvtoolArgs = varargin(1:count-1);
            varargin   = varargin(count:end);
            
            if ~isempty(fvtoolArgs) && (iscell(fvtoolArgs{1}) || ...
                    ~isempty(regexpi(class(fvtoolArgs{1}), '^dfilt.\w+'))),
                
                fvtoolArgs = fvtool2.process_filt_array(fvtoolArgs{:});
                
            end

            obj.FvtoolHandle = fvtool(fvtoolArgs{:}, varargin{:});
           
            obj.Selection = 1:numel(obj.FvtoolHandle);
            
        end
        
        
        function delete(obj)
            
            for i = 1:numel(obj.FvtoolHandle),
                tmp = obj.FvtoolHandle(i);
                set(tmp, 'Visible', 'on')
                
                close(tmp);                
                
            end
           
            obj.FvtoolHandle    = [];
            
        end
    end
    
    
end