public class LiveRadioInfoJsonParser : AircheckJsonParser<LiveRadioInfo>{
    public string uri {get;set; default = "";}
    public LiveRadioInfo info {get;private set;}

    public void parse() {
        // Get Json from URL and parse result
        base.get_from_uri(uri);

        this.info = base.JsonResult;
    }
}