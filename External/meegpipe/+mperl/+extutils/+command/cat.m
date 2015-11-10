function out = cat(varargin)
import mperl.extutils.command.perl;
import mperl.join;

out = perl(['-MExtUtils::Command -e cat ' join(' ', varargin)]);



end