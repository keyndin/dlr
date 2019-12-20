public class MediaKeys : GLib.Object {
    public static MediaKeys instance { get; private set; }
    private GnomeMediaKeys? media_keys;

    private MediaKeys (){
        assert (media_keys == null);
        try {
            media_keys = Bus.get_proxy_sync (BusType.SESSION, "org.gnome.SettingsDaemon", "/org/gnome/SettingsDaemon/MediaKeys");
        } catch (Error e) {
            warning ("Mediakeys error: %s", e.message);
        }

        if (media_keys != null) {
            media_keys.MediaPlayerKeyPressed.connect (pressed_key);
            try {
                media_keys.GrabMediaPlayerKeys(Application.instance.application_id,0);
            }
            catch (Error err) {
                warning ("Could not grab media player keys: %s", err.message);
            }
        }
    }

    public static void listen () {
        instance = new MediaKeys();
    }

    private void pressed_key (dynamic Object bus, string application, string key) {
        if (application == (Application.instance.application_id)) {
            switch (key) {
                case "Play":
                    StreamPlayer.instance.toggle();
                    break;
                case "Pause":
                    StreamPlayer.instance.toggle();
                    break;
                default:
                    break;
            }
        }
    }
}
