public with sharing class HDT_UTL_GlobaMigrationKey {
    
    public static void setGlobalMigrationKey(List<Sobject> newObjList, Map<Id,SObject> oldObjMap){
        for (SObject obj :newObjList){
            Id recordId = (Id)obj.get('Id');
            String fieldToCheck = getSapCodeField(recordId);
            String newCodiceSap = obj.get(fieldToCheck) != null ? (String) obj.get(fieldToCheck) : '';
            String oldCodiceSap = (String) oldObjMap.get(recordId).get(fieldToCheck);
            /* Aggiunta casistica in cui i codici sap old/new non sono differenti ma la global migration key e' nulla */
            if  (!newCodiceSap.equalsIgnoreCase(oldCodiceSap) || (String.isNotBlank(newCodiceSap) && obj.get('GlobalMigrationKey__c') == null)){
                obj.put('GlobalMigrationKey__c',setMigrationKey(recordId, newCodiceSap));
            }
        }
    }

    /**
     * Metodo che aggiorna la chiave di migrazione sugli Account di tipo distributore**/
    public static void setGlobalMigrationKeyDistributor(List<Account> newAccountList){
        for(Account singleAccount : newAccountList){
            //If is distributor
            if(String.isNotBlank(singleAccount.Code__c)){
                singleAccount.GlobalMigrationKey__c = singleAccount.Code__c;
            }
        }
    }

    private static String getSapCodeField(Id recordId){
        if (recordId.getSobjectType() == Schema.Account.getSobjectType()){
                return 'CustomerCode__c';
        }else if (recordId.getSobjectType() == Schema.BillingProfile__c.getSobjectType()){
            return 'ContractAccountCode__c';
        }else if (recordId.getSobjectType() == Schema.ServicePoint__c.getSobjectType()){
            return 'SAPImplantCode__c';
        }else if (recordId.getSobjectType() == Schema.Contract.getSobjectType()){
            return 'SAPContractCode__c';
        }
        throw new HDT_UTL_HeraException('Non è prevista la gestione dell\'object type ' + recordId.getSobjectType());
    }

    private static String setMigrationKey(Id recordId, String codiceSap){
        if (String.isEmpty(codiceSap)){
            return '';
        }if (recordId.getSobjectType() == Schema.Account.getSobjectType()){
            return 'A_'+codiceSap;
        }else if (recordId.getSobjectType() == Schema.BillingProfile__c.getSobjectType()){
            return 'BP_'+codiceSap;
        }else if (recordId.getSobjectType() == Schema.ServicePoint__c.getSobjectType()){
            return 'SP_'+codiceSap;
        }else if (recordId.getSobjectType() == Schema.Contract.getSobjectType()){
            return 'CO_'+codiceSap;
        }
        throw new HDT_UTL_HeraException('Non è prevista la gestione dell\'object type ' + recordId.getSobjectType());
    }
}
