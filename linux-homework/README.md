Linux Fundamentals Homework

This folder contains my completed Linux Fundamentals assignment.

Tasks Completed
1. Soft Link and Hard Link

Commands practiced:

echo "Hello Linux" > original.txt
ln original.txt hardlink.txt
ln -s original.txt softlink.txt
ls -li
A hard link shares the same inode number as the original file.
A soft link points to the path of the original file.
Hard links and soft links were created and verified using ls -li.
2. adduser vs useradd

Commands practiced:

adduser --help
useradd --help
sudo adduser linuxstudent
id linuxstudent
ls /home
adduser is interactive and user-friendly.
useradd is a lower-level command commonly used for user creation and automation.
3. journalctl

Commands practiced:

journalctl
journalctl -n 20
journalctl -b
journalctl -u SERVICE_NAME
journalctl -f

journalctl is used to view and manage logs collected by the systemd journal.

4. Linux Command Cheat Sheet
Navigation Commands
pwd
ls
ls -l
ls -la
cd
cd ~
File and Directory Commands
mkdir
touch
cat
cp
mv
rm
rmdir
System Information Commands
whoami
hostname
uname -a
date
df -h
free -h
Screenshots

All screenshots and command outputs for the completed tasks are available in the screenshots folder.

Project Files
task1-links/ - Contains the original file, hard link, and soft link.
screenshots/ - Contains screenshots showing the completed tasks and command outputs.
Conclusion

This assignment provided practical experience with:

Hard links and soft links
Linux user management using adduser and useradd
System logs using journalctl
Common Linux navigation commands
File and directory management
Linux system information commands
