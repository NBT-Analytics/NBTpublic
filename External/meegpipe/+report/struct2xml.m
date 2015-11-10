function [ref, refTarget] = struct2xml(rootDir, pValue)

import mperl.file.spec.catfile;
import xml.struct2xml;
import misc.unique_filename;
import safefid.safefid;
import misc.fid2fname;
import datahash.DataHash;

% Just in case some of the struct fields contain objects
warning('off', 'JSimon:BadDataType');
ref        = DataHash(pValue);
warning('on', 'JSimon:BadDataType');
refTarget  = catfile(rootDir, [ref '.xml']);

% Write struct contents to .xml file
fid = safefid(refTarget, 'w');
fprintf(fid, '%s', struct2xml(pValue));
tidyObj = mperl.xml.tidy.tidy(refTarget);
make_tidy(tidyObj);


end