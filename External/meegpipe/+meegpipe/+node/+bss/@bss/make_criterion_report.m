function count = make_criterion_report(obj, myCrit, labels, icSel, isAutoSel)

import mperl.join;

rep = get_report(obj);

count = 0;
count = count + ...
    print_title(rep, 'Component selection criterion', get_level(rep) + 2);

count = count + fprintf(rep, myCrit, labels);
count = count + fprintf(rep, '\n\n');

if ~any(icSel),
    msg = 'No components';
else
    msg = ['Component(s) __[' join(',', icSel) ']__'];
end

if ~isAutoSel
    warnMsg = 'This is a user-defined selection.';
else
    warnMsg = [];
end

rej = get_config(obj, 'Reject');

if isempty(rej),
    count = count + print_paragraph(rep, [msg ...
        ' were produced as output in this node.' warnMsg]);
elseif rej,
    count = count + print_paragraph(rep, [msg ...
        ' were __REJECTED__. ' warnMsg]);
else
    count = count + print_paragraph(rep, [msg ...
        ' were __ACCEPTED__. ' warnMsg]);
end

end