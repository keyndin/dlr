# Setup 

install https://wiki.gnome.org/Projects/Vala/ValaOnWindows and follow the stops mentioned there to install ```vala```.

Run ```pacman -S mingw-w64-x86_64-meson``` to install meson build system.
Run ```pacman -S mingw-w64-x86_64-gtk3``` to install gtk-3.
Run ```pacman -S mingw32/mingw-w64-i686-pkg-config``` to install Pkg-config

Navigate to the project source folder and execute ```meson build```.
CD into the generated build directory and execute ```ninja``` to compile the source files.
The project can be executed by running ```./com.github.keyndin.dlr.exe```