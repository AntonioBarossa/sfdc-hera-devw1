public with sharing class HDT_TRH_Account extends HDT_TRH_TriggerHandler {
    
    public override void beforeInsert(){
        // List<String> listRecordTypeMarkingValue = new List<String>{'AAS Parti comuni', 'AAS Persona fisica','ACEL-Persona fisica',
        // 'ANTENORE ENERGY-Persona fisica','Amga-Persona fisica','BE POWER-Persona fisica',
        // 'BENACO-Persona fisica','BLU RANTON-Persona fisica','CMV E e I - Persona fisica',
        // 'D1 - Persona fisica','D2 - Ditta individuale','D3 - Azienda','D4 - Parti comuni',
        // 'D5 - Condominio','D6 - Associazione','D7 - BP Doppio',
        // 'D8 - Marcatura nulla','ENERGETICA-Persona fisica',
        // 'ENERGIA SOCIALE-Persona fisica','ENERGIECHIARE-Persona fisica',
        // 'ENERGYGAS ITA - Persona fisica','ENERGYPOLIS-Persona fisica',
        // 'ERMES-Persona fisica','ETRURIA-Persona fisica','Enegan-Persona fisica','EstEnergy-Persona fisica','FUTURA TR-Persona fisica', 'FUTURENERGY-Persona fisica', 'GENESI-Persona fisica','GRAN SASSO-Persona fisica', 'GREEN EN-Persona fisica','ITALIANGAS-Persona fisica','LIRENAS-Persona fisica','LUCEEG IT SERV-Persona fisica', 'MIWA ENERGIA-Persona fisica','MMS Parti comuni','MMS Persona fisica',
        // 'MOODS-Persona fisica','NEWENRGGEL-Persona fisica', 'NOIENERGIA-Persona fisica','NWGENERGIA-Persona fisica',
        // 'OMNIA EN-Persona fisica','ONE POWER-Persona fisica','ONOVA-Persona fisica','PIUENERGIA SPA-Persona fisica',
        // 'Parti comuni','Persona fisica','S4 ENERGIA-Persona fisica','SGR-Persona fisica','TOP ENERGY-Persona fisica',
        // 'UNION-Persona fisica'};
        HDT_ObjectRecordType__mdt accBus = HDT_ObjectRecordType__mdt.getInstance('Acc_CustomerMarking_HDT_RT_Business');
        HDT_ObjectRecordType__mdt accRes = HDT_ObjectRecordType__mdt.getInstance('Acc_CustomerMarking_HDT_RT_Residenziale');
        List<String> listDeniedRes = accRes.ValueToRemove__c.split(';');
        List<String> listDeniedBus = accBus.ValueToRemove__c.split(';');

        Map<String, HDT_ObjectRecordType__mdt> mcs = HDT_ObjectRecordType__mdt.getAll();
 System.debug('');
        Id accRecordTypeResId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
        Id accRecordTypeBusId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();
 
        List<Account> listAcc = (List<Account>)trigger.new;
        for (Account tempAcc : listAcc) {
            tempAcc.CustomerAccountStatus__c='Prospect';
            if (tempAcc.recordtypeId==accRecordTypeResId && listDeniedRes.contains(tempAcc.CustomerMarking__c) ) {
             tempAcc.addError('Il valore selezionato per "Marcatura" non è coerente con il tipo di record selezionato');
             }
       
            else if (tempAcc.recordtypeId==accRecordTypeBusId && listDeniedBus.contains(tempAcc.CustomerMarking__c) ) {
                 tempAcc.addError('Il valore selezionato per "Marcatura" non è coerente con il tipo di record selezionato');
            }
          
        }
         HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
         createKpiExtension();
     }
 
     protected override void beforeUpdate() {
         checkAccountName();
         createKpiExtension();
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
 
             if (!acc.Name.equals(expectedNewName)) {
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
             Datetime dt= Datetime.now().addMinutes(2);
             String cron = dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' * * ?';
 
             HDT_SCH_QueueAssignmentScheduler s = new HDT_SCH_QueueAssignmentScheduler(accts); 
             System.schedule('PartnerQueues ' + String.valueOf(Datetime.now()), cron, s);
         }
     }
 }