function y = eq(a,b)
% == Equal.
%
%   A == B does element by element comparisons between two arrays of event
%   objects or between an array of event objects and a string.
%
% See also: pset.event

% Documentation: class_pset_event.txt
% Description: Tests for equality


if ~isa(a, 'physioset.event.event'),
    tmp = a;
    a = b;
    b = tmp;
end

y = false(size(a));

if ischar(b),
    for i = 1:numel(a) 
        y(i) = strcmpi(a(i).Type, b);        
    end
elseif iscell(b),
    for i = 1:numel(a)
       y(i) = ismember(num2str(a(i).Type), b); 
    end
elseif isnumeric(b),
    for i = 1:numel(a)
        y(i) = abs((a(i).Type-b)) < eps;        
    end    
elseif isa(b, 'physioset.event.event'),
    if numel(b) > 1 && (ndims(a)~=ndims(b) || ~all(size(a)==size(b))),
        error('The dimensions of the input arguments do not match.');
    end
    if numel(a) == 1 && numel(b) > 1,
        a = repmat(a, numel(b),1);
    elseif numel(b) == 1 && numel(a) > 1,
        b = repmat(b, numel(a), 1);
    end
    for i = 1:prod(size(a)) %#ok<PSIZE> 
       
        y(i) = strcmpi(a(i).Type, b(i).Type);
        
        y(i) = y(i) && strcmp(class(a(i)), class(b(i)));        
   
    end    
else
    error('Attempted comparison between incompatible types.');
    
end
