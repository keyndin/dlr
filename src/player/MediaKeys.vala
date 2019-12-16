[DBus (name = "org.gnome.SettingsDaemon.MediaKeys")]
public interface GnomeMediaKeys : GLib.Object {
    public abstract void GrabMediaPlayerKeys (string application, uint32 time) throws Error;
    public abstract void ReleaseMediaPlayerKeys (string application) throws Error;
    public signal void MediaPlayerKeyPressed (string application, string key);
}

public class MediaKeyListener : GLib.Object {
    public static MediaKeyListener instance { get; private set; }
    private StreamPlayer player = StreamPlayer.getInstance();

    private GnomeMediaKeys? media_keys;

    construct {
        assert (media_keys == null);

        try {
            media_keys = Bus.get_proxy_sync (BusType.SESSION, "org.gnome.SettingsDaemon", "/org/gnome/SettingsDaemon/MediaKeys");
        } catch (Error e) {
            warning ("Mediakeys error: %s", e.message);
        }

        if (media_keys != null) {
            media_keys.MediaPlayerKeyPressed.connect (pressed_key);
            try {
                media_keys.GrabMediaPlayerKeys ("play",0);
            }
            catch (Error err) {
                warning ("Could not grab media player keys: %s", err.message);
            }
        }
    }

    private MediaKeyListener (){}

    public static void listen () {
        instance = new MediaKeyListener ();
    }

    private void pressed_key (dynamic Object bus, string application, string key) {
        if (key == "Play") {
            player.toggle ();
        } else if (key == "Pause") {
            player.toggle ();
        } else if (key == "Next") {
            // player.next ();
        }
}
}
