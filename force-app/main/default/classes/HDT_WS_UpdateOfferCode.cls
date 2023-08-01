
@RestResource(urlMapping='/offercode32/*')
global with sharing class HDT_WS_UpdateOfferCode {

    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeResponse responseWrap = new HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeResponse();
        try{
            String requestBody = request.requestBody.toString();
            HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeRequest requestWrap = (HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeRequest) JSON.deserialize(requestBody, HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeRequest.class);
            try{
                HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeResponse outcomeResponse = handleRequest(requestWrap);
                responseWrap.data = outcomeResponse.data;
                responseWrap.outcome = 'OK';
                responseWrap.outcomeCode = 'S0';
                response.statusCode = 200;

            }catch (Exception e){
                response.statusCode = 400;
                responseWrap.outcome = 'KO';
                responseWrap.outcomeCode = 'S3';
                HDT_UTL_IntegrationLog.handleGenericErrorRequest(request.requestBody.toString(), 'doPost', 'Exception handle request', 'HDT_WS_UpdateOfferCode', '');
            }      
        }catch (Exception e){
            response.statusCode = 500;
            responseWrap.outcome = 'KO';
            responseWrap.outcomeCode = 'S3';   
            HDT_UTL_IntegrationLog.handleGenericErrorRequest(request.requestBody.toString(), 'doPost', 'Error deserializing request', 'HDT_WS_UpdateOfferCode', '');         
        }
        finally {
            response.responseBody = Blob.valueOf(JSON.serialize(responseWrap));
        }
    }


    private static HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeResponse handleRequest (HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeRequest wrap){
        HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeResponse response = new HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeResponse();
        if(!wrap.data.isEmpty() && wrap.data.size() > Integer.valueOf(Label.HDT_OfferCodeMaxItem)){
            for(HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData item : wrap.data){
                item.outcome = 'KO';
                item.outcomeCode = 'S2';
            }
            response.data = wrap.data;
            return response;
        }else{
            Set<String> contractCode = new Set<String>();
            for(HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData item : wrap.data){
                contractCode.add(item.sapContractCode);   
            }
            List<Contract> listOfContract = new List<Contract>();
            if(!contractCode.isEmpty()){
                HDT_QR_Contract qrContract= new HDT_QR_Contract();
                listOfContract = qrContract.getContractBySapCodeWithStatusActive(contractCode);
            }
            Map<String, Contract> mapSapContractCodeContract = new Map<String, Contract>();
            for(Contract con : listOfContract){
                mapSapContractCodeContract.put(con.SAPContractCode__c, con);
            }
            List<OfferCodeUpdateLog__c> listOfOfferCodeLog = new List<OfferCodeUpdateLog__c>();
            for(HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData item : wrap.data){
                if(!mapSapContractCodeContract.containsKey(item.sapContractCode)){ 
                    item.outcome = 'KO';
                    item.outcomeCode = 'S1';
                }else{
                    item.outcome = 'OK';
                    item.outcomeCode = 'S0';
                    listOfOfferCodeLog.add(createOfferCodeLog(item));
                }
            }
            if(!listOfOfferCodeLog.isEmpty()){
                HDT_UTL_DatabaseService.insertSObject(listOfOfferCodeLog);
            }
            response.data = wrap.data;
            return response;
        }


    }

    private static OfferCodeUpdateLog__c createOfferCodeLog(HDT_WRP_UpdateOfferCode.HDT_WRP_UpdateOfferCodeData item){
        OfferCodeUpdateLog__c offerCodeUpdateLog = new OfferCodeUpdateLog__c();
        offerCodeUpdateLog.SapContractCode__c = item.sapContractCode;
        offerCodeUpdateLog.Pod__c = item.pod;
        offerCodeUpdateLog.OfferCode__c = item.offerCode;
        offerCodeUpdateLog.Profile__c = item.profile;
        offerCodeUpdateLog.Commodity__c = item.commodity;
        offerCodeUpdateLog.EffectiveDate__c = Date.valueOf(item.effectiveDate);
        offerCodeUpdateLog.CodTzero__c = item.codTzero;
        offerCodeUpdateLog.EffectiveMonths__c = Integer.valueOf(item.effectiveMonths);
        offerCodeUpdateLog.CausalCode__c = item.causalCode;
        return offerCodeUpdateLog;
    }
   
}