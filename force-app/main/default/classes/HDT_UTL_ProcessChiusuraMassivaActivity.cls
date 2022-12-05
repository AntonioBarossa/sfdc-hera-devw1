@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessChiusuraMassivaActivity extends HDT_UTL_ProcessExecution {
    List<MassiveLoaderRequestItem__c> itemsToSave;
    Map<String, String> mapActivityFields;
    Map<String, String> mapCaseFields;
    Map<String, String> mapWrapperCaseFields;
    Map<String, String> mapWrapperActivityFields;

    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');

        //System.debug(LoggingLevel.DEBUG, '>>> this.processName: ' + this.processName);
        itemsToSave = new List<MassiveLoaderRequestItem__c>();

        mapFieldsObject();


        podIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('POD'));
        contractIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CONTRATTO'));
        //accountIdIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ACCOUNTID'));

        if(!isVolturaProcess){
            orderVolturaIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('ORDER_VOLTURA'));
        }

        System.debug(LoggingLevel.DEBUG, '>>> Index: podIndex [' + podIndex + ']; contract [' + contractIndex + ']; accountId [' + accountIdIndex + ']; orderVoltura [' + orderVolturaIndex + ']');

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);

            checkRequiredFields(item, tempSplitedFields);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }

            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;

            //accountIdSet.add(processObj.csvSplitted[accountIdIndex]);
            contractCodeSet.add(processObj.csvSplitted[contractIndex]);
            processObjList.add(processObj);



        }

    }


    private void mapFieldsObject(){
        List<HDT_MassiveFieldsObjectMap__mdt> listActivityFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listCaseFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listWrapperCaseFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listWrapperActivityFields;

        mapActivityFields = new Map<String, String>();
        mapCaseFields = new Map<String, String>();
        mapWrapperCaseFields = new Map<String, String>();
        mapWrapperActivityFields = new Map<String, String>();

        listActivityFields = getMapFieldsObject('wrts_prcgvr__Activity__c', this.processName);
        listCaseFields = getMapFieldsObject('Case', this.processName);
        listWrapperCaseFields = getMapFieldsObject('WrapperCase', this.processName);
        listWrapperActivityFields = getMapFieldsObject('WrapperActivity', this.processName);

        for(HDT_MassiveFieldsObjectMap__mdt temp : listActivityFields){
            mapActivityFields.put(temp.labelField__c, temp.nameField__c);
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listCaseFields){
            mapCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperCaseFields){
            mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperActivityFields){
            mapWrapperActivityFields.put(temp.labelField__c, temp.nameField__c);
        }

    }
}
