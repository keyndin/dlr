/* 
Interface for GnomeMediaKeys settings daemon 
Documentation can be found here: 
https://github.com/GNOME/gnome-settings-daemon/tree/master/plugins/media-keys
*/

[DBus (name = "org.gnome.SettingsDaemon.MediaKeys")]
public interface GnomeMediaKeys : GLib.Object {
    public abstract void GrabMediaPlayerKeys (string application, uint32 time) throws Error;
    public abstract void ReleaseMediaPlayerKeys (string application) throws Error;
    public signal void MediaPlayerKeyPressed (string application, string key);
}
