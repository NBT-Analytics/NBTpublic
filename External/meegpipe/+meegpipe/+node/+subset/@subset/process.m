function [dataOut, dataNew] = process(obj, dataIn, varargin)
% PROCESS - Select data subset
%
% See also: subset


import mperl.file.spec.catfile;
import goo.globals;

dataNew = [];

autoDestroyMemMap = get_config(obj, 'AutoDestroyMemMap');

verbose          = is_verbose(obj);
verboseLabel     = get_verbose_label(obj);
origVerboseLabel = globals.get.VerboseLabel;
globals.set('VerboseLabel', verboseLabel);

fileName = catfile(get_full_dir(obj), get_name(dataIn)); 

if verbose,
   fprintf([verboseLabel 'Extracting subset from %s ...\n\n'], ...
       get_name(dataIn)); 
end

dataOut  = subset(dataIn,  ...
    'FileName',             fileName, ...
    'Temporary',            true, ...
    'AutoDestroyMemMap',    autoDestroyMemMap);


%% Undo stuff
globals.set('VerboseLabel', origVerboseLabel);


end