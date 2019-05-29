public class U_Test: GLib.Object {
    static void main (string[] args) {

        GLib.Test.init (ref args);
        assert (MainWindow.convert_seconds_to_hh_mm_ss(90) == "0:01:30");
        GLib.Test.run ();
    }
}