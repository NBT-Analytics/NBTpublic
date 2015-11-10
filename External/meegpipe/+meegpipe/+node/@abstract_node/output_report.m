function report = output_report(obj, data)

import report.object.object;
import misc.toc4humans;

report = get_report(obj);

print_title(report, 'Node output', 2);

print_paragraph(report, ...
    sprintf('Output was produced on %s (processing took %s).', ...
    datestr(now, 'dd-mm-yy HH:MM:SS'), ...
    get_duration(obj)));

% Add a link to the binary output in the report

% Node output may be a physioset or a list (cell) of physiosets
if ~iscell(data),
    cData = {data};
else
    cData = data;
end

for i = 1:numel(cData),
    set_method_config(cData{i}, 'fprintf', 'ParseDisp', true);
    set_method_config(cData{i}, 'fprintf', 'SaveBinary', get_save(obj));
end

subReport = object(cData{:}, 'Title', 'Node output');
childof(subReport, report);
generate(subReport);

print_paragraph(report, 'See [output report][%s]', get_name(cData{1}));

print_ref(report, get_filename(subReport), get_name(cData{1}));


end