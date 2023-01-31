/**
 * @author Marco Ficorella NTTDATA
 * Classe utility per la gestione della chiusura massiva delle attività (custom) e aggiornamento della fase entità correlate (case o order)
 **/
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessChiusuraMassivaActivity extends HDT_UTL_ProcessExecution {
    List<MassiveLoaderRequestItem__c> itemsToSave;
    Map<String, String> mapActivityFields;
    Map<String, String> mapWrapperActivityFields;
    Map<String,wrts_prcgvr__Activity__c> mapActivityId;
    Map<Id,Id> mapActivityOrderId;
    Map<Id,Id> mapActivityCaseId;
    Map<String,User> mapUserAdn;
    Map<String,String> mapUserActId;

    Integer activityIndex;
    Integer faseIndex;
    Integer utenteIndex;
    Set<String> userNameSet;
    List<HDT_WRP_ProcessObjects> processObjList;
    HDT_WRP_ProcessObjects processObj;
    Set<String> activityIdSet;
    List<Order> orderToSave;
    List<Case> caseToSave;
    List<wrts_prcgvr__Activity__c> actToSave;

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');

        //System.debug(LoggingLevel.DEBUG, '>>> this.processName: ' + this.processName);
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        mapFieldsObject();
        // UTENTE_CHIUSURA  recuperare user da loginADN
        // CANALE_UTENTE_CHIUSURA LoginChannel__c user
        // GRUPPO_CREATORE_CHIUSURA CreatorGroup__c dello user che va verificato se corrisponde con l'utente chiusura e il canale


        
        activityIndex = mapHeaderForWrapper.get(mapWrapperActivityFields.get('ID_ATTIVITA'));
        faseIndex = mapHeaderForWrapper.get(mapWrapperActivityFields.get('FASE_PROCESSO'));
        utenteIndex = mapHeaderForWrapper.get(mapWrapperActivityFields.get('UTENTE_CHIUSURA'));


        System.debug(LoggingLevel.DEBUG, '>>> Index: activityIndex [' + activityIndex + '];  faseIndex [' + faseIndex + ']; userIndex [' + utenteIndex + '];  ');

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        userNameSet=new Set<String>();
        mapUserActId=new Map<String,String>();
        mapActivityId = new Map<String,wrts_prcgvr__Activity__c>();
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);
            //verifica campi obbligatori
            checkRequiredFields(item, tempSplitedFields);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }

            //inizializzazione processobj
            String activityId = tempSplitedFields[activityIndex];
            String utente = tempSplitedFields[utenteIndex];
            String fase = tempSplitedFields[faseIndex];

            userNameSet.add(utente);

            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;
            processObj.activity = new wrts_prcgvr__Activity__c();
            mapUserActId.put(activityId,utente);
            
            Integer count = 0;
            String convertionError;
            //popolamento automatico dei campi dell'activity e verifica dei valori picklist
            for (String tempField : processObj.csvSplitted) {

                if ('null'.equalsIgnoreCase(tempField)) {
                   tempField = '';
                }

                if(!String.isEmpty(convertionError)){
                    // error happened -> exit
                    break;
                }

                if(String.isNotBlank(mapActivityFields.get(mapHeaderByPosition.get(count))) && String.isNotBlank(tempField)){
                    System.debug(LoggingLevel.DEBUG, '>>> tempField: ' + tempField + ' # Header: ' + mapHeaderByPosition.get(count) + ' # ActivityFields: ' + mapActivityFields.get(mapHeaderByPosition.get(count)));
                    convertionError = mapTypeField(processObj.activity, mapActivityFields, count, tempField);

                    if(!String.isEmpty(convertionError)){
                        // error happened -> exit
                        break;
                    }
                }
                count++;
            }

            if(!String.isEmpty(convertionError)){
                itemsToSave.add(setErrorItem(processObj.requestItem, convertionError));
                continue;
            }

            if(errorForPicklistValue('wrts_prcgvr__Activity__c', 'ActivityOutcome__c', processObj.activity.ActivityOutcome__c)){
                itemsToSave.add(setErrorItem(processObj.requestItem, 'Valore Esito attività non corretto: ' + processObj.activity.ActivityOutcome__c));
                continue;
            }


            processObj.activity.Id = activityId;
            processObj.activity.wrts_prcgvr__Status__c = 'Chiusa';

            mapActivityId.put(activityId,processObj.activity);
            processObj.fase=fase;
            processObjList.add(processObj);

        }

    }


    public override void getRecords(){
        activityIdSet=mapActivityId.keySet();
        mapActivityOrderId=new Map<Id,Id>();
        mapActivityCaseId=new Map<Id,Id>();
        mapUserAdn=new Map<String,User>();
        //recupero delle attività
        List<wrts_prcgvr__Activity__c> activityList=HDT_QR_ProcessPostSales.getActivityById(activityIdSet);
        //eseguo mapping degli order e case correlati
        for(wrts_prcgvr__Activity__c activity:activityList){
            if(activity.Order__c!=null){
                mapActivityOrderId.put(activity.Id,activity.Order__c);
            }
            if(activity.Case__c!=null){
                mapActivityCaseId.put(activity.Id,activity.Case__c);
            }
        }
        //recupero gli user e li mappo
        List<User> userList=HDT_QR_ProcessPostSales.getUserByLoginAdn(userNameSet);
        for(User usr:userList){
            mapUserAdn.put(usr.LoginADN__c,usr);
        }


    }

    public override void registryCreation(){
        List<MassiveLoaderRequestItem__c> requestItemForUpsertAct = new List<MassiveLoaderRequestItem__c>();
        Map<Id,MassiveLoaderRequestItem__c> mapRequestItemForUpsertNext = new Map<Id,MassiveLoaderRequestItem__c>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsertOrd = new List<MassiveLoaderRequestItem__c>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsertCase = new List<MassiveLoaderRequestItem__c>();
        getLimitDetails('START registryCreation');
        actToSave = new List<wrts_prcgvr__Activity__c>();
        orderToSave = new List<Order>();
        caseToSave = new List<Case>();
        //preparazione aggiornamento entità
        //mappo prima gli user nell'activity
        for(HDT_WRP_ProcessObjects procObj:processObjList){
            wrts_prcgvr__Activity__c act=procObj.activity;
            String usrAdn=mapUserActId.get(act.Id);

            if(!mapUserAdn.containsKey(usrAdn)){
                itemsToSave.add(setErrorItem(procObj.requestItem, 'Utente non trovato con LoginADN: ' + usrAdn));
                continue;
            }

            User usr=mapUserAdn.get(usrAdn);
            

            act.ClosingUserChannel__c = usr.LoginChannel__c;
            act.ClosingCreatorGroup__c = usr.CreatorGroup__c;
            act.ClosedByUsername__c = usr.Username;

            actToSave.add(act);           
            
            requestItemForUpsertAct.add(procObj.requestItem);
        }

        if(!actToSave.isEmpty()){
            //salvo le activity
            HDT_WRP_SaveResponse saveResponse;
            saveResponse = databaseUpsert(actToSave, requestItemForUpsertAct, 'wrts_prcgvr__Activity__c');
            actToSave.clear();
            getLimitDetails('AFTER ACT CLOSE');
            
            Map<Id, String> errorItemMap=saveResponse.errorItemMap;
            for( MassiveLoaderRequestItem__c requestItem:saveResponse.reponseItemList){
                //verifico quali activity sono andate ok e le mappo per la successiva elaborazione. Quelle in errore non verranno rielaborate
                if(errorItemMap.containsKey(requestItem.Id)){
                    itemsToSave.add(setErrorItem(requestItem, errorItemMap.get(requestItem.Id)));
                } else {
                    mapRequestItemForUpsertNext.put(requestItem.Id,requestItem);
                }
            }

            for(HDT_WRP_ProcessObjects procObj:processObjList){
                //skip delle richieste andate in errore in precedenza
                if(!mapRequestItemForUpsertNext.containsKey(procObj.requestItem.Id)){
                    continue;
                }

                wrts_prcgvr__Activity__c act=procObj.activity;
                //recupero l'order se associatio e lo mappo
                Id relOrdId;
                if(mapActivityOrderId.containsKey(act.Id)){
                    relOrdid=mapActivityOrderId.get(act.Id);
                    if(errorForPicklistValue('Order', 'Phase__c', procObj.fase)){
                        itemsToSave.add(setErrorItem(procObj.requestItem, 'Valore fase Order non corretto: ' + procObj.fase));
                        continue;
                    }
                    Order refOrder=new Order(Id=relOrdid,Phase__c=procObj.fase);
                    orderToSave.add(refOrder);
                    requestItemForUpsertOrd.add(procObj.requestItem);
                    System.debug(LoggingLevel.DEBUG, '>>> requestItemForUpsertOrd' + requestItemForUpsertOrd);
                }
                
                //recupero il case se associato e lo mappo
                Id relCaseId;
                if(mapActivityCaseId.containsKey(act.Id)){
                    relCaseId=mapActivityCaseId.get(act.Id);
                    if(errorForPicklistValue('Case', 'Phase__c', procObj.fase)){
                        itemsToSave.add(setErrorItem(procObj.requestItem, 'Valore fase Case non corretto: ' + procObj.fase));
                        continue;
                    }
                    Case refCase=new Case(Id=relCaseId  ,Phase__c=procObj.fase);
                    caseToSave.add(refCase);
                    requestItemForUpsertCase.add(procObj.requestItem);
                    System.debug(LoggingLevel.DEBUG, '>>> requestItemForUpsertCase' + requestItemForUpsertCase);
                }
                
            }
            System.debug(LoggingLevel.DEBUG, '>>> itemsToSave' + itemsToSave);
            //aggiorno gli order
            if(!orderToSave.isEmpty()){
                HDT_WRP_SaveResponse saveResponseOrd;
                saveResponseOrd = databaseUpsert(orderToSave, requestItemForUpsertOrd, 'Order');
                orderToSave.clear();
                getLimitDetails('AFTER Order UPDATE');
                System.debug(LoggingLevel.DEBUG, '>>> saveResponseOrd.reponseItemList' + saveResponseOrd.reponseItemList);
                if(saveResponseOrd.reponseItemList.size() > 0){
                    itemsToSave.addAll(saveResponseOrd.reponseItemList);
                }
                System.debug(LoggingLevel.DEBUG, '>>> itemsToSave - Ord' + itemsToSave);

            }
            //aggiorno i case
            if(!caseToSave.isEmpty()){
                HDT_WRP_SaveResponse saveResponseCase;
                saveResponseCase = databaseUpsert(caseToSave, requestItemForUpsertCase, 'Case');
                caseToSave.clear();
                getLimitDetails('AFTER Case UPDATE');
                System.debug(LoggingLevel.DEBUG, '>>> saveResponseCase.reponseItemList' + saveResponseCase.reponseItemList);
                if(saveResponseCase.reponseItemList.size() > 0){
                    itemsToSave.addAll(saveResponseCase.reponseItemList);
                }
                System.debug(LoggingLevel.DEBUG, '>>> itemsToSave - Case' + itemsToSave);

            }
            System.debug(LoggingLevel.DEBUG, '>>> itemsToSave - Final' + itemsToSave);

        }


    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');

        if(itemsToSave.size() > 0){
            update itemsToSave;
        }

    }

    private void mapFieldsObject(){
        //esegue il caricamento dei valori in mappa
        List<HDT_MassiveFieldsObjectMap__mdt> listActivityFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listWrapperActivityFields;

        mapActivityFields = new Map<String, String>();
        mapWrapperActivityFields = new Map<String, String>();

        listActivityFields = getMapFieldsObject('wrts_prcgvr__Activity__c', this.processName);
        listWrapperActivityFields = getMapFieldsObject('WrapperActivity', this.processName);
        System.debug(LoggingLevel.DEBUG, '>>> listActivityFields' + listActivityFields);
        System.debug(LoggingLevel.DEBUG, '>>> mapWrapperActivityFields' + listWrapperActivityFields);

        for(HDT_MassiveFieldsObjectMap__mdt temp : listActivityFields){
            mapActivityFields.put(temp.labelField__c, temp.nameField__c);
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperActivityFields){
            mapWrapperActivityFields.put(temp.labelField__c, temp.nameField__c);
        }

    }


    private class HDT_WRP_ProcessObjects {
        private Case refCase;
        private Order refOrder;
        private String fase;
        private wrts_prcgvr__Activity__c activity;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }
}
