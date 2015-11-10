function [status, MEh] = test1()

import mperl.file.spec.*;
import report.gallery.*;
import test.simple.*;
import pset.session;
import safefid.safefid;

MEh     = [];

warning('off', 'session:NewSession');
PATH = session.instance.Folder;
warning('on', 'session:NewSession');

FILE = catfile(PATH, 'test.txt');

initialize(3);

%% construct custom gallery
try
    
    name = 'construct custom gallery';
    myConfig = config('ThumbWidth', 400);
    myGallery1 = gallery(myConfig);
    myGallery2 = gallery('ThumbWidth', 400);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% set gallery props after construction
try
    
    name = 'set gallery props';
    myGallery1 = set(myGallery1, 'Title', 'Gallery');
    myGallery2 = set(myGallery2, 'Title', 'Inverted Gallery');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% print gallery to file
try
    
    name = 'print gallery to file';
    fid = safefid.fopentmp(FILE, 'w');
    fprintf(fid, myGallery1, myGallery2);
    clear fid; 
    ok(true, name);
    
catch ME
    
    clear fid; 
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Testing summary
status = finalize();