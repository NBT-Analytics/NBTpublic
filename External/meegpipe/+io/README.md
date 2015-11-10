io
=========

I/O capabilities for various data formats. This MATLAB package is intented
to be used a component of a larger project. It is unlikely that you would
like to use the functions included in this repository directly. 

## Installation

First clone the repository to a local directory:

````bash
# I will assume you start at your home directory
cd
mkdir myworkdir;
cd myworkdir;
git clone git://github.com/germangh/matlab_io
````

__Note:__ If you wonder whether creating `myworkdir` is necessary, the 
answer is no, but it is a good idea, as will become clear later.

### Dependencies

The `+io` package has third party dependencies, which you should load
using [matlab_submodules](http://github.com/germangh/matlab_submodules)

First ensure that [matlab_submodules](http://github.com/germangh/matlab_submodules)
has been added to your MATLAB search path. First clone [matlab_submodules](https://github.com/germangh/matlab_submodules)
if you have not done so already:

````bash    
# Choose any location you like, e.g. your home directory
cd
git clone git://github.com/germangh/matlab_submodules
```` 

Then start MATLAB and run:

````matlab
addpath(fullfile(pwd, matlab_sumodules));
````

You are now ready to create local copies of all dependencies:

````matlab
cd
cd myworkdir/matlab_io
submodule_update([], 'johndoe', true);
````

where `johndoe` is the username that you want to use when connecting to 
[GitHub](http://github.com). If left empty then `submodule_update` will 
connect anonimously using the `git://` protocol. For more information see
the documentation of [matlab_submodules](https://github.com/germangh/matlab_submodules).
The last argument to `submodule_update` indicates that both `matlab_io` and
all its dependencies should be added to MATLAB's search path. If you prefer
to set the path manually, then set that flag to `false`.

It may be now clear to you why we created the `myworkdir` directory when 
we cloned [matlab_io](http://github.com/germangh/matlab_io). Function 
`submodule_update` cloned each dependency into a separate directory 
under `myworkdir` (e.g. dependency `mperl` is under `myworkdir/mperl`). 
Without a pristine work directory like `myworkdir` you risk messing 
around with already existing directories that just happen to have the same
name as some of the package dependencies. 


## Usage

As I already said, [matlab_io](http://github.com/germangh/matlab_io) is not
intended to be used directly. This is the best excuse that I have at this 
moment for the complete lack of documentation. However, a few 
functions do have some (maybe outdated) documentation:

````matlab
help io.conversion.edf2mit
```` 
    

## License

Released under the [MIT license](http://opensource.org/licenses/MIT).





