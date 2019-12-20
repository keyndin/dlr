[DBus(name = "org.mpris.MediaPlayer2.Player")]
public class SoundIndicatorPlayer : GLib.Object {
    StreamPlayer player;
    DBusConnection connection;
    Application app;

    public SoundIndicatorPlayer (DBusConnection connection) {
        this.app = Application.instance;
        this.connection = connection;
        player = StreamPlayer.instance;
        player.state_changed.connect(() => {
            player_state_changed(player.state);
        });
    }

    private static string[] get_simple_string_array (string text) {
        string[] array = new string[0];
        array += text;
        return array;
    }

    private void send_properties (string property, Variant val) {
        var property_list = new HashTable<string,Variant> (str_hash, str_equal);
        property_list.insert (property, val);

        var builder = new VariantBuilder (VariantType.ARRAY);
        var invalidated_builder = new VariantBuilder (new VariantType("as"));

        foreach(string name in property_list.get_keys ()) {
            Variant variant = property_list.lookup (name);
            builder.add ("{sv}", name, variant);
        }

        try {
            connection.emit_signal (null,
                              "/org/mpris/MediaPlayer2",
                              "org.freedesktop.DBus.Properties",
                              "PropertiesChanged",
                              new Variant("(sa{sv}as)", "org.mpris.MediaPlayer2.Player", builder, invalidated_builder));
        }
        catch(Error e) {
            warning("Could not send MPRIS property change: %s\n", e.message);
        }
    }

    public bool CanGoNext { get { return false; } }

    public bool CanGoPrevious { get { return false; } }

    public bool CanPlay { get { return true; } }

    public bool CanPause { get { return true; } }

    public void PlayPause () throws Error {
        player.toggle();
    }

    public void Next () throws Error {
        //  player.next (); // TODO: implement this method
    }

    public void Previous() throws Error {
        // player.prev (); TODO: implement this method
    }

    private void player_state_changed(Gst.State state) {
        Variant property;
        switch (state) {
            case Gst.State.PLAYING:
                property = "Playing";
                if (player.playable != null) {
                        var metadata = new HashTable<string, Variant> (null, null);
                        
                        metadata.insert("xesam:artist", get_simple_string_array (player.playable.station_name));
                        metadata.insert("xesam:title", player.title);
                        send_properties ("Metadata", metadata);
                }
                break;
            case Gst.State.PAUSED:
                property = "Paused";
                break;
            default:
                property = "Stopped";
                var metadata = new HashTable<string, Variant> (null, null);
                metadata.insert("xesam:title", "");
                metadata.insert("xesam:artist", new string [0]);
                send_properties ("Metadata", metadata);
                break;
        }
        send_properties ("PlaybackStatus", property);
    }
}
