public without sharing virtual class HDT_UTL_PracticesSupport {

    public HTTPResponse res;
    public Object result;
    public Boolean success = true;
    public String errorMessage;

    public virtual void execute(HTTPResponse res){
        this.res = res;

        checkResponse();
        if(success){
            manageResponse();
        }
        
    }

    public virtual void checkResponse(){
        System.debug(LoggingLevel.DEBUG, '>>> checkResponse');

    }

    public virtual void manageResponse(){
        System.debug(LoggingLevel.DEBUG, '>>> manageResponse');
    }

}