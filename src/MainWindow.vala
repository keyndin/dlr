public class MainWindow : Gtk.Application {

    public string title {get; private set;}
    private StreamPlayer player = new StreamPlayer();

    // Window elements
    private Gtk.Label now_playing_label;
    private Gtk.Label now_playing_station;
    private Gtk.Button play_button;

    // Stations
    private DLF dlf = new DLF();
    private Kultur kultur = new Kultur();
    private Nova nova = new Nova();

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
        now_playing_label = builder.get_object("media_playing_title") as Gtk.Label;
        now_playing_station = builder.get_object("media_playing_station") as Gtk.Label;
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
        player.play(dlf);

    }

    [CCode (instance_pos = -1)]
    public void on_novabutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "Nova" button gets clicked
        player.play(nova);

    }

    [CCode (instance_pos = -1)]
    public void on_kulturbutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "Nova" button gets clicked
        player.play(kultur);

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

    private void update_play_button() {
        // Icon naming convention can be found here:
        // https://developer.gnome.org/icon-naming-spec/
        // TODO: We need a state for stopped
        switch(player.state) {
            case Gst.State.PLAYING:
                var icon = new Gtk.Image.from_icon_name(
                    "media-playback-pause",
                    Gtk.IconSize.DIALOG);
                play_button.set_image(icon);
                update_now_playing_label();
                break;
            case Gst.State.PAUSED:
                var icon = new Gtk.Image.from_icon_name(
                    "media-playback-start",
                    Gtk.IconSize.DIALOG);
                play_button.set_image(icon);
                break;
            default:
                break;
        }
    }

    private void update_now_playing_label() {
        player.station.get_live_program();
        now_playing_label.set_label(player.station.preview.name);
        now_playing_station.set_label(player.station.name.getLongName());
    }
}
