function [status, MEh] = test1()
% TEST1 - Tests basic reporting functionality

import mperl.file.spec.*;
import report.generic.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

initialize(8);

%% Create a new session
try
    
    name = 'create new session';
    warning('off', 'session:NewSession');
    session.instance;
    warning('on', 'session:NewSession');
    hashStr = DataHash(randn(1,100));
    session.subsession(hashStr(1:5));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% default constructor
try
    
    name = 'constructor';
    myReport = generic; 
    ok(~initialized(myReport), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% print_title()
try
    
    name = 'print_title()';
    print_title(myReport, 'A random report');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% childof()
try
    
    name = 'childof()';
    myParentReport = generic;
    print_title(myParentReport, 'Parent report');
    childof(myReport, myParentReport);
    ok(true , name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% fprintf()
try
    
    name = 'fprintf()';   
    count = fprintf(myParentReport, 'This is the parent report\n\n');
    count = count + fprintf(myReport, 'And this is the child report\n\n');
    ok(count == 57 , name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% print_paragraph()
try
    
    name = 'print_paragraph()';   
    
    text = ['Lorem ipsum dolor sit amet, consectetur adipisicing elit, ' ...
        'sed do eiusmod tempor incididunt ut labore et dolore magna ' ...
        'aliqua. Ut enim ad minim veniam, quis nostrud exercitation ' ...
        'ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis '...
        'aute irure dolor in reprehenderit in voluptate velit esse ' ...
        'cillum dolore eu fugiat nulla pariatur. Excepteur sint ' ...
        'occaecat cupidatat non proident, sunt in culpa qui officia ' ...
        'deserunt mollit anim id est laborum.'];
    
    count = print_paragraph(myReport, text);
    ok(count == 448 , name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% print_paragraph()
try
    
    name = 'print_code()';
    
    code = {...
        'for i = 1:100' ...
        '    count = count + i;' ...
        '    for j = 1:100' ...
        ['        count = count + j + count + 2*count-4*j+i*count-count' ...
        '+ 2*count-4*j+i*count-count;'] ...
        ['        myLongPathName = ''C:\some\very\very\very\very\very\' ...
        'verylong\path\to\some\random\place\in\the\disk'';'] ...
        '    end' ...
        'end' ...
        };
        
    count = print_code(myReport, code{:});
    ok(count == 332 , name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear myReport myParentReport;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();