public inherited sharing class HDT_SRV_ComunicationsSearchList {

    public static Object getWsData(String wrapperObj) {

        System.debug('>>> wrapperObj ' + wrapperObj);

        HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj wsObj = new HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj();
        
        try{

            HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = new HDT_WS_MulesoftCaller.HDT_WRP_HttpObj();
            httpObj.headersMap = new Map<String, String>();
            httpObj.endPoint = 'callout:docComunicationsSearch';    
            httpObj.httpMethod = 'POST';
            httpObj.headersMap.put('Content-Type', 'application/json');

            if(httpObj == null){
                wsObj.success = false;
                wsObj.message = 'Metadati httpObj non configurati';
                return wsObj;
            }
    
            HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(wrapperObj, httpObj);
            System.debug('>>>> RETRIEVE FROM WS ' + responseCtrl);

            //if(!responseCtrl.success){
            //    wsObj.success = false;
            //    wsObj.message = responseCtrl.message;
            //    return JSON.serialize(wsObj);
            //}

            //HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj restMessage = (HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj)JSON.deserialize(responseCtrl.body, HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj.class);

            //if(restMessage.status != 'success'){
            //    wsObj.success = false;
            //    wsObj.message = 'Mulesoft side [code: ' + restMessage.errorDetails.code;
            //    wsObj.message += ']; Detail: ' + restMessage.errorDetails.message;
            //    wsObj.message += '; Additional Info' + restMessage.errorDetails.additionalInfo;
            //    return JSON.serialize(wsObj);
            //}
    
            //System.debug('>>>> RETRIEVE FROM WS ' + restMessage);

            wsObj.success = true;
            wsObj.message = '';
            wsObj.body = getFakeData();

            //Account a = new Account();
            //a.Id = '';
            //insert a;

        } catch (Exception ex){
            wsObj.success = false;
            wsObj.message = ex.getMessage();
            wsObj.body = null;
        }

        return JSON.serialize(wsObj);
    }

    public static String getFakeData(){
        System.debug('>>> getFakeData');
        String s = '[';

        Integer max = 50;
        Date dd = Date.today();
        Date currentDate;
        String stringDate;
        for(Integer n=1; n <= max; n++){
            currentDate = dd.addDays(n);
            String d = (currentDate.day()<10) ? '0' + String.valueOf(currentDate.day()) : String.valueOf(currentDate.day());
            String m = (currentDate.month()<10) ? '0' + String.valueOf(currentDate.month()) : String.valueOf(currentDate.month());
            stringDate = d + '/' + m + '/' + String.valueOf(currentDate.year());
            s += '{"id": "' + String.valueOf(n) + '", "billNumber": "' + String.valueOf(n) + '", "billDate": "' + stringDate + '"}';
            if(n != max){
                s += ',';
            }
        }

        s += ']';
        return s;
    }

}