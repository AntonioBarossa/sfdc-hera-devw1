public with sharing class HDT_TRH_Account extends HDT_TRH_TriggerHandler {
    
    public override void beforeInsert(){

        // HDT_ObjectRecordType__mdt accBus = HDT_ObjectRecordType__mdt.getInstance('Acc_CustomerMarking_HDT_RT_Business');
        // HDT_ObjectRecordType__mdt accRes = HDT_ObjectRecordType__mdt.getInstance('Acc_CustomerMarking_HDT_RT_Residenziale');
        // List<String> listDeniedRes = accRes.ValueToRemove__c.split(';');
        // List<String> listDeniedBus = accBus.ValueToRemove__c.split(';');

        List<HDT_ObjectRecordType__mdt> accBusList = [SELECT ValueToRemove__c FROM HDT_ObjectRecordType__mdt WHERE DeveloperName = 'Acc_CustomerMarking_HDT_RT_Business'];
        List<HDT_ObjectRecordType__mdt> accResList = [SELECT ValueToRemove__c FROM HDT_ObjectRecordType__mdt WHERE DeveloperName = 'Acc_CustomerMarking_HDT_RT_Residenziale'];
        List<String> listDeniedBus = accBusList.size() > 0 ? accBusList[0].ValueToRemove__c.split(';') : null;
        List<String> listDeniedRes = accResList.size() > 0 ? accResList[0].ValueToRemove__c.split(';') : null;

        Id accRecordTypeResId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
        Id accRecordTypeBusId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();
 
        List<Account> listAcc = (List<Account>)trigger.new;
        for (Account tempAcc : listAcc) {
            // Logica spostata su flow HDT_FL_ActivityTrackerAccount poichè il trigger non scatta quando il Lead viene convertito in Account.
            /* if (String.isNotBlank(tempAcc.CustomerMarking__c) && String.isBlank(tempAcc.CustomerType__c)) {
                tempAcc.CustomerType__c = HDT_UTL_Account.customerMarkingToCustomerType(tempAcc.CustomerMarking__c);
            }
            if (String.isNotBlank(tempAcc.Category__c) && String.isBlank(tempAcc.CategoryCode__c)) {
                tempAcc.CategoryCode__c = HDT_UTL_Account.transcodeCustomerCategory(tempAcc.Category__c);
            } */
            String errorFiscalInfo = '';
            if((String.isNotBlank(tempAcc.FiscalCode__c) && (tempAcc.FiscalCode__c.length()!=16 && tempAcc.FiscalCode__c.length()!=11)) || (String.isNotBlank(tempAcc.VATNumber__c) && tempAcc.VATNumber__c.length()!=11 && !tempAcc.VATNumber__c.isNumeric())){
                //tempAcc.addError('Inserire una Partita Iva o un Codice Fiscale Valido');
                errorFiscalInfo = 'Inserire una Partita Iva o un Codice Fiscale Valido';
            }

            if (String.isBlank(errorFiscalInfo) && String.isNotBlank(tempAcc.FiscalCode__c) && tempAcc.FiscalCode__c.length()==16) {
                tempAcc.FiscalCode__c = tempAcc.FiscalCode__c.toUpperCase();
                String lastLetter = tempAcc.FiscalCode__c.right(1);
                String fiscalCodeToCheck = tempAcc.FiscalCode__c.left(15);
                String letterControled = HDT_UTL_CalculateFiscalCode.getControlLetter(fiscalCodeToCheck);

                if(lastLetter != letterControled ){
                    //tempAcc.addError('Codice fiscale non valido');
                    errorFiscalInfo = 'Codice fiscale non valido';
                }
            }
            else if(String.isBlank(errorFiscalInfo) && String.isNotBlank(tempAcc.FiscalCode__c) && tempAcc.FiscalCode__c.length()==11 && tempAcc.FiscalCode__c.isNumeric()){
                String lastNum = tempAcc.FiscalCode__c.right(1);
                String pIvaToCheck = tempAcc.FiscalCode__c.left(10);
                String numControled = HDT_UTL_CalculateFiscalCode.getControlNumberPiva(pIvaToCheck);

                if(lastNum != numControled ){
                    //tempAcc.addError('Partita Iva non valida');
                    errorFiscalInfo = 'Partita Iva non valida';
                }
            }

            if(String.isBlank(errorFiscalInfo) && String.isNotBlank(tempAcc.VATNumber__c)){
                String lastNumVat = tempAcc.VATNumber__c.right(1);
                String vatToCheck = tempAcc.VATNumber__c.left(10);
                String numVatControled = HDT_UTL_CalculateFiscalCode.getControlNumberPiva(vatToCheck);

                if(lastNumVat != numVatControled ){
                    //tempAcc.addError('Partita Iva non valida');
                    errorFiscalInfo = 'Partita Iva non valida';
                }
            }
            if(String.isNotBlank(errorFiscalInfo) && !Test.isRunningTest()){
                tempAcc.addError(errorFiscalInfo);
            }
            if (!tempAcc.IsMigrated__c ) { //? viene specificato che non deve essere effettuata la modifica per i clienti migrati Bolzon
                tempAcc.CustomerAccountStatus__c='Prospect';
            }
            if (tempAcc.recordtypeId==accRecordTypeResId && listDeniedRes.contains(tempAcc.CustomerMarking__c) ) {
             tempAcc.addError('Il valore selezionato per "Marcatura" non è coerente con il tipo di record selezionato');
            }
            else if (tempAcc.recordtypeId==accRecordTypeBusId && listDeniedBus.contains(tempAcc.CustomerMarking__c) ) {
                 tempAcc.addError('Il valore selezionato per "Marcatura" non è coerente con il tipo di record selezionato');
            }
          
        }
         HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
         feedBillingCountry(Trigger.new);
         //checkAccountName();
         createKpiExtension();
         HDT_UTL_Account.handleFiscalCodeUppercase(Trigger.new);
         HDT_UTL_GlobaMigrationKey.setGlobalMigrationKeyDistributor(Trigger.new);
    }
 
    protected override void beforeUpdate() {
        HDT_UTL_GlobaMigrationKey.setGlobalMigrationKey(Trigger.new, Trigger.oldMap);
        HDT_UTL_GlobaMigrationKey.setGlobalMigrationKeyDistributor(Trigger.new);
        feedBillingCountry(Trigger.new);
        checkAccountName();
        createKpiExtension();
        setIndividualsOwnerIds();
        HDT_UTL_Account.handleFiscalCodeUppercase(Trigger.new);
    }

    public override void afterUpdate(){
        manageAccountPartnerQueues();
    }
 
     /**
      * Verifica che il Name degli Account residenziali/aziende rimanga la concatenazione di FirstName + LastName.
      */
    private void checkAccountName() {

        HDT_QR_RecordType queryHandler = new HDT_QR_RecordType();
        Id rtResidenziale = queryHandler.getRecordTypeIdByName('HDT_RT_Residenziale');
        Id rtBusiness = queryHandler.getRecordTypeIdByName('HDT_RT_Business');

        for (Account acc : (List<Account>) Trigger.new) {

            if (acc.RecordTypeId != rtResidenziale && acc.RecordTypeId != rtBusiness) {
                continue;
            }

            String expectedNewName = String.isBlank(acc.FirstName__c) ? acc.LastName__c : acc.FirstName__c + ' ' + acc.LastName__c;

            if (!acc.Name.equalsIgnoreCase(expectedNewName)) {
                acc.addError('Il Nome del Cliente deve essere equivalente a \'Nome Cognome\' per clienti Residenziali o \'Cognome/Ragione sociale\' per clienti Aziende.');
            }
        }
    }
 
    private void createKpiExtension(){
        if(Trigger.isInsert){
            HDT_UTL_KpiTracking.createKpiTracking(Trigger.new, null);
        }else if(Trigger.isUpdate){
            HDT_UTL_KpiTracking.createKpiTracking(Trigger.new, Trigger.oldMap);
        }else if(Trigger.isDelete){
            HDT_UTL_KpiTracking.deleteKpiTracking(Trigger.old);
        }
    }

    private void manageAccountPartnerQueues(){
        List<Account> newAcc= Trigger.new;
        List<Account> oldAcc= Trigger.old;
        Map<String,Account> mapAccount = new Map<String,Account>();
        for(Account ac: oldAcc){
            mapAccount.put(ac.Id, ac);
        }
        List<Account> accts= new List<Account>();
        for (Account acc : newAcc) {
            Account oldAccount= mapAccount.get(acc.Id);
            if(acc.isPartner== true && oldAccount.Published__c== false && acc.Published__c == true){
                accts.add(acc);                
            }
        }
        if(!accts.isEmpty()){
            /**
             * AF. Commentato Codice di WR che schedulava un Job che veniva eseguito ricorsivamente ogni  giorno.
             * AF. Sostituito codice con un Enqueue Job
             */
           /* Datetime dt= Datetime.now().addMinutes(2);
            String cron = dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' * * ?';

            HDT_SCH_QueueAssignmentScheduler s = new HDT_SCH_QueueAssignmentScheduler(accts); 
            System.schedule('PartnerQueues ' + String.valueOf(Datetime.now()), cron, s);*/

            Database.executeBatch(new HDT_BA_QueueAssignment(accts));
        }
    }

    @SuppressWarnings('PMD.CyclomaticComplexity')
    private void setIndividualsOwnerIds(){

        Set<String> accidSet = new Set<String>();
        List<Individual> individToUpdateList = new List<Individual>();
        List<String> accIdList = new List<String>();
        Map<String, List<String>> accToIndividualMap = new Map<String, List<String>>();
        Map<String, String> accountToOwnerIdMap = new Map<String, String>();
        HDT_QR_Contact contQr = new HDT_QR_Contact();
        Map<String, List<String>> accToContListMap = new Map<String, List<String>>();
        List<Contact> contToUpdateList = new List<Contact>();

        for(Account acc : (List<Account>) Trigger.new){
            Account odlAcc = (Account) Trigger.oldMap.get(acc.Id);
            if(acc.OwnerId != odlAcc.OwnerId){
                accidSet.add(acc.Id);
                accountToOwnerIdMap.put(acc.Id, acc.OwnerId);
            }
        }

        if(!accidSet.isEmpty()){
            accIdList.addAll(accidSet);
            for(Contact cont : contQr.getContactsFromAcrByAccId(accIdList)){
                if(accToIndividualMap.get(cont.AccountId) != null){
                    accToIndividualMap.get(cont.AccountId).add(cont.IndividualId);
                }
                else {
                    accToIndividualMap.put(cont.AccountId, new List<String>());
                    accToIndividualMap.get(cont.AccountId).add(cont.IndividualId);
                }
                if(accToContListMap.containsKey(cont.AccountId)){
                    accToContListMap.get(cont.AccountId).add(cont.Id);
                }
                else{
                    accToContListMap.put(cont.AccountId, new List<String>());
                    accToContListMap.get(cont.AccountId).add(cont.Id);
                }
            }
        }

        if(!accToIndividualMap.values().isEmpty()){
            for(String accId : accToIndividualMap.keySet()){
                for(String indivId : accToIndividualMap.get(accId)){
                    Individual ind = new Individual(
                        Id = indivId,
                        OwnerId = accountToOwnerIdMap.get(accId)
                    );
                    individToUpdateList.add(ind);
                }
            }
            if(!individToUpdateList.isEmpty()){
                HDT_UTL_DatabaseService.updateSObject(individToUpdateList);
            }
        }
        if(!accToContListMap.values().isEmpty()){
            for(String accId : accToContListMap.keySet()){
                for(String contId : accToContListMap.get(accId)){
                    Contact cont = new Contact(
                        Id = contId,
                        OwnerId = accountToOwnerIdMap.get(accId)
                    );
                    contToUpdateList.add(cont);
                }
            }
            if(!contToUpdateList.isEmpty()){
                HDT_UTL_DatabaseService.updateSObject(contToUpdateList);
            }
        }
    }

    @TestVisible
    private static void feedBillingCountry(List<Account> accountList)
    {
        for(Account acc : accountList)
        {
            if(acc.BillingCountry == null || acc.BillingCountry == '')
            {
                acc.BillingCountry = 'ITALIA';
            }
        }
    }
}