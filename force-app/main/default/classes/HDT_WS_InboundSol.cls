@RestResource(urlMapping='/SolInboundServices/*')
global with sharing class HDT_WS_InboundSol {
    
    @HttpGet
    global static HDT_WRP_SolContractVas getContractVas() {
        String accountId = RestContext.request.params.get('ownerAccountId');
        return HDT_SRV_SolContractVas.handleRequest(accountId);
    }

    @HttpPost
    webservice static void doPost() {
        String body = RestContext.request.requestBody.toString();
        Map<String,Object> bodyMap = (Map<String,Object>) JSON.deserializeUntyped(body);
        String caseId = (String) bodyMap.get('caseId');
        String method = (String) bodyMap.get('method');
        String phase = bodyMap.get('phase') != null? (String)bodyMap.get('phase'):'';
        switch on method {
            when 'compatibility' {
                HDT_SRV_GenericSolHandler.checkCompatibility(caseId,phase);
            }
            when 'installment'{
                HDT_SRV_GenericSolHandler.handleInstallment(caseId);
            }
            when 'analisiConsumi'{
                HDT_SRV_GenericSolHandler.handleAnalisiConsumi(bodyMap);
            }
            when 'volturah2o'{
                HDT_SRV_GenericSolHandler.handleVolturaH2O(bodyMap);
            }
            when else {
                HDT_SRV_GenericSolHandler.dataEnrichment(caseId);
            }
        }
        //RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        RestContext.response.headers.put('Content-Type', 'application/json');
        RestContext.response.statusCode = 200;
    }
}