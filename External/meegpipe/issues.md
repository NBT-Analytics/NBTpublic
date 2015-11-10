Known problems/limitations
===

## Long path names under Windows

_meegpipe_ has a tendency to generate reports with very deep file structures.
Under Windows this might cause a problem due to the 
[maximum path length limitation][maxpath]. At this moment there is no 
failproof workaround. However, you should be able to avoid the problem
by simply using short pipeline names, and by avoiding deep nesting of 
pipelines within pipelines.


## Inkscape crashes

Under some very rare circumstances, [inkscape][inkscape] crashes when being
called from the command line in Windows 8. Such crashes typically manifest 
as a pop-up window with an error message. This problem can be solved by
using the [development version of Inkscape][inkscape-dev] (release r23126
 and above).

[maxpath]: http://msdn.microsoft.com/en-us/library/aa365247%28VS.85%29.aspx#maxpath
[inkscape-dev]: https://skydrive.live.com/?cid=09706d11303fa52a&id=9706D11303FA52A%21217#cid=09706D11303FA52A&id=9706D11303FA52A%21275
[inkscape]: http://www.inkscape.org/en/

## Local `.svg` files do not render under Windows 8

Under __Windows 8__ neither Firefox nor Google Chrome are able to render 
local .svg files.  There are two possible solutions to this problem:

* Use MS Explorer under Windows 8. This is far from ideal as MS Explorer 
  is quite slow at rendering .svg files. In particular, you will experience 
  very poor performance when trying to zoom-in an image. 

* Run a local HTTP server that will serve the report page. In practice 
  this just means double clicking on the `pyserver.bat` file that you 
  will find on the root directory of each generated report. The `.bat` 
  file will use Python to start a local server at port 8000. It will also 
  try opening Chrome and point it to the server root
  URL: http://127.0.0.1:8000/ . Of course for this solution to work both 
  Python and Chrome need to be installed on your Windows 8 system. Also,
  the installation directory of Chrome must be the default under Windows 8:
  `C:\Program Files (x86)\Google\Chrome\Application\chrome.exe`.


The downside of the second solution above is that you will not be able to
display multiple reports simultaneously in Chrome. This problem can be 
overcome by editing `pyserver.bat` so that different reports are served on
different HTTP ports. 

