/**@frpanico 19/10/2021
 * Dispatcher class that implements the ProcessClick PhaseManager custom Apex Action interface
 * call the relative methods based on the input method passed from ProcessClick
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class HDT_SRV_VoltureChangeDispatcher implements wrts_prcgvr.Interfaces_1_0.IApexAction
{
    private static HDT_SRV_VoltureChangeManager voltureChangeSrv = new HDT_SRV_VoltureChangeManager();
    global Object execute(Object args)
    {
        Map<String, Object> argsMap = (Map<String,Object>)args;
        String method = (String)argsMap.get('method');
        SObject sender = (SObject)argsMap.get('sender');


        switch on method
        {
            /* Used to clone an order, update the input order and the cloned order*/
            when 'cloneOrder'
            {
                voltureChangeSrv.cloneOrderAndUpdate(sender);   
            }
            /* Create and publish the platform event for the update and callout */
            when 'publishUpdate'
            {
                voltureChangeSrv.handlePublishUpdate((Order)sender);
            }
            when 'precheckOk'{

                voltureChangeSrv.orderPrecheckOk((Order)sender);
            }
        }

        return null;
    }
}