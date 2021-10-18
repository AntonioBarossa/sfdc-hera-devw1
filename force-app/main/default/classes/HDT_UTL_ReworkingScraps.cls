public with sharing class HDT_UTL_ReworkingScraps extends  HDT_UTL_ProcessExecution { 
    private List<String> listIdOrder = new List<String>();
    private List<String> listIdCase  = new List<String>();

    public override void checks(){

        for (String tempField : currentProcess.currentRequestItem.Data__c.split(',')) {
            if ('O-'.containsIgnoreCase(tempField)) {
                listIdOrder.add(tempField);
            }
            else if('C-'.containsIgnoreCase(tempField)) {
                listIdCase.add(tempField);
            }
            else {
                throw new HDT_WRP_ProcessEntitiesException( 'Number Not Recognized','Number Not Recognized OrderNumber/CaseNumber');
            }
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
            currentProcess.currentFatherOrder=listOrd.get(0);
        }
        else if (listCase!=null && listCase.size()>0) {
            currentProcess.currentCase=listCase.get(0);
        }
    }
    /*public override void finalUpdate(){

    }
*/
}