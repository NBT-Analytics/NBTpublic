function cArray = get_varargin(cfg, section)
% GET_VARARGIN - Gets section arguments as a varargin cell array
%
% cArray = get_varargin(cfg, section)
%
% Where
%
% CFG is a inifile object
%
% SECTION is a section of the ini file
%
% CARRAY is a cell array containing pairs of parameter names and parameter
% values.
%
% ## Usage synopsis:
%
% cfg = inifile('proc_node_config.ini');
% inputArg = get_varargin(cfg, 'myfunc');
% myfunc(data, inputArg{:});
%
%
% ## Notes:
%
% * Function eval() will be applied to all parameter values before forming
%   the output cell array. That is, a parameter value 1:6 in the inifile
%   will be converted to a numeric matlab array while value 'mystring' will
%   be converted to a char array of 8 elements that contains the text mystring
%
%
% See also: inifile

% Documentation: class_mperl_config_inifiles_inifile.txt
% Description: Get section parameters as a cell array


params = parameters(cfg, section);

if ischar(params),
    params = {params};
end

cArray = cell(1, numel(params)*2);
count = 0;
for i = 1:numel(params)    
    count = count + 1;
    cArray{count} = params{i};
    paramVal = val(cfg, section, params{i}, true);
    if iscell(paramVal),
        paramVal = cellfun(@(x) eval(x), paramVal, 'UniformOutput', false);
    else
        paramVal = eval(paramVal);
    end
    cArray{count+1} = paramVal;
    count = count+1;
end

end