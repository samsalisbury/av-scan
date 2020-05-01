#!/usr/bin/env bash

set -euo pipefail

# MALDET_VERSION and MALDET_SHA256SUM should always be updated together!
MALDET_VERSION=1.6.4
MALDET_SHA256SUM=3ad66eebd443d32dd6c811dcf2d264b78678c75ed1d40c15434180d4453e60d2

# MALDET_URL is the url to download the maldet source tarball from.
MALDET_URL=https://github.com/rfxn/linux-malware-detect/archive/$MALDET_VERSION.tar.gz
# MALDET_LOCAL_DIRNAME is the dir to extract the maldet tarball to.
MALDET_LOCAL_DIRNAME=maldet-$MALDET_VERSION
# MALDET_LOCAL_FILENAME is the name of the tarball file we download to.
MALDET_LOCAL_FILENAME=$MALDET_LOCAL_DIRNAME.tar.gz

apt-get update
# wget is required by maldet, not just this script.
apt-get install -y clamav ca-certificates wget
freshclam
#clamscan /var/log/dpkg.log # test

# Install maldet.
wget -O $MALDET_LOCAL_FILENAME $MALDET_URL

# Ensure checksum is as expected.
sha256sum -c - "$MALDET_SHA256SUM  $MALDET_LOCAL_FILENAME"

# Create local dir for extraction to.
mkdir -p $MALDET_LOCAL_DIRNAME

# We assume the tarball contains an inner directory containing the source,
# hence --strip-components=1 to remove that outer dir.
tar -xzvf $MALDET_LOCAL_FILENAME --strip-components=1 -C $MALDET_LOCAL_DIRNAME

cd $MALDET_LOCAL_DIR
./install.sh

# Do not ignore files owned by root.
echo 'scan_ignore_root="0"' >> /usr/local/maldetect/conf.maldet

# Update sigs.
maldet -u

# Setup test data.
GOOD_DIR=/av-test/good
BAD_DIR=/av-test/bad
mkdir -p $GOOD_DIR $BAD_DIR
echo "This file is free of malware, I hope!" > $GOOD_DIR/goodfile.txt
# EICAR_TEST_FILE was downloaded from https://secure.eicar.org/eicar.com.txt 2020-05-01.
EICAR_TEST_FILE='X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
echo "$EICAR_TEST_FILE" > $BAD_DIR/badfile.txt

# Check exit codes behaving as expected.
clamscan $GOOD_DIR > clamav.log 2>&1 || {
	echo "ClamAV exited non-zero scanning known malware-free file, log:"
	cat clamav.log
	exit 1
}
clamscan $BAD_DIR > clamav.log 2>&1 && {
	echo "ClamAV exited zero scanning the malware test file, log:"
	cat clamav.log
	exit 1
}

echo "OK: ClamAV is functioning correctly."

maldet -a $GOOD_DIR > maldet.log 2>&1 || {
	echo "maldet exited non-zero scanning known-malware-free file, log:"
	cat maldet.log
	exit 1
}

maldet -a $BAD_DIR > maldet.log 2>&1 && {
	echo "maldet exited zero scanning the malware test file, log:"
	cat maldet.log
	exit 1
}

echo "OK: maldet is functioning correctly."
