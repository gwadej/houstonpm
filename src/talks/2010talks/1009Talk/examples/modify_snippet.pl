#!/usr/bin/env perl -i.bak
# The '-i.bak' in the above line enables 'in-place edits' with a backup file.

use strict;
use warnings;

# The following line reads all lines from all files named on the command line
# one line at a time. The loop processes the line. Any printed output goes to
# the new version of the file.
while(<>)
{
    # Recognize the line to change
    # Change the line
    # Print it (unless deleting the line)
}

