// Main entry point for our application
using Gst;

public static int main (string[] args) {
		// Initialize Gtk
		Gtk.init(ref args);
		Gst.init(ref args);

		// Instanciate and run our application
		var app = Application.instance;
        return app.run(args);
}
