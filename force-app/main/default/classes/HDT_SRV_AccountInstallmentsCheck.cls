public with sharing class HDT_SRV_AccountInstallmentsCheck {
    
    @InvocableMethod(label='Check Piani Rata Non Pagati')
    public static List<HDT_SRV_AccountInstallmentsCheckOutput> execute(List<HDT_SRV_AccountInstallmentsCheckInput> inputs){
        if(inputs==null || inputs.size()<=0) return null;
      
        HDT_SRV_AccountInstallmentsCheckInput input = inputs[0];

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = HDT_LC_AccountStatementCtrlUtility.setHttpObject('EC4', '');

        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow bodyWrapper = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        // REQUEST VISTA RATE HOME
        bodyWrapper.applicativo = 'ML';
        bodyWrapper.loginId = '0-1';
        bodyWrapper.tipoTransazione = 'EC4';
        bodyWrapper.tipoEstrattoConto = 'ORDINARIO';
        bodyWrapper.codiceCliente = input.customerCode;

        String body = JSON.serialize(bodyWrapper, true);
        System.debug('HDT_SRV_AccountInstallmentsCheck: request body = ' + body);
        HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(body, httpObj);

        List<String> uniqueInstallmentPlans = new List<String>();


        if (responseCtrl.body == null) {
            System.debug('HDT_SRV_AccountInstallmentsCheck: null response');
            return null;
        }

        Boolean isLetturaStimata = false;
        Boolean isMultiContratto = false;
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseCtrl.body);
        System.debug('HDT_SRV_AccountInstallmentsCheck: parsed response body = ' + JSON.serialize(responseBodyMap));

        if (responseBodyMap.containsKey('data')) {
            List<Object> dataObj = (List<Object>) responseBodyMap.get('data');
            System.debug('HDT_SRV_AccountInstallmentsCheck: parsed response data = ' + dataObj);
            // TODO: parse response
            // Bisogna contare il numero di record del primo livello con campo residuo > 0 e numero piano rata differente.
            Map<String, Object> singleObjMap = new Map<String,Object>();
            String installmentPlan;
    
            for(Object singleObj : dataObj){

                singleObjMap = (Map<String, Object>) singleObj;

                System.debug('SRV_AccountInstallmentsCheck residuo --> ' + Decimal.valueOf((String) singleObjMap.get('residuo')));
                System.debug('SRV_AccountInstallmentsCheck documento --> ' + (String) singleObjMap.get('documento'));

                installmentPlan = (String) singleObjMap.get('documento');

                if(Decimal.valueOf((String) singleObjMap.get('residuo')) > 0.0){

                    if(!uniqueInstallmentPlans.contains(installmentPlan)){
                        
                        uniqueInstallmentPlans.add(installmentPlan);

                    }
                }
            }

        }

        HDT_SRV_AccountInstallmentsCheckOutput output = new HDT_SRV_AccountInstallmentsCheckOutput();
        output.existingInstallmentPlanUnpaid = uniqueInstallmentPlans.size(); 

        List<HDT_SRV_AccountInstallmentsCheckOutput> outputList = new List<HDT_SRV_AccountInstallmentsCheckOutput>();
        outputList.add(output);

        return outputList;
    }

    public class HDT_SRV_AccountInstallmentsCheckInput {
    
        @InvocableVariable
        public String customerCode;
    }

    public class HDT_SRV_AccountInstallmentsCheckOutput {
        
        @InvocableVariable
        public Integer existingInstallmentPlanUnpaid; 
    }
}