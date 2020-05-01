# AV Scanner for CI

Anti-virus and malware scanning for CI or other automated contexts.

Run the anti-virus and malware detectors [ClamAV](https://www.clamav.net/) (clamscan)
and [linux-malware-detect](https://github.com/rfxn/linux-malware-detect)
(maldet) against a single directory of files, print the generated reports, and exit
with 0 if no malware detected, otherwise exit non-zero.

## Basic Usage

Assuming you have Docker installed, simply clone this repository, and then run:

```shell
export SCAN_DIR=/path/to/directory
make scan
```

This will build the docker image, mount `SCAN_DIR` and run the scanners.

**You can trust the exit code** so you could also write something like this in bash
without fear:

```shell
export SCAN_DIR=/path/to/directory
if ! make scan; then
	echo "Malware detected."
else
	echo "No malware detected."
```

## TODO

- Set up CI to publish a new docker image, with the updated signatures
  each day, so users can just `docker pull samsalisbury/av-scanner:latest`
  and always have the latest signatures ready.
