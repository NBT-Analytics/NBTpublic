function [status, result] = cpan(varargin)

import mperl.join;

if ispc
  % PC
  
  warning('mperl:cpan:DidYouMeanPPM', ...
     ['On this platform MATLAB uses its own built-in Perl. ' ...
     'Did you mean to use mperl.ppm instead?']);
  
  perlCmd = fullfile(matlabroot, 'sys\perl\win32\bin\');
  cmdString = ['cpan ' join(' ', varargin)];	 
  perlCmd = ['set PATH=',perlCmd, ';%PATH%&' cmdString];
  [status, result] = dos(perlCmd);
else
  % UNIX
  [status ignore] = unix('which perl'); %#ok
  if (status == 0)
    cmdString = ['cpan ' join(' ', varargin)];	
    [status, result] = unix(cmdString);
  else
    error('MATLAB:perl:NoExecutable', errTxtNoPerl);
  end
end


end