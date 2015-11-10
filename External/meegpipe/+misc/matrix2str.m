function y = matrix2str(x, multiline)
% MATRIX2STR Converts a numeric matrix to a character array
%
%   Y = matrix2str(X) converts the array X=[1 2 3; 4 5 6] into the char
%   array '[1 2 3; 4 5 6]' so that X==eval(Y).
%
% See also: misc/struct2xml, misc/cell2str

if nargin < 2 || isempty(multiline),
    multiline = true;
end

if ndims(x) > 2,
    error('Numeric arrays of more than 2 dimensions are not supported');
end

if isempty(x),
    
    y = '[]';
    return;
end

y = num2str(x);

if numel(x) > 1,
    
    isMatrix = false;
    if size(y, 1) > 1,
        
        tmp = '';
        
        isMatrix = true;
        for j = 1:size(y,1)-1
            
            tmp = [tmp regexprep(y(j,:), '(\w+)\s+', '$1, ')  '; ']; %#ok<*AGROW>
            
            if multiline,
                
                tmp = [tmp char(10)];
                
            end
            
        end
        
        y = [tmp y(end,:)];
        
    end
    
    if multiline,
        
        y = ['[' char(10) y char(10) ']'];
        
    else
        
        if ~isMatrix,
            y = regexprep(y, '\s+', ', ');
        end
        
        y = ['[' y ']'];
        
    end
    
end
