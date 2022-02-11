/**@frpanico 09/02/2022
 * Implementato Batch
 * per chiamare credit check dopo
 * 60 giorni apertura activity
 */
public with sharing class HDT_BA_CallCreditCheck implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts{

    private Date lastSixtyDays = Date.today().addDays(-60);

    public List<SObject> start(Database.BatchableContext bc)
    {
        return[SELECT Order__c,
        Order__r.Id,
        Order__r.CreatedById,
        Order__r.ProcessType__c,
        Order__r.SupplyPostalCode__c,
        Order__r.Catalog__c,
        Order__r.SupplyCity__c,
        Order__r.Market__c,
        Order__r.ChannelTransCode__c,
        Order__r.SupplyState__c,
        Order__r.Commodity__c,
        Order__r.AnnualConsumption__c,
        Order__r.SalesCompany__c,
        Order__r.SupplyStreetName__c,
        Order__r.CustomerType__c,
        Account__c,
        Account__r.CustomerType__c,
        Account__r.CustomerMarking__c,
        Account__r.Category__c,
        Account__r.FirstName__c,
        Account__r.LastName__c,
        Account__r.FiscalCode__c,
        Account__r.VATNumber__c,
        Account__r.CustomerCode__c
        FROM wrts_prcgvr__Activity__c
        WHERE (RecordType.DeveloperName = 'HDT_RT_CreditCheckKO' OR RecordType.DeveloperName = 'HDT_RT_KoPrecedeteCliente')
        AND wrts_prcgvr__Status__c = 'Aperta'
        AND StartDate__c <= :this.lastSixtyDays
        WITH SECURITY_ENFORCED];
    }
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void execute(Database.BatchableContext bc, List<SObject> scope)
    {
        String request = '';
        HDT_WS_CreditCheckResponse res = new HDT_WS_CreditCheckResponse();
        HDT_WS_CreditCheckRequest myCreditCheckRequest = new HDT_WS_CreditCheckRequest();
        for(wrts_prcgvr__Activity__c activity : (List<wrts_prcgvr__Activity__c>)scope)
        {
            request = makeRequest(activity);
            if(request != ''){
                myCreditCheckRequest = (HDT_WS_CreditCheckRequest)JSON.deserialize(request, HDT_WS_CreditCheckRequest.class);
                res = HDT_WS_CreditCheck.callService(myCreditCheckRequest);
            }
            System.debug(LoggingLevel.DEBUG, 'Response ' + JSON.serialize(res));
        }
        return;
    }
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId() WITH SECURITY_ENFORCED];
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_CallCreditCheck - finished job: ' + a);
    }

    private String makeRequest(wrts_prcgvr__Activity__c activity)
    {
        HDT_WS_CreditCheckRequest request = new HDT_WS_CreditCheckRequest();
        List<HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail> details = new List<HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail>();
        HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail detail = new HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail();

        detail.totalConsumption = '';
        detail.annualConsumption = String.valueOf(activity.Order__r.AnnualConsumption__c);
        detail.commodity = tryParse(activity.Order__r.get('Commodity__c')) == 'Gas' ? 'GAS' : 'ENERGIA ELETTRICA';

        request.userId = tryParse(activity.Order__r.get('CreatedById'));
        request.sistema = 'eEnergy';
        request.secondaryCustomerId = tryParse(activity.Account__r.get('VATNumber__c'));
        request.postCode = tryParse(activity.Order__r.get('SupplyPostalCode__c'));
        request.operation = tryParse(activity.Order__r.get('ProcessType__c'));
        request.offerType = tryParse(activity.Order__r.get('Catalog__c'));
        request.municipality = tryParse(activity.Order__r.get('SupplyCity__c'));
        request.market = tryParse(activity.Order__r.get('Market__c'));
        request.jobTitle = tryParse(activity.Order__r.get('ChannelTransCode__c'));
        request.internalCustomerId = tryParse(activity.Account__r.get('CustomerCode__c'));
        request.externalCustomerId = tryParse(activity.Account__r.get('FiscalCode__c')) == '' ? tryParse(activity.Account__r.get('VATNumber__c')) : tryParse(activity.Account__r.get('FiscalCode__c'));
        request.district = tryParse(activity.Order__r.get('SupplyState__c'));
        request.customerType = 'CT0';
        request.crmId = tryParse(activity.Order__r.get('Id'));
        request.crmEntity = 'Order';
        request.companyName = tryParse(activity.Account__r.get('FirstName__c')) == '' ? tryParse(activity.Account__r.get('LastName__c')) : tryParse(activity.Account__r.get('FirstName__c')) + ' ' + tryParse(activity.Account__r.get('LastName__c'));
        request.companyGroup = tryParse(activity.Order__r.get('SalesCompany__c'));
        request.caso = 'Transazionale';
        request.bpType = tryParse(activity.Order__r.get('CustomerType__c'));
        request.bpCategory = getCustomerMarking(tryParse(activity.Account__r.get('CustomerMarking__c')));
        request.bpAlternative = '';
        request.alternativeCustomerId = '';
        request.address = tryParse(activity.Order__r.get('SupplyStreetName__c'));
        request.activationUser = 'AccountCommercialePRM';
        request.account = 'AccountCommercialePRM';

        details.add(detail);
        request.details = details;

        return JSON.serialize(request);
    }
    private String tryParse(Object field)
    {
        String result = '';
        try
        {
            result = String.valueOf(field);
        }
        catch(Exception e)
        {
            result = '';
        }
        return result;
    }
    private String getCustomerMarking(String customerMarking)
    {
        String result = '';
        String regex = '^D[0-9] - .*';
        if(String.isBlank(customerMarking))
        {
            return result;
        }
        else
        {
            Pattern regexPattern = Pattern.compile(regex);
            if(regexPattern.matcher(customerMarking).matches())
            {
                result = customerMarking.replaceAll('D[0-9] - ','');
            }
        }
        return result;
    }

}