filter
=============

Digital filter classes for MATLAB. 

## Pre-requisites

If you have not installed [matlab_submodules][msub]
then do so by cloning the repository to a local directory:

    git clone https://github.com/germangh/matlab_submodules.git

Then start MATLAB and add directory `matlab_submodules` to your path. It is
a good idea to save that directory in your default MATLAB path. It 
contains only three functions so the pollution of your global namespace is
minimal, and almost all my MATLAB repositories use [matlab_submodules][msub]
to handle dependencies.

[msub]: http://github.com/germangh/matlab_submodules

## Installation

Clone the repository to a local directory:

````bash
cd ~
mkdir workdir
git clone git://github.com/germangh/matlab_filter.git
````

Then start MATLAB and run:

````matlab
cd ~/workdir/matlab_filter
submodule_update([], true)
````

The latter command above will result in several dependencies being cloned 
under your `workdir` directory. The second input argument to 
`submodule_update` indicates that the dependencies' directories should be
automatically added to MATLAB's search path.


### Test the installation

It is recommended that you test your installation to ensure that all 
dependencies have been properly installed, and that the code in this repo 
is fully supported by your MATLAB version. Just run in MATLAB:

    filter.make_test



If any test fails and you are a collaborator, please create an issue. 
Otherwise you may consider becoming a collaborator by [emailing me][].


## Basic usage






## License

Released under the [MIT license](http://opensource.org/licenses/MIT).



