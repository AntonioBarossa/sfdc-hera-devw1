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
    List<String> casesId;
    List<String> ordersId;
    List<Case> caseList;
    List<Order> orderList;

    Integer caseIndex;
    Integer orderIndex;

    private Map<String, SObject> objMap;
  
    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');

        mapFieldsObject();
 
        casesId = new List<String>();
        ordersId = new List<String>();
        //caseList = new List<Case>();
        //orderList = new List<Order>();
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
                //caseList.add(new Case(Id = tempSplitedFields[caseIndex]));
                casesId.add(tempSplitedFields[caseIndex]);
            }
            else{
                //orderList.add(new Order(Id = tempSplitedFields[orderIndex]));
                ordersId.add(tempSplitedFields[orderIndex]);
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
        caseList = new List<Case>();
        orderList = new List<Order>();
        caseList = HDT_QR_ProcessPostSales.getAllCaseIdInList(casesId);
        orderList = HDT_QR_ProcessPostSales.getAllOrderIdInList(ordersId);
        for(Case c : caseList){
            objMap.put(c.Id, c);
        }
        for(Order o : orderList){
            objMap.put(o.Id, o);
        }
    }

    public override void registryCreation(){
        System.debug(LoggingLevel.DEBUG, 'registryCreation');
        List<Case> caseToSave = new List<Case>();
        List<Order> orderToSave = new List<Order>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsertOrd = new List<MassiveLoaderRequestItem__c>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsertCase = new List<MassiveLoaderRequestItem__c>();

        for(HDT_WRP_ProcessObjects currentObj : processObjList){
            String caseId = currentObj.csvSplitted[caseIndex];
            String orderId = currentObj.csvSplitted[orderIndex];
            if(!String.isBlank(caseId) && objMap.get(caseId)!=null){
                Case tempCase = (Case) objMap.get(caseId);
                tempCase.Phase__c = 'Annullato per decorrenza dei termini';
                tempCase.Status = 'Chiuso';
                caseToSave.add(tempCase);
                requestItemForUpsertCase.add(currentObj.requestItem);              
                continue;
            }
            if(!String.isBlank(orderId) && objMap.get(orderId)!=null){
                Order tempOrder = (Order) objMap.get(orderId);
                tempOrder.Phase__c = 'Annullato per decorrenza dei termini';
                tempOrder.Status = 'Completed';
                orderToSave.add(tempOrder);
                requestItemForUpsertOrd.add(currentObj.requestItem);            
                continue;
            }
            setErrorItem(currentObj.requestItem, 'Errore, Id non presente nel DB');
            itemsToSave.add(currentObj.requestItem); 
        }

        System.debug(LoggingLevel.DEBUG, '>>> itemsToSave' + itemsToSave);

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