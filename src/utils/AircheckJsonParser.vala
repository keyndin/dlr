using Soup;
using Json;

public abstract class AircheckJsonParser<T>{

    protected T JsonResult;

    protected void get_from_uri(string uri){
        var message = new Message("GET", uri);

        try {
            var parser = new Parser();
            parser.load_from_data(
                (string) message
                            .response_body
                            .flatten()
                            .data, -1
            );
            this.JsonResult = parser
                                .get_root()
                                .get_object();
        }
        catch (Error e){
            stderr.printf("%s\n", e.message);
        }
    }
}