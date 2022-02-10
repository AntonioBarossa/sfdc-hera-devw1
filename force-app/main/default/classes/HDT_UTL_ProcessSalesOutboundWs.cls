@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessSalesOutboundWs {

    public List<Id> accountIdsList;
    public List<Id> billProfIdsList;
    public List<Id> servPointIdsList;
    List<ServicePoint__c> servicePointList;
    public Map<Id, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj> idsMap;

    public HDT_UTL_ProcessSalesOutboundWs() {
        System.debug(LoggingLevel.DEBUG, 'HDT_UTL_ProcessSalesOutboundWs');
    }

    public void setRequestItemList(List<MassiveLoaderRequestItem__c> requestItemList){

        System.debug(LoggingLevel.DEBUG, '# setRequestItemList #');

        accountIdsList = new List<Id>();
        billProfIdsList = new List<Id>();
        servPointIdsList = new List<Id>();

        HDT_UTL_ProcessSales.HDT_WRP_NextDataObj obj;
        idsMap = new Map<Id, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj>();
        for(MassiveLoaderRequestItem__c singleItem : requestItemList){

            if(!String.isEmpty(singleItem.NextStepData__c)){
                obj = (HDT_UTL_ProcessSales.HDT_WRP_NextDataObj)JSON.deserialize(singleItem.NextStepData__c, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj.class);
                System.debug('>>>> current item data ' + obj);
    
                idsMap.put(singleItem.Id, obj);
    
                accountIdsList.add(obj.accountId);
                billProfIdsList.add(obj.billProfId);
                servPointIdsList.add(obj.servPointId);
            }

        }
    }

    public void getRecords(){
        System.debug(LoggingLevel.DEBUG, '# getRecords #');
        servicePointList = HDT_QR_ProcessSales.getServicePointList(servicePointList, servPointIdsList);
        System.debug(LoggingLevel.DEBUG, '>>> servicePointList size ' + servicePointList.size());
    }

    public void executeWebService(){

        System.debug(LoggingLevel.DEBUG, '# executeWebService #');
        HDT_WS_ArrichmentDataEntityResponse serResp;

        for(ServicePoint__c sp : servicePointList){
            try {
                serResp = HDT_WS_ArrichmentDataEntityInvoker.callService('', sp.Name);//'IT001E04893470'
                System.debug(serResp);
                sp = HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(sp, serResp)[0];
                System.debug('>>> update sp ' + sp);
            } catch (Exception e){
                System.debug('Exception > ' + e.getMessage());
            }
        }

        update servicePointList;

        System.debug('CpuTime > ' + limits.getCpuTime());

    }

}