@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessGeneralTermsCondition extends HDT_UTL_ProcessExecution {

    private Map<String, String> mapAllFields;
    private Map<String, MassiveFieldsObjectMap__c> sobjectMap;
    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private List<Product2> productToRetrieve;
    private List<MassiveLoaderRequestItem__c> itemsToSave;

    public override void checks(){

        mapFieldsObject();

        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        productToRetrieve = new List<Product2>();

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;

        for(MassiveLoaderRequestItem__c item : requestItemList){
            processObj = new HDT_WRP_ProcessObjects();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);

            processObj.requestItem = item;

            String csvHeader;
            String convertionError;
            String tempValue;
            String objField;
            for(Integer count=0; count < tempSplitedFields.size(); count++){
                tempValue = tempSplitedFields[count];
                csvHeader = mapHeaderByPosition.get(count);
                objField = mapAllFields.get(csvHeader);

                if(String.isBlank(objField) || String.isBlank(tempValue)){
                    continue;
                }

                if(sobjectMap.containsKey(csvHeader)){
                    switch on sobjectMap.get(csvHeader).objectType__c {
                        when 'Product2' {
                            convertionError = mapTypeField(processObj.product, mapAllFields, count, tempValue);
                        }
                        when 'GeneralTermsCondition__c' {
                            convertionError = mapTypeField(processObj.generalTermsCondition, mapAllFields, count, tempValue);
                        }
                    }
                }

                if(String.isNotEmpty(convertionError)){
                    // error happened -> exit
                    //system.debug(LoggingLevel.DEBUG, '>>> break for loop...' + csvHeader + ' - ' + tempValue);
                    break;
                }

            }

            if(String.isNotEmpty(convertionError)){
                processObj.requestItem = setErrorItem(processObj.requestItem, convertionError);
                itemsToUpdate.add(processObj.requestItem);
                continue;
            }

            processObjList.add(processObj);

        }

        getLimitDetails('convertionEnd');

    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');
    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');
        List<GeneralTermsCondition__c> cgcList = new List<GeneralTermsCondition__c>();
        List<MassiveLoaderRequestItem__c> itemList = new List<MassiveLoaderRequestItem__c>();
        for(HDT_WRP_ProcessObjects processObj : processObjList){
            System.debug(LoggingLevel.DEBUG, '>>> Product2: ' + processObj.product);
            System.debug(LoggingLevel.DEBUG, '>>> cgc: ' + processObj.generalTermsCondition);
            cgcList.add(processObj.generalTermsCondition);
            itemList.add(processObj.requestItem);
        }
        HDT_WRP_SaveResponse saveResponse = databaseUpsertWithKey(cgcList,itemList,'GeneralTermsCondition__c','CgcCode__c');
        
        System.debug(LoggingLevel.DEBUG, '>>>>>> reponseItemList ' + saveResponse.reponseItemList);
        System.debug(LoggingLevel.DEBUG, '>>>>>> savedObject ' + saveResponse.savedObject);
        System.debug(LoggingLevel.DEBUG, '>>>>>> itemIdToObjId ' + saveResponse.itemIdToObjId);
        
        
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        itemsToSave.addAll(saveResponse.reponseItemList);

        for(MassiveLoaderRequestItem__c i : itemsToSave){
            if(saveResponse.itemIdToObjId.containsKey(i.Id)){
                i.Result__c = saveResponse.itemIdToObjId.get(i.Id);
            }
        }
        
    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');
        if(itemsToSave.size() > 0){
            update itemsToSave;
        }
    }

    private void mapFieldsObject(){

        mapAllFields = new Map<String, String>();
        List<MassiveFieldsObjectMap__c> allFieldForThisProcess;

        sobjectMap = new Map<String, MassiveFieldsObjectMap__c>();
        allFieldForThisProcess = [
            SELECT objectType__c, labelField__c, nameField__c
            FROM MassiveFieldsObjectMap__c 
            WHERE processType__c = 'CGC'
            WITH SECURITY_ENFORCED
        ];

        for(MassiveFieldsObjectMap__c temp : allFieldForThisProcess){
            mapAllFields.put(temp.labelField__c, temp.nameField__c);
            sobjectMap.put(temp.labelField__c, temp);
        }



    }

    private class HDT_WRP_ProcessObjects {
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
        private Product2 product;
        private GeneralTermsCondition__c generalTermsCondition;

        private HDT_WRP_ProcessObjects(){
            product = new Product2();
            generalTermsCondition = new GeneralTermsCondition__c();
        }

    }

}