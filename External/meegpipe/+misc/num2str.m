function str = num2str(num, clip)

import misc.strtrim;

if nargin < 2 || isempty(clip), clip = Inf; end

if isempty(num),
    str = '';
elseif numel(num) == 1,
    str = num2str(num);
elseif ndims(num) == 2
    % If short, print, otherwise write to file and link 
    tmpStr = num2str(num);
    str    = repmat(' ', 1, numel(tmpStr)+(size(tmpStr, 1) - 1));
    count  = 1;
    if size(tmpStr,1) > 1,
        for i = 1:size(tmpStr,1)-1
            this = strtrim(tmpStr(i,:));
            str(count:(count+numel(this))) = [this ';'];
            count = count + numel(this) + 1;
        end
        this = strtrim(tmpStr(end,:));
        str(count:(count+numel(this)-1)) = this;
        str((count+numel(this)):end) = [];   
    else
        str = tmpStr;
    end   
    str = strtrim(str);
    str = regexprep(str, '\s+', ' , ');
    str = ['[ ' strrep(str, ';', ' ; ') ' ] '];
else
    str = sprintf('[ %s %s ]', num2str(size(num)), class(num));
end

if numel(str) > clip,
    idx = [strfind(str, ',') strfind(str, ';')];
    idx(idx > clip) = [];    
    if isempty(idx),
        str = [str(1:clip) ' ...]'];
    else
        str = [str(1:idx(end)) ' ...]'];
    end
end

end