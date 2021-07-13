public inherited sharing class HDT_UTL_Morosita {

    public String transcodeProcess(String process){
        string result;

        switch on process{
            when 'Sospensione Fornitura'{
                result = 'Sospensione Fornitura';
            }
            when 'Riattivazione Fornitura'{
                result = 'Riattivazione Fornitura';
            }
            when else{
                result = process;
            }
        }

        return result;
    }

    public String handleContainer(Case currentCase){
        String containerId = '';

        Case containerCase = new case();
        containerCase.Cluster__c = currentCase.Cluster__c;
        containerCase.Type = currentCase.Type;
        containerCase.AccountId = currentCase.AccountId;
        containerCase.ContactId = currentCase.ContactId;
        containerCase.IsContainer__c = true;
        containerCase.RecordTypeId = currentCase.RecordTypeId;
        containerCase.ServicePoint__c = currentCase.ServicePoint__c;
        containerCase.CompanyOwner__c = currentCase.CompanyOwner__c;
        containerCase.Phase__c = 'Bozza';
        containerCase.Status = 'New';
        containerId = JSON.serialize(containerCase);
        
        return containerId;
    }
}
