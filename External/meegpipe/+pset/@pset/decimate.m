function y = decimate(obj, varargin)

import misc.process_varargin;
import pset.globals;

if nargin < 2,
    varargin = {1};
end

THIS_OPTIONS = {'verbose'};

verbose = globals.evaluate.Verbose;

[cmd_str, remove_flag] = process_varargin(THIS_OPTIONS, varargin);
eval(cmd_str);
varargin(remove_flag) = [];

transposed_flag = false;
if obj.Transposed,
    obj.Transposed = false;
    transposed_flag = true;
end
s.type = '()';

if verbose,
    [~, name, ext] = fileparts(obj.DataFile);
    fprintf('\n(decimate) Decimating ''%s''', [name ext]);  
end
y = pset.zeros(size(obj,1), ceil(size(obj,2)/varargin{1}));
y.Writable = true;
y.Temporary = true;
y.Compact = obj.Compact;

for i = 1:obj.NbDims
    s.subs = {i, 1:obj.NbPoints};
    data = decimate(subsref(obj, s), varargin{:});  
    s.subs = {i, 1:length(data)};
    y = subsasgn(y, s, data);    
    if verbose && ~mod(i, floor(obj.NbDims/10)),
        fprintf('.');
    end
end
if verbose, fprintf('[done]\n');  end

if transposed_flag,
    obj.Transposed = true;    
    obj.Transposed = true; 
    y.Transposed = true;
end


end