function [token_file_list, token_value] = regexpi_dir(folder, token_str, token_name)
% regexpi_dir - Names of files matching a regular expression (case
% insensitive)
%
%   FILE_LIST = regexpi_dir(FOLDER, REG_EXP) where FOLDER is the folder to
%   search for matching file names and REG_EXP is the regular expression to
%   match. The ouput FILE_LIST is a cell array with the matching file
%   names.
%
% See also: REGEXPI


if nargin < 3, token_name = ''; end

if ~strcmp(folder(end), filesep),
    folder = [folder filesep];
end

file_list = dir(folder);
pname = fileparts(folder);

token_file_list = cell(length(file_list), 1);
token_count = 0;
if isempty(token_name),
    for i = 1:length(file_list)
        this_fname = file_list(i).name;
        token_idx = regexpi(this_fname, token_str,'tokens');
        if ~isempty(token_idx),
            token_count = token_count+1;
            token_file_list{token_count} = [pname filesep this_fname];
        end
    end
    token_file_list(token_count+1:end) = [];
else
    token_value = nan(length(file_list), 1);
    for i = 1:length(file_list)
        this_fname = file_list(i).name;
        token = regexpi(this_fname, token_str,'names');
        if ~isempty(token),
            token_count = token_count+1;
            token_file_list{token_count} = [pname filesep this_fname];
            token_value(token_count) = str2double(token.(token_name));
        end
    end
    token_value(token_count+1:end) = [];
    [token_value, idx] = sort(token_value, 'ascend');
    token_file_list = token_file_list(idx);
end




end
