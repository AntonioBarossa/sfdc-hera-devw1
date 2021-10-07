public with sharing class HDT_SRV_VoltureChangeManager 
{
    private static HDT_UTL_VoltureChangeManager voltureChangeUtl = new HDT_UTL_VoltureChangeManager();

    /**
     * @frpanico 06/10/2021
     * This method call the cloneSobject method from the HDT_UTL_VoltureChangeManager class
     * at the current state no extra fields need to be excluded
     * After the insert of the object the input sobj needs to pass on phase "Annullato".
     */
    public void cloneOrderAndUpdate(SObject sobj)
    {
        /* Call to the cloneSobject method */
        Order clonedOrder = (Order)voltureChangeUtl.cloneSObject(sobj, null);
        /* Add process Type to the cloned order and insert*/
        clonedOrder.put('ProcessType__c','Voltura con Switch');
        HDT_UTL_DatabaseService.insertSObject(clonedOrder);
        /* Update in "Annullato" phase the input order */
        Order inputOrder = (Order)sobj;
        inputOrder.Phase__c = 'Annullato';
        /*TODO: add other fields of annullment if needed*/
        HDT_UTL_VoltureChangeManager.updateOrderFuture(JSON.serialize(inputOrder));


    }
}
