function tags = parse_filename(fileName)
% PARSE_TAGS - Parse meta-tags from file name
%
% tags = parse_filename(fileName)
%
% Where
%
% TAGS is struct having as fields the tag names.
%
% See also: somsds

% You should make this function generic using a configuration file!

import mperl.split;

[~, fName, ext] = fileparts(fileName);

regex = ['(?<Recording>[-\w]+)_(?<Subject>\d+)_(?<Modality>[^_\.]+)_' ...
    '(?<Condition>[^_\.]+)_?(?<Extra>[^_\.]*).*$'];

tags = regexp([fName ext], regex, 'names');

if isempty(tags),
    tags = struct;
    return;
end

% Parse sub-conditions
if isfield(tags, 'Condition') && ~isempty(tags.Condition),
    conditions = split('-', tags.Condition);
    tags = rmfield(tags, 'Condition');
    for i = 1:numel(conditions)
        cName = ['Condition' num2str(i)];
        tags.(cName) = conditions{i};
    end
end

end