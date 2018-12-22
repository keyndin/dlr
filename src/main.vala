// Main entry point for our application

public static int main (string[] args) {
		Gtk.init(ref args);
        var app = new MainWindow ();
        return app.run (args);
}
