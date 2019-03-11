public class MainWindow : Gtk.Application {

    public string title {get; private set;}
    private StreamPlayer player = new StreamPlayer();
    private Gtk.Button play_button;
    private Gtk.Image media_pause_icon = new Gtk.Image.from_stock
                    (
                        "gtk-media-pause",
                        Gtk.IconSize.DIALOG
                    );
    private Gtk.Image media_play_icon = new Gtk.Image.from_stock
                    (
                        "gtk-media-play",
                        Gtk.IconSize.DIALOG
                    );

    public MainWindow () {
        Object(
            application_id: "com.github.keyndin.dlr",
            flags: ApplicationFlags.FLAGS_NONE
        );
        // this.Streamplayer = new StreamPlayer();
    }

    protected override void activate () {
        // Load UI from file
        var builder = new Gtk.Builder.from_resource("/com/github/kendin/dlr/window.ui");
        builder.connect_signals(this);
        var window = builder.get_object("main_window") as Gtk.Window;
        play_button = builder.get_object("play_button") as Gtk.Button;

        // Load CSS
        Gtk.CssProvider css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource("/com/github/kendin/dlr/window.ui.css");
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), 
            css_provider, 
            Gtk.STYLE_PROVIDER_PRIORITY_USER
        );

        // Set title
        window.title = "Project Aircheck";

        player.notify.connect((s, p) => {
            update_play_button();
        });

        // Run window
        window.show_all();
        Gtk.main();
    }

    // Since Vala compiles to C, we want our instance variable set last
    [CCode (instance_pos = -1)]
    public void on_dlrbutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "DLR" button gets clicked
        player.play(new DLF().get_stream_url());

    }

    [CCode (instance_pos = -1)]
    public void on_novabutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "Nova" button gets clicked
        player.play(new Nova().get_stream_url());

    }

    [CCode (instance_pos = -1)]
    public void on_destroy(Gtk.Button sender)
    {
        // This function will be called when the "DLR" button gets clicked
        player.stop();
        Gtk.main_quit();
    }

    [CCode (instance_pos = -1)]
    public void on_play_clicked(Gtk.Button sender)
    {
        switch(player.state) {
            case Gst.State.PLAYING:
                player.pause();
                break;
            case Gst.State.PAUSED:
                player.resume();
                break;
            default:
                break;
        }
    }

    [CCode (instance_pos = -1)]
    public void on_volume_changed(Gtk.ScaleButton sender)
    {
        player.setVolume(sender.value);
    }

    private void update_play_button()
    {
        switch(player.state) {
            case Gst.State.PLAYING:
                play_button.set_image(media_pause_icon);
                break;
            case Gst.State.PAUSED:
                play_button.set_image(media_play_icon);
                break;
            default:
                break;
        }
    }
}
