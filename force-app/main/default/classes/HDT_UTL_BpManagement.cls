
public with sharing class HDT_UTL_BpManagement extends HDT_UTL_ProcessExecution{

    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Set<String>contractCodes=new Set<String>();
    private Integer contractIndex;
    public override void checks(){
        mapFieldsObject();
        contractIndex = mapHeaderForWrapper.get('CODICECONTRATTO');
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);//valore dei campi
            checkRequiredFields(item, tempSplitedFields);
            if(String.isNotBlank(item.Status__c) && item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }
            contractCodes.add(tempSplitedFields[contractIndex]);
            processObjList.add(new HDT_WRP_ProcessObjects(item,tempSplitedFields));
        }
        //case RT HDT_RT_UnificazioneSeparazioneCABolletta
    }
    public override void getRecords(){}
    public override void registryCreation(){
        for(HDT_WRP_ProcessObjects currentObj:processObjList){
            currentObj.newCase
        }
    }
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
            mapCaseFields.put(temp.labelField__c, temp.nameField__c); //mappa header -> api
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperCaseFields){
            mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

    }

    private class HDT_WRP_ProcessObjects {
        private Case newCase;
        //private Contract contract;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;

        public HDT_WRP_ProcessObjects(){}

        public HDT_WRP_ProcessObjects(MassiveLoaderRequestItem__c requestItem,List<String>csvSplitted){
            this.requestItem=requestItem;
            this.csvSplitted=csvSplitted;
        }

        public HDT_WRP_ProcessObjects(MassiveLoaderRequestItem__c requestItem,List<String>csvSplitted,Case newCase){
            this.requestItem=requestItem;
            this.csvSplitted=csvSplitted;
            this.newCase=newCase;
        }
    }
}