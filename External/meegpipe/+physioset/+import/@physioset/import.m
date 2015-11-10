function physObj = import(obj, varargin)
% import - Imports .pset files
%
% physObj = import(obj, file1, file2, ...)
%
% Where
%
% OBJ is an physioset.import.physioset object.
%
% FILE1, FILE2, ... are the full paths to the .pseth files associated to
% the physiosets that are to be imported.
%
% PHYSOBJ is a physioset object, or a cell array of physioset objects if
% multiple file names are provided.
%
%
% See also: physioset.import


% Deal with the multi-filename case using recursion
if numel(varargin) > 1,
    physObj = cell(numel(varargin), 1);
    for i = 1:numel(varargin)
        physObj{i} = import(obj, varargin{i});
    end   
    return;
end

fileName = varargin{1};
fileName = resolve_link(obj, fileName);

% Read the dataset
physObj = pset.load(fileName);

if ~isa(physObj, 'physioset.physioset'),
    error('physioset:InvalidType', ...
        'File %s does not store a physioset object', fileName);
end

psetObj = physObj.PointSet;

psetObj.AutoDestroyMemMap = obj.AutoDestroyMemMap;

if ~isempty(obj.Sensors)
   set_sensors(physObj, obj.Sensors); 
end

end