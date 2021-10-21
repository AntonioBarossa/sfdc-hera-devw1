@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_SRV_ComunicationsSearchList {

    public static String getCompanyCodeHelper(String companyName){

            List<HDT_HeraCompany__mdt> companyList;
            companyList = HDT_QR_AccountStatement.getCompanyList(companyList);

            for(HDT_HeraCompany__mdt company : companyList){
                if(company.label.equalsIgnoreCase(companyName)){
                    return company.CompanyCode__c;
                }
            }

            return '';
    }

    public static Object getWsData(String wrapperObj) {

        System.debug(LoggingLevel.DEBUG, '>>> wrapperObj ' + wrapperObj);

        HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj wsObj = new HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj();
        
        try{

            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(wrapperObj);
            Object documentCategory = (Object)jsonMap.get('documentCategory');
            System.debug(LoggingLevel.DEBUG, '>>> CURRENT TYPE: ' + String.valueOf(documentCategory));

            //if(String.valueOf(documentCategory) == 'solleciti'){
            HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = new HDT_WS_MulesoftCaller.HDT_WRP_HttpObj();
            httpObj.headersMap = new Map<String, String>();

            if(String.valueOf(documentCategory) == 'Bollette'){
                httpObj.endPoint = 'callout:documentaryBillsSearch';
                //wsObj.success = true;
                //wsObj.message = '';
                //wsObj.body = getFakeData();
                //return JSON.serialize(wsObj);
            } else {
                httpObj.endPoint = 'callout:docComunicationsSearch';
            }

            httpObj.httpMethod = 'POST';
            httpObj.headersMap.put('Content-Type', 'application/json');

            if(httpObj == null){
                wsObj.success = false;
                wsObj.message = 'Metadati httpObj non configurati';
                return wsObj;
            }
    
            HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(wrapperObj, httpObj);
            System.debug(LoggingLevel.DEBUG, '>>>> RETRIEVE FROM WS ' + responseCtrl);

            if(!responseCtrl.success){
                wsObj.success = false;
                wsObj.message = responseCtrl.message;
                wsObj.body = responseCtrl.body;
                return JSON.serialize(wsObj);
            }

            wsObj.success = true;
            wsObj.message = '';
            wsObj.body = responseCtrl.body;
            //}

            //wsObj.success = true;
            //wsObj.message = '';
            //wsObj.body = getFakeData();

        } catch (Exception ex){
            wsObj.success = false;
            wsObj.message = ex.getMessage();
            wsObj.body = null;
        }

        return JSON.serialize(wsObj);
    }

    public static HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj sendFileToPrint(String body){
        System.debug(LoggingLevel.DEBUG, '# saveNewOfferConfigured #');
        System.debug(LoggingLevel.DEBUG, '>>> body: ' + body);

        HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj responseObj = new HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj();

        try{
            
            HttpRequest req = new HttpRequest();
            //req.setEndpoint('https://monted-dev-ed.my.salesforce.com/services/apexrest/getFileToPrint/0');
            req.setEndpoint('callout:documentaryInvoices');
            req.setMethod('POST');
            //req.setHeader('Authorization', 'Bearer ' + Label.MockSessionId);
            req.setHeader('Content-Type', 'application/json');
            req.setbody(body);
            req.setTimeout(120000); // timeout in milliseconds

            HDT_WS_DocumentaryInvoices.HDT_WRP_ReturnObj returnObj = HDT_WS_DocumentaryInvoices.sendFile(req);
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
        System.debug(LoggingLevel.DEBUG, '>>> getFakeData');
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
            s += '{"id": "' + String.valueOf(n) + '", "envelopeId": "' + String.valueOf(n) + '", "issueDate": "' + stringDate + '"}';
            if(n != max){
                s += ',';
            }
        }

        s += ']}';
        return s;
    }

}