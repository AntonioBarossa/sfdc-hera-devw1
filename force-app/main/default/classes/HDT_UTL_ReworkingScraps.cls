public with sharing class HDT_UTL_ReworkingScraps extends  HDT_UTL_ProcessExecution { 
    private List<String> listIdOrder = new List<String>();
    private List<String> listIdCase  = new List<String>();

    public override void checks(){
        Integer count=0;
        for (String tempField : currentProcess.currentRequestItem.Data__c.split(',')) {
            // Se devono essere aggiunti altri campi req
            if ('null'.equalsIgnoreCase(tempField)) {
                tempField='';
            }
            if (mapRequiredByPosition.get(count)!=null && String.isBlank(tempField)) {
                throw new HDT_WRP_ProcessEntitiesException( 'Missing Required Field','Missing Required Field '+mapHeaderByPosition.get(count));
            }
            // Se devono essere aggiunti altri campi req
            if ('OrderNumber/CaseNumber'.equalsIgnoreCase(mapHeaderByPosition.get(count))&&tempField.startsWith('O-')) {
                listIdOrder.add(tempField);
            }
            else if('OrderNumber/CaseNumber'.equalsIgnoreCase(mapHeaderByPosition.get(count))&&tempField.startsWith('C-')) {
                listIdCase.add(tempField);
            }

            count++;
        }
    }
    public override void getRecords(){
        List<Order> listOrd;
        List<Case> listCase;
        if (listIdOrder!=null && listIdOrder.size()>0) {
            listOrd = qrOrder.getOrdersByOrderNumber(listIdOrder);
        }
        else if (listIdCase!=null && listIdCase.size()>0) {
            listCase = qrCase.getCasesByCaseNumbers(listIdCase);
        }

        if (listOrd!=null && listOrd.size()>0) {
            currentProcess.currentFatherOrder               = listOrd.get(0);
            currentProcess.currentRequestItem.Account__c    = currentProcess.currentFatherOrder.AccountId ;
        }
        else if (listCase!=null && listCase.size()>0) {
            currentProcess.currentCase                      = listCase.get(0);
            currentProcess.currentRequestItem.Account__c    = currentProcess.currentCase.AccountId;
        }
        if ((listOrd==null ||listOrd.isEmpty())  &&(listCase==null ||listCase.isEmpty()) ) {
            throw new HDT_WRP_ProcessEntitiesException( 'Number Not Recognized','Number Not Recognized OrderNumber/CaseNumber');
        }
    }
    public override void finalUpdate(){
        currentProcess.currentRequestItem.Status__c=constant.MASSIVLOADER_STATUS_CHIUSO;
        update  currentProcess.currentRequestItem;
    }
}