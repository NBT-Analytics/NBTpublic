function y = subsref(obj, s)
% SUBSREF Subscripted reference for pset objects
%
%   A(I) is an array formed from the elements of pset object A specified by
%   the  subscript vector I. The resulting array is the same size as I.
%
%   A(I,J) is an array formed from the points specified by index J and from
%   the dimensions specified by the index I. If the Transposed property of
%   object A is set to true, then I identifies point indices while J
%   identifies dimension indices.
%
% See also: pset.SUBSASGN

import misc.find_pattern;


if strcmpi(s(1).type, '()') && ~isempty(obj)
    
    if isempty(obj.MemoryMap) || any(cellfun(@(x) isempty(x), obj.MemoryMap)) ,
        make_mmemmapfile(obj);
    end
    
end

nbPoints = nb_pnt(obj);
nbDims   = nb_dim(obj);

switch s(1).type
    case '()'
        if isempty(obj),
            error('pset:pset:subsref:invalidIndex', ...
                'Index exceeds the dimensions of the pset object.');
        end
        for i = 1:(length(s(1).subs)-2),
            if any(s(1).subs{i+2}~=1),
                error('pset:pset:subsref:invalidIndex', ...
                    'A pset object has only two dimensions.');
            end
        end
        
        % Has the pset been transposed?
        if obj.Transposed
            pOrder = 1;
            dOrder = 2;
        else
            pOrder = 2;
            dOrder = 1;
        end
        if length(s(1).subs) > 1
            % a(I,J)
            % Determine point indices
            isPidxOrdered = false; % Are the point indices ordered?
            if ischar(s(1).subs{pOrder}) && strcmp(s(1).subs{pOrder},':'),
                isPidxOrdered = true;
                pIdx = 1:nbPoints;
            elseif isnumeric(s(1).subs{pOrder}),
                pIdx = s(1).subs{pOrder};
            elseif islogical(s(1).subs{pOrder}),
                isPidxOrdered = true;
                pIdx = find(s(1).subs{pOrder});
            else
                error('pset:pset:subsref:invalidIndex', ...
                    'Index must be an scalar array or the string '':''');
            end
            if any(pIdx<0 | pIdx > nbPoints),
                error('pset:pset:subsref:invalidIndex', ...
                    'Index exceeds the dimensions of the pset object.');
            end
            
            % Determine dimension indices
            if ischar(s(1).subs{dOrder}) && strcmp(s(1).subs{dOrder},':'),
                dIdx = 1:nbDims;
                
            elseif isnumeric(s(1).subs{dOrder}),
                dIdx = s(1).subs{dOrder};
            elseif islogical(s(1).subs{dOrder}),
                
                dIdx = find(s(1).subs{dOrder});
            else
                error('pset:pset:subsref:invalidIndex', ...
                    'Index must be an scalar array or the string '':''');
            end
            if any(dIdx<0 | dIdx > nbDims),
                error('pset:pset:subsref:invalidIndex', ...
                    'Index exceeds the dimensions of the pset object.');
            end
            
            % Initialize output data
            if obj.Transposed
                y = nan(length(pIdx), numel(dIdx));
            else
                y = nan(length(dIdx), numel(pIdx));
            end
            
            % Sort point indices
            if ~isPidxOrdered,
                [pIdx, pIdxUnsort] = sort(pIdx(:), 'ascend');
                if all(diff(pIdxUnsort) > 0),
                    isPidxOrdered = true;
                end
            end
            
            % User-selected data
            if ~isempty(obj.PntSelection),
                pIdx = obj.PntSelection(pIdx);
            end
            if ~isempty(obj.DimSelection),
                dIdx = obj.DimSelection(dIdx);
            end
            
            [mIdx, pIdx] = get_map_index(obj, pIdx);
            umIdx = unique(mIdx);
            
            % Ensure the memory map can be read if even if we dont have
            % write permissions
            
            
            
            if obj.Transposed,
                for i = 1:length(umIdx)
                    this_map_subset = (mIdx==umIdx(i));
                    origWritable = obj.MemoryMap{umIdx(i)}.Writable;
                    obj.MemoryMap{umIdx(i)}.Writable = false;
                    y(this_map_subset, :) = ...
                        obj.MemoryMap{umIdx(i)}.Data.Data(dIdx, ...
                        pIdx(this_map_subset))';
                    obj.MemoryMap{umIdx(i)}.Writable = origWritable;
                end
            else
                for i = 1:length(umIdx)
                    this_map_subset = (mIdx==umIdx(i));
                    origWritable = obj.MemoryMap{umIdx(i)}.Writable;
                    obj.MemoryMap{umIdx(i)}.Writable = false;
                    y(:, this_map_subset) = ...
                        obj.MemoryMap{umIdx(i)}.Data.Data(dIdx, ...
                        pIdx(this_map_subset));
                    obj.MemoryMap{umIdx(i)}.Writable = origWritable;
                    if obj.AutoDestroyMemMap,
                        destroy_mmemmapfile(obj, umIdx(i));
                    end
                end
            end
            
            
            
            % Undo the sorting
            if ~isPidxOrdered
                if obj.Transposed,
                    y(pIdxUnsort,:) = y;
                else
                    y(:,pIdxUnsort) = y;
                end
            end
            
        else
            % a(I)
            
            if ischar(s(1).subs{1}) && strcmp(s(1).subs{1},':'),
                indices = (1:(nbDims*nbPoints))';
            elseif isnumeric(s(1).subs{1}),
                indices = s(1).subs{1};
            else
                error('pset:pset:subsref:invalidIndex', ...
                    'Index must be an scalar array or the string '':''');
            end
            
            y = nan(size(indices));
            
            if obj.Transposed
                colIdx = ceil(indices/nbPoints);
                rowIdx = mod(indices-1,nbPoints)+1;
                
                if length(indices) == nbDims*nbPoints,
                    thisS.type = '()';
                    
                    pntIdx = 1:nbPoints;
                    
                    dimIdx = 1:nbDims;
                    
                    thisS.subs = {pntIdx, dimIdx};
                    y = subsref(obj, thisS);
                    y = reshape(y, size(indices));
                else
                    % Worst case: very slow -> think of something smarter?
                    for i = 1:length(indices)
                        thisS.type = '()';
                        thisS.subs = {rowIdx(i), colIdx(i)};
                        y(i) = subsref(obj, thisS);
                    end
                end
            else
                colIdx = ceil(indices/nbDims);
                rowIdx = mod(indices-1,nbDims)+1;
                
                pos = find_pattern(rowIdx,1:nbDims);
                if length(pos) == ceil(length(indices)/nbDims)
                    % All dimensions are selected for all points
                    thisS.type = '()';
                    pntIdx = unique(colIdx);
                    
                    thisS.subs = {':', pntIdx};
                    y = subsref(obj, thisS);
                    y = reshape(y, size(indices));
                elseif all(diff(indices)==1) && ~isempty(pos)
                    % At most the first and last point are "cut"
                    for i = 1:(pos(1)-1)
                        thisS.type = '()';
                        thisS.subs = {rowIdx(i),colIdx(i)};
                        y(i) = subsref(obj,thisS);
                    end
                    thisS.type = '()';
                    thisS.subs = {1:nbDims,...
                        unique(colIdx(pos(1):(pos(end)+nbDims-1)))};
                    y(pos(1):(pos(end)+nbDims-1))= ...
                        subsref(obj, thisS);
                    for i = (pos(end)+nbDims):length(indices)
                        thisS.type = '()';
                        thisS.subs = {rowIdx(i),colIdx(i)};
                        y(i) = subsref(obj, thisS);
                    end
                else
                    % Worst case: very slow -> think of something smarter?
                    for i = 1:length(indices)
                        thisS.type = '()';
                        thisS.subs = {rowIdx(i),colIdx(i)};
                        y(i) = subsref(obj, thisS);
                    end
                end
            end
        end
        
    case '.'
        if length(s) < 2,
            y = obj.(s(1).subs);
        else
            y = subsref(obj.(s(1).subs),s(2:end));
        end
        
    otherwise
        error('pset:pset:subsref:invalidIndexingType',...
            'Indexing of type %s is not allowed for pset objects.', s(1).type);
end
