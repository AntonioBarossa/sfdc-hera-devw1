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
    private Map<String, String> accountContactMap = new Map<String, String>();
    private Map<String, Contract> podContractMap = new Map<String, Contract>();
    
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

            processObjList.add(processObj);

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
