function obj = generate(obj)
% GENERIC - Generate report content
%
% obj = generate(obj)
%
% ## Side effects:
%
% The remark report associated with OBJ will be initialized if necessary
% (i.e. will be attached to a valid open file handle), and the title and
% parent properties of the report will be printed to the associated file.
%
% See also: initialize, finalize, generic


if ~initialized(obj), initialize(obj); end



end