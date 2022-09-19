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
        List<SObject> sobjToUpdate = bpCaUtl.handleResponse(response, inputOrder);
        if(!sobjToUpdate.isEmpty())
        {
            HDT_UTL_DatabaseService.updateSObject(sobjToUpdate);
        }
        return;
    }

}
