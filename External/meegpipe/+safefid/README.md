MATLAB class safefid
==============

An exception safe implementation of a file handle for MATLAB. See this 
[stackoverflow post](http://stackoverflow.com/questions/8847866/how-can-i-close-files-that-are-left-open-after-an-error/12569456#12569456)
for more information on the problem that this class aims to solve.

## Installation

First clone the repo to a directory (e.g. `safefid`) on your local machine:

````git
git clone https://github.com/germangh/matlab_safefid safefid
````

Then start matlab, add `safefid` to your MATLAB's search path:

````matlab
addpath safefid
````

## Usage synopsis

You can create an exception FID for writing to `file.txt` using:

````matlab
function write_hello_world(filePath)
    import safefid.safefid;

    % Open file myfile.txt for writing
    mySafeFID = safefid.fopen('myfile.txt', 'w');
 
    % Write something to 'myfile.txt'
    fprintf(mySafeFID, 'Hello World!');
    
    % No need of explicitly closing myfile.txt
end
````

A great advantage of using `safefid` instead of a built-in MATLAB file 
identifier is that you don't need to worry about `fprintf()` (or any other
code within `write_hello_world()` throwing an exception and leaving file 
`myfile.txt` open. Class `safefid`'s destructor will take care of 
automatically closing the file when `mySafeFID` goes out of scope. 

Otherwise, `safefid` objects behave very much like MATLAB's built-in file
identifiers, e.g.:

````matlab
import safefid.safefid;
mySafeFID = safefid.fopen('myFile.txt', 'w+');
fprintf(mySafeFID, 'Hello World!');

% Move back to the beginning of the file
fseek(mySafeFID, 0, 'bof');
  
% Write a line of text, rewind the file position indicator, and read line
fprintf(mySafeFID, 'A line of text\n');
frewind(mySafeFID);
line = fgetl(mySafeFID);
assert(strcmp(line, 'A line of text'));

% This will implicitly close myfile.txt
clear mySafeFID;
````  

## External dependencies

Class `safefid` should not have any external dependencies but I might have 
misssed something. In that case, please file a bug report because this repo
is intented to be fully self-contained. 


