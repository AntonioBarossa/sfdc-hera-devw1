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
    List<AccountContactRelation> accContRelList;
    Map<Id, AccountContactRelation> accRelMap;
    List<MassiveLoaderRequestItem__c> requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();
    private Set<String> servicePointFields;
    private String process;

    public HDT_UTL_ProcessSalesOutboundWs() {
        System.debug(LoggingLevel.DEBUG, 'HDT_UTL_ProcessSalesOutboundWs');
    }

    public void setRequestItemList(List<MassiveLoaderRequestItem__c> requestItemList, String process){
        this.requestItemList = requestItemList;
        this.process = process;
        setServicePointFields('ServicePoint__c', 'CarMassEnrichmentFields');
    }

    public void generateWrapperMap(){

        System.debug(LoggingLevel.DEBUG, '# setRequestItemList #');

        accountIdsList = new List<Id>();
        billProfIdsList = new List<Id>();
        servPointIdsList = new List<Id>();
        Set<Id> servPointIdSet = new Set<Id>();
        accRelMap = new Map<Id, AccountContactRelation>();

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
                    //servPointIdsList.add(obj.servPointId);
                    servPointIdSet.add(obj.servPointId);
                }

            }

        }

        if(servPointIdSet.size()>0){
            servPointIdsList.addAll(servPointIdSet);
        }

    }

    public void getRecords(){
        System.debug(LoggingLevel.DEBUG, '# getRecords #');

        servicePointList = HDT_QR_ProcessSales.getServicePointList(servicePointList, servPointIdsList);
        servicePointMap = new Map<Id, ServicePoint__c>(servicePointList);

        System.debug(LoggingLevel.DEBUG, '>>> servicePointList size ' + servicePointList.size());

        accContRelList = HDT_QR_ProcessSales.getAccountContactRelationList(accContRelList, accountIdsList);

        for(AccountContactRelation rel : accContRelList){
           accRelMap.put(rel.AccountId, rel);
        }

    }

    public void executeWebService(){

        System.debug(LoggingLevel.DEBUG, '# executeWebService #');
        HDT_WS_ArrichmentDataEntityResponse serResp;
        servicePointToUpdate = new List<ServicePoint__c>();
        List<Account> accountToUpdate = new List<Account>();
        ServicePoint__c servPointFromWs;
        ServicePoint__c oldServPoint;
        Id servicePointId;
        Id accountId;
        Account account;
        Contact contact;
        
        for(MassiveLoaderRequestItem__c singleItem : requestItemList){
            try {
                servicePointId = idsMap.get(singleItem.Id).servPointId;

                if(String.isNotEmpty(servicePointId)){

                    servPointFromWs = servicePointMap.get(servicePointId);

                    if(process.equalsIgnoreCase('CambioUso')){
                        oldServPoint = setOldServicePoint(servPointFromWs, oldServPoint);
                    }

                    serResp = HDT_WS_ArrichmentDataEntityInvoker.callService('', servPointFromWs.Name);
                    System.debug(serResp);

                    if(serResp.statusCode == 200){
                        servPointFromWs = HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(servPointFromWs, serResp)[0];
                        System.debug(LoggingLevel.DEBUG, '>>> update sp ' + servPointFromWs);

                        if(process.equalsIgnoreCase('CambioUso')){
                            servPointFromWs = setServicePointAfterWebService(servPointFromWs, oldServPoint);
                        }

                        servicePointToUpdate.add(servPointFromWs);
                        requestItemForUpsert.add(singleItem);
                    } else {
                        System.debug(LoggingLevel.DEBUG, '>>> [ServicePoint__c] errore arrichimento dati');
                    }
                }
            } catch (Exception e){
                System.debug(LoggingLevel.DEBUG, 'Exception > HDT_UTL_ProcessSalesOutboundWs: ' + e.getMessage());
                singleItem.Status__c = 'Errore';
                singleItem.StatusDescription__c = e.getMessage().abbreviate(250);
            }
        }
    }

    public void updateItems(){

        if(servicePointToUpdate.size() > 0){
            update servicePointToUpdate;
        }

        update requestItemList;
        //HDT_UTL_ProcessExecution.getLimitDetails('finalUpdate');
    }

    public static Account setAccountRecord(AccountContactRelation rel, Account a){
        a.Id = rel.AccountId;
        a.Name = rel.Account.Name;
        a.RecordTypeId = rel.Account.RecordTypeId;
        a.LastName__c = rel.Account.LastName__c;
        a.FirstName__c = rel.Account.FirstName__c;
        a.Category__c = rel.Account.Category__c;
        a.Fax = rel.Account.Fax;
        a.CustomerMarking__c = rel.Account.CustomerMarking__c;
        a.FiscalCode__c = rel.Account.FiscalCode__c;
        a.Vatnumber__c = rel.Account.Vatnumber__c;
        a.BillingCity = rel.Account.BillingCity;
        a.BillingCountry = rel.Account.BillingCountry;
        a.BillingStreetNumber__c = rel.Account.BillingStreetNumber__c;
        a.BillingPostalCode = rel.Account.BillingPostalCode;
        a.BillingState = rel.Account.BillingState;
        a.BillingStreetName__c = rel.Account.BillingStreetName__c;
        a.CustomerCode__c = rel.Account.CustomerCode__c;
        a.MobilePhone__c = rel.Account.MobilePhone__c;
        a.BuildingFloor__c = rel.Account.BuildingFloor__c;
        a.PrimaryEmail__c = rel.Account.PrimaryEmail__c;
        a.VATGroup__c = rel.Account.VATGroup__c;
        a.VATGroupStartDate__c = rel.Account.VATGroupStartDate__c;
        a.VATGroupEndDate__c = rel.Account.VATGroupEndDate__c;
        return a;
    }

    public static Contact setContactRecord(AccountContactRelation rel, Contact c){
        c.Id = rel.ContactId;
        c.MobilePhone = rel.Contact.MobilePhone;
        c.email = rel.Contact.email;
        c.fiscalCode__c = rel.Contact.fiscalCode__c;
        c.CertifiedEmail__c = rel.Contact.CertifiedEmail__c;
        return c;
    }

    private ServicePoint__c setOldServicePoint(ServicePoint__c servPointFromWs, ServicePoint__c oldServPoint){
        oldServPoint = new ServicePoint__c();
 
        Map<String, Object> fieldsToValue;
        fieldsToValue = servPointFromWs.getPopulatedFieldsAsMap();

        Object field;
        for(String fieldToSet : servicePointFields){
            field = fieldsToValue.get(fieldToSet);
            oldServPoint.put(fieldToSet, field);
        }

        return oldServPoint;
    }

    private ServicePoint__c setServicePointAfterWebService(ServicePoint__c servPointFromWs, ServicePoint__c oldServPoint){

        Map<String, Object> fieldsToValue;
        fieldsToValue = oldServPoint.getPopulatedFieldsAsMap();

        Object field;
        for(String fieldToSet : servicePointFields){
            field = fieldsToValue.get(fieldToSet);
            servPointFromWs.put(fieldToSet, field);
        }

        return servPointFromWs;
    }

    public void setServicePointFields(String sObjectName, String fieldSetName){
        List<Schema.FieldSetMember> fieldSetMembers;
        servicePointFields = new Set<String>();  
        fieldSetMembers = ((SObject)Type.forName(sObjectName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
        for(Schema.FieldSetMember s : fieldSetMembers) {
            servicePointFields.add(String.valueOf(s.getFieldPath()));
        }
    }

}