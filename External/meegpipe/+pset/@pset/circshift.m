function b = circshift(a, shiftsize)
% circshift - Shift pointset circularly
%
%   B = circshift(A, SHIFTSIZE) circularly shifts the values in the
%   pset object A by SHIFTSIZE elements. SHIFTSIZE is a vector or integer
%   scalars where the N-th element specifies the shift amount for the N-th
%   dimension of the pset object. If an element in SHIFTSIZE is positive,
%   the values of A are shifted down (or to the right). If it is negative,
%   the values are shifted up (or to the left).
%
% See also: pset.pset

import misc.isinteger;

if nargin < 2 || isempty(shiftsize) || ~isinteger(shiftsize) || ...
        length(shiftsize) > 2,
    error('pset.pset:circshift:invalidInput', ...
        'Second input argument must be a scalar integer or a vector of two scalar integers.');
end

if ~any(shiftsize), 
    b = copy(a);
    return; 
end 

if abs(shiftsize(2)) > size(a,2),
    error('pset.pset:circshift:invalidShift', ...
        'Attempted to shift %d columns but there are only %d columns.', ...
        shiftsize(2), size(a,2));
end

% Initialize the output
b = pset.nan(a.NbDims, a.NbPoints);
    
if a.Transposed,
    transposed_flag = true;
    a.Transposed = false;
    b.Transposed = false;
    if length(shiftsize) > 1,
        shiftsize = [shiftsize(2) shiftsize(1)];
    else
        shiftsize = [0 shiftsize];
    end
else
    transposed_flag = false;
end

if length(shiftsize) < 2,
   % Shift only the rows
   s.type = '()';   
   for i = 1:a.NbChunks
       [idx, data] = get_chunk(a, i);
       data = circshift(data, shiftsize(1));
       s.subs = {1:b.NbDims, idx};
       b = subsasgn(b, s, data);
   end
else
   % Shift both rows and columns   
   s.type = '()';   
   
   % Shift the rows
   if shiftsize(1) ~= 0,       
       for i = 1:a.NbChunks
           [idx, data] = get_chunk(a, i);
           data = circshift(data, shiftsize(1));
           s.subs = {1:b.NbDims, idx};
           b = subsasgn(b, s, data);
       end
       a = b;
   end
   
   % Shift the columns
   if shiftsize(2) > 0 
       % Move the last points to the front
       s.subs = {1:b.NbDims, b.NbPoints-shiftsize(2)+1:b.NbPoints};       
       data_back = subsref(a, s); 
       for i = 1:a.NbChunks
           [idx, data] = get_chunk(a, i); 
           idx = idx + shiftsize(2);
           data(:,idx>b.NbPoints) = [];
           idx(idx>b.NbPoints) = [];           
           s.subs = {1:b.NbDims, idx};       
           b = subsasgn(b, s, data);
       end
       s.subs = {1:b.NbDims, 1:shiftsize(2)};
       b = subsasgn(b, s, data_back);       
       
   elseif shiftsize(2) < 0
       % Move the front points to the last part
       s.subs = {1:b.NbDims, 1:abs(shiftsize(2))};       
       data_front = subsref(a, s); 
       for i = 1:a.NbChunks
           [idx, data] = get_chunk(a, i); 
           idx = idx + shiftsize(2);
           data(:, idx < 1) = [];
           idx(idx < 1) = [];           
           s.subs = {1:b.NbDims, idx};       
           b = subsasgn(b, s, data);
       end
       s.subs = {1:b.NbDims, b.NbPoints+shiftsize(2)+1:b.NbPoints};
       b = subsasgn(b, s, data_front);      
       
   else
       % do nothing
   end
    
end

b.Transposed = transposed_flag;
a.Transposed = transposed_flag;