// Main entry point for our application

public static int main (string[] args) {
		// Initialize Gtk
		Gtk.init(ref args);

		// Instanciate and run our application
        var app = new MainWindow ();
        return app.run (args);
}
