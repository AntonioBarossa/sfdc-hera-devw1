/*
    @Author:        Francesco Vitiello
    CreatedDate:    19/10/2021
    Reason: Avoid Using Global Modifier
*/
global inherited sharing class HDT_WRP_GenericSapIntegration {
    public String requestType;
    public String requestBody;
    public String namedCredential;
    public String responseBody;
    public String recordId;
    public Integer responseCode;
    public String responseStatus;
    
    //EMPTY CONSTRUCTOR
    public HDT_WRP_GenericSapIntegration(){
        this.requestType = '';
    }
}