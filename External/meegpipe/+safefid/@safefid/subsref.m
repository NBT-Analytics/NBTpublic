function varargout = subsref(this, s)

if numel(this) > 1,
    varargout = cell(size(this));
    for i = 1:numel(this),
        varargout{i} = subsref(this(i), s);
    end
    return;
end

switch s(1).type
    
    case '.'
        
        if nargout > 0,
            lhs = 'varargout{%d} ';
            lhs = repmat(lhs, 1, nargout);
            lhs = ['[' sprintf(lhs, 1:nargout) ']='];
        else
            lhs = '';
        end
        
        if ismember(s(1).subs, {'FileName', 'Valid'}),
            varargout = {this.(s(1).subs)};
            return;
        end
        
        if this.Valid,
            
            if numel(s) > 1,
                eval(...
                    sprintf(...
                    '%sfeval(''%s'', this.FID,  s(2).subs{:});', ...
                    lhs, s(1).subs) ...
                    );
            else
                eval(...
                    sprintf('%sfeval(''%s'', this.FID);', ...
                    lhs, s(1).subs) ...
                    );
            end
            
        else
            
            throw(MException('safefid:InvalidFID', ...
                'Cannot operate with an invalid file identifier'));
            
        end       
        
    otherwise
        
        varargout{1} = builtin('subsref', this, s);
        
end

end
