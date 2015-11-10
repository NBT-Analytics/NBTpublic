## Highly recommended dependencies

The following dependencies need to be installed in your system for _meegpipe_
to be able to generate beautiful HTML reports:

### Python

A. Kenneth Reitz has written an excellent guide on
[how to install Python][python-install]. _meegpipe_ requires a Python 2.x
interpreter, where x is ideally at least 7.

[python]: http://python.org
[python-install]: http://docs.python-guide.org/en/latest/starting/installation/

If your OS is Linux-based (that includes Mac OS X) chances are that Python is
already installed on your system. In that case, open a terminal and ensure that
you have the required version of Python:

	python --version


On Mac OS X you may also need to install XCode via the [Mac App Store][xcode].
Alternatively, if you have a free Apple Developer Account, you can just install
[Command Line Tools for Xcode][xcode-cmdtools]. You can check whether Xcode is
already installed on your Mac OS X system by opening a terminal window and typing:

````
gcc --version
````

Which should display something else than a `Command not found` error.

[xcode]: https://developer.apple.com/xcode/
[xcode-cmdtools]: https://developer.apple.com/downloads/index.action


### easy_install and pip

See the [Python installation guide][python-install] for instructions on how to
install __easy_install__ and __pip__ on your system.

[easy_install]: https://pypi.python.org/pypi/setuptools#installation-instructions
[pip]: https://pypi.python.org/pypi/pip


### Python development tools (Linux only)

__NOTE__: If you use [Arch Linux][archlinux] then you can skip
this step.

[archlinux]: http://www.archlinux.org

If your Linux distro uses the [yum package manager][yum] run:

    sudo yum install python-devel

If your Linux distro uses [apt-get][apt-get] to manage packages then run instead:

    sudo apt-get install python-dev

[yum]: http://yum.baseurl.org/
[apt-get]: http://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_basic_package_management_operations


### Remark

The [Remark][remark] python library is required for generating HTML reports.
To install Remark in Mac OS X and Linux run from the command line:

[remark]: http://kaba.hilvi.org/remark/remark.htm

    sudo pip install remark

In Windows, open a terminal and run:

    easy_install pillow
    pip install remark


### Inkscape

[Inkscape][inkscape] is required for generating the thumbnail images that
are embedded in the data processing reports. To install on Red Hat
based Linux distros:

    sudo yum install inkscape

For Debian-based distros:

    sudo apt-get install inkscape

For [Arch Linux][archlinux]:

    sudo pacman -S inkscape

For Windows and Mac OS X you can use the installation packages available at
[Inkscape's web page][inkscape].

[inkscape]: http://en.dev.inkscape.org/download/
[pygments]: http://pygments.org/
[markdown]: http://freewisdom.org/projects/python-markdown/
[pil]: http://www.pythonware.com/products/pil/

__IMPORTANT NOTE:__ If you use [Arch Linux][archlinux], you will also need
to ensure that MATLAB uses the up-to-date version of the GNU C++ library
that ships with your Arch Linux system. Open a terminal and type:

````
cd /usr/local/MATLAB/R(your release)/sys/os/glnxa64
sudo unlink libstdc++.so.6
sudo ln -s /usr/lib/libstdc++.so.6
````

### Google Chrome

_meegpipe_ generates HTML reports with lots of [.svg][svg] graphics
embedded. [Google Chrome][gc] is far superior to other browsers when handling
`.svg` files and thus it is strongly recommended that you install Google
Chrome.

[svg]: http://en.wikipedia.org/wiki/Scalable_Vector_Graphics
[gc]: https://www.google.com/intl/en/chrome/browser/




