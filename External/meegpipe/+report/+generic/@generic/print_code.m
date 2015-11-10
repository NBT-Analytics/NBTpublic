function count = print_code(obj, varargin)
% PRINT_CODE - Print MATLAB code to remark report
%
% count = print_code(obj, line1, line2, ...)
%
% Where
%
% LINE1, LINE2, ... are the lines of code to be printed.
%
% COUNT is the number of characters that were actually written to the
% report text file.
%
% See also: print_title, print_paragraph, print_link, print_file_link
   
import misc.code2multiline;
import misc.quote;

count = fprintf(obj, '[[Code]]:\n');

for i = 1:numel(varargin)
    code = varargin{i};
    code = code2multiline(code, [], char(9));
    count = count + fprintf(obj, [quote(code) '\n\n']);
end


end