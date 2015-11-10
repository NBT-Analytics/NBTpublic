function y = struct2xml(x, filename)
% STRUCT2XML Converts a struct into an XML-encoded string
%
%   Y = struct2xml(X) where X is a struct with fields 'field1', 'field2',
%   with values value1 and value2, respectively, generates the following
%   XML string:
%
%   <struct>
%       <field1>value1</field1>
%       <field1>value2</field1>
%   <struct>
%
%   All property values which are not struct will be encoded as strings.
%
% See also: xml2struct

import xml.struct2xml;
import misc.matrix2str;
import misc.cell2str;

if numel(x) > 1,
   y = sprintf('<struct>\n');
   for k = 1:numel(x)
      this = struct2xml(x(k)); 
      y = [y this]; %#ok<*AGROW>
   end
   y = [y sprintf('</struct>')];
   return;
end

y = sprintf('<struct>\n');
fnames = fieldnames(x);
for i = 1:length(fnames)
    if isstruct(x.(fnames{i})),
        fvalue = struct2xml(x.(fnames{i}));
    elseif isnumeric(x.(fnames{i})),
        fvalue = matrix2str(x.(fnames{i}));
    elseif ischar(x.(fnames{i})),       
        fvalue =  x.(fnames{i});
    elseif iscell(x.(fnames{i})),
        fvalue = cell2str(x.(fnames{i}));
    else
        try
            fvalue = char(x.(fnames{i}));
        catch ME %#ok<NASGU>
            fvalue = 'null';
        end
    end
    
    tmp = sprintf('<%s>%s</%s>', fnames{i}, fvalue, fnames{i});
    y = [y tmp];             %#ok<AGROW>
end
y = [y sprintf('</struct>')];

if nargin > 1 && ~isempty(filename),
    fid = fopen(filename, 'w');
    fwrite(fid, y);
    fclose(fid);
    tidyObj = mperl.xml.tidy.tidy(filename);
    make_tidy(tidyObj);
end