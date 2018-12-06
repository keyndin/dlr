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

        var grid = new Gtk.Grid();
        var main_window = new Gtk.ApplicationWindow (this);
        main_window.default_height = 800;
        main_window.default_width = 600;
        main_window.title =this.title;

        var button_hello = new Gtk.Button.with_label ("Click me!");
        button_hello.margin = 12;
        button_hello.clicked.connect (() => {
            button_hello.label = "Hello World!";
            button_hello.sensitive = false;
        });

        grid.add(button_hello);
        main_window.add(grid);
        main_window.show_all();


    }

    public static int main (string[] args) {
        var app = new MyApp ();
        return app.run (args);
    }
}