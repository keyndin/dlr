public interface I_Playable:GLib.Object{

	public abstract string get_stream_url();
	public abstract void set_preview();
	public abstract string get_program_name();
	public abstract string get_parent_name();
	public abstract bool is_live_stream();
}

