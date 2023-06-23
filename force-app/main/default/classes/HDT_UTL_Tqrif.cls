public with sharing class HDT_UTL_Tqrif {

    private static HDT_QR_Account qrAccount = new HDT_QR_Account();
    private static HDT_UTL_GarbageMan utlGarbage = new HDT_UTL_GarbageMan();

    private List<String> fieldsName = new List<String>
    {
        'CardKey1__c',
        'CardKey2__c',
        'CardKey3__c',
        'CardKey4__c',
        'GarbageBag1__c',
        'GarbageBag2__c',
        'GarbageBag3__c',
        'GarbageBag4__c',
        'GarbageBin1__c',
        'GarbageBin2__c',
        'GarbageBin3__c',
        'GarbageBin4__c',
        'GarbageBin5__c',
        'GarbageBin6__c',
        'GarbageBin7__c'
    };
    
    public List<Case> createEquipmentHandler(Case theCase){
        List<Case> casesToCreate = new List<Case>();
        Set<String> equipmentCodes = getEquipmentCodes(theCase.Id);
        system.debug(equipmentCodes);
        List<AggregateResult> volumetrics = [   SELECT MIN(Volumetry__c) volMin, MAX(Volumetry__c) volMax 
                                                FROM Equipment__c 
                                                WHERE 
                                                    Contract__c = :theCase.Contract__c AND
                                                    EquipmentCode__c IN :equipmentCodes
                                                WITH SECURITY_ENFORCED Group By Contract__c];
        if(volumetrics.isEmpty()){   return casesToCreate;  }

        List<Account> accs = qrAccount.getAccountById(theCase.AccountId);

        if(
            Integer.valueOf(volumetrics[0].get('volMin')) < 120 
            || 'Domicilio'.equalsIgnoreCase(theCase.Consegna_Restituzione_dotazioni__c)
        ){
            //crea case GestDot
            Case gestDot = initCase(theCase, accs[0]);
            casesToCreate.add(gestDot);
        }

        if(
            Integer.valueOf(volumetrics[0].get('volMax')) >= 120
            && !'Domicilio'.equalsIgnoreCase(theCase.Consegna_Restituzione_dotazioni__c)
        ){
            //crea altro case GestDot
            Case gestDot = initCase(theCase, accs[0]);
            casesToCreate.add(gestDot);
        }

        return casesToCreate;
    }

    private Set<String> getEquipmentCodes(Id caseId){
        Set<String> equipmentCodes = new Set<String>();
        List<ProcessEquipment__c> proc = getProcessEquipment(caseId);
        if(proc.isEmpty()){     return null;     }
        for(String oldField : fieldsName){
            String code = STRING.valueOf(proc[0].get('Old'+oldField));
            if(STRING.isNotBlank(code)){    equipmentCodes.add(code);    }
        }
        return equipmentCodes;
    }

    private List<ProcessEquipment__c> getProcessEquipment(Id caseId){
        String query = 'SELECT ' +
            'Old'+STRING.join(fieldsName, ', Old') +', ' + //aggiunta desinenza Old
            'New' + STRING.join(fieldsName, ', New') +' ' +//aggiunta desinenza New
            ' FROM ProcessEquipment__c ' +
            ' WHERE Case__c =:caseId ' +
            'WITH SECURITY_ENFORCED ';

        system.debug(query);
        return (List<ProcessEquipment__c>) Database.query(STRING.escapeSingleQuotes(query));
    }

    private Case initCase(Case parentCase, Account account){//parentCase query on HDT_QR_HerokuPostSalesManager
        Case theCase = new Case();
        theCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();
        theCase.Cluster__c = 'Segnalazioni';
        theCase.Type = 'Gestione Dotazioni';
        theCase.Origin = parentCase.Origin;
        theCase.Commodity__c = 'Ambiente';
        theCase.Phase__c = 'Bozza';
        theCase.Status = 'Bozza';
        theCase.ServicePoint__c = parentCase.ServicePoint__c;
        theCase.Contract__c = parentCase.Contract__c;
        theCase.RelatedCase__c = parentCase.Id;

        List<AccountContactRelation> accContactRels = utlGarbage.getContactRelation(account?.Id);
        if(!accContactRels.isEmpty()){
            AccountContactRelation accContactRel = accContactRels[0];
            theCase.AccountId = account.Id;
            theCase.CompanyOwner__c = account.CompanyOwner__c;
            theCase.ContactId = accContactRel.ContactId;
            theCase.SuppliedEmail = accContactRel.Contact.Email;
            theCase.SuppliedPhone = accContactRel.Contact.MobilePhone;
            theCase.BillingCity__c = account.BillingPlace__c;
        }
        
        return theCase;
    }
}