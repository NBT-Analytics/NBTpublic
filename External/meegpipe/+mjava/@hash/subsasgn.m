function obj = subsasgn(obj, S, B)
% SUBSASGN Subscripted assignment for class @hash
%

switch S(1).type
    case '()',
        if numel(S(1).subs) == 1 && iscell(S(1).subs)
            obj.Class.put(S(1).subs{1}, class(B));
            obj.Dimensions.put(S(1).subs{1}, size(B));
            
            if isempty(B),
                obj.Hashtable.put(S(1).subs{1}, '__empty__');
                return;
            end
            
            switch class(B),
                case 'char',
                    if strcmpi(B, '__empty__'),
                       error('String ''__empty__'' cannot be used as hash value'); 
                    end
                case {'single', 'double', 'cell', 'logical'}
                    % No conversion necessary
                case 'function_handle',
                    B = char(B);
                    
                case 'mjava.hash',
                    B = cell(B);
                    % We need to keep track of the dimensions of all
                    % elements of the cell array because the Java
                    % implementation of the hash somehow messes the
                    % dimensions when nesting hashes within hashes
                    dims = cell(1, numel(B));
                    for i = 1:numel(B),
                        dims{i} = size(B{i});
                    end
                    obj.Dimensions.put(S(1).subs{1}, size(B));
                    B={B,dims};
                otherwise
                    warning('off', 'MATLAB:structOnObject');
                    B = struct(B);
                    warning('on', 'MATLAB:structOnObject');
                    obj.FieldNames.put(S(1).subs{1}, fieldnames(B));
                    B = struct2cell(B);
            end
           
            obj.Hashtable.put(S(1).subs{1}, B);
            
            return;
        elseif numel(S(1).subs) > 1 && iscell(S(1).subs)% && ..
            thisSubs        = S(1);
            thisSubs.subs   = thisSubs.subs(1);
            A = subsref(obj, thisSubs);
            thisSubs        = S(1);
            thisSubs.subs   = thisSubs.subs(2:end);
            if ~isempty(A),
                A = subsasgn(A, thisSubs, B);
            else
                A = mjava.hash;
                A = subsasgn(A, thisSubs, B);
            end
            thisSubs        = S(1);
            thisSubs.subs   = thisSubs.subs(1);
            obj = subsasgn(obj, thisSubs, A);
        else
            invalidIndex = MException('hash:subasgn:InvalidIndex', ...
                'Invalid index in indexed assignment');
            throw(invalidIndex);
        end
        
    case '{}',
        maxCount = numel(S(1).subs);
        if maxCount == 1 && isnumeric(S(1).subs{1}),
            S(1).subs = num2cell(S(1).subs{1});
            maxCount = numel(S(1).subs);
        end
        if ~iscell(B) || numel(B) == 1,
            if ~iscell(B),
                B = {B};
            end
            B = repmat(B, 1, maxCount);
        end
        
        if mod(maxCount,2)>1 || maxCount~=numel(B) || ~iscell(B),
            invalidIndex = MException('hash:subasgn:InvalidIndex', ...
                'Invalid index in indexed assignment');
            throw(invalidIndex);
        end
        for count = 1:maxCount
            s.type = '()';
            s.subs = S(1).subs(count);
            obj = subsasgn(obj, s, B{count});
        end
        
    otherwise,
        ME = MException('misc:hash:subasgn:InvalidIndex', ...
            'Invalid indexing type %s in indexed assignment', S(1).type);
        throw(ME);
        
end



end