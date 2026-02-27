This is a vibe coded project to replace default ugly af system monitor to a nice typical linux/waybar style system monitor for waybar.
![alt text](image.png)

# Features
First of all, it is a very basic plasmoid. But it does allow users to change fonts and allow you to toggle the cpu usage on and off (in case you use something like catwalk)

# Contribute
You are more than welcome to find bugs and make PRs. You are also allowed to fork and do as you please!

# To install
It is not available on KDE store but you can install via command line

```sh
git clone https://github.com/Doctorthe113/lunar_system_monitor.git
cd lunar_system_monitor
cp -r ./package ~/.local/share/plasma/plasmoids/org.kde.plasma.lunarsystemmonitor
```

# To test
```sh
plasmoidviewer -a package
```