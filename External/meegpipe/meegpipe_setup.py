#!/user/bin/env python
"""meegpipe automated installation script
"""

def main(version=DEFAULT_VERSION):
    """Install or upgrade setuptools and EasyInstall"""
    options = _parse_args()
    tarball = download_setuptools(download_base=options.download_base,
        downloader_factory=options.downloader_factory)
    return _install(tarball, _build_install_args(options))

if __name__ == '__main__':
    sys.exit(main())
