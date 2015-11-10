classdef rfilt  
    % RFILT - Regression filter interface
    %
    % 
    % Interface methods:
    %
    % ### y = filter(obj, data, regressor)
    %
    % Where:
    %
    % DATA is a numeric matrix or any time that implements equivalent 
    % subsref and subsasgn methods (e.g. a pset.mmappset object).
    %
    % REGRESSOR is a numeric NxL matrix with N regressors.
    %
    % Y is the result of regressing out REGRESSOR from DATA.
    %
    % 
    % See also: filter
    
    
    methods (Abstract)
        [y, varargout] = filter(obj, x, varargin);        
    end
    
    
end