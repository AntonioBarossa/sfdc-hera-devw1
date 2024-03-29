/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 18/06/2021
* @description Class that holds util functions for wrts_prcgvr__Activity__c
* @history Keltin Mesonjesi – 18/06/2021 – Created class
*/

@SuppressWarnings('PMD.CyclomaticComplexity, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces, PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ActivityCustom {

    public final Static String ANNULLAMENTO_SIEBEL = 'Annullamento processo transitorio Siebel';
    public final Static String CONTRATTO_NON_RICHIESTO = 'Contratto non richiesto da gestire';
    
    private FINAL static string APPOINTMENTDEVELOPERNAME = 'HDT_RT_DistributorAppointment';
    private FINAL static string MODCONFERMATO = 'Modifica confermata';
    private FINAL static string APPCONFERMATO = 'Appuntamento confermato';
    private static HDT_SRV_ActivityCustom activityCustomSrv = new HDT_SRV_ActivityCustom();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_QR_Recordtype rtQr = new HDT_QR_Recordtype();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 18/06/2021
    * @description Create new wrts_prcgvr__Activity__c based on passed params
    * @param Map<String,String> params
    */
    
    @AuraEnabled
    public static boolean riassegnaComCod(string recordId,String causale){
        try{
            List<SObject> sobjToUpdate = new List<SObject>();
            // HDT_QR_Case caseQr = new HDT_QR_Case();
            wrts_prcgvr__Activity__c s = HDT_QR_ActivityCustom.getRecordByIdS(recordId);
          //  Case c = caseQr.getRecordById(s.case__c);
            Case c = new Case();
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            c.id = s.case__c;
            c.phase__c	='In Attesa Approvazione';
            c.ReassignmentReason__c = causale;
            activity.Id = s.Id;
            activity.wrts_prcgvr__Description__c = causale;
            sobjToUpdate.add(c);
            sobjToUpdate.add(activity);
            HDT_UTL_DatabaseService.updateSObject(sobjToUpdate);
            System.debug(LoggingLevel.DEBUG,'*******trueComm');
            return true;
        }catch(exception e){
            System.debug(LoggingLevel.DEBUG,'*******falseComm:' + e);
            return false;
        }
        
    }
    @AuraEnabled
    public static boolean cambiaphaseComm(string recordId,string causale){
        try{
            HDT_QR_Case caseQr = new HDT_QR_Case();
            List<SObject> sobjToUpdate = new List<SObject>();
            //wrts_prcgvr__Activity__c sToCreate = new wrts_prcgvr__Activity__c();
            wrts_prcgvr__Activity__c s = HDT_QR_ActivityCustom.getRecordByIdS(recordId);
            // sToCreate.account__c = s.account__c;
            // sToCreate.case__c = s.case__c;
            // sToCreate.recordtypeid = s.recordtypeid;
            // sToCreate.approved__c = causale;
            // sToCreate.type__c = 'Contratti/Bonus Commerciale';
            wrts_prcgvr__Activity__c activity = HDT_UTL_Scarti.closeDiscardActivity(s.Id);
            activity.ClosingNote__c = causale;
            sobjToUpdate.add(activity);
            //activityCustomSrv.createRecord(sToCreate);
            Case c = new Case();
            c.Id = s.Case__c;
            c.phase__c	='In Lavorazione';
            c.Note__c = causale;
            sobjToUpdate.add(c);

            HDT_UTL_DatabaseService.updateSObject(sobjToUpdate);

            Set<String> idToNotificate = new Set<String>();
            idToNotificate.add(s.CreatedById);
            HDT_UTL_NewsNotificationCenter.fireNotification('Attivita Chiusa', 'L\'Attivita è stata '+causale, activity.Id, idToNotificate);

           // caseSrv.updateRecord(c);
            return true;
        }
        catch(Exception e){
            System.debug(LoggingLevel.DEBUG,e);
            return false;
        }
    }

    public static void createActivityWithParams(Map<String,String> params){

        System.debug(LoggingLevel.DEBUG,'HDT_UTL_ActivityCustom START');
        System.debug(LoggingLevel.DEBUG,'HDT_UTL_ActivityCustom params: ' + params);

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
            HerokuPracticeCode__c = params.get('HerokuPracticeCode__c'),
            FiscalCode__c = params.get('FiscalCode__c'),
            VATNumber__c = params.get('VATNumber__c')

        ));

        System.debug(LoggingLevel.DEBUG,'HDT_UTL_ActivityCustom END');
    }


    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/02/2021
    * @description Get record type ID for record types of wrts_prcgvr__Activity__c
    * @param String
    * @return String
    */
    public static String getRecordTypeId(String recordTypeDeveloperName){
        System.debug(LoggingLevel.DEBUG,'HDT_UTL_ActivityCustom - getRecordTypeId START');
        System.debug(LoggingLevel.DEBUG,'HDT_UTL_ActivityCustom - recordTypeDeveloperName: ' + recordTypeDeveloperName);

        List<Schema.RecordTypeInfo> recordTypes = wrts_prcgvr__Activity__c.SObjectType.getDescribe().getRecordTypeInfos();
        String recordTypeId = '';
        for (Schema.RecordTypeInfo recordType : recordTypes) {
            if (recordType.getDeveloperName() == recordTypeDeveloperName) {
                recordTypeId = recordType.getRecordTypeId();
            }
        }

        System.debug(LoggingLevel.DEBUG,'HDT_UTL_ActivityCustom - getRecordTypeId END');
        System.debug(LoggingLevel.DEBUG,'HDT_UTL_ActivityCustom - recordTypeId: ' + recordTypeId);

        return recordTypeId;
    }
    @AuraEnabled
    public static boolean validaActivityVocal(String recordid, String validazione){
        wrts_prcgvr__Activity__c act = HDT_QR_ActivityCustom.getRecordByIdValidation(recordid);
        wrts_prcgvr__Activity__c actToUpdate = new wrts_prcgvr__Activity__c(Id = recordid);
        actToUpdate.validation__c = validazione;
        boolean res = false;
        Order ord = new Order();
        ord.id = act.order__c;
        if(validazione == 'Si'){
            actToUpdate.wrts_prcgvr__status__c = 'Chiusa';
            res = true;
            ord.DocumentPackage__c = 'Validato';
            ord.phase__c = 'Registrazione validata';
            //ord.SignedDate__c = Date.today();
            //ord.DocumentalPhase__c = 'Plico firmato';
            //ord.status = 'Activated';
        }
        else{
            ord.CancellationReason__c = 'Registrazione non conforme';
        }
        activityCustomSrv.updateRecord(actToUpdate);
        orderSrv.updateRecord(ord);

        return res;
        //update act;
    }

    @SuppressWarnings('PMD.CyclomaticComplexity')
    @AuraEnabled
    public static void updateTimeRefAppointment(List<wrts_prcgvr__Activity__c> oldList,List<wrts_prcgvr__Activity__c> newList){
        Map<String,wrts_prcgvr__Activity__c> mapOld = new Map<String,wrts_prcgvr__Activity__c>();
        try {
            ID recTypeId = rtQr.getRecordTypeIdByName(APPOINTMENTDEVELOPERNAME, 'wrts_prcgvr__Activity__c');
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
            if(act.recordTypeId == rtKoOldClient && act.wrts_prcgvr__Status__c=='KO Risolto' && String.isNotBlank(act.Reason__c) && 'Dimostrata Estraneità'.equalsIgnoreCase(act.Reason__c)){
                actsToCheck.add(act.Id);
            }
        }
        if(!actsToCheck.isEmpty()){
            List<wrts_prcgvr__Activity__c> actsWithAttachments = [select Id, (select Id from AttachedContentDocuments ) from wrts_prcgvr__Activity__c where id IN :actsToCheck WITH Security_Enforced];
            for(wrts_prcgvr__Activity__c act : actsWithAttachments){
                if(!(act.AttachedContentDocuments?.size()>0)){//if AttachedContentDocuments.isEmpty() or null
                    newActsMap.get(act.id).addError('Allegare Documentazione Obbligatoria');
                }
            }
        }
    }

    @AuraEnabled
    public static string rejectActivityDocument(String recordId, String noteChiusura){
        try {
        
            wrts_prcgvr__Activity__c oldActivity = HDT_QR_ActivityCustom.getRecordByIdValidation(recordId);
            String res = '';
            if(!oldActivity.isUserActivity__c){
                res = 'Not User';
            }
            else{
                wrts_prcgvr__Activity__c oldActivityToUpdate = HDT_UTL_Scarti.closeDiscardActivity(recordId);
                oldActivityToUpdate.validation__c = 'No';
                oldActivityToUpdate.ClosingNote__c = noteChiusura;
                Date d = System.today();
                Date dataAnnullRich = d.addDays(30);
                string activityType = ( oldActivity.type__c== 'Validazione Documentale'|| oldActivity.type__c== 'Documenti non validati' )? 
                                            'Documenti non validati':
                                            'Vocal Order non validato';
                wrts_prcgvr__Activity__c newActivity = new wrts_prcgvr__Activity__c(account__c = oldActivity.account__c,
                                                                                    wrts_prcgvr__Status__c= 'Aperta',
                                                                                    order__c = oldActivity.order__c,
                                                                                    type__c = activityType,
                                                                                    recordtypeid=rtQr.getRecordTypeIdByName('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c'),
                                                                                    RequestedCancellationDate__c=dataAnnullRich, 
                                                                                    OpeningNote__c=noteChiusura);
                if( ( oldActivity.type__c== 'Validazione Vocal Order' || oldActivity.type__c== 'Vocal Order non validato') && oldActivity.DiscardCount__c == null ){
                    newActivity.DiscardCount__c = 1;
                }else if ( ( oldActivity.type__c== 'Validazione Vocal Order' || oldActivity.type__c== 'Vocal Order non validato') && oldActivity.DiscardCount__c == 1){
                    newActivity.DiscardCount__c = 2;
                }
                /**@frpanico 2022-11-22 TK 910955C
                 * L'activity Documenti non validati non deve essere creata
                 */
                if(newActivity.Type__c != null && newActivity.Type__c == 'Vocal Order non validato')
                {
                    activityCustomSrv.createRecord(newActivity);
                }
                res = 'Creata';  
                activityCustomSrv.updateRecord(oldActivityToUpdate);
            }
            
            return res;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String validaActivityDocument(String recordid, String validazione){
        wrts_prcgvr__Activity__c oldActivity = HDT_QR_ActivityCustom.getRecordByIdValidation(recordid);
        String res = '';
        if(!oldActivity.isUserActivity__c){
            res = 'Not User';
        }
        else{
            wrts_prcgvr__Activity__c oldActivityToUpdate = HDT_UTL_Scarti.closeDiscardActivity(recordid);
            oldActivityToUpdate.validation__c = validazione;
            activityCustomSrv.updateRecord(oldActivityToUpdate);
            List<Order> orderToUpd = new List<Order>();
            if(validazione == 'Si'){
                // res = true;
                 Order ord = new Order();
                 ord.id = oldActivity.order__c;
                 ord.DocumentPackage__c = 'Validato';
                 //
                 //ord.DocumentalPhase__c = 'Plico firmato';
                 if(oldActivity.Type__c.containsIgnoreCase('Vocal Order'))
                 {
                    ord.Phase__c = 'Registrazione validata';
                    if(!oldActivity.Order__r?.Account?.Category__c.equalsIgnoreCase('Famiglie'))
                    {
                        ord.SignedDate__c = Date.today();
                    }
                    else
                    {
                        /* Per evitare eventuali ordini per cui manca la configurazione CC */
                        List<Order> ol = [SELECT Id,SignedDate__c FROM Order WHERE ComfortCallDaysDue__c = null AND ParentOrder__c = :ord.id WITH SECURITY_ENFORCED];
                        for(order o : ol)
                        {
                            o.SignedDate__c = Date.today();
                            o.ConfirmCustomerContract__c = 'Comfort call';
                            orderToUpd.add(o);
                        }
                    }   
                 }
                 else
                 {
                     ord.phase__c = 'Documentazione Gestita';
                     ord.status = 'Completed';
                     ord.SignedDate__c = Date.today();
                 }
                 orderToUpd.add(ord);  
                 HDT_UTL_DatabaseService.updateSObject(orderToUpd);
             }
             else{
                 // Id rt = rtQr.getRecordTypeIdByName('HDT_RT_AttivitaGestionali');
                 /* 
                 List<wrts_prcgvr__Activity__c> actCusList =  HDT_QR_ActivityCustom.getRecordByOrderIdAndType(act.order__c,'Documenti non validati');
                 Modifica del 28/01/2022 --> l'apertura di un activity di provochera la chiusura dell'attuale ed il componentino sarà presente
                 per creare una nuova o gestire la documentazione. 
                 if(actCusList != null && !actCusList.isEmpty()){
                     if(actCusList[0].wrts_prcgvr__status__c == 'Chiusa'){
                         act.wrts_prcgvr__status__c = 'Chiusa';
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
                 }  */ 
                 Date d = System.today();
                 Date dataAnnullRich = d.addDays(30); 
                 wrts_prcgvr__Activity__c newActivity = new wrts_prcgvr__Activity__c(account__c = oldActivity.account__c,wrts_prcgvr__Status__c= 'Aperta',order__c = oldActivity.order__c,type__c='Documenti non validati',recordtypeid=rtQr.getRecordTypeIdByName('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c'),RequestedCancellationDate__c=dataAnnullRich);
                 activityCustomSrv.createRecord(newActivity);
                 res = 'Creata';  
              }
        }
        
        return res;
    }

    @AuraEnabled(cacheable=true)
    public static boolean isMandatoryComplete( String recordid ){
        return recordId == null ? true : HDT_QR_ActivityCustom.isActivityNotClosed(recordid);
    }

    public static void inheritUserFields(List<wrts_prcgvr__Activity__c> activites) {
        User user = [SELECT Id, CreatorGroup__c, LoginChannel__c, Station__c FROM User WHERE Id =: UserInfo.getUserId()];
        List<String> excludedActivityType = new List<String>{'chiamata outbound', 'chiamata inbound', 'sportello'};
        String recordTypeAct = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_HCPoint').getRecordTypeId();
        for(wrts_prcgvr__Activity__c activity : activites) {
            activity.CreatorGroup__c = user.CreatorGroup__c;
            if (!activity.IsMigrated__c && String.isNotBlank(activity.Type__c) && (!excludedActivityType.contains(activity.Type__c.toLowerCase()) || (activity.RecordTypeId == recordTypeAct && activity.Type__c == 'Sportello'))){
                activity.Place__c	 = user.Station__c;
                activity.LoginChannel__c = user.LoginChannel__c;
            }
        }
    }

    public static void changeOwnerCase(List<wrts_prcgvr__Activity__c> triggerNew,Map<id,wrts_prcgvr__Activity__c> triggerOld){
        map<String,String> caseNewOwner = new map<String,String>();
        List<Case> caseToUpdate = new List<Case>();
        for(wrts_prcgvr__Activity__c A:triggerNew){
            if((A.Type__c == 'In gestione' || A.Type__c == 'Reclamo da Riclassificare') && triggerOld.get(A.id).OwnerId != A.OwnerId) caseNewOwner.put(A.Case__c,A.OwnerId);
        }
        for(Case C:[SELECT id,OwnerId FROM Case WHERE id IN: caseNewOwner.keySet()]){
            if(caseNewOwner.containsKey(C.id) && c.OwnerId != caseNewOwner.get(C.id)){
                c.OwnerId = caseNewOwner.get(C.id);
                caseToUpdate.add(C);
            } 
        }
        update caseToUpdate;
    }
    public static void setConvertCloseStatus(List<wrts_prcgvr__Activity__c> activites){
        List<String> stateToConvert = new List<String>{'completed'};
        Set<String> closedStatus = new Set<String>();
        for (wrts_prcgvr__ActivityStatusSetting__c config : wrts_prcgvr__ActivityStatusSetting__c.getAll().values()){
            if (String.isNotBlank(config.wrts_prcgvr__ApiName__c) && config.wrts_prcgvr__IsClosed__c){
                closedStatus.add(config.wrts_prcgvr__ApiName__c.toUpperCase());
            }
        }
        for(wrts_prcgvr__Activity__c activity : activites) {
            if (String.isNotBlank(activity.wrts_prcgvr__Status__c) && stateToConvert.contains(activity.wrts_prcgvr__Status__c.toLowerCase())){
                activity.wrts_prcgvr__Status__c = 'Chiusa';
            }
            if (String.isNotBlank(activity.wrts_prcgvr__Status__c) && closedStatus.contains(activity.wrts_prcgvr__Status__c.toUpperCase()) && (activity.ActivityEndTime__c == null || activity.ActivityEndTime__c < activity.ActivityStartTime__c)  ){
                activity.ActivityEndTime__c = DateTime.now();
            }
            if (String.isNotBlank(activity.wrts_prcgvr__Status__c) && closedStatus.contains(activity.wrts_prcgvr__Status__c.toUpperCase())
            && activity.ActivityEndTime__c != null){
                activity.EndDate__c = activity.ActivityEndTime__c.date();
            }
            if(activity.ActivityStartTime__c == null){
                activity.ActivityStartTime__c = DateTime.now();
            }
        }
    }

    public static void checkForProcessFields(List<wrts_prcgvr__Activity__c> newActivities, Map<Id,wrts_prcgvr__Activity__c> oldActivitiesMap){
        Set<Id> caseId = new Set<Id>();
        Set<Id> orderId = new Set<Id>();
        for (wrts_prcgvr__Activity__c act :newActivities){
            if (conditionForProcessFields(act,  oldActivitiesMap.get(act.Id), 'Case__c')){
                caseId.add(act.Case__c);
            }else if (conditionForProcessFields(act,  oldActivitiesMap.get(act.Id), 'Order__c')){
                orderId.add(act.Order__c);
            }else if (act.Case__c == null && act.Order__c == null){
                act.ParentCluster__c = null;
                act.ParentProcess__c = null;
                act.ParentSubprocess__c = null;
            }
            //ticket 920338C non togliere in alcuni casi quando il record viene creato da Automated Process, non viene valorizzato il recordtype.
            if (act.RecordTypeId == null){
                act.RecordTypeId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Default').getRecordTypeId();
            }
        }
        Map<Id,Case> caseFieldProcessMap = new Map<Id,Case>();
        Map<Id,Order> orderFieldProcessMap = new Map<Id,Order>();
        if (!caseId.isEmpty()){
            caseFieldProcessMap = new Map<Id,Case>([SELECT id,Cluster__c,Type,Subprocess__c,AccountId  FROM Case WHERE Id IN: caseId WITH SECURITY_ENFORCED]);
        }
        if (!orderId.isEmpty()){
            orderFieldProcessMap = new Map<Id,Order>([SELECT id,Cluster__c, Process__c, ProcessType__c,Subprocess__c,AccountId FROM Order WHERE Id IN: orderId WITH SECURITY_ENFORCED]);
        }
        if (!caseFieldProcessMap.isEmpty() || !orderFieldProcessMap.isEmpty()){
            setAllProcessFields(newActivities, caseFieldProcessMap, orderFieldProcessMap);
        }
    }

    private static Boolean conditionForProcessFields(wrts_prcgvr__Activity__c newAct,wrts_prcgvr__Activity__c oldAct, String fieldToCheck){
        switch on fieldToCheck {
            when 'Case__c' {
                return newAct.Case__c != null && (oldAct == null || newAct.Case__c != oldAct.Case__c || (String.isBlank(newAct.ParentCluster__c)&&String.isBlank(newAct.ParentProcess__c)&&String.isBlank(newAct.ParentSubprocess__c)));
            }
            when 'Order__c' {
                return newAct.Case__c == null && newAct.Order__c != null && (oldAct == null || newAct.Order__c != oldAct.Order__c || (String.isBlank(newAct.ParentProcess__c)&&String.isBlank(newAct.ParentSubprocess__c)));
            }
        }
        return false; 
    }

    private static void setAllProcessFields(List<wrts_prcgvr__Activity__c> activities,Map<Id,Case> caseFieldProcessMap,Map<Id,Order> orderFieldProcessMap){
        for (wrts_prcgvr__Activity__c act : activities){
            if (act.Case__c != null && caseFieldProcessMap.containsKey(act.Case__c)){
                Case c = caseFieldProcessMap.get(act.Case__c);
                act.ParentCluster__c = c.Cluster__c;
                act.ParentProcess__c = c.Type;
                act.ParentSubprocess__c = c.Subprocess__c;
                if(c.AccountId==null){
                    if(act.Type__c !='Chiamata outbound' && act.Type__c !='Sportello' && act.Type__c !='Chiamata inbound' && act.Type__c !='Richiesta non identificata'){
                        act.Account__c = c.AccountId;
                    }
                }
            }else if (act.Order__c != null && orderFieldProcessMap.containsKey(act.Order__c)){
                Order o = orderFieldProcessMap.get(act.Order__c);
                act.ParentCluster__c = o.Cluster__c;
                act.ParentProcess__c = o.Process__c;
                act.ParentSubprocess__c = 'Voltura'.equalsIgnoreCase(act.ParentProcess__c)? o.Subprocess__c :  o.ProcessType__c;
                if(o.AccountId==null){
                    if(act.Type__c !='Chiamata outbound' && act.Type__c !='Sportello' && act.Type__c !='Chiamata inbound' && act.Type__c !='Richiesta non identificata'){
                        act.Account__c = o.AccountId;
                    }
                }
            }
        }
    }

    public static void postSurvayWorkActivity(List<wrts_prcgvr__Activity__c> newActsList){
        try{
            Map<Id,wrts_prcgvr__Activity__c> actToCreate = new Map<Id,wrts_prcgvr__Activity__c>();
            for (wrts_prcgvr__Activity__c newAct : newActsList){
                if (!'Lavorazione Reclamo Post Survey'.equalsIgnoreCase(newAct.Type__c)){
                    continue;
                }
                Id recordId = newAct.Case__c != null ? newAct.Case__c : newAct.Order__c;
                if (recordId == null) {
                    continue;
                }
                actToCreate.put(recordId,newAct);
            }
            if (actToCreate.isEmpty()){
                return;
            }
            List<wrts_prcgvr__Activity__c> actToUpdate = new List<wrts_prcgvr__Activity__c>();
            for (wrts_prcgvr__Activity__c act : HDT_QR_ActivityCustom.getActivityByType('Lavorazione Reclamo Post Survey',actToCreate.keySet())){
                Id recordId = act.Case__c != null ? act.Case__c : act.Order__c;
                if (act.wrts_prcgvr__IsClosed__c){
                    actToCreate.get(recordId).wrts_prcgvr__Status__c = 'Annullata';
                    actToCreate.get(recordId).ClosingNote__c = 'Attività creata in stato annullato a causa dell\'avvenuta lavorazione della Survey (vedi '+act.Name+')';
                    continue;
                }
                actToUpdate.add(new wrts_prcgvr__Activity__c(Id = act.Id, wrts_prcgvr__Status__c = 'Annullata', ClosingNote__c = 'Annullata per apertura nuova attività'));
            }
            if (!actToUpdate.isEmpty()){
                HDT_UTL_DatabaseService.updateSObject(actToUpdate);
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }
    }

    public static void setCompanyName(List<wrts_prcgvr__Activity__c> activities){
        List<wrts_prcgvr__Activity__c> actToCheckList = new List<wrts_prcgvr__Activity__c>();
        Set<Id> setActivityId = new Set<Id>();
        Set<Id> setAccountId = new Set<Id>();
        Set<Id> setOrderId = new Set<Id>();
        Set<Id> setCaseId = new Set<Id>();
        
        for(wrts_prcgvr__Activity__c act : activities) {
            if (act.CompanyOwner__c == null){
    
                if(act.Account__c!=null)setAccountId.add(act.Account__c);
                if(act.Order__c!=null)setOrderId.add(act.Order__c);
                if(act.Case__c!=null)setCaseId.add(act.Case__c);
                setActivityId.add(act.Id);
            }
        }
        if (setActivityId.isEmpty()){
            return;
        }
        Map <Id, Account> mapAccountToId = new Map <Id, Account> ([SELECT Id, CompanyOwner__c FROM Account WHERE Id IN: setAccountId]);
        Map <Id, Order> mapOrderToId = new Map <Id, Order> ([SELECT Id, CompanyOwner__c FROM Order WHERE Id IN: setOrderId]);
        Map <Id, Case> mapCaseToId = new Map <Id, Case> ([SELECT Id, CompanyOwner__c FROM Case WHERE Id IN: setCaseId]);
        List<wrts_prcgvr__Activity__c> actToUpdateList = [SELECT Id, CompanyOwner__c,Account__c,Order__c,Case__c FROM wrts_prcgvr__Activity__c WHERE Id IN: setActivityId];
        for(wrts_prcgvr__Activity__c act : actToUpdateList){
            String companyName = getCompanyName(mapAccountToId.get(act.Account__c), mapOrderToId.get(act.Order__c), mapCaseToId.get(act.Case__c));
            if(companyName!=null){
                act.CompanyOwner__c = companyName;
                
            }
            else{
                act.CompanyOwner__c = Label.CompanyNameLabel;
                
            }
            
        }
            
        if(actToUpdateList.size()>0){
                update actToUpdateList;
        }
    }
    private static String getCompanyName(Account acc,Order order, Case cas){
        if(acc!=null){
            if(acc.CompanyOwner__c != null){
                return acc.CompanyOwner__c;
            }
        }
        if(order!=null){
            if(order.CompanyOwner__c != null){
                return order.CompanyOwner__c;
            }
        }
        if(cas!=null){
            if(cas.CompanyOwner__c != null){
            return cas.CompanyOwner__c;
            }
        }
        return null;
    }
    public static void setAccountIdFromCaseOrder(List<SObject> sObjectList){
        
        List<String> caseIds= new List<String>();
        List<String> orderIds= new List<String>();
        List<Case> casesList= new List<Case>();
        List<Order> ordersList= new List<Order>();
        Map<String,Case> casesMap=new Map<String,Case>();
        Map<String,Order> ordersMap=new Map<String,Order>();
        String objectApiName = '';
        
        for(SObject obj : sObjectList){
            objectApiName = String.valueOf(obj.getSObjectType());
            if(objectApiName == 'wrts_prcgvr__Activity__c'){
                if(String.valueOf(obj.get('Case__c')) != '' && String.valueOf(obj.get('Case__c')) != null)
                    caseIds.add(String.valueOf(obj.get('Case__c')));
                if(String.valueOf(obj.get('Order__c')) != '' && String.valueOf(obj.get('Order__c')) != null)
                    orderIds.add(String.valueOf(obj.get('Order__c')));
            }
        }
        if(!caseIds.isEmpty()){
            casesList = caseQr.getRecordsById(caseIds, 'Id,CompanyOwner__c,AccountId');
        }
        if(!orderIds.isEmpty()){
            ordersList=orderQr.getRecordsByIdWithFields(orderIds, 'Id,CompanyOwner__c,AccountId');
        }
        for(Case c : casesList){
            casesMap.put(c.Id,c);
        }
        for(Order o : ordersList){
            ordersMap.put(o.Id,o);
        }

        for(SObject obj : sObjectList){
            objectApiName = String.valueOf(obj.getSObjectType());
            if(objectApiName == 'wrts_prcgvr__Activity__c'){
                if(String.valueOf(obj.get('Account__c')) == '' || String.valueOf(obj.get('Account__c')) == null){
                    if (casesMap.containsKey(String.valueOf(obj.get('Case__c')))){
                        Case caseObj = casesMap.get(String.valueOf(obj.get('Case__c')));
                        if (caseObj != null){
                            obj.put('Account__c', caseObj.AccountId);
                        }
                    }else{
                        Order orderObj = ordersMap.get(String.valueOf(obj.get('Order__c')));
                        if (orderObj != null){
                            obj.put('Account__c', orderObj.AccountId);
                        }
                    }
                }
            }
        }    
    }
    public static void executeOnCloseActions(List<wrts_prcgvr__Activity__c> newTriggerList,  Map<Id,SObject> oldTriggerMap){

        HDT_UTL_ActivityCloseActions.executeOnCloseActions(newTriggerList, oldTriggerMap);

    }

    @AuraEnabled
    public static void setNoteRicontattoCliente(List<wrts_prcgvr__Activity__c> oldList,List<wrts_prcgvr__Activity__c> newList){
        Map<String,wrts_prcgvr__Activity__c> mapOld = new Map<String,wrts_prcgvr__Activity__c>();
        Datetime nowDate = null;
        String nowDateFormat = '';
        try {
            for(wrts_prcgvr__Activity__c act : oldList){
                mapOld.put(act.id,act);
            }
            for(wrts_prcgvr__Activity__c act : newList){
                if((mapOld.get(act.id).ContactResult__c != act.ContactResult__c) && !String.isBlank(act.ContactResult__c) && 'Presa Appuntamento'.equalsIgnoreCase(act.Type__c)){
                    nowDate = Datetime.now();
                    nowDateFormat = nowDate.format('dd/MM/yyyy h:mm a');
                    act.NoteRicontattoCliente__c = !String.isBlank(mapOld.get(act.id).NoteRicontattoCliente__c) ? mapOld.get(act.id).NoteRicontattoCliente__c + '\n' + act.ContactResult__c + ' in data ' + nowDateFormat : act.ContactResult__c + ' in data ' + nowDateFormat;
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Throwed exception: ' + e.getMessage());
        }
    }

    @InvocableMethod(label = 'Get Activities By Ids')
    public static List<HDT_WRP_ActivitiesResponse> agencyActivityProcess(List<HDT_WRP_ActivitiesForFlowQuery> inputs){
        HDT_WRP_ActivitiesResponse resp = new HDT_WRP_ActivitiesResponse();
        if (inputs != null && inputs[0].ids != null && !inputs[0].ids.isEmpty() && String.isNotBlank(inputs[0].fields)){
            String condition = 'Id IN (\'' + String.join(inputs[0].ids, '\',\'')+'\')';
            resp.activities = HDT_QR_GenericQuery.getGenericRecords(inputs[0].fields, 'wrts_prcgvr__Activity__c', condition);
            resp.found = resp.activities.size() > 0;
        }
        return new List<HDT_WRP_ActivitiesResponse>{resp};
    }

    public class HDT_WRP_ActivitiesForFlowQuery{
        @InvocableVariable
        public List<Id> ids;
        @InvocableVariable
        public String fields;
    }

    public class HDT_WRP_ActivitiesResponse{
        @InvocableVariable
        public List<wrts_prcgvr__Activity__c> activities;
        @InvocableVariable
        public Boolean found = false;
    }
     
}