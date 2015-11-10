function [status, result] = ppm(varargin)

import mperl.join;

if ispc
  % PC
  perlCmd = fullfile(matlabroot, 'sys\perl\win32\bin\');
  cmdString = ['ppm ' join(' ', varargin)];	 
  perlCmd = ['set PATH=',perlCmd, ';%PATH%&' cmdString];
  [status, result] = dos(perlCmd);
else
  % UNIX
  [status ignore] = unix('which perl'); %#ok
  if (status == 0)
    cmdString = ['ppm ' join(' ', varargin)];	
    [status, result] = unix(cmdString);
  else
    error('MATLAB:perl:NoExecutable', errTxtNoPerl);
  end
end


end