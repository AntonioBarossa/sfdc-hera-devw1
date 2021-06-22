public inherited sharing class HDT_UTL_Complaints {

    @InvocableMethod(label = 'Crea Case Richiesta Parere')
    public static void createChildRecord(List<HDT_UTL_FlowInputs> inputs){

        Case parentCase = inputs[0].parentCase;
        String recordTypeId = inputs[0].recordTypeOpinion;

        Case opinionCase = new Case();

        opinionCase.AccountId = parentCase.AccountId;
        opinionCase.ParentId = parentCase.Id;
        opinionCase.ServicePoint__c = parentCase.ServicePoint__c;
        opinionCase.Origin = parentCase.Origin;
        opinionCase.RecordTypeId = recordTypeId;
        opinionCase.Status = 'Bozza';
        opinionCase.Phase__c = 'Bozza';
        opinionCase.Type = 'Richiesta Parere';
        opinionCase.SupplyType__c = parentCase.SupplyType__c;
        opinionCase.Contract__c = parentCase.Contract__c;


        HDT_UTL_DatabaseService.insertSObject(opinionCase);

        return;




    }

    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public Case parentCase;
    
        @InvocableVariable
        public String recordTypeOpinion;
    
    
    }



}


