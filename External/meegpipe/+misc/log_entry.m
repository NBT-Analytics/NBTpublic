function ME = log_entry(fid, value)

if isempty(fid), return; end
ME = [];
[st, idx] = dbstack;
str = strrep([datestr(now) ' : ' st(idx+1).name ...
    '(' num2str(st(idx+1).line) ') : ' value], '\', '\\');
try
    fprintf(fid, ['\n' str '\n']);
catch ME
    warning('misc:misc:log_entry', ...
        'For some reason I could not write to the log file');
end
   
    