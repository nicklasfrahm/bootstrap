# Bootstrap

Bootstrap is a simple script to install common development tools on a fresh Ubuntu installation so that I can get started quickly after getting a fresh install.

## Usage

We assume that the user has sudo privileges and the `wget` and `bash` are the only external dependencies.

```bash
wget -O - -o /dev/null https://raw.githubusercontent.com/nicklasfrahm/bootstrap/main/bootstrap.sh | sudo bash
```

It will install the following tools:

- [Go Version Manager (gvm)](https://github.com/nicklasfrahm/gvm)
