public with sharing class HDT_WS_VoltureChangeManager implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction{

    /**@frpanico 13/10/2021
     * WS class that handles the new Precheck call for "Voltura con Switch"
     * Implements the ProcessClick standard interface to make the call
     */

    HDT_QR_HerokuPostSalesManager herokuPostSalesQr = new HDT_QR_HerokuPostSalesManager();

    public Object execute(Object args)
    {   
        /* Variable Declaration */
        Map<String,Object> argsMap = (Map<String,Object>)args;
        Map<String,Object> calloutMap = new Map<String,Object>();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        wrts_prcgvr.MRR_1_0.MultiResponse responseMrr  = new wrts_prcgvr.MRR_1_0.MultiResponse();
        String method;

        /* Extract informations from the input map:
         * "method" - custom string passed from the phase manager's callout configuration
         * "sender" - Trigger.new (in this use-case an Order)
         * 
        */

        method = (String) argsMap.get('method');
        SObject sobj = (SObject) argsMap.get('sender');

        Order currentOrder = (Order)sobj;

        /*setup and make the callout*/
        try
        {
            /*Get Callout Template*/
            wrts_prcgvr.Interfaces_1_0.IPhaseManagerUtils pMUtils = 
            ((wrts_prcgvr.Interfaces_1_0.IPhaseManagerUtils) wrts_prcgvr.VersionManager.newClassInstance('PhaseManagerUtils'));
            Map<Id, List<wrts_prcgvr__PhaseTransition__c>> result = 
            (Map<Id, List<wrts_prcgvr__PhaseTransition__c>>)pMUtils.getTransitionCalloutsForObjects(new Map<String, Object> {'triggerNew' => new List<Order>{currentOrder}});
            List<wrts_prcgvr__PhaseTransition__c> ptList = result.get(currentOrder.Id);
            wrts_prcgvr__CalloutTemplate__c template = herokuPostSalesQr.getCalloutTemplateByCode(ptList[0].wrts_prcgvr__CalloutTemplate__c);
            argsMap.put('template', template);

            /*Apply Callout Template*/
            wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng templateEngine =
            (wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng) wrts_prcgvr.VersionManager.newClassInstance('CalloutTemplateMng');
            argsMap = (Map<String,Object>) templateEngine.getTemplate(argsMap);
            argsMap = (Map<String,Object>) templateEngine.applyTemplate(argsMap);
        
            /*Get EndpointRule*/
            wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration endpointUtils = 
            (wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration) wrts_prcgvr.VersionManager.newClassInstance('EndpointRulesIntegration');
            String endpoint = endpointUtils.getEndpoint(new Map<String,Object>{'Order'=>currentOrder});

            /*Get MMRequest*/
            wrts_prcgvr.MRR_1_0.MultiRequest mrrList = (wrts_prcgvr.MRR_1_0.MultiRequest) argsMap.get('multirequest');

            /*Build Request*/
            calloutMap.put('endpoint', endpoint);
            calloutMap.put('timeout', 12000);
            calloutMap.put('payload',mrrList);
            calloutMap.put('clientType','REST');
            calloutMap.put('contentType','application/json');

            /*Make Callout*/            
            wrts_prcgvr.Interfaces_1_0.ICalloutClient client = 
            (wrts_prcgvr.Interfaces_1_0.ICalloutClient) wrts_prcgvr.VersionManager.newClassInstance('CalloutClient');
            responseMrr  =  (wrts_prcgvr.MRR_1_0.MultiResponse) client.send(calloutMap);
        }
        catch(exception e)
        {
            responseMrr = null;
        }

        /*Handle Response*/
        if(responseMrr != null)
        {

        }
        /*Expected output of the Interface method*/
        response.success = true;
        response.message = 'OK';
        return response;
    }

}
