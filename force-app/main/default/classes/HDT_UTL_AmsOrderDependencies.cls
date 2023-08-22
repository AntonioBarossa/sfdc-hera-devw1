public with sharing class HDT_UTL_AmsOrderDependencies 
{
    HDT_QR_AmsAdministration amsQr = new HDT_QR_AmsAdministration();

    public List<Order> startOperations(String method){
        List<Order> orderToWork = new List<Order>();
        switch on method {
            when 'SEQUENZIALIZZAZIONE_ORDERS' 
            {
                orderToWork = amsQr.getOrderToSeq();
            }
            when 'DESEQUENZIALIZZAZIONE_ORDERS'
            {
                orderToWork = amsQr.getOrderToDeseq();
            }
            when else {

            }
        }
        return orderToWork;
    }


    public HDT_WRP_AmsAdministration.HDT_WRP_OperationResult operate(String method, List<Order> orderToWork){
        HDT_WRP_AmsAdministration.HDT_WRP_OperationResult result = new HDT_WRP_AmsAdministration.HDT_WRP_OperationResult();
        switch on method {
            when 'SEQUENZIALIZZAZIONE_ORDERS' 
            {
                result = sequenzialization(orderToWork);
            }
            when 'DESEQUENZIALIZZAZIONE_ORDERS'
            {
                result = desequenzialization(orderToWork);
            }
            when else {

            }
        }
        return result;
    }

    /* Per consentire il corretto funzionamento e' necessario che le attivita siano chiuse prima del passaggio di fase degli ordini */
    private HDT_WRP_AmsAdministration.HDT_WRP_OperationResult sequenzialization(List<Order> orderToWork){
        HDT_WRP_AmsAdministration.HDT_WRP_OperationResult result = new HDT_WRP_AmsAdministration.HDT_WRP_OperationResult();
        List<wrts_prcgvr__Activity__c> actToClose = new List<wrts_prcgvr__Activity__c>();
        for(Order o : orderToWork)
        {
            if(o.Activities_Custom__r != null && o.Activities_Custom__r[0].Id != null)
            {
                actToClose.add(new wrts_prcgvr__Activity__c(Id = Activities_Custom__r[0].Id, ClosingNote__c = 'Chiusura per Bonifica AMS', wrts_prcgvr__Status__c = 'Chiusa	'));
            }
            o.Phase__c = 'Sequenzializzato';
            o.Status = 'Sequenzializzato';
        }
        if(!actToClose.isEmpty())
        {
            result.results.addAll(performUpdateOperation(actToClose, 'wrts_prcgvr__Activity__c'));
        }
        if(orderToWork.isEmpty())
        {
            result.results.addAll(performUpdateOperation(orderToWork, 'Order'));
        }
        return result;
    }

    private HDT_WRP_AmsAdministration.HDT_WRP_OperationResult desequenzialization(List<Order> orderToWork){
        List<ServiceRequest> srToDelete = orderToWork.ServiceRequests__r;
        HDT_WRP_AmsAdministration.HDT_WRP_OperationResult result = new HDT_WRP_AmsAdministration.HDT_WRP_OperationResult();
        // Salvare informazioni su numero record
        if(!srToDelete.isEmpty())
        {
            result.results.addAll(performDeleteOperation(srToDelete, 'ServiceRequest__c'));
        }
        for(Order o : orderToWork)
        {
            o.Phase__c = 'Esportazione VS Siebel';
            o.Status = 'In Lavorazione';
        }
        if(!orderToWork.isEmpty())
        {
            result.results.addAll(performUpdateOperation(orderToWork, 'Order'));
        }
        return result;
    }


    private List<HDT_WRP_AmsAdministration.HDT_WRP_Result> performDeleteOperation(List<SObject> sobjToDelete, String objectName)
    {
        List<HDT_WRP_AmsAdministration.HDT_WRP_Result> result = new List<HDT_WRP_AmsAdministration.HDT_WRP_Result>();
        Database.DeleteResult[] deleteResults = Database.delete(sobjToDelete, false);
        for(Database.DeleteResult dRes : deleteResults)
        {
            HDT_WRP_AmsAdministration.HDT_WRP_Result singleResult = new HDT_WRP_AmsAdministration.HDT_WRP_Result();
            if(!dRes.isSuccess())
            {
                for(Database.Error err : dRes.getErrors())
                {
                    singleResult.errorMessage = err.getMessage();
                    singleResult.isSuccess = false;
                    singleResult.objectType = objectName;
                    singleResult.recordId = dRes.getId();
                }
            }
            else{
                singleResult.isSuccess = true;
                singleResult.recordId = dRes.getId();
                singleResult.objectType = objectName;
            }
            result.add(singleResult);
        }
        return result;
    }

    private List<HDT_WRP_AmsAdministration.HDT_WRP_Result> performUpdateOperation(List<SObject> sobjToUpdate, String objectName)
    {
        List<HDT_WRP_AmsAdministration.HDT_WRP_Result> result = new List<HDT_WRP_AmsAdministration.HDT_WRP_Result>();
        Database.SaveResult[] updateResults = Database.update(sobjToUpdate, false);
        for(Database.SaveResult sRes : updateResults)
        {
            HDT_WRP_AmsAdministration.HDT_WRP_Result singleResult = new HDT_WRP_AmsAdministration.HDT_WRP_Result();
            if(!sRes.isSuccess())
            {
                for(Database.Error err : sRes.getErrors())
                {
                    singleResult.errorMessage = err.getMessage();
                    singleResult.isSuccess = false;
                    singleResult.objectType = objectName;
                    singleResult.recordId = sRes.getId();
                }
            }
            else{
                singleResult.isSuccess = true;
                singleResult.recordId = sRes.getId();
                singleResult.objectType = objectName;
            }
            result.add(singleResult);
        }
        return result;
    }

}