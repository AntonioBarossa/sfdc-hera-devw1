public with sharing class HDT_TRH_Account extends HDT_TRH_TriggerHandler {
    
    public override void beforeInsert(){

        HDT_ObjectRecordType__mdt accBus = HDT_ObjectRecordType__mdt.getInstance('Acc_CustomerMarking_HDT_RT_Business');
        HDT_ObjectRecordType__mdt accRes = HDT_ObjectRecordType__mdt.getInstance('Acc_CustomerMarking_HDT_RT_Residenziale');
        List<String> listDeniedRes = accRes.ValueToRemove__c.split(';');
        List<String> listDeniedBus = accBus.ValueToRemove__c.split(';');

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
         createKpiExtension();
         HDT_UTL_Account.handleFiscalCodeUppercase(Trigger.new);
    }
 
    protected override void beforeUpdate() {
        HDT_UTL_GlobaMigrationKey.setGlobalMigrationKey(Trigger.new, Trigger.oldMap);
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

        for(Account acc : (List<Account>) Trigger.new){
            Account odlAcc = (Account) Trigger.oldMap.get(acc.Id);
            if(acc.OwnerId != odlAcc.OwnerId){
                accidSet.add(acc.Id);
                accountToOwnerIdMap.put(acc.Id, acc.OwnerId);
            }
        }

        if(!accidSet.isEmpty()){
            accIdList.addAll(accidSet);
            for(Contact cont : contQr.getContactsIdByAccountIdList(accIdList)){
                if(accToIndividualMap.get(cont.AccountId) != null){
                    accToIndividualMap.get(cont.AccountId).add(cont.IndividualId);
                }
                else {
                    accToIndividualMap.put(cont.AccountId, new List<String>());
                    accToIndividualMap.get(cont.AccountId).add(cont.IndividualId);
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