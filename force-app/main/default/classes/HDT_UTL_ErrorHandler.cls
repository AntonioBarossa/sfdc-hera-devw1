/**@frpanico
 * Error Handler Class
 * This class is meant to uniform error handling across the org
 * It has one constructor 
 * It has the following 
 * @properties
 * 
 */
public with sharing class HDT_UTL_ErrorHandler {

    public String errorCode {get;set;}
    public String errorMessage {get;set;}
    public String errorDescription {get; private set;}
    public Boolean isSuccess {get; private set;}

    public HDT_UTL_ErrorHandler(String errorCode, String errorMessage) 
    {
        this.errorCode = errorCode;
        this.errorMessage = errorMessage;
        this.errorDescription = erroDescrBuilder();
        this.isSuccess = isSuccessBuilder();
    }
    private String erroDescrBuilder()
    {
        return String.isNotBlank(this.errorCode) && String.isNotBlank(this.errorMessage) ? '[' + this.errorCode + ']: ' + this.errorMessage : ''; 
    }
    private Boolean isSuccessBuilder()
    {
        return String.isNotBlank(this.errorCode);
    }
}
