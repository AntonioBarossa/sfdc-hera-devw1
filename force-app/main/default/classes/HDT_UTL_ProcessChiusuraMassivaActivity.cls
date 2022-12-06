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
    Integer esitoIndex;
    Integer faseIndex;
    Integer utenteIndex;
    Integer gruppoIndex;
    Integer noteIndex;
    Integer canaleIndex;
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


        activityIndex = mapHeaderForWrapper.get(mapActivityFields.get('ID_ATTIVITA'));
        esitoIndex = mapHeaderForWrapper.get(mapActivityFields.get('ESITO_ATTIVITA'));
        faseIndex = mapHeaderForWrapper.get(mapWrapperActivityFields.get('FASE_PROCESSO'));
        utenteIndex = mapHeaderForWrapper.get(mapWrapperActivityFields.get('UTENTE_CHIUSURA'));
        gruppoIndex = mapHeaderForWrapper.get(mapActivityFields.get('GRUPPO_CREATORE_CHIUSURA'));
        noteIndex = mapHeaderForWrapper.get(mapActivityFields.get('NOTE_CHIUSURA'));
        canaleIndex = mapHeaderForWrapper.get(mapActivityFields.get('CANALE_UTENTE_CHIUSURA'));

        System.debug(LoggingLevel.DEBUG, '>>> Index: activityIndex [' + activityIndex + ']; esitoIndex [' + esitoIndex + ']; faseIndex [' + faseIndex + ']; userIndex [' + utenteIndex + ']; gruppoIndex [' + gruppoIndex + ']; noteIndex [' + noteIndex + ']; canaleIndex [' + canaleIndex + ']; ');

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        userNameSet=new Set<String>();
        mapUserActId=new Map<String,String>();
        mapActivityId = new Map<String,wrts_prcgvr__Activity__c>();
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);

            checkRequiredFields(item, tempSplitedFields);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }

            //accountIdSet.add(processObj.csvSplitted[accountIdIndex]);
            String activityId = tempSplitedFields[activityIndex];
            String esito = tempSplitedFields[esitoIndex];
            String note = tempSplitedFields[noteIndex];
            String gruppo = tempSplitedFields[gruppoIndex];
            String canale = tempSplitedFields[canaleIndex];
            String utente = tempSplitedFields[utenteIndex];
            String fase = tempSplitedFields[faseIndex];

            if(!esito.equalsIgnoreCase('Positivo') && !esito.equalsIgnoreCase('Negativo')){
                itemsToSave.add(setErrorItem(item,'Valore di esito (\''+esito+'\') non valido.'));
                continue;
            }

            userNameSet.add(utente);

            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;
            wrts_prcgvr__Activity__c activity=new wrts_prcgvr__Activity__c();
            mapUserActId.put(activityId,utente);
            
            activity.Id = activityId;
            activity.ActivityOutcome__c = esito;
            activity.wrts_prcgvr__Status__c = 'Chiusa';
            activity.ClosingNote__c = note;
            activity.ClosingCreatorGroup__c = gruppo;
            activity.ClosingUserChannel__c = canale;

            mapActivityId.put(activityId,activity);
            processObj.activity=activity;
            processObj.fase=fase;
            processObjList.add(processObj);

        }

    }


    public override void getRecords(){
        activityIdSet=mapActivityId.keySet();
        mapActivityOrderId=new Map<Id,Id>();
        mapActivityCaseId=new Map<Id,Id>();
        mapUserAdn=new Map<String,User>();

        List<wrts_prcgvr__Activity__c> activityList=HDT_QR_ProcessPostSales.getActivityById(activityIdSet);

        for(wrts_prcgvr__Activity__c activity:activityList){
            if(activity.Order__c!=null){
                mapActivityOrderId.put(activity.Id,activity.Order__c);
            }
            if(activity.Case__c!=null){
                mapActivityCaseId.put(activity.Id,activity.Case__c);
            }
        }

        List<User> userList=HDT_QR_ProcessPostSales.getUserByLoginAdn(userNameSet);

        for(User usr:userList){
            mapUserAdn.put(usr.LoginADN__c,usr);
        }


    }

    public override void registryCreation(){
        List<MassiveLoaderRequestItem__c> requestItemForUpsert;
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();
        getLimitDetails('START registryCreation');
        actToSave = new List<wrts_prcgvr__Activity__c>();

        for(HDT_WRP_ProcessObjects procObj:processObjList){
            wrts_prcgvr__Activity__c act=procObj.activity;
            String usrAdn=mapUserActId.get(act.Id);

            if(!mapUserAdn.containsKey(usrAdn)){
                itemsToSave.add(setErrorItem(procObj.requestItem, 'Utente non trovato con LoginADN: ' + usrAdn));
                continue;
            }

            User usr=mapUserAdn.get(usrAdn);
            Id relOrdId;
            Id relCaseId;

            if(mapActivityOrderId.containsKey(act.Id)){
                relOrdid=mapActivityOrderId.get(act.Id);
                if(errorForPicklistValue('Order', 'Phase__c', procObj.fase)){
                    itemsToSave.add(setErrorItem(processObj.requestItem, 'Valore fase non corretto: ' + procObj.fase));
                    continue;
                }
                Order refOrder=new Order(Id=relOrdid,Phase__c=procObj.fase);
                orderToSave.add(refOrder);
            }

            if(mapActivityCaseId.containsKey(act.Id)){
                relCaseId=mapActivityCaseId.get(act.Id);
                if(errorForPicklistValue('Case', 'Phase__c', procObj.fase)){
                    itemsToSave.add(setErrorItem(processObj.requestItem, 'Valore fase non corretto: ' + procObj.fase));
                    continue;
                }
                Case refCase=new Case(Id=relCaseId  ,Phase__c=procObj.fase);
                caseToSave.add(refCase);
            }
            
            act.ClosingUserChannel__c = usr.LoginChannel__c;
            act.ClosingCreatorGroup__c = usr.CreatorGroup__c;
            act.ClosedByUsername__c = usr.Username;
            
            actToSave.add(act);
            requestItemForUpsert.add(procObj.requestItem);
        }


    }

    private void mapFieldsObject(){
        List<HDT_MassiveFieldsObjectMap__mdt> listActivityFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listWrapperActivityFields;

        mapActivityFields = new Map<String, String>();
        mapWrapperActivityFields = new Map<String, String>();

        listActivityFields = getMapFieldsObject('wrts_prcgvr__Activity__c', this.processName);
        listWrapperActivityFields = getMapFieldsObject('WrapperActivity', this.processName);

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
