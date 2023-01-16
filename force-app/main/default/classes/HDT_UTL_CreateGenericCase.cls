public inherited sharing class HDT_UTL_CreateGenericCase {

    //HDT_QR_CreateGenericCase cgcQr = new HDT_QR_CreateGenericCase();

    /*
    * @Author: Salvatore A. Sarà 21/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public List<Case> createCaseFromCase(Map<String, Object> inputs){

        String recordTypeId = (String) inputs.get('recordTypeId');
        String caseType = (String) inputs.get('type');
        String caseCluster = (String) inputs.get('cluster');
        Case parentCase = (Case) inputs.get('inputSObj');
        User currentUser=new User();

        if (caseType=='Riattivazione Fornitura') {
            string uid=UserInfo.getUserId();
            currentUser=HDT_QR_UserQueries.getCurrentUser(uid);
        }

        List<Case> childCases = new List<Case>();
        Map<String, Object> populateFields = new Map<String, Object>();
        Set<String> fieldExcludeList = new Set<String>
            {
                'LastModifiedDate', 
                'Id', 
                'SystemModstamp', 
                'Phase__c', 
                'PhaseStory__c', 
                'Status',
                'Cluster__c',
                'DistributorNote__c',
                'Type',
                'Subprocess__c',
                'RecordTypeId',
                'ServiceRequestID__c',
                'CreatedDate',
                'CreatedById',
                'OwnerId',
                'LastModifiedById',
                'Origin'
            };
        Case childCase = new Case();
        
        populateFields = parentCase.getPopulatedFieldsAsMap();
        
        for(String fieldName : populateFields.keySet()){
            try{
                if(!fieldExcludeList.contains(fieldName)){
                    childCase.put(fieldName, populateFields.get(fieldName));
                }
            }catch(Exception e){
                System.debug(LoggingLevel.DEBUG,'Exception--> '+e.getMessage());
            }
        }
        
        System.debug(LoggingLevel.DEBUG,'RecordTypeId' +recordTypeId);

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

    /*
    * @Author: Salvatore A. Sarà 21/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public Case createCaseFromOrder(Map<String, Object> inputs){

        String recordTypeId = (String) inputs.get('recordTypeId');
        String caseType = (String) inputs.get('type');
        String caseCluster = (String) inputs.get('cluster');
        Order parentOrder = (Order) inputs.get('inputSObj');

        if (String.isBlank(recordTypeId) || String.isBlank(caseCluster) || String.isBlank(caseType) || parentOrder == null) {
            System.debug(LoggingLevel.DEBUG,'HDT_UTL_CreateGenericCase::createCaseFromOrder - invalid inputs: ' + inputs);
            return null;
        }

        Case newCase = new Case();

        newCase.RecordTypeId = recordTypeId;
        newCase.Type = caseType;
        newCase.Cluster__c = caseCluster;
        newCase.Phase__c = 'Bozza';

        newCase.AccountId = parentOrder.AccountId;
        newCase.ContactId = parentOrder.Contact__c;
        newCase.CompanyOwner__c = parentOrder.CompanyOwner__c;
        newCase.Order__c = parentOrder.Id;
        // Campi sezione Dati Residenza
        newCase.BillingCity__c = parentOrder.ResidentialCity__c;
        newCase.BillingCityCode__c = parentOrder.ResidentialCityCode__c;
        newCase.BillingCountry__c = parentOrder.ResidentialCountry__c;
        newCase.BillingIsAddressVerified__c = parentOrder.ResidentialIsAddressVerified__c;
        newCase.BillingPlace__c = parentOrder.ResidentialPlace__c;
        newCase.BillingPostalCode__c = parentOrder.ResidentialPostalCode__c;
        newCase.BillingProvince__c = parentOrder.ResidentialState__c;
        newCase.BillingStreetName__c = parentOrder.ResidentialStreetName__c;
        newCase.BillingStreetNumber__c = parentOrder.ResidentialStreetNumber__c;
        // Campi sezione Dati Esazione
        newCase.BillingProfile__c = parentOrder.BillingProfile__c;
        newCase.InvoicingCity__c = parentOrder.BillingCity__c;
        newCase.InvoicingCityCode__c = parentOrder.BillingCityCode__c;
        newCase.InvoicingCountry__c = parentOrder.BillingCountry__c;
        newCase.IsInvoicingVerified__c = parentOrder.BillingIsAddressVerified__c;
        newCase.InvoicingPlace__c = parentOrder.BillingPlace__c;
        newCase.InvoicingPostalCode__c = parentOrder.BillingPostalCode__c;
        newCase.InvoicingProvince__c = parentOrder.BillingProvince__c;
        newCase.InvoicingStreetName__c = parentOrder.BillingStreetName__c;
        newCase.InvoicingStreetNumber__c = parentOrder.BillingStreetNumber__c;
        // Campi sezione Dati Fornitura
        newCase.SupplyCity__c = parentOrder.SupplyCity__c;
        newCase.SupplyCityCode__c = parentOrder.SupplyCityCode__c;
        newCase.SupplyCountry__c = parentOrder.SupplyCountry__c;
        newCase.SupplyIsAddressVerified__c = parentOrder.SupplyIsAddressVerified__c;
        newCase.SupplyPlace__c = parentOrder.SupplyPlace__c;
        newCase.SupplyPlaceCode__c = parentOrder.SupplyPlaceCode__c;
        newCase.SupplyPostalCode__c = parentOrder.SupplyPostalCode__c;
        newCase.SupplyProvince__c = parentOrder.SupplyState__c;
        newCase.SupplyStreetName__c = parentOrder.SupplyStreetName__c;
        newCase.SupplyStreetNumber__c = parentOrder.SupplyStreetNumber__c;
        newCase.SupplyType__c = parentOrder.SupplyType__c;
        // Campi sezione Tributi e Dati Commerciali
        newCase.TaxRate__c = parentOrder.VAT__c;
        newCase.AtecoCode__c = parentOrder.AtecoCode__c;
        newCase.Market__c = parentOrder.Market__c;
        newCase.Contract__c = parentOrder.ContractId;
        newCase.ServicePoint__c = parentOrder.ServicePoint__c;
        // Campi sezione Altri Dati
        newCase.Disconnectable__c = parentOrder.Disconnectable__c;
        newCase.OfficeSubjectCode__c = parentOrder.SubjectCode__c;
        newCase.DistributorCode__c = parentOrder.DistributorCode__c;
        newCase.FirstName__c = parentOrder.CustomerName__c;
        newCase.LastName__c = parentOrder.CustomerLastName__c;
        newCase.VatNumber__c = parentOrder.CustomerVATNumber__c;
        newCase.FiscalCode__c = parentOrder.CustomerFiscalCode__c;
        newCase.Resident__c = parentOrder.Resident__c;
        if (parentOrder.Contact__c != null) {
            newCase.PhoneNumber__c = parentOrder.Contact__r.MobilePhone != null ? parentOrder.Contact__r.MobilePhone : parentOrder.Contact__r.Phone;
            newCase.Email__c = parentOrder.Contact__r.Email;
        }

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

    /*
    * @Author: Salvatore A. Sarà 21/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public Case createCase(Map<String, Object> inputs){

        String recordTypeId = (String) inputs.get('recordTypeId');
        String caseType = (String) inputs.get('type');
        String caseCluster = (String) inputs.get('cluster');
        String accountId = (String) inputs.get('accountId');
        String contactId = (String) inputs.get('contactId');
        String companyOwner = (String) inputs.get('companyOwner');
        String servicePointId = (String) inputs.get('servicePointId');
        String herokuCode = (String) inputs.get('HerokuPracticeCode__c');

        if (String.isBlank(recordTypeId) || String.isBlank(accountId) || String.isBlank(caseCluster) || String.isBlank(caseType)) {
            System.debug(LoggingLevel.DEBUG,'HDT_UTL_CreateGenericCase::createCase - invalid inputs: ' + inputs);
            return null;
        }

        Case newCase = new Case();

        newCase.AccountId = accountId;
        newCase.ContactId = contactId;
        newCase.CompanyOwner__c = companyOwner;
        newCase.RecordTypeId = recordTypeId;
        newCase.ServicePoint__c = servicePointId;
        newCase.Type = caseType;
        newCase.Cluster__c = caseCluster;
        newCase.WrittenReceiptRequestDate__c = Date.today();
        newCase.HerokuPracticeCode__c = herokuCode;

        newCase.Phase__c = 'Bozza';

        return newCase;
    }

}