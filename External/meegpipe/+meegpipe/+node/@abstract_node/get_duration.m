function str = get_duration(obj)

import misc.toc4humans;


str = toc4humans(toc(get_tinit(obj)));


end