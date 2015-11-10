function obj = egi(ns)
import io.edfplus.header;

recId = edfplus.recid('Equipment', ['egi' num2str(ns)]);

patId = edfplus.patid;

signalSet = edfplus.signalset.egi(ns);

obj = header(...
    'recid', recId, ...
    'patid', patId, ...
    'signalset', signalSet ...
    );
        


end