@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessSalesOutboundWs {

    private List<Id> accountIdsList;
    private List<Id> billProfIdsList;
    private List<Id> servPointIdsList;
    private List<ServicePoint__c> servicePointList;
    private Map<Id, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj> idsMap;
    Map<Id, ServicePoint__c> servicePointMap;
    List<MassiveLoaderRequestItem__c> requestItemList;
    List<ServicePoint__c> servicePointToUpdate;

    public HDT_UTL_ProcessSalesOutboundWs() {
        System.debug(LoggingLevel.DEBUG, 'HDT_UTL_ProcessSalesOutboundWs');
    }

    public void setRequestItemList(List<MassiveLoaderRequestItem__c> requestItemList){
        this.requestItemList = requestItemList;
    }

    public void generateWrapperMap(){

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
    
                if(String.isNotEmpty(obj.accountId)){
                    accountIdsList.add(obj.accountId);
                }

                if(String.isNotEmpty(obj.billProfId)){
                    billProfIdsList.add(obj.billProfId);
                }

                if(String.isNotEmpty(obj.servPointId)){
                    servPointIdsList.add(obj.servPointId);
                }

            }

        }
    }

    public void getRecords(){
        System.debug(LoggingLevel.DEBUG, '# getRecords #');

        servicePointList = HDT_QR_ProcessSales.getServicePointList(servicePointList, servPointIdsList);
        servicePointMap = new Map<Id, ServicePoint__c>(servicePointList);

        System.debug(LoggingLevel.DEBUG, '>>> servicePointList size ' + servicePointList.size());

    }

    public void executeWebService(){

        System.debug(LoggingLevel.DEBUG, '# executeWebService #');
        HDT_WS_ArrichmentDataEntityResponse serResp;
        servicePointToUpdate = new List<ServicePoint__c>();

        ServicePoint__c servPointFromWs;
        Id servicePointId;
        for(MassiveLoaderRequestItem__c singleItem : requestItemList){

            servicePointId = idsMap.get(singleItem.Id).servPointId;

            if(String.isNotEmpty(servicePointId)){
                try {
                    servPointFromWs = servicePointMap.get(servicePointId);

                    serResp = HDT_WS_ArrichmentDataEntityInvoker.callService('', servPointFromWs.Name);//'IT001E04893470'
                    //serResp = HDT_WS_ArrichmentDataEntityInvoker.callService('', 'xxx');
                    System.debug(serResp);

                    if(serResp == null || serResp.statusCode != 200){
                        singleItem.Status__c = 'Errore';
                        singleItem.StatusDescription__c = '[' + serResp.errorDetails[0].code + '] ' + serResp.errorDetails[0].message;
                        System.debug(LoggingLevel.DEBUG, '>>> Additional info: ' + serResp.errorDetails[0].additionalInfo);
                        continue;
                    }

                    servPointFromWs = HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(servPointFromWs, serResp)[0];
                    System.debug(LoggingLevel.DEBUG, '>>> update sp ' + servPointFromWs);

                    servicePointToUpdate.add(servPointFromWs);

                    singleItem.Status__c = 'Chiuso';

                } catch (Exception e){
                    System.debug(LoggingLevel.DEBUG, 'Exception > ' + e.getMessage());
                    singleItem.Status__c = 'Errore';
                    singleItem.StatusDescription__c = e.getMessage().abbreviate(250);
                }

            }

        }

        System.debug(LoggingLevel.DEBUG, 'CpuTime > ' + limits.getCpuTime());

    }

    public void updateItems(){

        if(servicePointToUpdate.size() > 0){
            update servicePointToUpdate;
        }

        update requestItemList;
    }

}