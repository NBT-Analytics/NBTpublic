function rep = make_bss_report(obj, myBSS, ics, data, icSel)

import goo.globals;
import meegpipe.node.bss.bss;

verb      = globals.get.Verbose;
verbLabel = globals.get.VerboseLabel;

globals.set('Verbose', false);

if verb,
    fprintf([verbLabel 'Generating BSS report ...\n\n']);
end
parentRep = get_report(obj);
rep = report.generic.new('Title', 'Blind Source Separation report');
rep = childof(rep, parentRep);

make_bss_object_report(obj, myBSS, ics, rep, verb, verbLabel);

make_spcs_snapshots_report(obj, ics, rep, verb, verbLabel);

[maxVar, maxAbsVar] = bss.make_explained_var_report(rep, myBSS, ics, data, verb, verbLabel);

make_spcs_topography_report(obj, myBSS, ics, data, rep, maxVar, maxAbsVar, verb, verbLabel);

make_spcs_psd_report(obj, ics, rep, verb, verbLabel);

if ~isempty(icSel)
    make_backprojection_report(obj, myBSS, ics, rep, verb, verbLabel);
end

print_title(parentRep, 'Blind Source Separation', get_level(parentRep)+2);
print_link2report(parentRep, rep);
globals.set('Verbose', verb);

end