/**
 * @author Elvin Iluca NTTDATA
 * Classe utility per la gestione della chiusura massiva Order e Case
 **/

@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessChiusuraOrderCase extends HDT_UTL_ProcessExecution {
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Map<String, SObject> objMap;
  
    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');
        
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
            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;
            processObjList.add(processObj);
        }
    }
 
    public override void getRecords(){
        System.debug(LoggingLevel.DEBUG, 'getRecords');
        objMap = new Map<String, SObject>();
        List<Case> caseList = HDT_QR_ProcessPostSales.getAllCaseId();
        List<Order> orderList = HDT_QR_ProcessPostSales.getAllOrderId();
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
            String caseId = currentObj.csvSplitted[0];
            String orderId = currentObj.csvSplitted[1];
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
        }
        if(recordsToUpdate.size()>0){
            List<Database.SaveResult> retList = Database.update(recordsToUpdate, false);
            for(Database.SaveResult record : retList){
                if(!record.isSuccess()){ 
                    for(MassiveLoaderRequestItem__c item : itemsToSave){
                        List<String> splittedId = item.Data__c.split(splitCharacter, -1);
                        
                        String recordId = record.getId();
                        if(( recordId == splittedId[0]) || (recordId == splittedId[1])){
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
        if((String.isBlank(row[0]) && String.isBlank(row[1])) || (!String.isBlank(row[0]) && !String.isBlank(row[1]))){
            setErrorItem(item, 'Error Data__c format');
        }
    }

    private class HDT_WRP_ProcessObjects {
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }
}