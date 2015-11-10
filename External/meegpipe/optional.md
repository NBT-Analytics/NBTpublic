Optional dependencies
===

The dependencies listed here are not required for _meegpipe_ to work, but
they can enhance _meegpipe_'s functionality.

### Fieldtrip

If you [Fieldtrip](http://fieldtrip.fcdonders.nl/) is installed on your 
system, meegpipe will be able to import data from any data format that 
Fieldtrip can read.

### NBT toolbox

If the [Neurophysiological Biomarkers Toolbox][nbt], has been installed 
on your system then _meegpipe_ will be able to import and export data 
from/to NBT data structures.

[nbt]: http://nbtwiki.net/


### Open grid engine

If [Open Grid Engine][oge] (OGE) is installed on your system,
then _meegpipe_ should be able to use it to push your processing jobs to the
grid.  A good overview on the administration of OGE can be found on
[this presentation][oge-slides] by Daniel Templeton.


[oge]: http://gridscheduler.sourceforge.net/
[oge-install]: http://docs.oracle.com/cd/E19680-01/html/821-1541/ciajejfa.html
[oge-slides]: http://beowulf.rutgers.edu/info-user/pdf/ge_presentation.pdf


### Condor high-throughput computing

If [Condor][condor] is installed on your system then _meegpipe_ will use it to
process multiple data files in parallel. Condor can
be used to submit jobs to specialized clusters, to idle computers, to
the grid, or even to the cloud.

[condor]: http://research.cs.wisc.edu/htcondor/

