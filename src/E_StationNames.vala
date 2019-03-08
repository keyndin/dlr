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
}
