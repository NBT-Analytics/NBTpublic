% DEMO - Demonstrates functionality of package report.gallery
%
% 
% See also: gallery

% Documentation: pkg_report_gallery.txt
% Description: Demonstrates package functionality

import meegpipe.root_path;
import mperl.file.spec.catfile;
import safefid.safefid;

if ~exist('INTERACTIVE', 'var') || isempty(INTERACTIVE),
    INTERACTIVE = true;    
end

if ~exist('FILE', 'var') || isempty(FILE),
    FILE = catfile(root_path, '+report/+gallery', 'test.txt');
end

if INTERACTIVE, echo on; close all; clc; end

% Create a gallery object with custom thumbnails width
import report.gallery.*;
myConfig = config('ThumbWidth', 400);
myGallery1 = gallery(myConfig);

% Alternatively, you could have done directly this:
myGallery2 = gallery('ThumbWidth', 400);
echo off; if INTERACTIVE, pause; clc; end

% For testing purposes
if ~INTERACTIVE, fprintf('.'); end
if INTERACTIVE, echo on; end

% Modify Gallery options after construction
myGallery1 = set(myGallery1, 'Title', 'Gallery');
myGallery2 = set(myGallery2, 'Title', 'Inverted Gallery');
echo off; if INTERACTIVE, pause; clc; end

% For testing purposes
if ~INTERACTIVE, fprintf('.'); end
if INTERACTIVE, echo on; end

% Add some figures to the Galleries
path = '+report/+gallery/';

for i = 1:2,
    
    thisFig1 = ['fig', num2str(i) '.png'];
    myGallery1 = add_figure(myGallery1, thisFig1, thisFig1);
    
    thisFig2 = ['fig', num2str(3-i) '.png'];
    myGallery2 = add_figure(myGallery2, thisFig2, thisFig2);    
    
end
echo off; if INTERACTIVE, pause; clc; end

% For testing purposes
if ~INTERACTIVE, fprintf('.'); end
if INTERACTIVE, echo on; end

% Print to FILE
fid = safefid.fopentmp(FILE, 'w');
fprintf(fid, myGallery1, myGallery2);
echo off; if INTERACTIVE, pause; clc; end

% For testing purposes
if ~INTERACTIVE, fprintf('.'); end

% For testing purposes
if ~INTERACTIVE, fprintf('.'); end

clear fid; % will delete the file as well