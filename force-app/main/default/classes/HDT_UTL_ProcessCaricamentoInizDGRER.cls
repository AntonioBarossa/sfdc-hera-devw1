/**
 * Marco Ficorella - NTTDATA - 30/11/2022
 * Processo di caricamento massivo per aggiornamento iniziativa DGRER
 * 
 **/
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessCaricamentoInizDgrer extends HDT_UTL_ProcessExecution {
    private Map<String, String> mapWrapperContractFields;
    private Integer contractIndex;
    private Integer dgrerIndex;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Set<String> contractCodeSet = new Set<String>();
    private List<Contract> contractList;
    private Map<String,String> mapContractDGRER;
    private List<MassiveLoaderRequestItem__c> itemsToSave;

    public override void checks(){
        /* CARICAMENTO DEI DATI UTILI AL PROCESSO E CONTROLLI PRELIMINARI*/
        itemsToSave=new List<MassiveLoaderRequestItem__c>();
        mapContractDGRER=new Map<String,String>();
        HDT_WRP_ProcessObjects processObj;
        processObjList=new List<HDT_WRP_ProcessObjects>();
        mapFieldsObject();
        contractIndex = mapHeaderForWrapper.get(mapWrapperContractFields.get('CONTRATTO'));
        dgrerIndex = mapHeaderForWrapper.get(mapWrapperContractFields.get('INIZIATIVA'));
        List<String> tempSplitedFields;
        System.debug(LoggingLevel.DEBUG, '>>> Index: contract [' + contractIndex + '];');
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
            
            String contractCode=processObj.csvSplitted[contractIndex];
            String dgrer=processObj.csvSplitted[dgrerIndex];
            contractCodeSet.add(contractCode);
            mapContractDGRER.put(contractCode, dgrer);
            processObjList.add(processObj);

           

        }

    }

    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');
        /* RECUPERO I CONTRATTI E CREO MAPPE*/
        Map<String,Contract> mapContract=new Map<String,Contract>();
        contractList=HDT_QR_ProcessPostSales.getContractsByCodSAPGDRER(contractList, contractCodeSet);
        
        for(Contract cnt:contractList){
            mapContract.put(cnt.SAPContractCode__c, cnt);
        }

        for(HDT_WRP_ProcessObjects procObj:processObjList){
            String contractCode=procObj.csvSplitted[contractIndex];
            Contract cnt=mapContract.get(contractCode);
            procObj.contract=cnt;
        }


    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');
        List<MassiveLoaderRequestItem__c> requestItemForUpsert;
        requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();
        List<Contract> contractToUpdate=new List<Contract>();

        getLimitDetails('START registryCreation');
        /*PREPARAZIONE DATI PER UPDATE*/
        for(HDT_WRP_ProcessObjects procObj:processObjList){
            String contractCode=procObj.contract.SAPContractCode__c;
            String dgrer=mapContractDGRER.get(contractCode);
            procObj.contract.Iniziativa__c=dgrer;
            contractToUpdate.add(procObj.contract);
            requestItemForUpsert.add(procObj.requestItem);

        }


        if(!contractToUpdate.isEmpty()){
            
            HDT_WRP_SaveResponse saveResponse;
            saveResponse = databaseUpsert(contractList, requestItemForUpsert, 'Contract');
 
            getLimitDetails('AFTER CONTRACT UPDATE');
            if(saveResponse.reponseItemList.size() > 0){
                itemsToSave.addAll(saveResponse.reponseItemList);
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

        List<HDT_MassiveFieldsObjectMap__mdt> listWrapperContractFields;
        mapWrapperContractFields=new Map<String,String>();

        listWrapperContractFields = getMapFieldsObject('WrapperContract', this.processName);
        System.debug(LoggingLevel.DEBUG, '>>> listWrapperContractFields: ' + listWrapperContractFields);

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperContractFields){
            mapWrapperContractFields.put(temp.labelField__c, temp.nameField__c);
        }

    }


    private class HDT_WRP_ProcessObjects {
        private Contract contract;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }
}
