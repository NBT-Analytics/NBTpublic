meegpipe API documentation
========

The components of the _meegpipe_ [API][api] are organized in various
[MATLAB packages][matlab-pkg]. The table below summarizes
the major components of the API.

[api]: http://en.wikipedia.org/wiki/Application_programming_interface
[matlab-pkg]: http://www.mathworks.nl/help/matlab/matlab_oop/scoping-classes-with-packages.html

MATLAB package    | What is there?
--------------    | --------------------
[+meegpipe/+node][meegpipe.node]         | Generic definitions of nodes and pipelines
[+aar][aar]                              | Node definitions for automatic artifact removal
[+physioset][physioset]                  | Data structure for physiological datasets
[+sensors][sensors]                      | Data structure for physiological sensors
[+filter][filter]                        | Digital filters
[+spt][spt]                              | Spatial transforms ([PCA][pca] and [BSS][bss])
[+spt/+criterion][spt.criterion]         | Component selection criteria
[+spt/+feature][spt.feature]             | Feature extractors for spatial transforms
[+pset][pset]                            | Low level data structure for high-dimensional point-sets

[meegpipe.node]: ./+node/README.md
[physioset]: ../+physioset/README.md
[sensors]: ../+sensors/README.md
[filter]: ../+filter/README.md
[spt]: ../+spt/README.md
[spt.criterion]: ../+spt/+criterion/README.md
[spt.feature]: ../+spt/+feature/README.md
[pset]: ../+pset/README.md

The _meegpipe_'s API follows the [object oriented (OO)][oo-programming]
programming paradigm. If you are not familiar with OO concepts like
_class_, _object_ or _interface_, you may want to read some
[background material][oo-concepts] before going any further. If you have
never used the OO paradigm in MATLAB, you may also want to read some
documentation on the specifics of [MATLAB's OO programming][matlab-oo].

[oo-concepts]: http://docs.oracle.com/javase/tutorial/java/concepts/

The most important component of the API from the user perspective is the
[meegpipe.node][meegpipe.node] package. It contains the definitions of
processing nodes for performing common tasks such as bad channel and bad epoch
rejection, filtering, ICA component rejection and others. The node definitions
in [meegpipe.node][meegpipe.node] are generic in the sense that their default
configurations may not be

[oo-programming]: http://en.wikipedia.org/wiki/Object-oriented_programming
[matlab-oo]: http://www.mathworks.nl/help/matlab/object-oriented-programming.html

