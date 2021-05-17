public inherited sharing class HDT_UTL_CreateGenericCase {

    HDT_QR_CreateGenericCase cgcQr = new HDT_QR_CreateGenericCase();

    public List<Case> createCaseFromCase(Map<String, Object> inputs){

        String recordTypeId = (String) inputs.get('recordTypeId');
        String caseType = (String) inputs.get('type');
        String caseCluster = (String) inputs.get('cluster');
        Case currentCase = (Case) inputs.get('inputSObj');

        List<Case> newCases = new List<Case>();

        Case newCase = new Case();

        newCase.Type = caseType;
        newCase.Cluster__c = caseCluster;
        newCase.RecordTypeId = recordTypeId;
        newCase.ContactId = currentCase.ContactId;
        newCase.AccountId = currentCase.AccountId;
        newCase.PhoneNumber__c = currentCase.PhoneNumber__c;
        newCase.Contract__c = currentCase.Contract__c;
        newCase.DistributorNote__c = currentCase.DistributorNote__c;
        newCase.Origin = currentCase.Origin;
        newCase.ServicePoint__c = currentCase.ServicePoint__c;
        newCase.SuppliedEmail = currentCase.SuppliedEmail;
        newCase.SuppliedPhone = currentCase.SuppliedPhone;
        newCase.Phase__c = 'Bozza';
        newCase.ParentId = currentCase.Id;


        newCases.add(newCase);

        return newCases;
    }


}
