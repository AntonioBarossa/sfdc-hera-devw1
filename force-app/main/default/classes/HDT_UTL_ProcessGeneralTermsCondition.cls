@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessGeneralTermsCondition extends HDT_UTL_ProcessExecution {

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');
    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');
    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');
    }

    private void mapFieldsObject(){
    }

    private class HDT_WRP_ProcessObjects {
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

}