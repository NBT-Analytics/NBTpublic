function status = finalize()
% FINALIZE - Finalizes a battery of tests and prints summary
%
% status = test.simple.finalize()
%
% Where
%
% STATUS is the exit code that results from performing the batery of tests.
%
% See also: initialize, ok


import test.simple.globals;

status = globals.get.Failure;

nbFailed   = globals.get.Failed;
nbOK       = globals.get.OK;
nbDied     = globals.get.Died;
nbTests    = globals.get.TestCount;

nbTestsActual = nbFailed + nbOK + nbDied;

notRun     = nbTests - nbTestsActual;

if nbOK == nbTests && nbTests > 0,
    
    status = 0;
    fprintf('# Looks like all %d test(s) succeeded\n', nbOK);    

elseif nbFailed > 0 
    
    status = nbFailed;
    fprintf('# Looks like %d test(s) of %d failed\n', nbFailed, ...
        nbTestsActual);
    
end

if notRun > 0 ,

    status  = nbFailed + notRun;
    fprintf('# Looks like %d of %d test(s) did not run\n', ...
        notRun, nbTests);
    
elseif notRun < 0
    
    status  = nbFailed - notRun;
    fprintf('# Looks like you ran %d test(s) too many (%d were planned)\n', ...
        -notRun, nbTests);
  
elseif (nbTests < 1),    
    
    fprintf('# Looks like you did not plan any test\n');    
    
end


if nbDied > 0    
    fprintf('# Looks like %d test(s) of %d died\n', nbDied, nbTestsActual);    
end

verbose = globals.get.Verbose;

if ~isempty(verbose),
    
   verboseGlobal = eval([globals.get.VerboseGlobal '.get']);
   verboseGlobal.set('Verbose', verbose);
   
end



    
end

