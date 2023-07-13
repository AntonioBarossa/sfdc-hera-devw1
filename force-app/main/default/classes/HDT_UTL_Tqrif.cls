public with sharing class HDT_UTL_Tqrif {

    private ProcessEquipment__c parentProcessEquipment;

    private static HDT_QR_Account qrAccount = new HDT_QR_Account();
    private static HDT_QR_Equipment qrEquipment = new HDT_QR_Equipment();
    private static HDT_UTL_GarbageMan utlGarbage = new HDT_UTL_GarbageMan();

    public List<String> fieldsName = new List<String>
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


    
    public void startProcess(Case theCase){
        getProcessEquipment(theCase.Id);
        Set<String> equipmentCodes = getEquipmentCodes(theCase.Id);
        system.debug(equipmentCodes);
        List<Case> casesToInsert = createEquipmentHandler(theCase, equipmentCodes);

        if(casesToInsert.isEmpty()){   return;    }
        HDT_UTL_DatabaseService.insertSObject(casesToInsert);
        List<ProcessEquipment__c> preqs = new List<ProcessEquipment__c>();

        if(casesToInsert.size()==1){
            ProcessEquipment__c preq = parentProcessEquipment.clone(false, false, false, false);
            preq.Case__c = casesToInsert[0].Id;
            preqs.add(preq);

        }else{

            preqs.addAll(
                getMultipleProcessEquipment(casesToInsert, qrEquipment.getEquipmentByCodes(equipmentCodes, theCase.Contract__c))
            );
        }

        if(!preqs.isEmpty()){   HDT_UTL_DatabaseService.insertSObject(preqs);   }
    }

    @SuppressWarnings('PMD.LocalVariableNamingConventions')
    private List<ProcessEquipment__c> getMultipleProcessEquipment(List<Case> casesInserted, Map<String, Equipment__c> codeToEquipment){
        ProcessEquipment__c under120 = new ProcessEquipment__c(Case__c=casesInserted[0].Id);
        ProcessEquipment__c over120 = new ProcessEquipment__c(Case__c=casesInserted[1].Id);
        List<ProcessEquipment__c> preqs = new List<ProcessEquipment__c>{under120, over120};


        for(String oldField : fieldsName){
            String code = STRING.valueOf(parentProcessEquipment.get('Old'+oldField));
            if(STRING.isBlank(code)){       continue;       }

            Equipment__c eq = codeToEquipment.get(code);
            if(eq==null){       continue;       }

            String newFieldValue = STRING.valueOf(parentProcessEquipment.get('New'+oldField));

            if(eq.Volumetry__c < 120){      under120.put('Old'+oldField, code);under120.put('New'+oldField, newFieldValue);     }
            else{      over120.put('Old'+oldField, code);over120.put('New'+oldField, newFieldValue);     }
        }

        return preqs;
    }
    
    @TestVisible
    private List<Case> createEquipmentHandler(Case theCase, Set<String> equipmentCodes){
        List<Case> casesToCreate = new List<Case>();
        if(equipmentCodes.isEmpty()){   return casesToCreate;  }

        List<AggregateResult> volumetrics = qrEquipment.getAggregatesInfosByCodes(equipmentCodes, theCase.Contract__c);
        if(volumetrics.isEmpty()){   return casesToCreate;  }

        List<Account> accs = qrAccount.getAccountById(theCase.AccountId);

        if(
            Integer.valueOf(volumetrics[0].get('volMin')) < 120 
            || 'Domicilio'.equalsIgnoreCase(theCase.EquipmentDeliveryOption__c)
        ){
            //crea case GestDot
            Case gestDot = initCase(theCase, accs[0]);
            casesToCreate.add(gestDot);
        }

        if(
            Integer.valueOf(volumetrics[0].get('volMax')) >= 120
            && !'Domicilio'.equalsIgnoreCase(theCase.EquipmentDeliveryOption__c)
        ){
            //crea altro case GestDot
            Case gestDot = initCase(theCase, accs[0]);
            casesToCreate.add(gestDot);
        }

        return casesToCreate;
    }

    @TestVisible
    private Set<String> getEquipmentCodes(Id caseId){
        Set<String> equipmentCodes = new Set<String>();
        if(parentProcessEquipment == null){     return null;     }
        for(String oldField : fieldsName){
            String code = STRING.valueOf(parentProcessEquipment.get('Old'+oldField));
            if(STRING.isNotBlank(code)){    equipmentCodes.add(code);    }
        }
        return equipmentCodes;
    }

    @TestVisible
    private void getProcessEquipment(Id caseId){
        String query = 'SELECT ' +
            'Old'+STRING.join(fieldsName, ', Old') +', ' + //aggiunta desinenza Old
            'New' + STRING.join(fieldsName, ', New') +' ' +//aggiunta desinenza New
            ' FROM ProcessEquipment__c ' +
            ' WHERE Case__c =:caseId ' +
            'WITH SECURITY_ENFORCED ';

        system.debug(query);
        List<ProcessEquipment__c> processes = (List<ProcessEquipment__c>) Database.query(STRING.escapeSingleQuotes(query));
        if(!processes.isEmpty()){    this.parentProcessEquipment = processes[0];   }
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
        theCase.ParentId = parentCase.Id;
        theCase.AccountId = account?.Id;

        List<AccountContactRelation> accContactRels = utlGarbage.getContactRelation(account?.Id);
        if(!accContactRels.isEmpty()){
            AccountContactRelation accContactRel = accContactRels[0];
            theCase.CompanyOwner__c = account.CompanyOwner__c;
            theCase.ContactId = accContactRel.ContactId;
            theCase.SuppliedEmail = accContactRel.Contact.Email;
            theCase.SuppliedPhone = accContactRel.Contact.MobilePhone;
            theCase.BillingCity__c = account.BillingPlace__c;
        }
        
        return theCase;
    }
}