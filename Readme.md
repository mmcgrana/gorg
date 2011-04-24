# Gorg

Persistence for [Doozer](https://github.com/ha/doozerd).


## Overview

Gorg provides persistence for Doozer, the in-memory distributed data store. Gorg can write snapshots of a Doozer cluster to a file, stream Doozer cluster state to an append-only file, and restore a Doozer cluster from such files.

Gorg may be useful for Doozer cluster backup and restore, for cluster transfer, and for facilitating full cluster restarts.


## Usage

Capture a snapshot of a Doozer process, kill the process, restore from the snapshot into a new process, and query the new process to verify a successful restore:

    $ doozerd
    $ echo "save me" | doozer add /data
    $ gorg dump -f doozer.dat
    $ killall doozerd
    $ doozerd
    $ gorg load -f doozer.dat
    $ doozer get /data

Stream state from a Doozer process into an append-only file (not yet implemented):

    $ doozerd
    $ echo "first" | doozer add /one
    $ gorg sink -f doozer.dat
    $ tail -f doozer.dat
    $ echo "second" | doozer add /two
    $ echo "third" | doozer add /three

Omit the `-f` argument to use standard in and out:

    $ gorg load < doozer.dat
    $ gorg dump > doozer.dat


## Installation

    $ git clone git://github.com/mmcgrana/gorg.git
    $ cd gorg
    $ bundle install


## Notes

* Saves but does not not load data under the `/ctl` prefix, which is used internally by Doozer.
* Does not preserve `rev`s across saves and restores.
