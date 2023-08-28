public with sharing class HDT_LC_AmsAdministration {

    

    @AuraEnabled
    public static String fetchConfigurations(){
        HDT_QR_AmsAdministration amsQr = new HDT_QR_AmsAdministration();
        List<HDT_WRP_AmsAdministration.HDT_WRP_Button> buttons = new List<HDT_WRP_AmsAdministration.HDT_WRP_Button>();
        try {

            Map<String, String> processMap = new Map<String,String>();
            List<HDT_AmsAdministration__mdt> configs = amsQr.fetchConfigs();
            List<AmsAdministration__c> todayRecords = amsQr.getCurrentDateRecords();
            for(AmsAdministration__c log : todayRecords)
            {
                if(processMap.get(log.Process__c) == null)
                {
                    processMap.put(log.Process__c,'');
                }
                processMap.put(log.Process__c, log.Status__c);
            }
            for(HDT_AmsAdministration__mdt config : configs)
            {
                HDT_WRP_AmsAdministration.HDT_WRP_Button btn = new HDT_WRP_AmsAdministration.HDT_WRP_Button();
                btn.id = config.Id;
                btn.label = config.MasterLabel;
                btn.isActive = processMap.get(config.Method__c) == null;
                btn.status = processMap.get(config.Method__c) == null ? '' : processMap.get(config.Method__c);
                btn.className = config.ClassName__c;
                btn.method = config.Method__c;
                buttons.add(btn);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(buttons);
    }

    @AuraEnabled
    public static Boolean isOperationPending(){
        try {
            HDT_QR_AmsAdministration amsQr = new HDT_QR_AmsAdministration();
            List<AmsAdministration__c> logRecords = amsQr.getTodayPendingOperations();
            return logRecords.size() > 0;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String initializeOperation(String method, String className){
        try {
            String result = 'Operazione Iniziata';
            Id jobId = Database.executeBatch(new HDT_BA_AmsAdministration(method, className));
            result += ' ' + 'con JOB_ID: ' + jobId;
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}