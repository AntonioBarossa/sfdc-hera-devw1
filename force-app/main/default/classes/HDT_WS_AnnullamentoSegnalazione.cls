/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 18-10-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.AvoidDebugStatements')
global inherited sharing class HDT_WS_AnnullamentoSegnalazione implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction{
    
    private static final String REQUEST_PATH = '/toBeDefined';

    global HDT_WS_AnnullamentoSegnalazione() {
        return;
    }

    public class HDT_WS_AnnullamentoSegnalazioneResponse extends HDT_WS_Response{
        @AuraEnabled public List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String correlationId {get;set;}
        @AuraEnabled public String timestamp {get;set;}
        @AuraEnabled public HDT_WRP_ResponseData data {get;set;}
    }

    private class HDT_WRP_ResponseData{
        @AuraEnabled public String esito {get;set;}
    }

    public virtual class HDT_WRP_AnnullamentoSegnalazioneReq extends HDT_WS_Request{
        String caseId;
        String noticeId;

        public HDT_WRP_AnnullamentoSegnalazioneReq(String caseId, String noticeId) {
            this.caseId = caseId;
            this.noticeId = noticeId;
        }
    }
      
    global Object execute(Object args){
        
        Map<String, Object> argsMap = (Map<String, Object>) args;
        SObject obj = (SObject) argsMap.get('sender');
        Case currentCase = (Case) obj;

        HDT_WRP_AnnullamentoSegnalazioneReq req = new HDT_WRP_AnnullamentoSegnalazioneReq(currentCase.Id, null); //noticeId null
        HDT_WS_AnnullamentoSegnalazioneResponse res = (HDT_WS_AnnullamentoSegnalazioneResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req, HDT_WS_AnnullamentoSegnalazioneResponse.class);
        System.debug(LoggingLevel.DEBUG,'response -> ' + res); 

        try {

            if(res.status.equalsIgnoreCase('success')){

                currentCase.TecnicalPhase__c = 'Annullato';
                currentCase.Status= 'Closed';

                if(!currentCase.WithdrawalFee__c){ //Se Ritiro Gratuito
            
                    Datetime createdDate = currentCase.CreatedDate;
                    Date dataUltimoRitiro = Date.newinstance(createdDate.year(), createdDate.month(), createdDate.day());

                    List<FreeWithdraw__c> ritiri = [SELECT Id , ServicePoint__c, LastFreeWithdrawDate__c
                                                FROM FreeWithdraw__c
                                                WHERE ServicePoint__c =:currentCase.ServicePoint__c
                                                AND LastFreeWithdrawDate__c =:dataUltimoRitiro
                                                WITH SECURITY_ENFORCED];
                    
                    FreeWithdraw__c ritiro = ritiri[0];
                    ritiro.Canceled__c = true;
                    HDT_UTL_DatabaseService.updateSObject(ritiro);
                }

            }else{
                String oldTransitions = currentCase.PhaseStory__c;
                String result;
                if(String.isNotBlank(oldTransitions)){
                    result=oldTransitions.split('\\|\\|')[0].trim().substringBefore('@');
                    System.debug(LoggingLevel.DEBUG,'oldTransition -> ' + result);
                    currentCase.Phase__c = result;
                }
            }

            HDT_UTL_DatabaseService.updateSObject(currentCase);

        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG,'exception --> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.DEBUG,'atLine --> ' + ex.getLineNumber());
            System.debug(LoggingLevel.DEBUG,ex.getMessage());
        }

        return res;
    }

}