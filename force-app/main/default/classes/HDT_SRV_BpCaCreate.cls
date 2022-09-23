/** Service Class of the BpCa Create module
 * This class expose the methods to generate the request
 * Handling the response
 * And performing updates
 */
public with sharing class HDT_SRV_BpCaCreate 
{
    private HDT_UTL_BpCaCreate bpCaUtl = new HDT_UTL_BpCaCreate();

    /** This method generates the body of the request
     * For further details check HDT_UTL_BpCaCreate
     */
    public String generateRequest(Order inputOrder)
    {
        return bpCaUtl.generateRequest(inputOrder, '');
        
    }
    /** This method handles the response from the BP/CA web service
     * It calls the same method from the HDT_UTL_BpCaCreate (check the class for further details)
     * To obtain the list of SOBject to update (Account, BillingProfile and all orders that need to be updated)
     * Account and Billing Profile can be updated via the standard update dml statement
     * Orders need to be updated via a platform event in order to make the PClick callout fires correctly
     * (It is possible to improve the method: since only the "inputOrder" need to perform a callout, other orders can be updated via standard update dml statements)
     * FYI: A trigger is subscribed to the platform event thtat perform an updated on the sobject passed to it. HDT_TRH_VoltureChangeManagerUpdateSobj
     */
    public void handleResponse(HttpResponse response, Order inputOrder)
    {
        List<SObject> sobjList = bpCaUtl.handleResponse(response, inputOrder);
        if(sobjList.isEmpty())
        {
            return;
        }
        List<SObject> sobjToUpdate = new List<SObject>();
        List<HDT_PEV_VoltureChangeManagerUpdateSObj__e> platEvents = new  List<HDT_PEV_VoltureChangeManagerUpdateSObj__e>();

        Map<String, List<Object>> updateMap = bpCaUtl.handleUpdate(sobjList);
        if(updateMap.get(bpCaUtl.SOBJ_KEY) != null)
        {
            sobjToUpdate = (List<SObject>) updateMap.get(bpCaUtl.SOBJ_KEY);
        }
        if(updateMap.get(bpCaUtl.EVT_KEY) != null)
        {
            platEvents = (List<HDT_PEV_VoltureChangeManagerUpdateSObj__e>) updateMap.get(bpCaUtl.EVT_KEY);
        }

        if(!sobjToUpdate.isEmpty())
        {
            HDT_UTL_DatabaseService.updateSObject(sobjToUpdate);
        }
        if(!platEvents.isEmpty())
        {
            Eventbus.publish(platEvents);
        }
        return;
    }

}
