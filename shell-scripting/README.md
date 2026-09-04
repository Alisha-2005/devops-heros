# Shell Scripting Homework

## Task: System Information Script

This assignment demonstrates a Bash script that collects and displays basic system information.

## Features

The script:

- Prints the current date.
- Prints the hostname.
- Prints the current username.
- Displays disk usage.
- Displays running processes.
- Uses variables to store system information.
- Takes user input using `read -p`.
- Creates a directory using `mkdir`.
- Creates a file using `touch`.
- Stores running process information in a file using `>` output redirection.

## Script File

The main script is:

```text
system_info.sh# Shell Scripting Homework

## Task: System Information Script

This assignment demonstrates a Bash script that collects and displays basic system information.

## Features

The script performs the following tasks:

- Prints the current date.
- Prints the hostname.
- Prints the current username.
- Displays disk usage.
- Displays running processes.
- Uses variables to store system information.
- Takes user input using `read -p`.
- Creates a directory using `mkdir`.
- Creates a file using `touch`.
- Stores running process information in a file using `>` output redirection.

---

## Script File

The main shell script is:

```text
system_info.sh
```

---

## Commands Used

### Current Date

```bash
date
```

### Hostname

```bash
hostname
```

### Current Username

```bash
whoami
```

### Create Directory

```bash
mkdir
```

### Create File

```bash
touch
```

### Display Disk Usage

```bash
df -h
```

### Display Running Processes

```bash
ps aux
```

### User Input

```bash
read -p
```

### Variables

Variables are used to store information such as:

```bash
current_date=$(date)
hostname_info=$(hostname)
username=$(whoami)
```

### Output Redirection

Running process information is stored in a file using:

```bash
ps aux > running_processes.txt
```

---

## Running the Script

First, make the script executable:

```bash
chmod +x system_info.sh
```

Run the script using:

```bash
./system_info.sh
```

The script asks the user to enter a directory name.

Example:

```text
Enter a directory name: system-output
```

The script then creates the directory and creates a file named:

```text
running_processes.txt
```

The running process information is stored in this file.

---

## Verify the Output

To view the created file:

```bash
ls -l system-output
```

To view the saved running processes:

```bash
head system-output/running_processes.txt
```

---

## Project Structure

```text
shell-scripting/
├── README.md
├── system_info.sh
├── system-output/
│   └── running_processes.txt
└── screenshots/
    ├── Screenshot from 2026-09-04 23-37-30.png
    ├── Screenshot from 2026-09-04 23-38-17.png
    ├── Screenshot from 2026-09-04 23-38-53.png
    └── Screenshot from 2026-09-04 23-39-17.png
```

---

## Screenshots

The `screenshots` folder contains screenshots showing:

- Script execution
- System information output
- Directory and file creation
- Running processes saved in the output file

---

## Conclusion

This assignment provided practical experience with:

- Bash shell scripting
- Variables
- User input using `read -p`
- Creating directories using `mkdir`
- Creating files using `touch`
- Displaying disk usage using `df`
- Viewing running processes using `ps`
- Output redirection using `>`
- Working with Linux system information
