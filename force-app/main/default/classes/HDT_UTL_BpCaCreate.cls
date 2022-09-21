public with sharing class HDT_UTL_BpCaCreate
{
    public final String BP_CA_CODE = 'BPC';
    public final String CA_CODE = 'CAC';


    public String generateRequest(Order inputOrder, String causalCode)
    {
        String result = '';
        if(causalCode.equalsIgnoreCase(BP_CA_CODE))
        {
            result = generateBpCaCreateRequest(inputOrder);
        }
        else
        {
            result = generateCaCreateRequest(inputOrder);
        }
        return result;
    }

    public List<SObject> handleResponse(HttpResponse response, Order inputOrder)
    {
        List<SObject> result = new List<Order>();
        
        String bodyResponse = response.getBody();
        HDT_WS_RichCreBpCaResponse responseWrp = (HDT_WS_RichCreBpCaResponse) JSON.deserialize(bodyResponse, HDT_WS_RichCreBpCaResponse.class);

        if(responseWrp.data != null && !responseWrp.data.tipoAttivita.containsIgnoreCase('Errore'))
        {
            result = handleSobjectUpdate(inputOrder, responseWrp);
        }

        return result;
    }

    private String generateBpCaCreateRequest(Order inputOrder)
    {
        String result = 'testCreate';
        return result;
    }
    private String generateCaCreateRequest(Order inputOrder)
    {
        String result = 'testCreate';
        return result;
    }
    private List<SObject> handleSobjectUpdate(Order inputOrder, HDT_WS_RichCreBpCaResponse response)
    {
        List<SObject> result = new List<SObject>();
        Order orderToUpdate = new Order(Id = inputOrder.Id);
        if(response.data.codiceCausale.equalsIgnoreCase(BP_CA_CODE))
        {
            orderToUpdate.CustomerCode__c = response.data.codiceBP;
            orderToUpdate.ContractAccountCode__c = response.data.codiceBPAlternativo;
            orderToUpdate.Phase__c = inputOrder.ProcessType__c.equalsIgnoreCase('Voltura') ? 'Documentazione Validata' : 'Comunicazione verso Heroku';
            Account accountToUpdate = new Account(Id = inputOrder.AccountId, CustomerCode__c = response.data.codiceBP);
            BillingProfile__c billingProfileToUpdate = new BillingProfile__c(Id = inputOrder.BillingProfile__c, ContractAccountCode__c = response.data.codiceBPAlternativo);
            result.add(accountToUpdate);
            result.add(billingProfileToUpdate);
            result.add(orderToUpdate);
        }
        else
        {
            orderToUpdate.ContractAccountCode__c = response.data.codiceBP;
            orderToUpdate.Phase__c = inputOrder.ProcessType__c.equalsIgnoreCase('Voltura') ? 'Documentazione Validata' : 'Comunicazione verso Heroku';
            BillingProfile__c billingProfileToUpdate = new BillingProfile__c(Id = inputOrder.BillingProfile__c, ContractAccountCode__c = response.data.codiceBP);
            result.add(billingProfileToUpdate);
            result.add(orderToUpdate);
        }
        return result;
    }
}
