/**
 * @description       : Get records from VasSupplierTable__c and copy their fields to related subscriptions/assets/orders
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-11-10
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_BA_VasSupplierTable implements Database.Batchable<SObject>, Schedulable, Database.Stateful{

    private static final String STATUS_PENDING = 'PENDING';
    private static final String STATUS_SUCCESS = 'SUCCESS';
    private static final String STATUS_ERROR = 'ERROR';

    private static final List<String> FIELDS_TO_COPY = new List<String>{
        'VasPolicyNumber__c',
        'VasSupplierStatus__c',
        'VasEffectiveDate__c',
        'VasSupplierStatusDetails__c',
        'VasSupplier__c',
        'VasPracticeDate__c',
        'VasShippingDate__c',
        'VasTrackingNr__c',
        'VasDeliveryDate__c',
        'VasServiceActivationDate__c',
        'VasCommunicationProgressive__c',
        'VasCommunicationDate__c',
        'VasReplacementRequestDate__c',
        'VasReplacementDate__c',
        'VasReturnedProductDate__c',
        'VasDisabledDate__c'
    };

    private static final Set<String> esitiFornitoreStatuses = new Set<String>{
        'ORDINE ACQUISITO',
        'Attesa esito preventivo',
        'Preventivo accettato',
        'IN CONSEGNA',
        'APP.TO FISSATO',
        'RIFIUTATO preventivamente',
        'CONSEGNA/Installazione RIFIUTATA',
        'INSTALLAZIONE FALLITA',
        'Consegnato/installato/attivato',
        'PRESTAZIONE ESEGUITA ',
        'Richiesta sostituzione',
        'SOSTITUITO',
        'RESO (PRODOTTO)',
        'DISATTIVATO/DISDETTO (SERVIZIO)'
    };

    private static Map<id, id> vasSupplToOrder;

    private Map<Id, String> caseToProcess;//gonna update on finish method

    private Set<String> assetVasCodeSet;

    public HDT_BA_VasSupplierTable(){
        this.caseToProcess=new Map<Id, String>();
        this.assetVasCodeSet = new Set<String>();
    }

    /**
    * @description Running batch
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param sc 
    **/
    public void execute(SchedulableContext sc){
        Database.executeBatch(this);
    }
    
    /**
    * @description Get records which have not been processed yet
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT '+String.join(FIELDS_TO_COPY, ',')+',VasPracticeCode__c,Status__c,ErrorDescription__c';
        QUERY += ' FROM VasSupplierTable__c WHERE Status__c=:STATUS_PENDING';
        return Database.getQueryLocator(query);
    }

    /**
    * @description Copying VasSupplierTable__c records to subscriptions/assets/orders and saving outcome
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param bc 
    * @param vasRecords 
    **/
    public void execute(Database.BatchableContext bc, List<VasSupplierTable__c> vasRecords) {
        vasSupplToOrder= new Map<Id, Id>();
        Map<String, VasSupplierTable__c> vasRecordsMap = mapVasRecords(vasRecords);
        Set<String> codes = vasRecordsMap.keySet();

        List<SBQQ__Subscription__c> subs = getSubscriptions(codes);
        List<Asset> assets = getAssets(codes);

        Map<SObject, String> recordsPerCode = new Map<SObject, String>();
        recordsPerCode.putAll( copyVasFields(subs, vasRecordsMap) );
        recordsPerCode.putAll( copyVasFields(assets, vasRecordsMap) );

        updateRecords(recordsPerCode, vasRecordsMap);
        
        saveVasRecords(vasRecords);

        Boolean limitQueueablesOk = Limits.getQueueableJobs() < Limits.getLimitQueueableJobs();
        if(caseToProcess.size()>400 && limitQueueablesOk){
            system.enqueueJob(new HDT_UTL_PrClickDoubleTransaction.HDT_QBL_BulkUpdate(extractNumRecordsFromMap(2000)));
        }
    }

    public void finish(Database.BatchableContext bc) {
        if(!caseToProcess.isEmpty()){
            system.enqueueJob(new HDT_UTL_PrClickDoubleTransaction.HDT_QBL_BulkUpdate(caseToProcess));
        }
    }


    private Map<Id, String> extractNumRecordsFromMap(Integer num){
        Map<Id, String> reducedMap = new Map<Id, String>();
        for(Id caseIdKey : caseToProcess.keySet()){
            if(num-- > 0){
                reducedMap.put(caseIdKey, caseToProcess.remove(caseIdKey));
            }
        }
        return reducedMap;
    }


    /**
    * @description Mapping Vas records by VasPracticeCode__c
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param vasRecords 
    * @return Map<String, VasSupplierTable__c> 
    **/
    private Map<String, VasSupplierTable__c> mapVasRecords(List<VasSupplierTable__c> vasRecords) {
        Map<String, VasSupplierTable__c> vasRecordsMap = new Map<String, VasSupplierTable__c>();
        for (VasSupplierTable__c vasRecord:vasRecords) {
            String code = vasRecord.VasPracticeCode__c;
            vasRecordsMap.put(code, vasRecord);
        }
        return vasRecordsMap;
    }

    /**
    * @description Getting subscriptions by VasPracticeCode__c
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param codes 
    * @return List<SBQQ__Subscription__c> 
    **/
    private List<SBQQ__Subscription__c> getSubscriptions(Set<String> codes) {
        return [SELECT VasPracticeCode__c, SBQQ__OrderProduct__r.OrderId, SBQQ__Product__r.Family FROM SBQQ__Subscription__c WHERE VasPracticeCode__c IN :codes WITH SECURITY_ENFORCED];
    }

    /**
    * @description Getting assets by VasPracticeCode__c
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param codes 
    * @return List<Asset> 
    **/
    private List<Asset> getAssets(Set<String> codes) {
        return [SELECT VasPracticeCode__c, SBQQ__OrderProduct__r.OrderId, Product2.Family, AccountId FROM Asset WHERE VasPracticeCode__c IN :codes AND SBQQ__RootAsset__c=null WITH SECURITY_ENFORCED];
    }

    /**
    * @description Copy fields from vas records to subscriptions/assets/orders
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param targets 
    * @param vasRecordsMap 
    **/
    private Map<SObject, String> copyVasFields(List<SObject> targets, Map<String, VasSupplierTable__c> vasRecordsMap) {
        Map<SObject, String> recordsPerCode = new Map<SObject, String>();

        if (!targets.isEmpty()) {
            Set<String> targetFieldNames = targets.get(0).getSObjectType().getDescribe().fields.getMap().keySet();
            
            for (SObject target:targets) {
                String code = (String)target.get('VasPracticeCode__c');
                Id recordId = (Id)target.get('Id');
                if (recordId.getSobjectType() == Schema.Asset.getSObjectType()){
                    this.assetVasCodeSet.add(code);
                }
                VasSupplierTable__c vasRecord = vasRecordsMap.get(code);
                Order orderToUpdate = new Order();

                //mapping VasSupplierTable__c to Asset/Subscription
                try {
                    for (String field:FIELDS_TO_COPY) {
                        if (targetFieldNames.contains(field.toLowerCase())) {
                            target.put(field, vasRecord.get(field));
                        }
                    }
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, e.getMessage());
                    System.debug(LoggingLevel.ERROR, e.getStackTraceString());
                    vasRecord.Status__c = STATUS_ERROR;
                    vasRecord.ErrorDescription__c = 'MAPPING_ERROR: Error mapping Asset/Subscription fields';
                }

                //mapping VasSupplierTable__c to Order
                try {
                    OrderItem item = (OrderItem)target.getSObject('SBQQ__OrderProduct__r');
                    orderToUpdate.Id = item.OrderId;
                    orderToUpdate.VasSupplierStatus__c = vasRecord.VasSupplierStatus__c;
                    vasSupplToOrder.put(vasRecord.Id, orderToUpdate.Id);
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, e.getMessage());
                    System.debug(LoggingLevel.ERROR, e.getStackTraceString());
                    vasRecord.Status__c = STATUS_ERROR;
                    vasRecord.ErrorDescription__c = 'MAPPING_ERROR: Error mapping Order fields';
                }

                //saving records in map if no errors have been encountered
                if (vasRecord.Status__c==STATUS_PENDING) {
                    recordsPerCode.put(target, code);
                    recordsPerCode.put(orderToUpdate, code);
                }
            }
        }
        return recordsPerCode;
    }

    private inherited sharing class HDT_WRP_Data{
        id sobjId {get;set;}
        string causaleScarto {get;set;}
        HDT_WRP_Data(Id sobjId){
            this.sobjId=sobjId;
        }
        HDT_WRP_Data(Id sobjId, String causale){
            this(sobjId);
            this.causaleScarto=causale;
        }
    }
   
    /**
    * @description Updating orders/assets/subscriptions
    * @author gabriele.rota@webresults.it | 2021-08-23 
    * @param recordsPerCode 
    * @param vasRecordsMap 
    **/
    private void updateRecords(Map<SObject, String> recordsPerCode, Map<String, VasSupplierTable__c> vasRecordsMap) {

        Id rtCaseDisattVas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PostSalesVAS').getRecordTypeId();
        List<Asset> assetsToUpdate = new List<Asset>();
        List<SBQQ__Subscription__c> subsToUpdate = new List<SBQQ__Subscription__c>();
        Map<Id, HDT_WRP_Data> assetToOrderKoFornitore = new Map<Id, HDT_WRP_Data>();
        Map<Id, HDT_WRP_Data> assetMigratedKoFornitore = new Map<Id, HDT_WRP_Data>();
        Map<Id, HDT_WRP_Data> assetToAccountEsitiFornitore = new Map<Id, HDT_WRP_Data>();
        List<sobject> relatedSobjectsToInsert = new List<sobject>();
        List<Case> casesDisattVas = new List<Case>();
        //List<Order> ordersToUpdate = new List<Order>();
        Map<Id, Order> mapOrdersToUpdate = new Map<Id, Order>();

        Map<Id, String> recordIdsPerCode = new Map<Id, String>();
        for (SObject record:recordsPerCode.keySet()) {
            if (record.getSObjectType() == Schema.Asset.getSObjectType()) {
                assetsToUpdate.add((Asset)record);
                switch on String.valueOf(record.get('VasSupplierStatus__c')){
                    when 'TEL - CLT NON TROVATO', 'CLIENTE NON TROVATO', 'DA RICHIAMARE', 'KO FORNITORE', 'IN RIASSORTIMENTO', 'USCITA A VUOTO' {
                        id sobjToRelateActivity = (ID) record.getSobject('SBQQ__OrderProduct__r')?.get('OrderId');
                        if(sobjToRelateActivity!=null){
                            //assetToAccountKoFornitore.put((Id) record.get('id'), (ID) record.get('AccountId'));
                            assetToOrderKoFornitore.put((Id) record.get('id'), new HDT_WRP_Data(sobjToRelateActivity));
                        }else{
                            assetMigratedKoFornitore.put((Id) record.get('id'),  new HDT_WRP_Data((Id) record.get('AccountId'), String.valueOf(record.get('VasSupplierStatus__c'))));
                        }
                    }
                    when 'CONSEGNA/Installazione RIFIUTATA', 'INSTALLAZIONE FALLITA', 'RESO (PRODOTTO)', 'RIFIUTATO preventivamente' {
                        String vasType = (String)record.getSObject('Product2')?.get('Family');
                        Case disattCase = new Case(AssetId=(Id) record.get('id'), RecordTypeId=rtCaseDisattVas);
                        disattCase.CancellationReason__c='Ripensamento da cliente';
                        disattCase.VasStatus__c='ANNUL PER RIPENS';
                        disattCase.Phase__c='Bozza';
                        disattCase.Type='Disattivazione VAS';
                        disattCase.AccountId=(ID) record.get('AccountId');
                        disattCase.CommercialProduct__c = vasType;
                        casesDisattVas.add(disattCase);
                        //assetToAccountEsitiFornitore.put((Id) record.get('id'), (ID) record.get('AccountId'));
                    }when else{
                        //aggiungere controllo KO
                        if(esitiFornitoreStatuses.contains(String.valueOf(record.get('VasSupplierStatus__c')))){
                            assetToAccountEsitiFornitore.put((Id) record.get('id'), new HDT_WRP_Data((ID) record.get('AccountId')));
                        }
                    }
                }
            }else if (record.getSObjectType() == Schema.SBQQ__Subscription__c.getSObjectType() && !this.assetVasCodeSet.contains(recordsPerCode.get(record))) {
                subsToUpdate.add((SBQQ__Subscription__c)record);
                String vasType = (String)record.getSObject('SBQQ__Product__r')?.get('Family');
                if ('VAS Servizio'.equalsIgnoreCase(vasType)){
                    switch on String.valueOf(record.get('VasSupplierStatus__c')){
                        when 'TEL - CLT NON TROVATO', 'CLIENTE NON TROVATO', 'DA RICHIAMARE', 'KO FORNITORE', 'IN RIASSORTIMENTO', 'USCITA A VUOTO' {
                            id sobjToRelateActivity = (ID) record.getSobject('SBQQ__OrderProduct__r')?.get('OrderId');
                            if(sobjToRelateActivity!=null){
                                //assetToAccountKoFornitore.put((Id) record.get('id'), (ID) record.get('AccountId'));
                                assetToOrderKoFornitore.put((Id) record.get('id'), new HDT_WRP_Data(sobjToRelateActivity));
                            }else{
                                assetMigratedKoFornitore.put((Id) record.get('id'),  new HDT_WRP_Data((Id) record.get('AccountId'), String.valueOf(record.get('VasSupplierStatus__c'))));
                            }
                        }
                    }
                } 
            }
            if (record.getSObjectType() == Schema.Order.getSObjectType()) {
                //ordersToUpdate.add((Order)record);
                mapOrdersToUpdate.put((ID) record.get('id'), (Order)record);
            }
            recordIdsPerCode.put((Id)record.get('Id'), recordsPerCode.get(record) );
        }

        relatedSobjectsToInsert.addAll(getActivitiesRicontatto(assetToOrderKoFornitore, 'CBS_ATT003__KO_FORNITORE', 'HDT_RT_Default'));
        relatedSobjectsToInsert.addAll(getActivitiesRicontatto(assetMigratedKoFornitore, 'CBS_ATT012__KO_FORNITORE', 'HDT_RT_Default'));
        //relatedSobjectsToInsert.addAll(getActivitiesRicontatto(assetToAccountEsitiFornitore, 'VAS001_GESTIONE_ESITI_FORNITORE', ''));
        relatedSobjectsToInsert.addAll(casesDisattVas);
        if(!relatedSobjectsToInsert.isEmpty()){
            HDT_UTL_DatabaseService.insertSObject(relatedSobjectsToInsert);
        }
        
        //Map<Id, String> caseToProcess = new  Map<Id, String>();
        for(Case c : casesDisattVas){
            caseToProcess.put(c.id, 'In Lavorazione');
        }
        //HDT_UTL_DatabaseService.updateSObject(casesDisattVas);


        saveAndCheckResults(assetsToUpdate, recordIdsPerCode, vasRecordsMap);
        saveAndCheckResults(subsToUpdate, recordIdsPerCode, vasRecordsMap);
        saveAndCheckResults(mapOrdersToUpdate.values(), recordIdsPerCode, vasRecordsMap);
    }

    /**
    * @description Run orders/assets/subscriptions update and save outcome
    * @author gabriele.rota@webresults.it | 2021-08-23 
    * @param vasRecords 
    * @param recordIdsPerCode 
    * @param vasRecordsMap 
    **/
    private void saveAndCheckResults(List<SObject> records, Map<Id, String> recordIdsPerCode, Map<String, VasSupplierTable__c> vasRecordsMap) {
        List<Database.SaveResult> saveResults = Database.update(records, false);

        for (Integer i=0;i<saveResults.size();i++) {
            Database.SaveResult saveResult = saveResults.get(i);
            SObject record = records.get(i);
            Id ordRefId;
            if (record.getSObjectType() == Schema.Order.getSObjectType()){
                ordRefId = (Id)record.get('Id');
            }
            String code = recordIdsPerCode.get((Id)record.get('Id'));
            VasSupplierTable__c vasRecord = vasRecordsMap.get(code);
            vasRecord.OrderReference__c = ordRefId;

            if (saveResult.isSuccess()) {
                if (vasRecord.Status__c==STATUS_PENDING) {
                    vasRecord.Status__c = STATUS_SUCCESS;
                    vasRecord.ErrorDescription__c = null;
                }
            }
            else {
                vasRecord.Status__c = STATUS_ERROR;
                if (vasRecord.ErrorDescription__c==null) {
                    vasRecord.ErrorDescription__c = '';
                }
                vasRecord.ErrorDescription__c += getErrorDescription(saveResult);
            }
        }
    }

    /**
    * @description Save VasSupplierTable__c records with new statuses
    * @author gabriele.rota@webresults.it | 2021-08-23 
    * @param vasRecords 
    **/
    private void saveVasRecords(List<VasSupplierTable__c> vasRecords) {
        List<String> ordsIdScarti = new List<String>();
        for (VasSupplierTable__c vasRecord:vasRecords) {
            if (vasRecord.Status__c==STATUS_PENDING) {
                vasRecord.Status__c = STATUS_ERROR;
                vasRecord.ErrorDescription__c = 'NOT_FOUND: VasPracticeCode__c not found';
            }else if(vasRecord.Status__c==STATUS_ERROR){
                ordsIdScarti.add(vasSupplToOrder.get(vasRecord.Id));
            }

            if (String.isNotBlank(vasRecord.ErrorDescription__c)) {
                vasRecord.ErrorDescription__c = vasRecord.ErrorDescription__c.abbreviate(255);
            }
        }
        Database.update(vasRecords, true);
        //createDraftActivities(ordsIdScarti);
    }

    /**
    * @description Get error description from SaveResult
    * @author gabriele.rota@webresults.it | 2021-08-20 
    * @param targets 
    * @param vasRecordsMap 
    **/
    private String getErrorDescription(Database.SaveResult saveResult) {
        String errorDesc = '';
        for(Database.Error err : saveResult.getErrors()) {
            errorDesc += err.getStatusCode()+': '+err.getMessage()+' ('+err.getFields()+'); ';
        }
        return errorDesc;
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 01-10-2021 
    * @param assetToAccount 
    * @return list<wrts_prcgvr__Activity__c> 
    **/
    private list<wrts_prcgvr__Activity__c> getActivitiesRicontatto(Map<Id, HDT_WRP_Data> assetToAccount, String templateName, String rtName){
        Id rtDefault = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get(rtName)?.getRecordTypeId();
        Map<Id, List<Id>> accToAssets = new Map<Id, List<Id>>();
        
        for(Id assId : assetToAccount.keySet()){
            String accId = assetToAccount.get(assId).sobjId;
            if(accToAssets.get(accId)==null){
                accToAssets.put(accId, new List<Id>());
            }
            accToAssets.get(accId).add(assId);
        }

        list<Id> objectIds = new list<Id>();
        for(HDT_WRP_Data data : assetToAccount.values()){
            objectIds.add(data.sobjId);
        }
        list<wrts_prcgvr__Activity__c> activities = getActivities(objectIds, templateName);

        for(wrts_prcgvr__Activity__c act : activities){
            Id recordId = accToAssets.get((ID) act.wrts_prcgvr__ObjectId__c).remove(0);
            if (recordId.getSObjectType() == Schema.Asset.getSObjectType()){
                act.Asset__c = recordId;
            }else if (recordId.getSObjectType() == Schema.SBQQ__Subscription__c.getSObjectType()){
                act.Subscription__c = recordId;
            }
            act.recordTypeId=rtDefault!=null? rtDefault : act.recordTypeId;
            act.Account__c=((ID) act.wrts_prcgvr__ObjectId__c).getSobjectType().getDescribe().getName().equalsIgnoreCase('Account')? (ID) act.wrts_prcgvr__ObjectId__c : null;
            String causaleScarto = assetToAccount.get(recordId).causaleScarto;
            act.wrts_prcgvr__Description__c=String.isNotBlank(causaleScarto)? causaleScarto : null;//popola causale solo per asset migrati
        }
        return activities;
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 24-08-2021 
    * @param ordsIdScarti 
    **/
    private void createDraftActivities(List<String> ordsIdScarti){
        list<wrts_prcgvr__Activity__c> activities = getActivities(ordsIdScarti, 'VAS001_GESTIONE_ESITI_FORNITORE');
        HDT_UTL_DatabaseService.insertSObject(activities);
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 01-10-2021 
    * @param sobjIds 
    * @param templateName 
    * @return list<wrts_prcgvr__Activity__c> 
    **/
    private list<wrts_prcgvr__Activity__c> getActivities(List<String> sobjIds, String templateName){
        if(sobjIds.isEmpty()) {
            return new list<wrts_prcgvr__Activity__c>();
        }
        return HDT_UTL_Scarti.createActivityByObjectIdAndTemplateNameBulk(sobjIds, templateName);
    }
}
