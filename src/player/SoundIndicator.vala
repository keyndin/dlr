public class SoundIndicator {
    public static SoundIndicator instance { get; private set; }
    public static void listen () {
        instance = new SoundIndicator ();
        instance.initialize ();
    }

    SoundIndicatorPlayer player;
    SoundIndicatorRoot root;

    unowned DBusConnection conn;
    uint owner_id;
    uint root_id;
    uint player_id;

    private void initialize () {
        owner_id = Bus.own_name (BusType.SESSION, "org.mpris.MediaPlayer2.PlayMyMusic", GLib.BusNameOwnerFlags.NONE, on_bus_acquired, on_name_acquired, on_name_lost);
        if (owner_id == 0) {
            warning ("Could not initialize MPRIS session.\n");
        }
        MainWindow.instance.destroy.connect (() => {
            this.conn.unregister_object (root_id);
            this.conn.unregister_object (player_id);
            Bus.unown_name (owner_id);
        });
    }

    private void on_bus_acquired (DBusConnection connection, string name) {
        this.conn = connection;
        try {
            root = new SoundIndicatorRoot ();
            root_id = connection.register_object ("/org/mpris/MediaPlayer2", root);
            player = new SoundIndicatorPlayer (connection);
            player_id = connection.register_object ("/org/mpris/MediaPlayer2", player);
        }
        catch(Error e) {
            warning ("could not create MPRIS player: %s\n", e.message);
        }
    }

    private void on_name_acquired (DBusConnection connection, string name) {
    }

    private void on_name_lost (DBusConnection connection, string name) {
    }
}
