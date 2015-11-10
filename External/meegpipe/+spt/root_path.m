function p = root_path
% ROOT_PATH - Returns EEGPIPE's absolute root path
%

thisPath = fileparts(mfilename('fullpath'));

p = regexprep(thisPath, '(.+).\+eegpipe$', '$1'); 

end