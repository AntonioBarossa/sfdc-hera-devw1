/** NTTDATA Classe per la gestione del caricamento massivo del Consumo Anomalo Idrico, 
 * richiamata dal batch HDT_BA_ProcessOrderCreation dinamicamente in base la configurazione del metadata HDT_MassiveLoaderProcess__mdt
 * e utilizzando il mapping field nel metadata HDT_MassiveFieldsObjectMap__mdt.
 **/
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessConsumoAnomaloIdrico extends HDT_UTL_ProcessExecution {
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private List<HDT_WRP_ProcessObjects> processObjList;
    //private Map<String, String> accountContactMap = new Map<String, String>();
    //private Map<String, Contract> podContractMap = new Map<String, Contract>();
    /*
        mapRequiredByPosition posizioneElemento->header colonna csv, mapCaseFields header colonna csv -> api name campo
        mapCaseFields.get(mapRequiredByPosition.get(someIndex)) -> api name campo per la posizione someIndex; csvSplitted[someIndex] valore della colonna in posizione someIndex
    */
    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');

        
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        //Carico mapping
        mapFieldsObject();



        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);//valore dei campi

            checkRequiredFields(item, tempSplitedFields);
            System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            if(item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }

            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;

            processObjList.add(processObj);

        }


    }

    public override void getRecords(){
        //get PDR
        // get contract via Contract.ServicePoint__c
    }

    public override void registryCreation(){
        List<Case> caseToInsert = new List<Case>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsert=new List<MassiveLoaderRequestItem__c>();
        for(HDT_WRP_ProcessObjects currentObj:processObjList){
            currentObj.newCase=new Case(Phase__c='in attesa processo doc massivo', Status='In Lavorazione');
            String fieldConversionError='';
            for(Integer headerIndex:mapHeaderByPosition.keySet()){
                String fieldValue= String.isBlank(currentObj.csvSplitted[headerIndex]) ? '':currentObj.csvSplitted[headerIndex];
                fieldConversionError=mapTypeField(currentObj.newCase,mapCaseFields,headerIndex,fieldValue);
                if(String.isNotBlank(fieldConversionError)){
                    break;
                }
                //fieldValue=String.isBlank(currentObj.csvSplitted[headerIndex]) ? '' : currentObj.csvSplitted[headerIndex];
                //currentCase.put(mapCaseFields.get(mapHeaderByPosition.get(headerIndex)),fieldValue);
            }
            if(String.isNotEmpty(fieldConversionError)){
                itemsToSave.add(setErrorItem(currentObj.requestItem, fieldConversionError));
                continue;
            }

            if(errorForPicklistValue('Case', 'Type', currentObj.newCase.Type)){
                itemsToSave.add(setErrorItem(currentObj.requestItem, 'Valore processo non corretto: ' + currentObj.newCase.Type));
                continue;
            }
            caseToInsert.add(currentObj.newCase);
            requestItemForUpsert.add(currentObj.requestItem);
        }

        if(caseToInsert.size()>0){
            HDT_WRP_SaveResponse saveResponse=databaseUpsert(caseToInsert,requestItemForUpsert,'Case');
            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
            }
        }
    }

    //public override void makeProcess(){
    //}

    public override void finalUpdate(){
        if(itemsToSave.size() > 0){
            update itemsToSave;
        }
    }

    private void mapFieldsObject(){
        List<HDT_MassiveFieldsObjectMap__mdt> listCaseFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listWrapperCaseFields;
        mapCaseFields = new Map<String, String>();
        mapWrapperCaseFields = new Map<String, String>();

        listCaseFields = getMapFieldsObject('Case', this.processName);
        listWrapperCaseFields = getMapFieldsObject('WrapperCase', this.processName);

        for(HDT_MassiveFieldsObjectMap__mdt temp : listCaseFields){
            mapCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperCaseFields){
            mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

    }


    private class HDT_WRP_ProcessObjects {
        private Case newCase;
        private Contract contract;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }
}
