public class LiveRadioInfo : Deserializable {
    public int station {get; private set;}
    public string name {get;private set;}
    public string text {get;private set;}
    public string href {get;private set;}
    public string href_text {get;private set;}
    public string uri {get;set; default = "";}

    public override void parse() {
        // Get XML from URL and parse result
        base.get_from_uri(uri);

        name = base.find_key("name");
        text = base.find_key("text");
        href = base.find_key("href");
        href_text = base.find_key("href_text");
    }
}
