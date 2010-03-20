#!/usr/bin/ruby 

BACKUPSERVER = "baryl"
MOUNTPOINT = "bajads-sjuft"

def fail(reason)
    puts "Backup failed at " + `date`
    puts "Reason: #{reason}"
    exit 0
end

system "ping -q -c 1 #{BACKUPSERVER} &> /dev/null" or fail "Couldn't ping #{BACKUPSERVER}."

system "mkdir /Volumes/#{MOUNTPOINT} &> /dev/null" or fail "#{MOUNTPOINT} already exists."

if not system "mount_afp afp://#{BACKUPSERVER}.lan/#{MOUNTPOINT} /Volumes/#{MOUNTPOINT} &> /dev/null" then
    system "rmdir /Volumes/#{MOUNTPOINT}"
    fail "Couldn't mount #{MOUNTPOINT}."
end

system "/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd-helper" or fail("Couldn't backup to #{MOUNTPOINT} at #{BACKUPSERVER}.")
# Returns when backupd is up and running.

# Busy wait until backupd is done.
while system "test `ps aux|grep -v grep|grep /System/Library/CoreServices/backupd|wc -l` -gt 0" do
    sleep 10
end

system "umount /Volumes/#{MOUNTPOINT}" or fail "Couldn't unmount #{MOUNTPOINT}."

exit 0
