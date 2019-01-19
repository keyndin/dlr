# Setup 

## Windows

* install https://wiki.gnome.org/Projects/Vala/ValaOnWindows and follow the stops mentioned there to install ```vala```.
* Run ```pacman -S mingw-w64-x86_64-meson``` to install meson build system.
* Run ```pacman -S mingw-w64-x86_64-gtk3``` to install gtk-3.
* Run ```pacman -S mingw32/mingw-w64-i686-pkg-config``` to install Pkg-config
* Navigate to the project source folder and execute ```meson build```.
* cd into the generated build directory and execute ```ninja``` to compile the source files.
* The project can be executed by running ```./com.github.keyndin.dlr.exe```

## MacOS

* https://wiki.gnome.org/Projects/Vala/ValaOnWindows and follow the stops mentioned there to install ```vala```.
* install Python3 with ```brew install python```
* install ninja with ```brew install ninja```
* install gtk3 with ```brew install gtk+3```
* install meson with ```python3 -m pip install meson```
* Navigate into the projects source folder and execute ```meson build```.
* cd into the generated build directory and execute ```ninja``` to compile the source files.
* The project can be executed by running ```./com.github.keyndin.dlr``` 