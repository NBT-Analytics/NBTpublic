function rm_rf(varargin)
import mperl.extutils.command.perl;

for i=1:nargin
    perl(['-MExtUtils::Command -e rm_rf ' varargin{i}]);
end


end