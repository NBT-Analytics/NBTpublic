function [out2, out] = xml2struct(xmlfile, evalFlag)
% XML2STRUCT - Read XML file into a structure
%
% str = xml2struct(file, evalFlag)
%
% Where
%
% FILE is the full path to a .xml file or, alternatively, a char array
% containing valid XML code.
%
% EVALFLAG is a logical scalar. If set to true, XML node values will be
% evaluated using eval(). If set to false, then XML node values will
% be char arrays. Default: EVALFLAG=false
%
% STR is the generated MATLAB structure
%
% See also: struct2xml

if nargin < 2,
    evalFlag = false;
end

import mperl.perl_eval;

if ischar(xmlfile) && ~exist(xmlfile, 'file'),
    tmpFile = tempname;
    fid = fopen(tmpFile, 'w');
    try
        fprintf(fid, xmlfile);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    fclose(fid);
    xmlfile = tmpFile;
end

% Remove blanks and newlines
tmp_xmlfile = tempname;
tmp_xmlfile2 = tempname;
perl('+mperl/strip_spaces.pl',   xmlfile, tmp_xmlfile);
perl('+mperl/strip_nl.pl',       tmp_xmlfile, tmp_xmlfile2);
tmp_xmlfile = tmp_xmlfile2;

xml = xmlread(tmp_xmlfile);

children = xml.getChildNodes;

nchildren = children.getLength;
c = cell(1, nchildren);
%'attributes',c,
out =  struct('name',c,'data',c,'children',c);
for i = 1:nchildren
    child = children.item(i-1);
    [out(i), out2] = node2struct(child, evalFlag);
end

out2 = purge_struct_fields(out2);



end


function out = purge_struct_fields(in)

if numel(in) > 1,
    out = in;
    for i = 1:numel(in)
        out(i) = purge_struct_fields(in(i));
    end
    return;
end

fnames = fieldnames(in);

out = in;
for j = 1:numel(fnames)
    if isstruct(in.(fnames{j})),
        fnames2 = fieldnames(in.(fnames{j}));
        if numel(fnames2) == 1 && strcmpi(fnames2{1}, 'struct'),
            out.(fnames{j}) = purge_struct_fields(in.(fnames{j}).struct);
        end
    end
end

end


function [s,s2] = node2struct(node, evalFlag)

s2='';
tmp = char(node.getNodeName);
tmp = strrep(tmp, '-', '_dash_');
tmp = strrep(tmp, ':', '_colon_');
tmp = strrep(tmp, '.', '_dot_');
s.name = tmp;

try
    s.data = char(node.getData);
catch %#ok<CTCH>
    s.data = '';
end

if node.hasChildNodes
    children = node.getChildNodes;
    nchildren = children.getLength;
    if nchildren==1 && strcmpi(char(children.item(0).getNodeName), '#text'),
        s.data = char(children.item(0).getData);
        s.children = [];
        if isempty(s.data),
            s2.(s.name) = '';
        elseif numel(s.data(1))>2 && strcmpi(s.data(1), '''') && strcmpi(s.data(end), ''''),
            s2.(s.name) = s.data(2:end-1);
        elseif evalFlag,
            try
                s2.(s.name) = eval(s.data);
            catch ME %#ok<*NASGU>
                try
                    s2.(s.name) = eval(['[' s.data ']']);
                catch ME
                    s2.(s.name) = s.data;
                end
            end
        else
            s2.(s.name) = s.data;
        end
        return;
    end
    c = cell(1,nchildren);
    %, 'attributes', c
    s.children = struct('name', c, 'data', c, 'children', c);
    
    for i = 1:nchildren
        child = children.item(i-1);
        childName = char(child.getNodeName);
        if strcmpi(childName, '#text'),
            childData = char(child.getData);
            if ~isempty(regexpi(childData, '^\s*$')),
                % It is a dummy node
                continue;
            else
                s.children(i).name = '#text';
                s.children(i).data = childData;
                tmp = struct('text', childData);
            end
        else
            [s.children(i), tmp] = node2struct(child, evalFlag);
        end
        
        if isfield(s2, childName),
            if isstruct(tmp) && isfield(tmp, childName),
                % This node name was already found before
                % so we attach it to the already existing field
                if numel(s2)==1 && isstruct(s2.(childName)),
                    s2.(char(child.getNodeName))(end+1:end+1) = ...
                        tmp.(char(child.getNodeName));
                else
                    s2 = [s2(:);tmp];
                end
            elseif isstruct(tmp)
                % A new node name, so we create a new field
                tmpFieldNames = fieldnames(tmp);
                s2.(childName)(end+1:end+1).(tmpFieldNames{1}) = ...
                    tmp.(tmpFieldNames{1});
                for itmpFieldNames=2:numel(tmpFieldNames)
                    s2.(childName)(end:end).(tmpFieldNames{itmpFieldNames}) = ...
                        tmp.(tmpFieldNames{itmpFieldNames});
                end
            end
        else
            if isstruct(tmp) && isfield(tmp, childName) ...
                    && numel(fieldnames(tmp)) < 2,
                s2.(childName) = tmp.(childName);
            else
                try
                    s2.(childName) = tmp;
                catch ME
                    if ~strcmpi(ME.identifier, ...
                            'MATLAB:AddField:InvalidFieldName'),
                        rethrow(ME);
                    end
                end
            end
        end
        
    end
    
else
    s.children = [];
end

end