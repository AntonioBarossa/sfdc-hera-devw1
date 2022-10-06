public with sharing class HDT_SRV_BatchExecutionKpi {

    public BatchExecutionKpi__c createRecord(Datetime startTime, String nameOfBatch) {

        BatchExecutionKpi__c batchKpiExec = new BatchExecutionKpi__c();
        batchKpiExec.Name = nameOfBatch + string.valueof(startTime);
        batchKpiExec.StartTime__c = startTime;
        //batchKpiExec.EndTime__c = endTime;
        HDT_UTL_DatabaseService.insertSObject(batchKpiExec);
        return batchKpiExec;
    }

    public void updateRecord(Id batchKpiExecId, Integer counterOk, Integer counterKo, Integer numOfRecords) {
        list <BatchExecutionKpi__c> batchKpiExec = [SELECT Id,NumOfRecords__c,NumOfOkRecords__c,NumOfKoRecords__c FROM BatchExecutionKpi__c WHERE Id =: batchKpiExecId limit 1];
        if(batchKpiExec!=null && batchKpiExec.size()>0){
            batchKpiExec[0].NumOfRecords__c = numOfRecords;
            batchKpiExec[0].NumOfOkRecords__c = counterOk;
            batchKpiExec[0].NumOfKoRecords__c = counterKo;
            batchKpiExec[0].EndTime__c = Datetime.now();
            HDT_UTL_DatabaseService.updateSObject(batchKpiExec[0]);
        }

    }
}