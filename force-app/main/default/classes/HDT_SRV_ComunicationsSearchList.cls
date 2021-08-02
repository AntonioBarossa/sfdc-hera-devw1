public inherited sharing class HDT_SRV_ComunicationsSearchList {

    public static Object getWsData(String wrapperObj) {

        System.debug('>>> wrapperObj ' + wrapperObj);

        HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj wsObj = new HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj();
        
        try{

            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(wrapperObj);
            Object documentCategory = (Object)jsonMap.get('documentCategory');
            System.debug('>>> CURRENT TYPE: ' + String.valueOf(documentCategory));

            //if(String.valueOf(documentCategory) == 'solleciti'){
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

                if(!responseCtrl.success){
                    wsObj.success = false;
                    wsObj.message = responseCtrl.message;
                    wsObj.body = responseCtrl.body;
                    return JSON.serialize(wsObj);
                }

            //    wsObj.success = true;
            //    wsObj.message = '';
            //    wsObj.body = responseCtrl.body;
            //    return JSON.serialize(wsObj);
            //}

            wsObj.success = true;
            wsObj.message = '';
            wsObj.body = getFakeData();

        } catch (Exception ex){
            wsObj.success = false;
            wsObj.message = ex.getMessage();
            wsObj.body = null;
        }

        return JSON.serialize(wsObj);
    }

    public static HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj sendFileToPrint(String dataList){
        System.debug('# saveNewOfferConfigured #');
        System.debug(dataList);

        HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj responseObj = new HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj();

        try{
            HDT_WS_EngageOnePrint.HDT_WRP_ReturnObj returnObj = HDT_WS_EngageOnePrint.sendFile(dataList);
            responseObj.success = returnObj.success;
            responseObj.bodyBase64 = returnObj.bodyBase64;
            responseObj.message = returnObj.message;

        } catch (Exception ex){
            responseObj.success = false;
            responseObj.message = ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber());
            return responseObj;
        }

        return responseObj;

    }

    public static String getFakeData(){
        System.debug('>>> getFakeData');
        String s = '{"status": "success", "data":[';

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

        s += ']}';
        return s;
    }

}