function rm_f(varargin)
import mperl.extutils.command.perl;

for i=1:nargin
    perl(['-MExtUtils::Command -e rm_f ' varargin{i}]);
end


end