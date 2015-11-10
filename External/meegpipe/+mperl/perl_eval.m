function [status, result] = perl_eval(cmd)

import mperl.join;

if ispc
  % PC
  perlCmd = fullfile(matlabroot, 'sys\perl\win32\bin\');
  cmdString = ['perl ' cmd];	 
  perlCmd = ['set PATH=',perlCmd, ';%PATH%&' cmdString];
  [status, result] = dos(perlCmd);
else
  % UNIX
  [status, result] = unix('which perl'); 
  if (status == 0)
    cmdString = ['perl ' cmd];	
    [status, result] = unix(cmdString);
  else
    error('MATLAB:perl:NoExecutable', errTxtNoPerl);
  end
end


end