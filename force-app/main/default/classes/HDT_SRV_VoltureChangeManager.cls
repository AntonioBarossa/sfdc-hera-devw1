public with sharing class HDT_SRV_VoltureChangeManager 
{
    private static HDT_UTL_VoltureChangeManager voltureChangeUtl = new HDT_UTL_VoltureChangeManager();
    private static HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();
    private static HDT_UTL_VoltureChangeUtilities voltureChangeUtils = new HDT_UTL_VoltureChangeUtilities();

    private static String voltureChangeRecordTypeName = 'HDT_RT_VolturaConSwitch';
    private static String clonedOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(voltureChangeRecordTypeName).getRecordTypeId();

    private static String ammissibilityCheckTemplate = 'Controlli Ammissibilità';
    @TestVisible
    private static String publishUpdatePhase = 'Comunicazione verso Heroku';
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

        /* Call to the cloneSobject method */
        extraParams.put('sobjName', 'Order');
        Order clonedOrder = (Order)voltureChangeUtl.cloneSObject(sobj, extraParams);
        Order inputOrder = (Order)sobj;        
        /* Add process Type to the cloned order and insert*/
        clonedOrder.put('ProcessType__c','Voltura con Switch');
        clonedOrder.put('RecordTypeId', clonedOrderRecordTypeId);
        clonedOrder.put('Phase__c','Bozza');
        clonedOrder.put('Status','Draft');
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

    /**@frpanico 18/10/2021
     * This method handle the ammissibility checks
     * Takes in input the paramsMap returned from the response
     * if the check is false it creates an activity
     */
    public void handleAmmissibilityCheck(Map<String,Object> paramsMap, Order currentOrder)
    {
        /**Execute the check and if its false creates the activity*/
        if(!voltureChangeUtl.handleAmmissibilityCheck(paramsMap, currentOrder))
        {
            wrts_prcgvr__Activity__c activity = voltureChangeUtils.createActivity(ammissibilityCheckTemplate);
            if(activity != null)
            {
                activity.Order__c = currentOrder.Id;
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
        HDT_PEV_VoltureChangeManagerUpdateSObj__e platEvent = new HDT_PEV_VoltureChangeManagerUpdateSObj__e();

        inputOrder.Phase__c = publishUpdatePhase;
        platEvent.SerializedSobj__c = JSON.serialize(inputOrder);
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
        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> posizioni = 
            (List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>)inputMap.get('posizioni');
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
}
