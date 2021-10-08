public with sharing class HDT_SRV_VoltureChangeManager 
{
    private static HDT_UTL_VoltureChangeManager voltureChangeUtl = new HDT_UTL_VoltureChangeManager();
    private static HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();

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
        Order clonedOrder = (Order)voltureChangeUtl.cloneSObject(sobj, null);
        Order inputOrder = (Order)sobj;
        /* Add process Type to the cloned order and insert*/
        clonedOrder.put('ProcessType__c','Voltura con Switch');
        clonedOrder.put('RecordTypeId', inputOrder.RecordTypeId);
        clonedOrder.put('Phase__c','Bozza');
        clonedOrder.put('Status','New');
        HDT_UTL_DatabaseService.insertSObject(clonedOrder);
        /*Retrieve and clone OrderItems from input order*/
        orderItemsToClone = voltureChangeQr.getOrderItemByOrderId(inputOrder.Id);
        if(orderItemsToClone.size() > 0)
        {
            for(OrderItem ordItem : orderItemsToClone)
            {
                OrderItem newOrdItem = (OrderItem)voltureChangeUtl.cloneSObject(ordItem, null);
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
