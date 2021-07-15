public with sharing class HDT_WS_TransitionWinBack {
    
    @AuraEnabled
    public static HDT_WS_TransitionWinBackResponse callTransitionCom(String pod){
        
        HDT_WS_TransitionWinBackRequest requ = new HDT_WS_TransitionWinBackRequest(pod);
        HDT_WS_TransitionWinBackResponse resp = (HDT_WS_TransitionWinBackResponse)HDT_WS_TransitionWinback.sendRequest('TransitorioWinback', requ,HDT_WS_TransitionWinBackResponse.class);
        
        return resp;
    }  


    /**
 * @author Elfrida Kora (elfrida.kora@dunegroup.it)
 * @date 08/07/2021
 * @description HDT_WS_TransitionWinBack.cls - Class that holds logic for Gestione Transitorio
 * @history Elfrida Kora  – 08/07/2021 – Created class
 */
    
    public class HDT_WS_TransitionWinBackRequest extends HDT_WS_Request{
        //@AuraEnabled public HDT_WS_TransitionReqObj transitione{get;set;}
        //public HDT_WS_TransitionWinBackRequest(String pod){
            //this.transitione = new HDT_WS_TransitionReqObj();
           // this.transitione.pod1 = pod;
       // }
       @AuraEnabled
       String pod {get;set;}
	}

    public class HDT_WS_TransitionWinBackResponse extends HDT_WS_Response{
        //@AuraEnabled public class HDT_WS_TransitioneObj  transitione{get;set;}
        @AuraEnabled public String pod {get;set;}
        @AuraEnabled public String dataDecorreza {get;set;}
        @AuraEnabled public String stato {get;set;}  
	}

    public class HDT_WS_TransitioneObj{
        @AuraEnabled public String pod {get;set;}
        @AuraEnabled public String dataDecorreza {get;set;}
        @AuraEnabled public String stato {get;set;}       
       
    }
}
