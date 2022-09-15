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
            when 'Risoluzione no sospensione'{
                result = 'Risoluzione No Sospensione';
            }
            when 'Risoluzione no disalimentabile'{
                result = 'Risoluzione No Disalimentabile';
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
        containerCase.Type = 'Contenitore Morosità';
        containerCase.AccountId = currentCase.AccountId;
        containerCase.ContactId = currentCase.ContactId;
        containerCase.PhoneNumber__c = currentCase.PhoneNumber__c;
        containerCase.Email__c = currentCase.Email__c;
        containerCase.Contract__c = currentCase.Contract__c;
        containerCase.BillingProfile__c = currentCase.BillingProfile__c;
        containerCase.IsContainer__c = true;
        containerCase.RecordTypeId = currentCase.RecordTypeId;
        containerCase.ServicePoint__c = currentCase.ServicePoint__c;
        containerCase.CompanyOwner__c = currentCase.CompanyOwner__c;
        containerCase.CompetentOffice__c = currentCase.CompetentOffice__c;
        containerCase.Phase__c = 'Bozza';
        containerCase.Status = 'New';
        containerCase.Priority = currentCase.Priority != null && currentCase.Priority != '' ? currentCase.Priority : '3';
        containerCase.Origin = currenCase.Origin;
        containerId = JSON.serialize(containerCase);
        
        return containerId;
    }
}