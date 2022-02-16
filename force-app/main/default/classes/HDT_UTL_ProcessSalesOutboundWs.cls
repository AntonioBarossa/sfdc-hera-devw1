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
    List<String> itemIds = new List<String>();

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
        Id servicePointId;
        Id accountId;
        Account account;
        Contact contact;
        
        for(MassiveLoaderRequestItem__c singleItem : requestItemList){
            try {
                servicePointId = idsMap.get(singleItem.Id).servPointId;

                if(String.isNotEmpty(servicePointId)){
                    
                    servPointFromWs = servicePointMap.get(servicePointId);

                    serResp = HDT_WS_ArrichmentDataEntityInvoker.callService('', servPointFromWs.Name);
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
                }

                accountId = idsMap.get(singleItem.Id).accountId;

                if(String.isNotEmpty(accountId)){
                    account = new Account();
                    contact = new Contact();
                    
                    account = setAccountRecord(accRelMap.get(accountId), account);
                    contact = setContactRecord(accRelMap.get(accountId), contact);
                    HDT_WS_RicCreBpCaRequest req = HDT_UTL_Account.callBpCaCreate(account, contact);
                    HDT_WS_RichCreBpCaResponse res = HDT_WS_RicCreBpCaInvoker.invokeCall(req);

                    if ('success'.equalsIgnoreCase(res.status)) {
                        if ('Errore'.equalsIgnoreCase(res.data.tipoAttivita)) {
                            System.debug(LoggingLevel.DEBUG, '>>> res.data.commenti: ' + res.data.commenti);
                            singleItem.Status__c = 'Errore';
                            singleItem.StatusDescription__c = res.data.commenti;
                        } else {
                            account.CustomerCode__c = res.data.codiceBP;
                            itemIds.add(singleItem.Id);
                            singleItem.Status__c = 'Chiuso';
                            accountToUpdate.add(account);
                            System.debug(LoggingLevel.DEBUG, 'CustomerCode__c > ' + account.CustomerCode__c);
                        }
                    } else {
                        System.debug(LoggingLevel.DEBUG, '>>> res.statusCode: ' + res.statusCode);
                        System.debug(LoggingLevel.DEBUG, '>>> res.body: ' + res.body);
                        System.debug(LoggingLevel.DEBUG, '>>> res.status: ' + res.status);
                        System.debug(LoggingLevel.DEBUG, '>>> res.errorDetails: ' + res.errorDetails);
                        System.debug(LoggingLevel.DEBUG, '>>> res.exceptionMessage: ' + res.exceptionMessage);
                        singleItem.Status__c = 'Errore';
                        singleItem.StatusDescription__c = res.exceptionMessage + ' - ' + res.errorDetails;
                    }

                }

            } catch (Exception e){
                System.debug(LoggingLevel.DEBUG, 'Exception > ' + e.getMessage());
                singleItem.Status__c = 'Errore';
                singleItem.StatusDescription__c = e.getMessage().abbreviate(250);
            }

        }

        if(accountToUpdate.size() > 0){
            Map<Id, MassiveLoaderRequestItem__c> errorItemMap = new Map<Id, MassiveLoaderRequestItem__c>();
            HDT_UTL_ProcessCommonOperations.HDT_WRP_SaveResponse updateAccountResponse;

            updateAccountResponse = HDT_UTL_ProcessCommonOperations.databaseInsert(accountToUpdate, itemIds, 'Account');

            for(MassiveLoaderRequestItem__c errorItem : updateAccountResponse.reponseItemList){
                if(errorItem.Status__c == 'Errore'){
                    errorItemMap.put(errorItem.Id, errorItem);
                }
            }

            for(MassiveLoaderRequestItem__c singleItem : requestItemList){
                if(errorItemMap.containsKey(singleItem.Id)){
                    singleItem = errorItemMap.get(singleItem.Id);
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
        a.BillingStreetToponym__c = rel.Account.BillingStreetToponym__c;
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

}