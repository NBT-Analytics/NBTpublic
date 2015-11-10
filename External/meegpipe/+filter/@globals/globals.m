classdef (Sealed) globals < dynamicprops
% GLOBALS Construct an object that stores global variables for package pset.
%
%   VALUE = globals.evaluate.varName where varName is the name of the
%   global variable to be evaluted. 
%
%   globals.evaluate will display the value of all global variables.
%
%   The values of the global variables can be modified by editing the text
%   file globals.evaluate.File
%
%   See also: pset.

    properties (SetAccess = private)
        File;
    end
    methods (Access = private)
        function obj = globals
            import misc.strtrim;
            % read globals from settings file
            path = fileparts(mfilename('fullpath'));
            obj.File = [path filesep 'globals.txt'];
            fid = fopen(obj.File);
            C = textscan(fid, '%s%[^\n^#]', 'CommentStyle','#');
            fclose(fid);
            for i = 1:size(C{1},1)
                obj.addprop(C{1}{i});  
                % If the value is an object of a class in the current
                % namespace, we have to be careful to avoid an infinite
                % recursion (if the constructor of such an object uses
                % some package specific global variable).
                idx = strfind(C{2}{i}, 'AAR.');
                if ~isempty(idx)
                    obj.(C{1}{i}) = strtrim(C{2}{i});
                else
                    try
                        obj.(C{1}{i}) = eval(C{2}{i});
                    catch %#ok<CTCH>
                        obj.(C{1}{i}) = strtrim(C{2}{i});
                    end
                end
            end
            
        end
    end
    methods (Static)
        function singleObj = evaluate
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = filter.globals;
            end
            singleObj = localObj;
        end
    end
    
end