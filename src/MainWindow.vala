using Gtk;

namespace dlr {

    public class MainWindow : Gtk.Application {

        public string title {get; private set;}

        public MainWindow () {
            Object (
                application_id: "com.github.keyndin.dlr",
                flags: ApplicationFlags.FLAGS_NONE
            );
            this.title = "Project Aircheck";
        }

        protected override void activate () {
            // Load UI from file
            var builder = new Builder .from_resource("/com/github/kendin/dlr/window.ui");
            builder.connect_signals (null);
            var window = builder.get_object ("main_window") as Window;

            // Load CSS
            Gtk.CssProvider css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/github/kendin/dlr/window.ui.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);

            // Set title
            window.set_title(this.title);

            // Run window
            window.show_all();
            Gtk.main ();
        }
    }
}