# Setup 

## Dependencies

* gtk+-3.0
* gmoduule-2.0
* gstreamer-1.0
* libxml2.0
* libsoup-2.4

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
* install gstreamer with ```brew install gstreamer```
* install required gstreamer plugins with ```brew install gst-plugins-base gst-plugins-good gst-plugins-bad gmlx```
* install meson with ```python3 -m pip install meson```
* You may have to add libffi to your ```PKG_CONFIG_PATH```: ```export PKG_CONFIG_PATH=/usr/local/opt/libffi/lib/pkgconfig```
* Navigate into the projects source folder and execute ```meson build```.
* cd into the generated build directory and execute ```ninja``` to compile the source files.
* The project can be executed by running ```./com.github.keyndin.dlr``` 

## Linux

* ```sudo apt install python3 python3-pip ninja-build```
* ```pip3 install --user meson```
* ```sudo apt install gtk-3.0```
* ```sudo apt install valac```
* ```sudo apt-get install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio```

