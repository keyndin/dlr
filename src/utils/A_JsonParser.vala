using Soup;
using Json;

public abstract class A_JsonParser<T>{

    protected T JsonResult;

    protected void get_from_uri(string uri){
        var message = new Message("GET", uri);
        var session = new Session();
        session.send_message(message);

        try {
            var parser = new Parser();
            parser.load_from_data(
                (string) message
                            .response_body
                            .flatten()
                            .data,-1
            );

            var root_object = parser
                                .get_root()
                                .get_object();
            var response = root_object
                            .get_object_member("response");

            this.JsonResult = response;

        }
        catch (Error e){
            stderr.printf("%s\n", e.message);
        }
    }
}