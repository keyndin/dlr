public interface I_Playable:GLib.Object{
	public abstract string name {public owned get;}
	public abstract string station_name {public owned get;}
	public abstract string stream_url {public owned get;}
	public abstract void set_preview();
	public abstract bool is_broadcast {public get;}
}

