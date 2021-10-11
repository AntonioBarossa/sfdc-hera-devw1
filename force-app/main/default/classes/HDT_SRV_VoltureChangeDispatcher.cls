public with sharing class HDT_SRV_VoltureChangeDispatcher implements wrts_prcgvr.Interfaces_1_0.IApexAction
{
    private static HDT_SRV_VoltureChangeManager voltureChangeSrv = new HDT_SRV_VoltureChangeManager();
    public Object execute(Object args)
    {
        Map<String, Object> argsMap = (Map<String,Object>)args;
        String method = (String)argsMap.get('method');
        SObject sender = (SObject)argsMap.get('sender');


        switch on method
        {
            when 'cloneOrder'
            {
                voltureChangeSrv.cloneOrderAndUpdate(sender);   
            }
        }

        return null;
    }

}
