function regex_rep(file, regex, rep)
% REGEX_REP - Match and replace regular expression within a text file
%
% regex_rep(file, regex, rep)
%
% where
%
% FILE is the full path to the file to be processed
%
% REGEX is the pattern to be matched
%
% REP is the replacement for each match
%
%
% Example:
% When converting Excel pages to .csv files you may find that division by
% zero errors have introduced the string #DIV/0! in different locations of 
% the csv file. This can be problematic when trying to import the csv file
% to MATLAB. The following command can be used to remove the #DIV/0!
% occurrences from the file:
%
% regex_rep('mycsvfile.csv', '#DIV/0!', '');
%
% 
% See also: +misc

% Use #DIV/0! for zero-divisions in Excel pages converted to csv format

tmpFile = tempname;
perl('+misc/regex_rep.pl', ['''' regex ''''], ['''' rep ''''], file, tmpFile);
movefile(tmpFile, file);

end