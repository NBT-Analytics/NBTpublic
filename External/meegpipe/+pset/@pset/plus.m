function y = plus(varargin)
% + Plus. 
%
%   A + B adds B to the contents of pset object A. B can be either a
%   numeric array or a pset object.
%
% See also: pset.pset


count = 1;
while count < nargin && ~isa(varargin{count}, 'pset.pset'),
    count = count + 1;
end

y = varargin{count};

varargin = varargin(setdiff(1:nargin, count));


for i = 1:y.NbChunks
    [index, dataa] = get_chunk(y, i);
    for j = 1:numel(varargin)        
        if isa(varargin{j}, 'pset.pset'),
            [~, datab] = get_chunk(varargin{j}, i);
        elseif numel(varargin{j})==1,
            datab = varargin{j}(1);
        else
            if y.Transposed,
                datab = varargin{j}(index, :);
            else
                datab = varargin{j}(:, index);
            end
        end
        if y.Transposed,
            s.subs = {index, 1:nb_dim(y)};
        else
            s.subs = {1:nb_dim(y), index};
        end
        s.type = '()';
        y = subsasgn(y, s, dataa + datab);
    end
end