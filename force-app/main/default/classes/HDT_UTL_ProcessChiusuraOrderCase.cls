/**
 * @author Elvin Iluca NTTDATA
 * Classe utility per la gestione della chiusura massiva Order e Case
 **/

@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessChiusuraOrderCase extends HDT_UTL_ProcessExecution {
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private Map<String, String> mapCaseFields;
    private Map<String, String> mapWrapperCaseFields;
    private Map<String, String> mapWrapperOrderFields;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private Map<String, SObject> objMap;


 //map<Id,processObject>    
    public override void checks(){
        System.debug(LoggingLevel.DEBUG, 'checks');

        //Controlli SE CASE != NULL ORDER != NULL SOLO CASE è popolato o solo ORDER è popolato
        
        mapFieldsObject();
        //map.put(caseid||orderId,processObject)
        // System.debug('DEB1: ' + mapCaseFields);
        // System.debug('DEB2: ' + mapWrapperCaseFields);
        // System.debug('DEB3: ' + mapWrapperOrderFields);

        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        // System.debug('DEB3.5: ' + requestItemList);
        for(MassiveLoaderRequestItem__c item : requestItemList){
            tempSplitedFields = new List<String>();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);//valore dei campi
           // System.debug(tempSplitedFields);
            checkRequiredFields(item, tempSplitedFields);
            checkConsistentItem(item);
            //System.debug(item);
            if(String.isNotBlank(item.Status__c) && item.Status__c.equalsIgnoreCase('Errore')){
                itemsToSave.add(item);
                continue;
            }
            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;
            processObj.csvSplitted = tempSplitedFields;
            processObjList.add(processObj);
        }
        //System.debug('DEB4: ' + itemsToSave);
        // System.debug('DEB5: ' + processObjList);
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
        //check integrita' sul db degli id in input
        for(HDT_WRP_ProcessObjects currentObj : processObjList){
            //Se l'id dell SObject in question non e' presente ne in caseList ne in orderList -> Errore
            String caseId = currentObj.csvSplitted[0];
            String orderId = currentObj.csvSplitted[1];
            if(!String.isBlank(caseId) && objMap.get(caseId)!=null){
                System.debug('Il case e\' presente nel db ' + currentObj);
                Case tempCase = (Case) objMap.get(caseId);
                tempCase.Phase__c = 'Annullato per decorrenza dei termini';
                tempCase.Status = 'Chiuso';
                //Cambio fase e status al case
                recordsToUpdate.add(tempCase);
                currentObj.requestItem.Status__c = 'Chiuso';
                itemsToSave.add(currentObj.requestItem);
                continue;
            }
            if(!String.isBlank(orderId) && objMap.get(orderId)!=null){
                System.debug('I\'order e\' presente nel db ' + currentObj);
                Order tempOrder = (Order) objMap.get(orderId);
                tempOrder.Phase__c = 'Annullato per decorrenza dei termini';
                tempOrder.Status = 'Completed';
                recordsToUpdate.add(tempOrder);

                currentObj.requestItem.Status__c = 'Chiuso';
                itemsToSave.add(currentObj.requestItem);
               
                continue;
            }
            System.debug('Errore object: ' + currentObj);
            setErrorItem(currentObj.requestItem, 'Errore, Id non presente nel DB');
        }
        if(recordsToUpdate.size()>0){ //Order e phase
            update recordsToUpdate;
        }
        System.debug(recordsToUpdate);

    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');

        if(itemsToSave.size() > 0){
            update itemsToSave;
        }

    }

    /*
    public virtual void registryCreation(){
    List<Sobject> recordsToUpdate=new List<Sobject>();
        System.debug(LoggingLevel.DEBUG, 'registryCreation');
        //aggiorni le fasi e stato
        for(HDT_WRP_ProcessObjects wrp: map.values){
            if(wrp.recordToProcess.getSobjectTYpe=='Case){
            }else{
            }
            recordsToupdate.add(recordToProcess)
        }
        if(recordsToUpdate.size>0){ //Order e phase
            update;
        }
    }
    public virtual void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');
        if(item to save .size>0){
            update item save //MassiveLoaderRequestItem
        }
    } */


    private void checkConsistentItem(MassiveLoaderRequestItem__c item){
        List<String> row = item.Data__c.split(splitCharacter, -1);
        if((String.isBlank(row[0]) && String.isBlank(row[1])) || (!String.isBlank(row[0]) && !String.isBlank(row[1]))){
            setErrorItem(item, 'Error Data__c format');
        }
    }

    private void mapFieldsObject(){
        List<HDT_MassiveFieldsObjectMap__mdt> listCaseFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listWrapperCaseFields;
        List<HDT_MassiveFieldsObjectMap__mdt> listWrapperOrderFields;
        mapCaseFields = new Map<String, String>();
        mapWrapperCaseFields = new Map<String, String>();
        mapWrapperOrderFields = new Map<String, String>();

        listCaseFields = getMapFieldsObject('Case', this.processName);
        listWrapperCaseFields = getMapFieldsObject('WrapperCase', this.processName);
        listWrapperOrderFields = getMapFieldsObject('WrapperOrder', this.processName);

        for(HDT_MassiveFieldsObjectMap__mdt temp : listCaseFields){
            mapCaseFields.put(temp.labelField__c, temp.nameField__c); //mappa header -> api
        }

        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperCaseFields){
            mapWrapperCaseFields.put(temp.labelField__c, temp.nameField__c);
        }
        for(HDT_MassiveFieldsObjectMap__mdt temp : listWrapperOrderFields){
            mapWrapperOrderFields.put(temp.labelField__c, temp.nameField__c);
        }

    }

    private class HDT_WRP_ProcessObjects {
        //private Case refCase;
        //private Order refOrder;
        private Sobject recordToProcess;
        private MassiveLoaderRequestItem__c requestItem; //<---- in caso di assenza del case/order
        private List<String> csvSplitted; //<--- 
    }
}