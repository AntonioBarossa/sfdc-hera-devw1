@RestResource(urlMapping='/SolInboundServices/*')
global with sharing class HDT_WS_InboundSol {
    
    @HttpGet
    global static HDT_WRP_SolContractVas getContractVas() {
        String accountId = RestContext.request.params.get('ownerAccountId');
        return HDT_SRV_SolContractVas.handleRequest(accountId);
    }
}