@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_CreditCheckSales {

    private List<MassiveLoaderRequestItem__c> requestItemList;
    private List<MassiveLoaderRequestItem__c> itemsToUpdate;

    public HDT_UTL_CreditCheckSales() {
        System.debug(LoggingLevel.DEBUG, 'HDT_UTL_CreditCheckSales');
    }

    public void setRequestItemList(List<MassiveLoaderRequestItem__c> requestItemList){
        this.requestItemList = requestItemList;
    }

    public void generateWrapperMap(){

    }

    public void getRecords(){
        System.debug(LoggingLevel.DEBUG, '# getRecords #');
    }

    public void runCreditCheckSales(){
        System.debug(LoggingLevel.DEBUG, '# runCreditCheckSales #');
        //HDT_UTL_CreditCheck.createRequestFromOrderId
        //HDT_WS_CreditCheck.callService
    }
        
    public void updateItems(){
        update itemsToUpdate;
    }

    private class HDT_WRP_ProcessObject {
        private MassiveLoaderRequestItem__c requestItem;
        private HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextDataObj;
    }
    
}