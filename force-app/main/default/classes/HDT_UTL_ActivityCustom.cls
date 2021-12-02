/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 18/06/2021
* @description Class that holds util functions for wrts_prcgvr__Activity__c
* @history Keltin Mesonjesi – 18/06/2021 – Created class
*/
public inherited sharing class HDT_UTL_ActivityCustom {
    
    private FINAL static string APPOINTMENTDEVELOPERNAME = 'HDT_RT_DistributorAppointment';
    private FINAL static string MODCONFERMATO = 'Modifica confermata';
    private FINAL static string APPCONFERMATO = 'Appuntamento confermato';
    private static HDT_SRV_ActivityCustom activityCustomSrv = new HDT_SRV_ActivityCustom();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_QR_Recordtype rtQr = new HDT_QR_Recordtype();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 18/06/2021
    * @description Create new wrts_prcgvr__Activity__c based on passed params
    * @param Map<String,String> params
    */
    
    @AuraEnabled
    public static boolean riassegnaComCod(string recordId,String causale){
        try{
            // HDT_QR_Case caseQr = new HDT_QR_Case();
            wrts_prcgvr__Activity__c s = HDT_QR_ActivityCustom.getRecordByIdS(recordId);
          //  Case c = caseQr.getRecordById(s.case__c);
            Case c = new Case();
            c.id = s.case__c;
            c.phase__c	='In Attesa Approvazione';
            c.ReassignmentReason__c = causale;
            caseSrv.updateRecord(c);
            system.debug('*******trueComm');
            return true;
        }catch(exception e){
            system.debug('*******falseComm:' + e);
            return false;
        }
        
    }
    @AuraEnabled
    public static boolean cambiaphaseComm(string recordId,string causale){
        try{
            HDT_QR_Case caseQr = new HDT_QR_Case();
            wrts_prcgvr__Activity__c sToCreate = new wrts_prcgvr__Activity__c();
            wrts_prcgvr__Activity__c s = HDT_QR_ActivityCustom.getRecordByIdS(recordId);
            sToCreate.account__c = s.account__c;
            sToCreate.case__c = s.case__c;
            sToCreate.recordtypeid = s.recordtypeid;
            sToCreate.approved__c = causale;
            sToCreate.type__c = 'Contratti/Bonus Commerciale';
            s.wrts_prcgvr__status__c = 'Completed';
            s.approved__c = causale;

            activityCustomSrv.updateRecord(s);
            //activityCustomSrv.createRecord(sToCreate);
            Case c = caseQr.getRecordById(s.case__c);
            c.phase__c	='In Lavorazione';
            update c;
           // caseSrv.updateRecord(c);
            return true;
        }
        catch(Exception e){
            system.debug(e);
            return false;
        }
    }

    public static void createActivityWithParams(Map<String,String> params){

        system.debug('HDT_UTL_ActivityCustom START');
        system.debug('HDT_UTL_ActivityCustom params: ' + params);

        List<Account> accountListRetrieved = new List<Account>();

        if (String.isNotBlank(params.get('FiscalCode__c')) && String.isNotBlank(params.get('VATNumber__c'))) {
            accountListRetrieved = accountQr.getAccountByFiscalCodeAndVat(params.get('FiscalCode__c'), params.get('VATNumber__c'));
        } else if(String.isNotBlank(params.get('FiscalCode__c'))){
            accountListRetrieved = accountQr.getAccountByFiscalCode(params.get('FiscalCode__c'));
        } else {
            accountListRetrieved = accountQr.getAccountByVat(params.get('VATNumber__c'));
        }

        activityCustomSrv.createRecord(new wrts_prcgvr__Activity__c(
            RecordTypeId = getRecordTypeId(params.get('RecordTypeDeveloperName')),
            Type__c = params.get('Type__c'),
            ServicePointCode__c = params.get('ServicePointCode__c'),
            Account__c = !accountListRetrieved.isEmpty() ? accountListRetrieved[0].Id : null,
            wrts_prcgvr__Status__c = params.get('wrts_prcgvr__Status__c'),
            EffectiveDate__c = String.isNotBlank(params.get('EffectiveDate__c')) ? Date.valueOf(params.get('EffectiveDate__c')) : null,
            HerokuPracticeCode__c = params.get('HerokuPracticeCode__c')
        ));

        system.debug('HDT_UTL_ActivityCustom END');
    }


    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/02/2021
    * @description Get record type ID for record types of wrts_prcgvr__Activity__c
    * @param String
    * @return String
    */
    public static String getRecordTypeId(String recordTypeDeveloperName){
        system.debug('HDT_UTL_ActivityCustom - getRecordTypeId START');
        system.debug('HDT_UTL_ActivityCustom - recordTypeDeveloperName: ' + recordTypeDeveloperName);

        List<Schema.RecordTypeInfo> recordTypes = wrts_prcgvr__Activity__c.SObjectType.getDescribe().getRecordTypeInfos();
        String recordTypeId = '';
        for (Schema.RecordTypeInfo recordType : recordTypes) {
            if (recordType.getDeveloperName() == recordTypeDeveloperName) {
                recordTypeId = recordType.getRecordTypeId();
            }
        }

        system.debug('HDT_UTL_ActivityCustom - getRecordTypeId END');
        system.debug('HDT_UTL_ActivityCustom - recordTypeId: ' + recordTypeId);

        return recordTypeId;
    }
    @AuraEnabled
    public static boolean validaActivityVocal(String recordid, String validazione){
        wrts_prcgvr__Activity__c act = HDT_QR_ActivityCustom.getRecordByIdValidation(recordid);
        act.validation__c = validazione;
        boolean res = false;
        Order ord = new Order();
        ord.id = act.order__c;
        if(validazione == 'Si'){
            act.wrts_prcgvr__status__c = 'Completed';
            res = true;
            ord.DocumentPackage__c = 'Validato';
            //ord.phase__c = 'Documentazione Gestita';
            //ord.status = 'Activated';
        }
        else{
            ord.CancellationReason__c = 'Registrazione non conforme';
        }
        orderSrv.updateRecord(ord);
        activityCustomSrv.updateRecord(act);

        return res;
        //update act;
    }

    @AuraEnabled
    public static void updateTimeRefAppointment(List<wrts_prcgvr__Activity__c> oldList,List<wrts_prcgvr__Activity__c> newList){
        Map<String,wrts_prcgvr__Activity__c> mapOld = new Map<String,wrts_prcgvr__Activity__c>();
        try {
            ID recTypeId = rtQr.getRecordTypeIdByName(APPOINTMENTDEVELOPERNAME);
            for(wrts_prcgvr__Activity__c act : oldList){
                mapOld.put(act.id,act);
            }
            for(wrts_prcgvr__Activity__c act : newList){
                if(recTypeId == act.recordtypeid){
                    if((mapOld.get(act.id).wrts_prcgvr__Status__c != MODCONFERMATO && act.wrts_prcgvr__Status__c == MODCONFERMATO) || (mapOld.get(act.id).wrts_prcgvr__Status__c != APPCONFERMATO && act.wrts_prcgvr__Status__c == APPCONFERMATO)){
                        act.DateTimeRef__c = Datetime.now();
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void checkForMandatoryAttachment(Map<Id, wrts_prcgvr__Activity__c> newActsMap){
        Id rtKoOldClient = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_KoPrecedeteCliente').getRecordTypeId();
        Set<Id> actsToCheck = new Set<Id>();

        for(wrts_prcgvr__Activity__c act : newActsMap.values()){
            if(act.recordTypeId == rtKoOldClient && act.wrts_prcgvr__Status__c=='KO Risolto' && String.isNotBlank(act.Reason__c)){
                actsToCheck.add(act.Id);
            }
        }
        List<wrts_prcgvr__Activity__c> actsWithAttachments = [select Id, (select Id from AttachedContentDocuments ) from wrts_prcgvr__Activity__c where id IN :actsToCheck WITH Security_Enforced];
        for(wrts_prcgvr__Activity__c act : actsWithAttachments){
            if(!(act.AttachedContentDocuments?.size()>0)){//if AttachedContentDocuments.isEmpty() or null
                newActsMap.get(act.id).addError('Allegare Documentazione Obbligatoria');
            }
        }
    }


    @AuraEnabled
    public static String validaActivityDocument(String recordid, String validazione){
        wrts_prcgvr__Activity__c act = HDT_QR_ActivityCustom.getRecordByIdValidation(recordid);
        
        act.validation__c = validazione;
        String res = '';
        if(validazione == 'Si'){
            act.wrts_prcgvr__status__c = 'Completed';
           // res = true;
            Order ord = new Order();
            ord.id = act.order__c;
            ord.DocumentPackage__c = 'Validato';
            ord.phase__c = 'Documentazione Gestita';
            ord.status = 'Activated';
            orderSrv.updateRecord(ord);
        }
        else{
            // Id rt = rtQr.getRecordTypeIdByName('HDT_RT_AttivitaGestionali');
            List<wrts_prcgvr__Activity__c> actCusList =  HDT_QR_ActivityCustom.getRecordByOrderIdAndType(act.order__c,'Documenti non validati');
            if(actCusList != null && !actCusList.isEmpty()){
                if(actCusList[0].wrts_prcgvr__status__c == 'Completed'){
                    act.wrts_prcgvr__status__c = 'Completed';
                    res = 'NoApprovata';
                }
                else{
                    res = 'NonChiusa';
                }
            }
            else {
                Date d = System.today();
                Date dataAnnullRich = d.addDays(30); 
                wrts_prcgvr__Activity__c act2 = new wrts_prcgvr__Activity__c(account__c = act.account__c,wrts_prcgvr__Status__c= 'Aperta',order__c = act.order__c,type__c='Documenti non validati',recordtypeid=rtQr.getRecordTypeIdByName('HDT_RT_AttivitaGestionali'),RequestedCancellationDate__c=dataAnnullRich);
                activityCustomSrv.createRecord(act2);
                res = 'Creata';
            }    
         }
        activityCustomSrv.updateRecord(act);
        return res;
        //update act;
    }

    @AuraEnabled(cacheable=true)
    public static boolean isMandatoryComplete( String recordid ){
        return HDT_QR_ActivityCustom.isActivityNotClosed(recordid);
    }
    
}