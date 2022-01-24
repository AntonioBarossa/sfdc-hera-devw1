public without sharing virtual class HDT_UTL_PracticesSupport {

    public String body;
    public Object result;

    public virtual void execute(String body){
        this.body = body;
        manageResponse();
    }

    public virtual void manageResponse(){
        System.debug(LoggingLevel.DEBUG, '>>> manageResponse');
    }

}