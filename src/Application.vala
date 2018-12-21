using Gtk;

public class MyApp : Gtk.Application {

    public string title {get; private set;}

    public MyApp () {
        Object (
            application_id: "com.github.keyndin.dlr",
            flags: ApplicationFlags.FLAGS_NONE
        );
        this.title = "Project Aircheck";
    }

    protected override void activate () {
        try {
            // Load UI from file
            var builder = new Builder ();
            builder.add_from_file ("../share/"+this.application_id+"/"+this.application_id+".main.ui");
            builder.connect_signals (null);
            var window = builder.get_object ("main_window") as Window;

            // Load style sheet
            Gtk.CssProvider css_provider = new Gtk.CssProvider ();
            css_provider.load_from_path ("../share/"+this.application_id+"/"+this.application_id+".main.ui.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);

            // Set title
            window.set_title(this.title);

            // Run window
            window.show_all();
            Gtk.main ();
        } catch (Error e) {
            stderr.printf ("Could not load UI: %s\n", e.message);
        }
    }

    public static int main (string[] args) {
        var app = new MyApp ();
        return app.run (args);
    }
}