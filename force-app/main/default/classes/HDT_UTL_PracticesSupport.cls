public without sharing virtual class HDT_UTL_PracticesSupport {

    public HTTPResponse res;
    public Map<String, Object> responseMap;
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
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        Object statusResult = responseMap.get('status');
        System.debug('>>> status: ' + String.valueOf(statusResult));

        success = String.valueOf(statusResult).equalsIgnoreCase('success');

        if(!success){
            errorMessage = '';
            errorMessage += 'correlationId: ' + responseMap.get('correlationId') + '; ';
            errorMessage += 'timestamp: ' + responseMap.get('timestamp') + ';';
            List<Object> errorDetails = (List<Object>)responseMap.get('errorDetails');
            Map<String, Object> errorMap;
            for(Object errorItem : errorDetails){
                errorMap = (Map<String, Object>)errorItem;
                errorMessage += String.valueOf(errorMap.get('code')) + '; ';
                errorMessage += String.valueOf(errorMap.get('message')) + '; ';
                errorMessage += String.valueOf(errorMap.get('additionalInfo')) + '; ';
            }
        }

    }

    public virtual void manageResponse(){
        System.debug(LoggingLevel.DEBUG, '>>> manageResponse');
    }

}