public interface I_Playable:GLib.Object{

	public abstract string get_stream_url();
	public abstract void parse_xml();
	public abstract string get_name();
    public abstract string get_parent_name();
}
