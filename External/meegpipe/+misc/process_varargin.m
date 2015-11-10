function [cmd_str, remove] = process_varargin(option_names, cell_array)

cmd_str = '';

if nargin < 2,
    remove = [];
    return;
end

nargs = length(cell_array);
remove = false(1,nargs);
arg_itr = 1;
while arg_itr < nargs
    if ~ischar(cell_array{arg_itr}),
        error('misc:process_varargin:invalidInput', ...
            'Input arguments must be in pairs (propname, propvalue).');
    end
    
    [~, loc] = ismember(lower(cell_array{arg_itr}), lower(option_names));
    if loc > 0 && ~all(isempty(cell_array{arg_itr + 1}))
        cmd_str = [cmd_str option_names{loc} '=varargin{' num2str(arg_itr+1)  '};']; %#ok<AGROW>
        remove(arg_itr:arg_itr+1) = true;
    end
    
    arg_itr = arg_itr + 2;
end
