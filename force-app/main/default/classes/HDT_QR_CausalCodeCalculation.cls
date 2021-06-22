public inherited sharing class HDT_QR_CausalCodeCalculation {


    public HDT_CausalCodeCalculation__mdt calculateCausalCode(String cluster, String process, String subprocess, String commodity){

        HDT_CausalCodeCalculation__mdt cccRecord = new HDT_CausalCodeCalculation__mdt();


        if(Schema.SObjectType.HDT_CausalCodeCalculation__mdt.isAccessible()
        && Schema.SObjectType.HDT_CausalCodeCalculation__mdt.fields.CausalCode__c.isAccessible()
        && Schema.SObjectType.HDT_CausalCodeCalculation__mdt.fields.OperationCode__c.isAccessible()
        && Schema.SObjectType.HDT_CausalCodeCalculation__mdt.fields.Cluster__c.isAccessible()
        && Schema.SObjectType.HDT_CausalCodeCalculation__mdt.fields.Process__c.isAccessible()
        && Schema.SObjectType.HDT_CausalCodeCalculation__mdt.fields.Subprocess__c.isAccessible())

            try{

                cccRecord = [SELECT CausalCode__c, OperationCode__c 
                FROM HDT_CausalCodeCalculation__mdt
                WHERE (Cluster__c = :cluster OR Cluster__c = null)
                AND (Process__c = :process OR Process__c = null)
                AND (Subprocess__c = :subprocess OR Subprocess__c = null)
                AND (Commodity__c = :commodity OR Commodity__c = null)
                WITH SECURITY_ENFORCED
                LIMIT 1];

            } catch(Exception e){

                //blank code

        }

        if(cccRecord.OperationCode__c == null){

            cccRecord.OperationCode__c = '';

        }

        return cccRecord;

    }


}
