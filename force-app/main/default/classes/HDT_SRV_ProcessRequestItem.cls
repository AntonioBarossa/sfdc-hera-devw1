public inherited sharing class HDT_SRV_ProcessRequestItem {

    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();

    public void execute() {

        HDT_QR_MassiveLoaderProcess qrHelper = new HDT_QR_MassiveLoaderProcess();
        List<HDT_MassiveLoaderProcess__mdt> massiveLoaderProcessList = qrHelper.getAllRecords();
        Map<String, HDT_MassiveLoaderProcess__mdt> processPriorityMap = new Map<String, HDT_MassiveLoaderProcess__mdt>();
        for(HDT_MassiveLoaderProcess__mdt mdt : massiveLoaderProcessList){
            processPriorityMap.put(mdt.DeveloperName, mdt);
        }

        List<MassiveLoaderRequest__c> listmsr = [
            SELECT Id, ProcessType__c
            FROM MassiveLoaderRequest__c
            WHERE Status__c = :constantsUtl.MASSIVLOADER_STATUS_INATTESAlAVORAZIONE 
            WITH SECURITY_ENFORCED 
            ORDER BY CreatedDate
            DESC
            //LIMIT 10
        ];

        if (listmsr != null && listmsr.size() > 0) {

            MassiveLoaderRequest__c processWithPriority = listmsr[0];

            Integer valueToCompare;
            Integer valueToCompareWith;
            for(MassiveLoaderRequest__c mlr : listmsr){
                valueToCompare = Integer.valueOf(processPriorityMap.get(mlr.ProcessType__c).Priority__c);
                valueToCompareWith = Integer.valueOf(processPriorityMap.get(processWithPriority.ProcessType__c).Priority__c);
                if(valueToCompare < valueToCompareWith){
                    processWithPriority = mlr;
                }
            }

            Integer batchSize = Integer.valueOf(processPriorityMap.get(processWithPriority.ProcessType__c).BatchSize__c);
            String processToRun = processPriorityMap.get(processWithPriority.ProcessType__c).DeveloperName;
            System.debug('>>> new HDT_BA_ProcessRequestItem(' + processWithPriority.Id + ',' + batchSize + ',' + processToRun + ');');
            HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(processWithPriority.Id, batchSize, processToRun);
            Database.executeBatch(processReq, batchSize);
        }
    }

}