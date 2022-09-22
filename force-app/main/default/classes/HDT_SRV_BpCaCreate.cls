public with sharing class HDT_SRV_BpCaCreate 
{
    private HDT_UTL_BpCaCreate bpCaUtl = new HDT_UTL_BpCaCreate();


    public String generateRequest(Order inputOrder)
    {
        return bpCaUtl.generateRequest(inputOrder, '');
        
    }


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
