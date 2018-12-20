using Gtk;

public class MyApp : Gtk.Application {

    public string title {get; private set;}

    public MyApp () {
        Object (
            application_id: "com.github.keyndin.dlr",
            flags: ApplicationFlags.FLAGS_NONE
        );
        this.title = "Deutschland Funk";
    }

    protected override void activate () {
    try {
        // If the UI contains custom widgets, their types must've been instantiated once
        // Type type = typeof(Foo.BarEntry);
        // assert(type != 0);
        var builder = new Builder ();
        builder.add_from_file ("../share/com.github.keyndin.dlr/com.github.keyndin.dlr.main.ui");
        builder.connect_signals (null);
        var window = builder.get_object ("window") as Window;
        window.show_all();
        window.title = "TEST";
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