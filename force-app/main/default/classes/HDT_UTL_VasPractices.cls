public inherited sharing class HDT_UTL_VasPractices extends HDT_UTL_PracticesSupport {

    private Map<String, Object> responseMap;

    public override void checkResponse(){
        System.debug(LoggingLevel.DEBUG, '>>> checkResponse');
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        Object statusResult = responseMap.get('status');
        System.debug('>>> status: ' + String.valueOf(statusResult));

        success = String.valueOf(statusResult).equalsIgnoreCase('success');

        if(!success){
            errorMessage = '';
            errorMessage += 'correlationId: ' + responseMap.get('correlationId') + '; ';
            errorMessage += 'timestamp: ' + responseMap.get('timestamp') + ';';
            List<Object> errorDetails = (List<Object>)responseMap.get('errorDetails');
            Map<String, Object> errorMap;
            for(Object errorItem : errorDetails){
                errorMap = (Map<String, Object>)errorItem;
                errorMessage += String.valueOf(errorMap.get('code')) + '; ';
                errorMessage += String.valueOf(errorMap.get('message')) + '; ';
                errorMessage += String.valueOf(errorMap.get('additionalInfo')) + '; ';
            }
        }

    }

    public override void manageResponse(){
        System.debug(LoggingLevel.DEBUG, '>>> HDT_UTL_VasPractices');

        HDT_WRP_DataTable dataTable = new HDT_WRP_DataTable();
        dataTable.details = new List<Object>();
        dataTable.rate = new List<Object>();

        //Object dataList = (Object)responseMap.get('data');
        Map<String, Object> dataMap = (Map<String, Object>)responseMap.get('data');

        System.debug(LoggingLevel.DEBUG, '>>> ' + dataMap);

        List<Object> detailsList = (List<Object>)dataMap.get('detail');

        Map<String, Object> detailItemMap;
        List<Object> rateList;
        String type;
        String practice;
        String jsonString;
        List<HDT_WRP_RateDetail> rateListDes;
        for(Object singleDetail : detailsList){
            detailItemMap = (Map<String, Object>)singleDetail;
            type = String.valueOf(detailItemMap.get('vasType'));
            practice = String.valueOf(detailItemMap.get('practice'));

            if(!type.equalsIgnoreCase('CANONE RAI')){
                System.debug(LoggingLevel.DEBUG, '>>> current type: ' + type);
                rateList = (List<Object>)detailItemMap.get('rate');
                dataTable.details.add(singleDetail);

                jsonString = JSON.serialize(rateList);
                rateListDes = (List<HDT_WRP_RateDetail>)JSON.deserialize(jsonString, List<HDT_WRP_RateDetail>.class);

                if(rateListDes != null && rateListDes.size() > 0){
                    for(HDT_WRP_RateDetail singleRate : rateListDes){
                        singleRate.practice = practice;
                    }
                    dataTable.rate.addAll(rateListDes);
                }

            }
        }
        
        //System.debug(LoggingLevel.DEBUG, '>>> details -> ' + String.valueOf(dataTable.details));
        //System.debug(LoggingLevel.DEBUG, '>>> rate -> ' + String.valueOf(dataTable.rate));

        result = dataTable;
    }

    public class HDT_WRP_RequestResponse {
        public Boolean success;
        public String message;
        public String body;
    }

    public class HDT_WRP_DataTable {
        @AuraEnabled public List<Object> details;
        @AuraEnabled public List<Object> rate;
    }

    public class HDT_WRP_RateDetail {
        @AuraEnabled public String practice;
        @AuraEnabled public String rateNumber;
        @AuraEnabled public String document;
        @AuraEnabled public String expiryDate;
        @AuraEnabled public String installmentAmount;
        @AuraEnabled public String installmentStatus;
    }

}