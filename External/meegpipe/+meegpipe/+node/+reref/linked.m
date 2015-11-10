function obj = linked(varargin)
% linked - Linked reference
%
% Re-references data to the average signal across a set of channels
%
% See also: reref

rerefMatrix = @(data) eye(size(data,1)) - ...
    1/numel(varargin)*ones(size(data,1), 1)*...
    reshape(ismember(lower(labels(sensors(data))), lower(varargin)), ...
    1, numel(labels(sensors(data))));

obj = meegpipe.node.reref.new('RerefMatrix', rerefMatrix, ...
    'Name', 'reref-linked');

end