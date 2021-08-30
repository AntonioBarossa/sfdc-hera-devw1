global inherited sharing class HDT_UTL_PrClickDoubleTransaction implements wrts_prcgvr.Interfaces_1_0.IApexAction {


    global Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        system.debug(json.serialize(args));
        SObject transition = (SObject) argsMap.get('transition');
        SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        Id objectId = (Id) sender.get('Id');
        Id orderId = objectId;
        Order currentOrder = (Order) sender;
        String newPhase = method.replaceAll('_', ' ');

        system.enqueueJob(new HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate(
                objectId, newPhase
            )
        );
        
        return null;
    }
}
