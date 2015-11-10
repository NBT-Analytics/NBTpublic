function pos = find_pattern(array, pattern)
% FIND_PATTERN Finds pattern in numeric array
%
%   POS = find_pattern(ARRAY, PATTERN) finds the locations of numeric
%   pattern PATTERN within the numeric array ARRAY.
%
% Note:
% This function has been written by Loren Shure. See:
% http://blogs.mathworks.com/loren/2008/09/08/finding-patterns-in-arrays/
% 
% 
len = length(pattern);
pos = find(array==pattern(1));
endVals = pos+len-1;
pos(endVals>length(array)) = [];
for pattval = 2:len    
    locs = pattern(pattval) == array(pos+pattval-1);    
    pos(~locs) = [];
end
