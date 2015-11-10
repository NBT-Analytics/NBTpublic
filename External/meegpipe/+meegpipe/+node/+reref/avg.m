function obj = avg()
% avg - Average reference
%
% See also: reref

rerefMatrix = @(x) eye(size(x,1)) - ...
    (1/size(x,1))*ones(size(x,1),1)*ones(1, size(x,1));

obj = meegpipe.node.reref.new('RerefMatrix', rerefMatrix, ...
    'Name', 'reref-avg');

end