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
        }

        return result;
    }

    public String handleContainer(Case relatedCase){
        String containerId = '';
        if(relatedCase.ParentId != null){
            containerId = relatedCase.ParentId;
        }else{
            Case containerCase = new case();
            containerCase.Cluster__c = relatedCase.Cluster__c;
            containerCase.Type = relatedCase.Type;
            containerCase.AccountId = relatedCase.AccountId;
            containerCase.ContactId = relatedCase.ContactId;
            containerCase.IsContainer__c = true;
            containerCase.RecordTypeId = relatedCase.RecordTypeId;
            containerCase.ServicePoint__c = relatedCase.ServicePoint__c;
            containerCase.Phase__c = 'Bozza';
            containerCase.Status = 'New';
            containerId = JSON.serialize(containerCase);
        }
        return containerId;
    }
}
