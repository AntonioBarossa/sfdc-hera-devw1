public with sharing class HDT_SRV_VoltureChangeManager{

    private static HDT_UTL_VoltureChangeManager voltureChangeUtl = new HDT_UTL_VoltureChangeManager();
    private static HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();
    private static HDT_UTL_VoltureChangeUtilities voltureChangeUtils = new HDT_UTL_VoltureChangeUtilities();
    private static HDT_QR_AnagAlignment regionalAdditionalQr = new HDT_QR_AnagAlignment();
    private static String voltureChangeRecordTypeName = 'HDT_RT_VolturaConSwitch';
    private static String ammissibilityCheckTemplate = 'Controlli Ammissibilità';
    @TestVisible
    private static String publishUpdatePhase = 'Comunicazione verso Heroku';
    @TestVisible
    private static String volturaTecnicaPhase = 'In attesa Data Decorrenza';
    private static String clonedOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(voltureChangeRecordTypeName).getRecordTypeId();
    private static String activityType = 'Valori non corrispondenti';
    private static String emptyEmailDefault = 'mailnondisponibile@acquirenteunico.it';
    /**
     * @frpanico 06/10/2021
     * This method call the cloneSobject method from the HDT_UTL_VoltureChangeManager class
     * at the current state no extra fields need to be excluded
     * After the insert of the object the input sobj needs to pass on phase "Annullato".
     */
    public void cloneOrderAndUpdate(SObject sobj)
    {
        /*Variable Declarations*/
        List<OrderItem> orderItemsToClone = new List<OrderItem>();
        List<OrderItem> orderItemsToCreate = new List<OrderItem>();
        Map<String,Object> extraParams = new Map<String,Object>();
        Map<String,Object> accountCheckParams = new Map<String,Object>();
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        HDT_SRV_Order orderSrv = new HDT_SRV_Order();

        /* Call to the cloneSobject method */
        extraParams.put('sobjName', 'Order');
        Order clonedOrder = (Order)voltureChangeUtl.cloneSObject(sobj, extraParams);
        Order inputOrder = (Order)sobj;        
        /* Add process Type, RecordType,Phase__s, Status,OrderReference to the cloned order and insert*/
        clonedOrder.put('ProcessType__c','Voltura con Switch');
        clonedOrder.put('ProcessCode__c','VT1');
        clonedOrder.put('RecordTypeId', clonedOrderRecordTypeId);
        clonedOrder.put('Phase__c','Bozza');
        clonedOrder.put('Status','Draft');
        clonedOrder.put('OrderReference__c',inputOrder.Id);
        clonedOrder.put('EffectiveDate__c',orderSrv.addBusinessDay(Date.today(), 3));
        clonedOrder.put('VoltureType__c','Ordinaria');
        /**@frpanico 2022-07-05
         * gestione campi mancanti integrazione
         */
        if(clonedOrder.get('PhoneNumber__c') == null || String.isBlank((String)clonedOrder.get('PhoneNumber__c')))
        {
            String phone = '123';
            List<Contact> contacts = [SELECT Id, MobilePhone, Phone FROM Contact WHERE Id = :((String)clonedOrder.get('Contact__c')) WITH SECURITY_ENFORCED];
            if(!contacts.isEmpty())
            {
                phone = contacts[0].MobilePhone != null || String.isNotBlank(contacts[0].MobilePhone)
                    ? contacts[0].MobilePhone
                    : contacts[0].Phone != null || String.isNotBlank(contacts[0].Phone)
                        ? contacts[0].Phone
                        : phone;
            }
            clonedOrder.put('PhoneNumber__c', phone);
        }
        if(clonedOrder.get('Email__c') == null || String.isBlank((String)clonedOrder.get('Email__c')))
        {
            clonedOrder.put('Email__c', emptyEmailDefault);
        }
        /* Calcolo Addizionale Regionale + Aliquota accise */
        String tax = (String) clonedOrder.get('ExciseEle__c');
        String city = (String) clonedOrder.get('SupplyCity__c');
        String region = '';
        clonedOrder.put('RegionalAdditional__c',regionalAdditionalQr.findRegionalAdditional(tax, city, region));
        clonedOrder.put('ExciseRate__c',voltureChangeQr.getExciseTranscode(tax)[0].Excise__c);
        HDT_UTL_DatabaseService.insertSObject(clonedOrder);
        /*Retrieve and clone OrderItems from input order*/
        orderItemsToClone = voltureChangeQr.getOrderItemByOrderId(inputOrder.Id);
        extraParams.put('sobjName','OrderItem');
        if(orderItemsToClone.size() > 0)
        {
            for(OrderItem ordItem : orderItemsToClone)
            {
                OrderItem newOrdItem = (OrderItem)voltureChangeUtl.cloneSObject(ordItem, extraParams);
                newOrdItem.put('OrderId', clonedOrder.Id);
                orderItemsToCreate.add(newOrdItem);
            }   
        }
        if(orderItemsToCreate.size() > 0)
        {
            HDT_UTL_DatabaseService.insertSObject(orderItemsToCreate);
        }
        /* Update in "Annullato" phase the input order */
        inputOrder.Phase__c = 'Annullato';
        /*TODO: add other fields of annullment if needed*/
        HDT_UTL_VoltureChangeUtilities.updateOrderFuture(JSON.serialize(inputOrder));
        /**@frpanico 12/10/2021*/
        /**
         * Get account info and create the map to be passed to the Util class
         * set the outcome phase from the accountCheck method
         */
        List<Account> orderAccount = voltureChangeQr.getAccountInfoById(clonedOrder.AccountId);
        accountCheckParams.put('accountType',orderAccount[0]?.RecordType.DeveloperName);
        accountCheckParams.put('orderId', clonedOrder.get('Id'));
        accountCheckParams.put('dataDecorrenza',inputOrder?.EffectiveDate__c);
        accountCheckParams.put('preavvisoRecesso',inputOrder?.RecessNotice__c);
        accountCheck = voltureChangeUtl.accountCheck(accountCheckParams);
        clonedOrder.put('Phase__c',accountCheck.nextPhase);
        HDT_UTL_DatabaseService.updateSObject(clonedOrder);
    }

    /**@frpanico 14/10/2021
     * This method handle the response from the WS
     * Takes in input the Response 
     * Updates the order with the information returned from the WS
     */
    public void handleResponse(wrts_prcgvr.MRR_1_0.MultiResponse response, Order currentOrder)
    {   
        Map<String,Object> fieldsMap = voltureChangeUtils.getFieldsMap(response);
        Order orderToUpdate = voltureChangeUtl.handleResponse(fieldsMap, currentOrder);
        HDT_UTL_DatabaseService.updateSObject(orderToUpdate);
    }
    /**@frpanico 07/02/2022
     * Handle null response
     */
    public void handleResponse(Order currentOrder)
    {
        Order orderToUpdate = new Order();
        orderToUpdate.Id = currentOrder.Id;
        orderToUpdate.TecnicalPhase__c = 'Comunicazione verso Heroku KO';
        orderToUpdate.DiscardReason__c = 'Errore nella risposta da Heroku';
        orderToUpdate.Description = 'Errore nella risposta da Heroku';
        HDT_UTL_DatabaseService.updateSObject(orderToUpdate);
    }

    /**@frpanico 18/10/2021
     * This method handle the ammissibility checks
     * Takes in input the paramsMap returned from the response
     * if the check is false it creates an activity
     */
    public void handleAmmissibilityCheck(Map<String,Object> paramsMap, Order currentOrder)
    {
        Map<String,Object> ammissibilityCheckMap = voltureChangeUtl.handleAmmissibilityCheck(paramsMap, currentOrder);
        /**Execute the check and if its false creates the activity*/
        if(!(Boolean)ammissibilityCheckMap.get('result'))
        {
            //wrts_prcgvr__Activity__c activity = voltureChangeUtils.createActivity(ammissibilityCheckTemplate);
            wrts_prcgvr__Activity__c activity = HDT_UTL_Scarti.createActivityByObjectIdAndTemplateName(currentOrder.Id,activityType,'Order');
            if(activity != null)
            {
                activity.OpeningNote__c = (String)ammissibilityCheckMap.get('note');
                activity.wrts_prcgvr__Description__c = (String)ammissibilityCheckMap.get('message');
                HDT_UTL_DatabaseService.insertSObject(activity);
            }
        }
        return;
    }

    /**@frpanico 19/10/2021
     * This method handle the PlatformEvent publish to update the order and make the callout
     * This method takes in input the order to update
     * update the order and publish the event
     */
    public void handlePublishUpdate(Order inputOrder)
    {
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Order__c = :inputOrder.Id AND Type__c = 'Valori non corrispondenti' WITH SECURITY_ENFORCED];
        if(!activities.isEmpty())
        {
            return;
        }
        HDT_PEV_VoltureChangeManagerUpdateSObj__e platEvent = new HDT_PEV_VoltureChangeManagerUpdateSObj__e();
        Order orderToUpdate = new Order();
        orderToUpdate.Id = inputOrder.Id;
        orderToUpdate.Phase__c = publishUpdatePhase;
        platEvent.SerializedSobj__c = JSON.serialize(orderToUpdate);
        Database.SaveResult sr = Eventbus.publish(platEvent);
        
        if(sr.isSuccess())
        {
            return;
        }
    }

    /**@frpanico 25/10/2021
     * Metodo che gestisce la risposta dell'arricchimento dati
     * esegue la query sul metadato di configurazione
     * richiama poi i metodi da utilizzare
     * Prende in input una mappa Map<String,List<Object>> dove gli argomenti sono:
     * List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> risposta dell'arricchimento
     * List<SObject> dove vengono passati gli SObject da arricchire
     * Ritorna in output gli SObject arricchiti
     */
    public List<SObject> handleResponseDataEnrichment(Map<String,List<Object>> inputMap)
    {
        /* Variable declaration */
        List<String> objectNameList = new List<String>();
        Map<String,Object> inputMapSingleSobj = new Map<String,Object>();
        List<HDT_GenericDataEnrichmentTranscode__mdt> transcodeConfigs = new List<HDT_GenericDataEnrichmentTranscode__mdt>();
        /* Get input variable */
        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> posizioni = (List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>)inputMap.get('posizioni');
        List<SObject> sobjList = (List<SObject>)inputMap.get('sobjList');
        /* Enrich SobjName List */
        for(SObject sobj : sobjList)
        {
            objectNameList.add(sobj.getSObjectType().getDescribe().getName());
        }
        /* Retrieve Configs */
        transcodeConfigs = voltureChangeQr.getDataEnrichmentTranscodeByObjectName(objectNameList);
        /* Populate input map for single sobj enrichment */
        inputMapSingleSobj.put('posizioni', JSON.serialize(posizioni));
        inputMapSingleSobj.put('configs', JSON.serialize(transcodeConfigs));
        /* Enrich Data */
        for(SObject sobj : sobjList)
        {   
            inputMapSingleSobj.put('sobj', sobj);
            sobj = voltureChangeUtl.enrichSobj(inputMapSingleSobj);
        }
        return sobjList;
    }

    /*Edoardo Zanatta 13/01/2022    
    */
    public void orderPrecheckOk(Order myOrder){
        
        Date today = System.today();

        Order ordToUpdate = new Order();
        ordToUpdate.Id = myOrder.Id;        
        ordToUpdate.Phase__c = myOrder.DateSentToSII__c > today ? 'In attesa tempi di ripensamento' : 'Comunicazione verso Heroku';

        HDT_PEV_VoltureChangeManagerUpdateSObj__e platEvent = new HDT_PEV_VoltureChangeManagerUpdateSObj__e();
        platEvent.SerializedSobj__c = JSON.serialize(ordToUpdate);
        Eventbus.publish(platEvent);            
    }
    public void orderPrecheckOk(List<Order> myOrderList){
        Date today = System.today();
        List<Order> orderListUpdate = new List<Order>();
        List<HDT_PEV_VoltureChangeManagerUpdateSObj__e> pltformEventList = new List<HDT_PEV_VoltureChangeManagerUpdateSObj__e>();
        for(Order singleOrder : myOrderList){
            if(singleOrder.Phase__c.equalsIgnoreCase('Amm. Precheck OK SII') 
            && (singleOrder.DocumentalProcessType__c.equalsIgnoreCase('Switch In') 
            /*|| singleOrder.DocumentalProcessType__c.equalsIgnoreCase('Voltura con Switch')*/)
            && singleOrder.TecnicalPhase__c == null){
                Order ordToUpdate = new Order();
                ordToUpdate.Id = singleOrder.Id;        
                ordToUpdate.Phase__c = singleOrder.DateSentToSII__c > today ? 'In attesa tempi di ripensamento' : 'Comunicazione verso Heroku';
                HDT_PEV_VoltureChangeManagerUpdateSObj__e platEvent = new HDT_PEV_VoltureChangeManagerUpdateSObj__e();
                platEvent.SerializedSobj__c = JSON.serialize(ordToUpdate);
                pltformEventList.add(platEvent);
            }
        }
        if(!pltformEventList.isEmpty()){
            Eventbus.publish(pltformEventList);  
        }       
    }
    public void createCaseFromOrder(Order myOrder){

        System.enqueueJob(new HDT_QBL_VoltureChangeManager(myOrder));
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('sender',myOrder);
        argsMap.put('method','service26');
        checkCallServiceTwentySix(argsMap);

    }

    public void bloccoVoltura(Order myOrder, string codiceCausale){

        System.enqueueJob(new HDT_QBL_VoltureChangeManager(myOrder, codiceCausale));
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('sender',myOrder);
        argsMap.put('method','service26');
        checkCallServiceTwentySix(argsMap);
    }

    public static String calloutVolture(Order order, string codiceCausale){

        HttpRequest request = new HttpRequest();
        Http http = new Http();
        
        HDT_WRP_VoltureChangeManager.HDT_WRP_BodyCall requestBody = new HDT_WRP_VoltureChangeManager.HDT_WRP_BodyCall();
        requestBody.rds = (string)order.getSObject('ParentOrder__r')?.get('OrderNumber');
        requestBody.rdo = (string)order.get('OrderNumber');
        requestBody.pod = (string)order.get('ServicePointCode__c');
        requestBody.contratto = (string)order.get('SapContractCode__c');
        requestBody.prestazione = (string)order.get('HerokuPracticeCode__c');
        requestBody.causale = codiceCausale;
        requestBody.tipologia = (string)order.get('DocumentalProcessType__c');

        HttpResponse response = new HttpResponse();
        
        try{
            request.setEndpoint('Callout:MulesoftBasePath/transfers/lock-unlock-calculations');
            request.setMethod('POST');
            request.setBody( JSON.serialize(requestBody) );
            request.setTimeout(12000);
            request.setHeader('Accept','application/json');
            request.setHeader('Content-Type','application/json');
            response = http.send(request);
        }catch(Exception e){
            response = null;
        }

        if (response != null ){
            HDT_WRP_VoltureChangeManager.HDT_WRP_Response responseBody = new HDT_WRP_VoltureChangeManager.HDT_WRP_Response( (Map<String, Object>)JSON.deserializeUntyped( response.getBody() ) );
            return descriptionConstructor(responseBody.prestazione.tipoAttivita, responseBody.prestazione.note);
        }else {
            return 'Errore nella comunicazione Blocco/Sblocco al calcolo';
        }
        
    }

    private static string descriptionConstructor(string tipoAttivita, string note){
        Datetime nowDate = Datetime.now();
        String descr = nowDate.format('dd/MM/yyyy h:mm a') + ': ';
        descr = tipoAttivita!=null? descr+tipoAttivita+' - ': descr ;
        return note!=null? descr+note: descr ;
    }
    // data: tipoaAttivita - ntoe


    public void checkCallServiceTwentySix(Map<String, Object> argsMap)
    {
        Order orderToCallout = (Order) argsMap.get('sender');
        if(orderToCallout.FlagServizio26__c != null && orderToCallout.FlagServizio26__c.equalsIgnoreCase('Y'))
        {
            HDT_SRV_SalesManager salesManager = new HDT_SRV_SalesManager();
            salesManager.execute(argsMap);
        }
    }

}