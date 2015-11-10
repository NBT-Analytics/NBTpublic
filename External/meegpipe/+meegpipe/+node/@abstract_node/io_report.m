function report = io_report(obj, input, output)
% IO_REPORT - Input/output report
%
% report = io_report(obj, input, output)
%
% See also: abstract_node

import goo.globals;

report = get_report(obj);

if isempty(obj.IOReport),
    return;
end

verbose      = globals.get.Verbose;
verboseLabel = globals.get.VerboseLabel;

% Deactivate verbose mode for any function call
globals.set('Verbose', false);

if verbose
    fprintf( [verboseLabel, 'Generating input/output report...\n\n']);
end

print_title(report, 'Input/output report', 2);

ioRep = childof(obj.IOReport, report);

generate(ioRep, input, output);

print_paragraph(report, 'See [IO report][IOReport]');
    
print_ref(report, get_filename(ioRep), 'IOReport');

% Return to original verbose mode
globals.set('Verbose', verbose);




end