function val = count_lines(file)
% COUNT_LINES - Counts the number of lines in text file using PERL
%
% val = count_lines(file)
%
% Where:
%
% FILE is a string with the file name
%
% VAL is the number of lines in the file
%
%
% (c) German Gomez-Herrero, german.gomezherrero@ieee.org


val = perl('+misc/count_lines.pl', file);


end