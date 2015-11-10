classdef dfilt  
    % DFILT - Digital filter interface
    %
    % 
    % Interface methods:
    %
    % ### y = filter(obj, data, ...)
    %
    % Where:
    %
    % DATA is a numeric matrix or any time that implements equivalent 
    % subsref and subsasgn methods (e.g. a pset.mmappset object).
    %
    % 
    % See also: filter
    
    
    methods (Abstract)
        [y, varargout] = filter(obj, x, varargin);   
        [y, varargout] = filtfilt(obj, x, varargin);   
    end
    
    
end