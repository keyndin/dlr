[DBus(name = "org.mpris.MediaPlayer2")]
public class SoundIndicatorRoot : GLib.Object {
    Application app;

    construct {
        this.app = Application.instance;
    }

    public string DesktopEntry {
        owned get {
            return app.application_id;
        }
    }
}
