function [pValue, refs] = pval2str(origRepObj, pValue, varargin)
% PVAL2STR - Convert pVals to strings and remark references
%
% [pValueStr, refs] = pval2str(obj, pValue)
% [pValueStr, refs] = pval2str(obj, pValue, 'key', value, ...)
%
% Where
%
% PVALUE is a cell array of parameter or object property values
%
% PVALUESTR is a cell array of strings that can be used to describe each of
% the provided pValues in the report. 
%
% REFS is a Kx2 cell array of strings with reference names and reference
% targets.
%
% ## Accepted (optional) key/value pairs:
%
%       PropName:   A string. Default: ''
%           If the provided pValues are properties of an object that is
%           itself a property value of another object, you can use this
%           property so that the generated references and report titles
%           will show also this piece of information.
%
%       ArgName:    A string. Default: ''
%           This key has a similar role as PropName but ArgName can be used
%           to specify that the provided pValues are properties of an
%           object that is itself an argument to a method or function. 
%
%
% See also: abstract_report, report

import mperl.file.spec.*;
import misc.cell2str;
import misc.process_arguments;
import mperl.file.spec.catfile;
import safefid.safefid;
import misc.unique_filename;
import misc.dimtype_str;

opt.PropName        = '';
opt.ArgName         = '';
[~, opt] = process_arguments(opt, varargin);

if isempty(pValue),
    pValue = [];
    refs = [];
    return;
end

fileName = get_filename(origRepObj);

if isempty(opt.PropName),
    opt.PropName = repmat({''}, 1, numel(pValue));
end

if isempty(opt.ArgName),
    opt.ArgName = repmat({''}, 1, numel(pValue));
end

if ~iscell(pValue),
    pValue = {pValue};
end

refs     = cell(numel(pValue),2);
[~, name] = fileparts(fileName);
for i = 1:numel(pValue)
    
    
    if isa(pValue{i}, 'goo.reportable'),
        %% goo.reportable objects
        
        [thisPVal, thisRefs] = reportable2str(origRepObj, pValue{i}, ...
            'ParentArgName',  opt.ArgName{i}, ...
            'ParentPropName', opt.PropName{i});
        refs(i,:) = thisRefs;
        pValue{i} = thisPVal;        
        continue;        
        
    elseif isnumeric(pValue{i})
        %% numeric matrices
        
        [thisPVal, thisRefs] = num2str(origRepObj, pValue{i}, ...
            'ArgName', opt.ArgName{i}, ...
            'PropName', opt.PropName{i});
        refs(i,:) = thisRefs;
        pValue{i} = thisPVal;        
        continue;
        
    elseif isa(pValue{i}, 'function_handle'),
        %% function handles
        
        [thisPVal, thisRefs] = fhandle2str(origRepObj, pValue{i}, ...
            'ParentArgName',  opt.ArgName{i}, ...
            'ParentPropName', opt.PropName{i}, ...
            'ID',             num2str(i));
        refs(i,:) = thisRefs;
        pValue{i} = thisPVal;        
        continue;
        
    elseif iscell(pValue{i}),
        %% cell arrays
        
        if isempty(pValue{i}),
            pValue{i} = '';
            continue;
        end
       
        fileName = catfile(get_rootpath(origRepObj), ...
            [name '_pval-' num2str(i) '.txt']);
        fileName = unique_filename(fileName);
        
        refs{i,1}    = sprintf('pValue-%d',i);
        [~, newName] = fileparts(fileName); 
        refs{i,2}    = [newName '.txt'];
        
        fid      = safefid(fileName, 'w');
        
        fprintf(fid, '%s', cell2str(pValue{i}));
       
        text = num2str(size(pValue{i}));
        text = regexprep(text, '\s+', 'x');
        pValue{i} = sprintf('[ {%s cell} ][%s]', text, refs{i,1});
        continue;        
        
    elseif isstruct(pValue{i}),
        %% structs
        
        [thisPVal, thisRefs] = struct2str(origRepObj, pValue{i}, ...
            'ParentArgName',    opt.ArgName{i}, ...
            'ParentPropName',   opt.PropName{i}, ...
            'ID',               num2str(i));
        refs(i,:) = thisRefs;
        pValue{i} = thisPVal;        
        continue;
        
    elseif ischar(pValue{i}),
        %% strings
        
        if numel(pValue{i}) > 40,
            fileName = catfile(get_rootpath(origRepObj), ...
                ['pval-' num2str(i) '.txt']);
            
            fileName = unique_filename(fileName);
            
            fid = safefid(fileName, 'w');
            fprintf(fid, '%s', pValue{i});
            dimTypeStr = dimtype_str(pValue{i});
            [~, newName] = fileparts(fileName);
            refs(i,:) = {newName, [newName '.txt']};
            pValue{i} = sprintf('[ [%s] ][%s]', dimTypeStr, newName);
        end

        continue;     
        
    elseif islogical(pValue{i}),
        %% logical arrays
        
        if numel(pValue{i}) == 1,
            if pValue{i},
                pValue{i} = 'true';
            else
                pValue{i} = 'false';
            end
            continue;
        end
        [thisPvalue, thisRef] = pval2str(origRepObj,double(pValue{i}));
        pValue{i} = thisPvalue{1};
        if ~isempty(thisRef{1,1}),
            refs{i,1} = sprintf('pValue-%d',i);
        end
        refs(i,2) = thisRef(1,2);
        
    else
        %% anything else
        
        try
            
            warning('off', 'MATLAB:structOnObject');
            strVal = struct(pValue{i});
            strVal.Class_ = class(pValue{i});
            [tmp, thisRef] = pval2str(origRepObj, strVal);
            warning('on', 'MATLAB:structOnObject');
            text = num2str(size(pValue{i}));
            text = [regexprep(text, '\s+', 'x') ' ' ...
                class(pValue{i})];            
            if ~isempty(thisRef{1,1}),
                refs{i,1} = sprintf('pValue-%d',i);
                pValue{i} = sprintf('[ [%s] ][%s]', text, refs{i,1});
            else
                pValue{i} = tmp{1};
            end            
            refs(i,2) = thisRef(1,2);
            continue;
            
        catch ME
            
            if strcmpi(ME.identifier, 'MATLAB:UndefinedFunction') && ...
                ~isempty(strfind(ME.message, 'method ''struct''')),
                continue;
            end
            rethrow(ME);
            
        end    
        
    end
    
    text = num2str(size(pValue{i}));
    text = ['[' regexprep(text, '\s+', 'x') ' ' class(pValue{i}) ']'];
    pValue{i} = text;
    
end

% Remove empty references
isEmpty = cellfun(@(x) isempty(x), refs(:,1));
refs(isEmpty,:) = [];


end