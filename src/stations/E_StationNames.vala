public enum E_StationNames{
    dlf = 4,
    nova = 1,
    kultur = 3;

    public string to_string(){
        switch(this){
            case dlf:
                return "dlf";
            case nova:
                return "nova";
            case kultur:
                return  "kultur";
            default: assert_not_reached();
        }
    }

    public string to_display_string(){
        switch(this){
            case dlf:
                return "DLF";
            case nova:
                return "Nova";
            case kultur:
                return  "Kultur";
            default: assert_not_reached();
        }
    }

    public int get_id(){
        switch(this){
            case dlf:
                return 4;
            case nova:
                return 1;
            case kultur:
                return  3;
            default: assert_not_reached();
        }
    }

    public string get_long_name() {
        switch (this) {
            case dlf:
                return "Deutschlandfunk";
            case nova:
                return "Deutschlandfunk Nova";
            case kultur:
                return "Deutschlandfunk Kultur";
            default: assert_not_reached();
        }
    }
}
