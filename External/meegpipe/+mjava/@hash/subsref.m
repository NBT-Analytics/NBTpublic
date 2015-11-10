function B = subsref(obj, S)
% SUBSREF Subscripted reference for class @hash
switch S(1).type
    case '()'
        if numel(S(1).subs) == 1 && iscell(S(1).subs)
            
            if numel(S(1).subs{1})  > 1 && ~ischar(S(1).subs{1}),
                
                % Use recursion
                tmp = S(1);
                if isnumeric(S(1).subs{1}),
                    tmp.subs = {S(1).subs{1}(1)};
                elseif iscell(S(1).subs{1}),
                    tmp.subs = S(1).subs{1}(1);
                else
                    error('Invalid subsref');
                end
                B = subsref(obj, tmp);
                B = repmat({B}, size(S(1).subs{1}));
                for i = 2:numel(S(1).subs{1})
                    if isnumeric(S(1).subs{1}(i)),
                        tmp.subs = {S(1).subs{1}(i)};
                    else
                        tmp.subs = S(1).subs{1}(i);
                    end
                    B{i} =  subsref(obj, tmp);
                end
                return;
                
            elseif iscell(S(1).subs{1})
                if isempty(S(1).subs{1}),
                    B = [];
                    return;
                else
                    S(1).subs{1} = S(1).subs{1}{1};
                end
            end
            
            B = obj.Hashtable.get(S(1).subs{1});
            
            mustBeClass = char(obj.Class.get(S(1).subs{1}));
            if isempty(B),
                if strcmp(mustBeClass, 'cell'),
                    B = {};
                end
                return;
            end
            if ~isa(B, mustBeClass) || ischar(B) && strcmp(B, '__empty__'),
                switch mustBeClass
                    case 'logical',
                        if strcmpi(B, '__empty__'),
                            B = logical([]);
                        else
                            B = logical(B);
                        end
                        
                    case {'single', 'double', 'char', 'cell'}
                        % Automatic conversion
                        if ischar(B) && strcmpi(B, '__empty__'),
                            B = '';  %#ok<NASGU>
                        end
                        B = eval([mustBeClass '(B);']);
                    case 'function_handle',
                        % function_handles cannot be empty
                        B = eval(B);
                        
                    case 'mjava.hash',
                        if ischar(B) && strcmpi(B, '__empty__'),
                            B = mjava.hash;
                        else
                            B = cell(B);
                            % Trick to be able to recover the right
                            % dimensions for each cell element when nesting
                            % hashes within hashes (see the corresp.
                            % comment in subsasgn)
                            dims = cell(B{2});
                            B = cell(B{1});
                            B = reshape(B, obj.Dimensions.get(S(1).subs{1})');
                            for i = 1:numel(B)
                                B{i} = reshape(B{i}, ...
                                    reshape(dims{i}, 1, numel(dims{i})));
                            end
                            B = mjava.hash.from_cell(B);
                        end
                        
                    otherwise
                        if ischar(B) && strcmpi(B, '__empty__'),
                            B = eval(mustBeClass);
                        else
                            fieldNames = cell(obj.FieldNames.get(S(1).subs{1}));
                            B = cell2struct(cell(B), fieldNames);    %#ok<NASGU>
                            try
                                B = eval([mustBeClass '(B);']);
                            catch %#ok<CTCH>
                                try
                                    B = eval([mustBeClass '.from_struct(B);']);
                                catch ME
                                    ME = MException('hash:subsref:CannotRecoverObject', ...
                                        'No from_struct method for class %s', ...
                                        mustBeClass);
                                    throw(ME);
                                end
                            end
                        end
                end
            end
            if ~ismember(mustBeClass, {'mjava.hash', 'function_handle'}),
                B = reshape(B, obj.Dimensions.get(S(1).subs{1})');
            end
            if numel(S)>1,
                B = subsref(B, S(2:end));
            end
            
            return;
            
        elseif numel(S(1).subs) > 1 && iscell(S(1).subs)% && ..
            
            thisSubs        = S(1);
            thisSubs.subs   = thisSubs.subs(1);
            B = subsref(obj, thisSubs);
            thisSubs        = S(1);
            thisSubs.subs   = thisSubs.subs(2:end);
            if ~isempty(B),
                B = subsref(B, thisSubs);
            end
            
            return;
            
        end
        
        ME = MException('misc:hash:subsref:InvalidIndex', ...
            'Invalid index in indexed reference');
        throw(ME);
        
    otherwise
        ME = MException('misc:hash:subasgn:InvalidIndex', ...
            'Invalid indexing type %s in indexed reference', S(1).type);
        throw(ME);
        
        
end



end