public with sharing class HDT_SRV_VoltureChangeManager 
{
    private static HDT_UTL_VoltureChangeManager voltureChangeUtl = new HDT_UTL_VoltureChangeManager();
    private static HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();
    private static HDT_UTL_VoltureChangeUtilities voltureChangeUtils = new HDT_UTL_VoltureChangeUtilities();

    private static String voltureChangeRecordTypeName = 'HDT_RT_VolturaConSwitch';
    private static String clonedOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(voltureChangeRecordTypeName).getRecordTypeId();
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
}
