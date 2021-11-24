@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_WS_VasCalloutActions implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction, wrts_prcgvr.Interfaces_1_2.IApexCriteria {
    global HDT_WS_VasCalloutActions() {
        return;
    }

    global Object execute(Object args) {
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Map<String,Object> argsMap = (Map<String,Object>) args;
        String method = (String) argsMap.get('method');
        SObject obj = (sObject) argsMap.get('sender');

        HDT_SRV_SalesManager slsManager = new HDT_SRV_SalesManager(true);
        //HDT_SRV_SalesManager slsManager = new HDT_SRV_SalesManager(false);//if true updates technical phase instead of Phase
        slsManager.vasCustomCallouts((ID) obj.get('ID'), method.toLowerCase());

        response.success = true;
        response.message = 'OK';
        return response;
    }

    global Boolean evaluate(Object args){//
        Map<String, Object> argsMap = (Map<String, Object>) args;
        //system.debug(json.serialize(args));
        //SObject transition = (SObject) argsMap.get('transition');
        //SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        //SObject record = (SObject) argsMap.get('record');
        Boolean evaluation = false;
        switch on method{
            when 'isFutureOrBatch'{
                evaluation = System.isFuture() || System.isBatch();
            }
            when 'notFutureNorBatch'{
                evaluation = !(System.isFuture() || System.isBatch());
            }
        }
        return evaluation;
    }
}