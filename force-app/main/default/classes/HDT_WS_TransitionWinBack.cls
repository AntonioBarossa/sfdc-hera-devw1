public with sharing class HDT_WS_TransitionWinBack {
    
    @AuraEnabled
    public static HDT_WS_TransitionWinBackResponse callTransitionCom(String pod){
        List<HDT_WS_TransitionWinBackRequest> listReq = new List<HDT_WS_TransitionWinBackRequest>();
        HDT_WS_TransitionWinBackRequest requ = new HDT_WS_TransitionWinBackRequest(pod);
        listReq.add(requ);
        HDT_WS_TransitionWinBackResponse re = (HDT_WS_TransitionWinBackResponse)HDT_WS_HTTPServiceCall.sendRequest('TransitorioWinback', listReq,HDT_WS_TransitionWinBackResponse.class);
       /* List<HDT_WS_TransitionWinBackResponse> re = new List<HDT_WS_TransitionWinBackResponse>();
        type r = HDT_WS_TransitionWinBackResponse.class;
        List<object> arra = (List<object>)HDT_WS_HTTPServiceCall.sendRequest('TransitorioWinback', listReq,HDT_WS_TransitionWinBackResponse.class);
        for(object ar : arra){
            String s = JSON.serialize(ar);
            HDT_WS_TransitionWinBackResponse respT = (HDT_WS_TransitionWinBackResponse)JSON.deserialize(s,HDT_WS_TransitionWinBackResponse.class);
            re.add(respT);
        }
*/
        return re;
    }  


    /**
 * @author Elfrida Kora (elfrida.kora@dunegroup.it)
 * @date 08/07/2021
 * @description HDT_WS_TransitionWinBack.cls - Class that holds logic for Gestione Transitorio
 * @history Elfrida Kora  – 08/07/2021 – Created class
 */
    
    public class HDT_WS_TransitionWinBackRequest extends HDT_WS_Request{
        //@AuraEnabled public HDT_WS_TransitionReqObj transitione{get;set;}
        public HDT_WS_TransitionWinBackRequest(String pod){
            //this.transitione = new HDT_WS_TransitionReqObj();
           // this.transitione.pod1 = pod;
           this.pod = pod;
        }
       @AuraEnabled
       public String pod {get;set;}
	}

    public class HDT_WS_TransitionWinBackResponse extends HDT_WS_Response{

        @AuraEnabled public List<HDT_WS_TransitioneObj> result{get;set;}
     /*   @AuraEnabled public String pod {get;set;}
        @AuraEnabled public String dataDecorreza {get;set;}
        @AuraEnabled public String stato {get;set;}  */
	}
    public class HDT_WS_TransitioneObj{
        @AuraEnabled public String pod {get;set;}
        @AuraEnabled public String effectiveDate {get;set;}
        @AuraEnabled public String status {get;set;}       
       
    }


}