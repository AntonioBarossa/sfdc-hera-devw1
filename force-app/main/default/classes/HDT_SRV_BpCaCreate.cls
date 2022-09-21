public with sharing class HDT_SRV_BpCaCreate 
{
    private HDT_UTL_BpCaCreate bpCaUtl = new HDT_UTL_BpCaCreate();


    public String generateRequest(Order inputOrder)
    {
        String result = '';
        String causalCode = inputOrder.CustomerCode__c == null ? bpCaUtl.BP_CA_CODE : inputOrder.ContractAccountCode__c == null ? bpCaUtl.CA_CODE : '';
        if(String.isBlank(result))
        {
            return result;
        }
        result = bpCaUtl.generateRequest(inputOrder, causalCode);
        return result;
    }


    public void handleResponse(HttpResponse response, Order inputOrder)
    {
        List<SObject> sobjList = bpCaUtl.handleResponse(response, inputOrder);
        List<SObject> sobjToUpdate = new List<SObject>();

        List<HDT_PEV_VoltureChangeManagerUpdateSObj__e> platEvents = new  List<HDT_PEV_VoltureChangeManagerUpdateSObj__e>();
        for(SObject sobj : sobjList)
        {
            if(sobj.getSObjectType().getDescribe().getName().equalsIgnoreCase('Order'))
            {
                HDT_PEV_VoltureChangeManagerUpdateSObj__e evt = new HDT_PEV_VoltureChangeManagerUpdateSObj__e();
                Order newOrder = new Order();
                newOrder.Id = (Id) sobj.get('Id');
                newOrder.Phase__c = 'Comunicazione verso Heroku';
                if(sobj.get('CustomerCode__c') != null)
                {
                    newOrder.CustomerCode__c = (String) sobj.get('CustomerCode__c');
                }
                if(sobj.get('ContractAccountCode__c') != null)
                {
                    newOrder.ContractAccountCode__c = (String) sobj.get('ContractAccountCode__c');
                }
                evt.SerializedSobj__c = JSON.serialize(newOrder);
                platEvents.add(evt);
            }
            else
            {
                sobjToUpdate.add(sobj);
            }
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
