/**
 * @author Elvin Iluca NTTDATA
 * Classe utility per la gestione della chiusura massiva Order e Case
 **/

@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessChiusuraOrderCase extends HDT_UTL_ProcessExecution {
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private List<HDT_WRP_ProcessObjects> processObjList;
    Map<String, String> mapWrapperCaseFields;
    Map<String, String> mapWrapperOrderFields;
    List<Case> caseList;
    List<Order> orderList;

    Integer caseIndex;
    Integer orderIndex;

    private Map<String, SObject> objMap;
  
    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');

        mapFieldsObject();
 
        caseList = new List<Case>();
        orderList = new List<Order>();
        caseIndex = mapHeaderForWrapper.get(mapWrapperCaseFields.get('CASE'));
        orderIndex = mapHeaderForWrapper.get(mapWrapperOrderFields.get('ORDER'));
        
        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        for(MassiveLoaderRequestItem__c item : requestItemList){
            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);
            checkRequiredFields(item, tempSplitedFields);
            checkConsistentItem(item);
            if(String.isNotBlank(item.Status__c) && item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);                
                continue;
            }
            if(String.isNotBlank(tempSplitedFields[caseIndex])){ 
                caseList.add(new Case(Id = tempSplitedFields[caseIndex]));
            }
            else{
                orderList.add(new Order(Id = tempSplitedFields[orderIndex]));
            }
            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;
            processObjList.add(processObj);
        }
    }
 
    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');
        objMap = new Map<String, SObject>();
        caseList = HDT_QR_ProcessPostSales.getAllCaseIdInList(caseList);
        orderList = HDT_QR_ProcessPostSales.getAllOrderIdInList(orderList);
        for(Case c : caseList){
            objMap.put(c.Id, c);
        }
        for(Order o : orderList){
            objMap.put(o.Id, o);
        }
    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');
        List<Sobject> recordsToUpdate=new List<Sobject>();
        for(HDT_WRP_ProcessObjects currentObj : processObjList){
            String caseId = currentObj.csvSplitted[caseIndex];
            String orderId = currentObj.csvSplitted[orderIndex];
            if(!String.isBlank(caseId) && objMap.get(caseId)!=null){
                Case tempCase = (Case) objMap.get(caseId);
                tempCase.Phase__c = 'Annullato per decorrenza dei termini';
                tempCase.Status = 'Chiuso';
                recordsToUpdate.add(tempCase);
                currentObj.requestItem.Status__c = 'Chiuso';
                itemsToSave.add(currentObj.requestItem);
                continue;
            }
            if(!String.isBlank(orderId) && objMap.get(orderId)!=null){
                Order tempOrder = (Order) objMap.get(orderId);
                tempOrder.Phase__c = 'Annullato per decorrenza dei termini';
                tempOrder.Status = 'Completed';
                recordsToUpdate.add(tempOrder);
                currentObj.requestItem.Status__c = 'Chiuso';
                itemsToSave.add(currentObj.requestItem);               
                continue;
            }
            setErrorItem(currentObj.requestItem, 'Errore, Id non presente nel DB');
            itemsToSave.add(currentObj.requestItem); 
        }
        if(recordsToUpdate.size()>0){
            List<Database.SaveResult> retList = Database.update(recordsToUpdate, false);
            for(Database.SaveResult record : retList){
                if(!record.isSuccess()){ 
                    for(MassiveLoaderRequestItem__c item : itemsToSave){
                        List<String> splittedId = item.Data__c.split(splitCharacter, -1);
                        
                        String recordId = record.getId();
                        if(( recordId == splittedId[caseIndex]) || (recordId == splittedId[orderIndex])){
                            setErrorItem(item, 'DML Error: ' + record.getErrors()[0].getMessage());
                        }

                    }
                }
            }
        }
    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');

        if(itemsToSave.size() > 0){
            update itemsToSave;
        }
    }

    private void checkConsistentItem(MassiveLoaderRequestItem__c item){
        List<String> row = item.Data__c.split(splitCharacter, -1);
        if((String.isBlank(row[caseIndex]) && String.isBlank(row[orderIndex])) || (!String.isBlank(row[caseIndex]) && !String.isBlank(row[orderIndex]))){
            setErrorItem(item, 'Error Data__c format');
        }
    }

    private void mapFieldsObject(){
        //esegue il caricamento dei valori in mappa
        List<HDT_MassiveFieldsObjectMap__mdt> listCaseFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listOrderFields;

        mapWrapperCaseFields = new Map<String, String>();
        mapWrapperOrderFields = new Map<String, String>();

        listCaseFields = getMapFieldsObject('WrapperCase', this.processName);
        listOrderFields = getMapFieldsObject('WrapperOrder', this.processName);
        System.debug(LoggingLevel.DEBUG, '>>> listCaseFields' + listCaseFields);
        System.debug(LoggingLevel.DEBUG, '>>> listOrderFields' + listOrderFields);

        for(HDT_MassiveFieldsObjectMap__mdt temp : listCaseFields){
            mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listOrderFields){
            mapWrapperOrderFields.put(temp.labelField__c, temp.nameField__c);
        }

    }

    private class HDT_WRP_ProcessObjects {
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }
}