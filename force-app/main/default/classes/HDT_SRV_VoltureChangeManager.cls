public with sharing class HDT_SRV_VoltureChangeManager 
{
    private static HDT_UTL_VoltureChangeManager voltureChangeUtl = new HDT_UTL_VoltureChangeManager();
    private static HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();

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
        /* Call to the cloneSobject method */
        Map<String,Object> extraParams = new Map<String,Object>();
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
        HDT_UTL_VoltureChangeManager.updateOrderFuture(JSON.serialize(inputOrder));
        /**@frpanico 07/10/2021*/
        /*Next step apply update cloneOrder logic*/
    }
}
