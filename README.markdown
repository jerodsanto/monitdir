About 
=====
Monitors a directory at given interval for file additions/subtractions. 
When a file is added or removed it will either print said file or perform
an action as specified in command line arguments. Best run as daemon

Usage 
=====
    monitDir.rb -d [directory to monitor] [options]

  use `monitDir.rb -h` for more info

Options
=======
    -d, --directory   Directory to monitor (required)
    -r, --recursive   Monitor subdirectories too (default = off)
    -i, --interval    Time between polls, in seconds (default = 5)
    -e, --execute     Command to execute when directory changes
    -p, --pass-file   Used in conjunction with -e, filenames are passed as argument to action
    -h, --help        Displays help message
    -v, --version     Display the version, then exit

Author
======
[Jerod Santo][1], email = "moc.liamg@otnas.dorej".reverse

Copyright
=========
Copyright (c) 2008 Jerod Santo. Licensed under the [MIT License][2]


[1]:http://blog.jerodsanto.net
[2]:http://www.opensource.org/licenses/mit-license.php
