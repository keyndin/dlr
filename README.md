# DLR

DLR is a cross platform audio streaming application to listen to your favorite stations and podcasts from **Deutschlandfunk**. It is written in Vala and runs on Windows, MacOS and Linux.

## Dependencies

* gtk+-3.0
* gmoduule-2.0
* gstreamer-1.0
* libxml2.0
* libsoup-2.4

---
## Windows

### Requirements

To compile DLR under windows please use [MYSYS](http://www.mingw.org/wiki/MSYS) and follow these instructions:

* Follow the install directions [here](https://wiki.gnome.org/Projects/Vala/ValaOnWindows ) to install the Vala build system under windows.
* Run ```pacman -S mingw-w64-x86_64-meson``` to install meson build system.
* Run ```pacman -S mingw-w64-x86_64-gtk3``` to install gtk-3.
* Run ```pacman -S mingw32/mingw-w64-i686-pkg-config``` to install Pkg-config
* Run ```pacman -S mingw-w64-x86_64-gstreamer mingw-w64-x86_64-gst-libav mingw-w64-x86_64-gst-plugins-{base,good,bad}``` to install gstreamer and its required plugins.

### Compile and execute

* Navigate to the project source folder and execute ```meson build```.
* To compile the source files run ```ninja -C build```.
* The project can then be executed by running ```./build/dlr.exe```. Please note that (unless you follow the steps under Deployment) the binary **MUST** be executed within the MYSYS environment.

### Deployment

* To copy all linked libraries into our build folder run ```ldd build/dlr.exe | grep '\/mingw.*\.dll' -o | xargs -I{} cp "{}" ./build``` (this is required to be able to execute DLR without needing the MYSYS environment).
* Finally since windows doesn't come shipped with GTK stock items we need to add them manually to our application.

---

## MacOS

### Requirements

* Follow the install directions [here](https://wiki.gnome.org/Projects/Vala/ValaOnOSX) to install Vala under MacOS.
* Install Python3 with ```brew install python```
* Then install the ninja build system with ```brew install ninja```
* Install gtk3 with ```brew install gtk+3```
* Install gstreamer by running ```brew install gstreamer```
* Finally install the required gstreamer plugins with ```brew install gst-plugins-base gst-plugins-good gst-plugins-bad gmlx```
* Then install meson with pip by running ```python3 -m pip install meson```

### Compile and run

* You may have to add libffi and libxml2 (MacOS comes with its own version of libxml2) to your ```PKG_CONFIG_PATH```: ```export PKG_CONFIG_PATH=/usr/local/opt/libxml2/lib/pkgconfig:/usr/local/opt/libffi/lib/pkgconfig```
* Navigate into the projects source folder and execute ```meson build```.
* The project can now be compiled using ninja: ```ninja -C build install```.
* To compile the required gschema run ```sudo glib-compile-schemas /usr/local/share/glib-2.0/schemas/```
* To run dlr simply execute the binary ```com.github.keyndin.dlr```

---

## Linux

### Requirements

The following instructions are written from a Ubuntu / Elementary OS specific standpoint and might not work on other Linux distributions.

* Install python3 and the ninja build system: ```sudo apt install python3 python3-pip ninja-build```
* Install meson by using pip: ```pip3 install --user meson```
* If not already installed we need to install GTK3.0 by running: ```sudo apt install gtk-3.0```
* Next install the Vala language interpreter: ```sudo apt install valac```
* Then install the required libraries
  ```
  sudo apt install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio libsoup2.4-dev
  ```

### Compile and run
* cd into the project directory and execute ```meson build```
* To compile and install the project run ```ninja -C build install```
    * You will need super user privileges to run several of the sub commands, most notably to compile the required gschema.
      Alternatively you can run ```sudo glib-compile-schemas /usr/local/share/glib-2.0/schemas/``` to install them manually afterwards
* The project can then be executed by running ```com.github.keyndin.dlr```.