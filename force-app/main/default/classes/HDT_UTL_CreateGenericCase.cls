public inherited sharing class HDT_UTL_CreateGenericCase {

    //HDT_QR_CreateGenericCase cgcQr = new HDT_QR_CreateGenericCase();

    public List<Case> createCaseFromCase(Map<String, Object> inputs){

        String recordTypeId = (String) inputs.get('recordTypeId');
        String caseType = (String) inputs.get('type');
        String caseCluster = (String) inputs.get('cluster');
        Case parentCase = (Case) inputs.get('inputSObj');

        List<Case> childCases = new List<Case>();
        Map<String, Object> populateFields = new Map<String, Object>();
        Set<String> fieldExcludeList = new Set<String>
            {
                'LastModifiedDate', 
                'Id', 
                'SystemModstamp', 
                'Phase__c', 
                'Status',
                'Cluster__c',
                'Type',
                'RecordTypeId'
            };
        Case childCase = new Case();
        
        populateFields = parentCase.getPopulatedFieldsAsMap();
        
        for(String fieldName : populateFields.keySet()){
            try{
                if(!fieldExcludeList.contains(fieldName)){

                    childCase.put(fieldName, populateFields.get(fieldName));

                }
            }catch(Exception e){
                System.debug('Exception--> '+e.getMessage());

            }   

        }
        
        System.debug('RecordTypeId' +recordTypeId);

        childCase.put('Phase__c', 'Bozza');
        childCase.put('Status', 'New');
        childCase.put('Cluster__c', caseCluster);
        childCase.put('Type',caseType);
        childCase.put('RecordTypeId', recordTypeId);
        childCase.put('ParentId',parentCase.Id);

        /*newCase.Type = caseType;
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
        newCase.ParentId = currentCase.Id;*/


        childCases.add(childCase);

        return childCases;
    }

        /**
     * Crea un Case da un Order. Input obbligatori:
     * - recordTypeId
     * - cluster
     * - type
     * - inputSObj
     */
    public Case createCaseFromOrder(Map<String, Object> inputs){

        String recordTypeId = (String) inputs.get('recordTypeId');
        String caseType = (String) inputs.get('type');
        String caseCluster = (String) inputs.get('cluster');
        Order parentOrder = (Order) inputs.get('inputSObj');

        if (String.isBlank(recordTypeId) || String.isBlank(caseCluster) || String.isBlank(caseType) || parentOrder == null) {
            System.debug('HDT_UTL_CreateGenericCase::createCaseFromOrder - invalid inputs: ' + inputs);
            return null;
        }

        Case newCase = new Case();

        newCase.AccountId = parentOrder.AccountId;
        newCase.ContactId = parentOrder.Contact__c;
        newCase.RecordTypeId = recordTypeId;
        newCase.Type = caseType;
        newCase.Cluster__c = caseCluster;

        newCase.Phase__c = 'Bozza';

        return newCase;
    }

    /**
     * Crea un Case da zero. Input obbligatori:
     * - recordTypeId
     * - cluster
     * - type
     * - accountId
     * - contactId
     */
    public Case createCase(Map<String, Object> inputs){

        String recordTypeId = (String) inputs.get('recordTypeId');
        String caseType = (String) inputs.get('type');
        String caseCluster = (String) inputs.get('cluster');
        String accountId = (String) inputs.get('accountId');
        String contactId = (String) inputs.get('contactId');

        if (String.isBlank(recordTypeId) || String.isBlank(accountId) || String.isBlank(caseCluster) || String.isBlank(caseType)) {
            System.debug('HDT_UTL_CreateGenericCase::createCase - invalid inputs: ' + inputs);
            return null;
        }

        Case newCase = new Case();

        newCase.AccountId = accountId;
        newCase.ContactId = contactId;
        newCase.RecordTypeId = recordTypeId;
        newCase.Type = caseType;
        newCase.Cluster__c = caseCluster;
        newCase.WrittenReceiptRequestDate__c = Date.today();

        newCase.Phase__c = 'Bozza';

        return newCase;
    }


}
