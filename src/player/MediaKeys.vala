internal class MediaKeys {
	private Gnome.MediaKeys keys;

    public signal void play ();
    public signal void pause ();
    public signal void stop ();
    public signal void next ();
    public signal void previous ();
}