function msg = hostname

import mperl.perl_eval;

[status, msg] = perl_eval('-MSys::Hostname -e ''print hostname;''');

if status,
    error('Something went wrong when calling perl-hostname:\n %s', msg);
end

end