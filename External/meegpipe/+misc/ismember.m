function [tf,loc] = ismember(A, S, varargin)


[tf, loc] = ismember(A, S, varargin{:});

if nargin < 2 || ...
        (~iscell(A) && ~ischar(A)) || (~iscell(S) && ~ischar(S)) ...
        || (ischar(A) && size(A,1)>1) ...
        || (ischar(S) && size(S,1)>1),
    return;
end

if ischar(A),
    A = {A};
end

if ischar(S),
    S = {S};
end

loc = loc(:);
loc_idx = setdiff(1:length(S), loc);
tf_idx = find(~tf);
As = A(tf_idx);

for i = 1:length(As)
    for j = 1:length(loc_idx)
       pat = ['\W*' As{i} '\W*'];
       if ~isempty(regexp(S{loc_idx(j)}, pat, 'once')),
          tf(tf_idx(i)) = true; 
          loc(tf_idx(i)) = loc_idx(j);
          break;
       end
    end
end


end