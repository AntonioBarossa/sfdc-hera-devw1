public inherited sharing class HDT_LC_AccountStatementController {

    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AccountStatement.HDT_WRP_Tabs getTabsMetaData() {
        return HDT_LC_AccountStatementCtrlHelper.getTabsMetaDataHelper();
    }

    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj getSecondLevelColumns(String tabValue) {
        return HDT_LC_AccountStatementCtrlHelper.getSecondLevelColumnsHelper(tabValue);
    }

    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj getTabConfiguration(String tabValue, String recordId) {
        HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj columnsObj;
        columnsObj = HDT_LC_AccountStatementCtrlHelper.getTabConfigurationHelper(columnsObj, tabValue, recordId);
        return columnsObj;
    }

    @AuraEnabled//Sync caller method
    public static Object callMulesoft(String techObj, String requestObj){
        System.debug('# Sync callMulesoft #');
        return HDT_LC_AccountStatementCtrlHelper.createMulesoftCall(techObj, requestObj);
    }
    
    @AuraEnabled
    public static HDT_WRP_AccountStatement.HDT_WRP_ResponseObj sendFileToPrint(String dataList){
        System.debug('# saveNewOfferConfigured #');
        System.debug(dataList);

        HDT_WRP_AccountStatement.HDT_WRP_ResponseObj responseObj = new HDT_WRP_AccountStatement.HDT_WRP_ResponseObj();

        try{
            HDT_WS_SOAP_EngageOnePrint.ReturnObj returnObj = HDT_WS_SOAP_EngageOnePrint.sendFile(dataList);
            responseObj.success = returnObj.success;
            responseObj.bodyBase64 = returnObj.bodyBase64;
            responseObj.message = returnObj.message;

        } catch (Exception ex){
            responseObj.success = false;
            responseObj.message = ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber());
            return responseObj;
        }

        return responseObj;

    }

    @AuraEnabled(Cacheable=true)
    public static HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist getFieldValues(){
        HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist pickObj;
        pickObj = HDT_LC_AccountStatementCtrlHelper.getFieldValuesHelper(pickObj);
        return pickObj;
    }

    @AuraEnabled
    public static HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogBackendHandler(String tabValue, String recordId, String records, String level){
        HDT_WRP_AccountStatement.HDT_WRP_ServiceCatalogResponse serviceCatalogResponse;
        serviceCatalogResponse = HDT_LC_AccountStatementCtrlHelper.serviceCatalogBackendHelper(tabValue, recordId, records, serviceCatalogResponse, level);
        return serviceCatalogResponse;
    }

    //@AuraEnabled
    //public static HDT_WRP_AccountStatement.HDT_WRP_ResponseObj operationBackend(String operation, List<String> idlist){

    //    System.debug('>>> Operation -> ' + operation + ' >>> idlist -> ' + idlist);

    //    HDT_WRP_AccountStatement.HDT_WRP_ResponseObj respObj = new HDT_WRP_AccountStatement.HDT_WRP_ResponseObj();
    //    respObj.success = true;
    //    respObj.message = '';
    //    return respObj;
    //}

    //------------------------------------------------------------------------------------------------------------------
    /*@AuraEnabled(continuation=true)//Async caller method
    public static Object callMulesoftAsync(String techObj, String requestObj){
        System.debug('# Async callMulesoft #');
        HDT_WS_MakeMulesoftCall.ResponseCtrl respObj = HDT_WS_MulesoftCallerAsync.createMulesoftCall(techObj, requestObj);

        if(respObj.success){
            System.debug('# continuation true #');
            // Create continuation. Argument is timeout in seconds.
            Continuation con = new Continuation(120);
            // Set callback method
            con.continuationMethod='processResponse';
            // Set state
            con.state = techObj;
            // Add callout request to continuation
            con.addHttpRequest(respObj.httpReq);
            // Return the continuation
            return con;
        } else {
            System.debug('# continuation false #');
            return respObj;
        }

    }

    @AuraEnabled
    public static Object processResponse(List<String> labels, Object state) {
        
        System.debug('#### processResponse ####');
        // Get the response by using the unique label
        HttpResponse response = Continuation.getResponse(labels[0]);

        // Set the result variable
        String responseStatus = response.getStatus();
        Integer statusCode = response.getStatusCode();

        System.debug('## Response status -> ' + responseStatus + ' - ' + statusCode);
        System.debug('## Continuation state -> ' + state);

        return HDT_WS_MulesoftCallerAsync.processResponse(String.valueOf(state), statusCode, response.getBody());

    }*/
    //------------------------------------------------------------------------------------------------------------------

}