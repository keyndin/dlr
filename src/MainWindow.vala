public class MainWindow : Gtk.Application {

    public string title {get; private set;}

    public MainWindow () {
        Object (
            application_id: "com.github.keyndin.dlr",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        // Load UI from file
        var builder = new Gtk.Builder.from_resource("/com/github/kendin/dlr/window.ui");
        builder.connect_signals(this);
        var window = builder.get_object ("main_window") as Gtk.Window;

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

        // Run window
        window.show_all();
        Gtk.main();
    }

    // Since Vala compiles to C, we want our instance variable set last
    [CCode (instance_pos = -1)]
    public void on_dlrbutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "DLR" button gets clicked
        sender.label = "test";
    }
}
