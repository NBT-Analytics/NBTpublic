function obj = subsasgn(obj, s, b)
% SUBSASGN Subcripted assignment
%
%   A(I,J) = B assigns the values of B into the points stored in the pset
%   object A.
%
%
% See also: subsref

if isempty(obj),
    error('pset:pset:subsasgn:invalidIndex', ...
        'Cannot assign to an empty pset object.');
end

if isempty(obj.MemoryMap) && strcmp(s(1).type, '()'),
    make_mmemmapfile(obj);    
end

switch s(1).type
    
    case '()',
        for i = 1:(length(s(1).subs)-2),
            if any(s(1).subs{i+2}~=1),
                error('pset:pset:subsasgn:invalidIndex', ...
                    'A pset object has only two dimensions.');
            end
        end
        
        % Has the pset been transposed?
        if obj.Transposed
            p_order = 1;
            d_order = 2;
        else
            p_order = 2;
            d_order = 1;
        end
        
        if length(s(1).subs) > 1
           % obj(I,J) = b; 
           % Determine point indices
            if ischar(s(1).subs{p_order}) && strcmp(s(1).subs{p_order},':'),
                pIdx = 1:nb_pnt(obj);
            elseif isnumeric(s(1).subs{p_order}),
                pIdx = s(1).subs{p_order};
            elseif islogical(s(1).subs{p_order}),
                pIdx = find(s(1).subs{p_order});
            else
                error('pset:pset:subsasgn:invalidIndex', ...
                    'Index must be an scalar array or the string '':''');
            end
            if any(pIdx<0 | pIdx > obj.NbPoints),
                error('pset:pset:subsasgn:invalidIndex', ...
                    'Index exceeds the dimensions of the pset object.');
            end
            % Determine dimension indices
            if ischar(s(1).subs{d_order}) && strcmp(s(1).subs{d_order},':'),
                dIdx = 1:nb_dim(obj);
            elseif isnumeric(s(1).subs{d_order}),
                dIdx = s(1).subs{d_order};
            elseif islogical(s(1).subs{d_order}),
                dIdx = find((s(1).subs{d_order}));
            else
                error('pset:pset:subsasgn:invalidIndex', ...
                    'Index must be an scalar array or the string '':''');
            end
            if any(dIdx<0 | dIdx > obj.NbDims),
                error('pset:pset:subsasgn:invalidIndex', ...
                    'Index exceeds the dimensions of the pset object.');
            end
            
            if ~isempty(obj.PntSelection),
                pIdx = obj.PntSelection(pIdx);
            end
            if ~isempty(obj.DimSelection),
                dIdx = obj.DimSelection(dIdx);
            end
                    
            % Determine the filemaps of each point
            [m_indices, pIdx] = get_map_index(obj, pIdx);
            
            % Write the corresponding points to each filemap
            u_m_indices = unique(m_indices);
            if obj.Transposed,
                for i = 1:length(u_m_indices)
                    this_map_subset = (m_indices==u_m_indices(i));
                    if prod(size(b)) < 2,
                        obj.MemoryMap{u_m_indices(i)}.Data.Data(dIdx, ...
                            pIdx(this_map_subset)) = b;
                    else
                        obj.MemoryMap{u_m_indices(i)}.Data.Data(dIdx, ...
                            pIdx(this_map_subset)) = b(this_map_subset, :).';
                    end
                end
            else
                for i = 1:length(u_m_indices)
                    this_map_subset = (m_indices==u_m_indices(i));
                    if prod(size(b)) < 2, %#ok<*PSIZE>
                        obj.MemoryMap{u_m_indices(i)}.Data.Data(dIdx, ...
                            pIdx(this_map_subset)) = b;
                    else
                        obj.MemoryMap{u_m_indices(i)}.Data.Data(dIdx, ...
                            pIdx(this_map_subset)) = b(:, this_map_subset);
                    end
                end
            end
        else
            % obj(I) = b;       
            error('pset:pset:subsasgn:invalidIndex', ...
                    'Single index subasgn had not been implemented yet!');           
        end
        
    
    case '.'
        if length(s) < 2,
           obj.(s(1).subs) = b;
        elseif strcmp(s(1).subs, 'PointSet'),
            if numel(s) > 2,
                error('Not implemented');
            else
                obj.(s(2).subs) = b;
            end
        else
            obj = subsasgn(obj.(s(1).subs),s(2:end),b);
        end
        
    otherwise
        error('pset:pset:subsasgn:invalidIndexingType',...
            'Indexing of type %s is not allowed for pset objects.', s(1).type);
        
        
end

end

