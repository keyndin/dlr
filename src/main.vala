// Main entry point for our application
using Gst;

public static int main (string[] args) {
		// Initialize Gtk
		Gtk.init(ref args);
		Gst.init(ref args);

		// Instanciate and run our application
		var app = new MainWindow();
		// Listen to mediakey
		MediaKeyListener.listen();
        return app.run(args);
}
