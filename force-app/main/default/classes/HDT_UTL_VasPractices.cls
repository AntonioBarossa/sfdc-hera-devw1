public inherited sharing class HDT_UTL_VasPractices extends HDT_UTL_PracticesSupport {

    public override void manageResponse(){
        System.debug('>>> HDT_UTL_VasPractices');

        HDT_WRP_DataTable dataTable = new HDT_WRP_DataTable();
        dataTable.details = new List<Object>();
        dataTable.rate = new List<Object>();

        //Object dataList = (Object)responseMap.get('data');
        Map<String, Object> dataMap = (Map<String, Object>)responseMap.get('data');

        System.debug('>>> ' + dataMap);

        List<Object> detailsList = (List<Object>)dataMap.get('detail');

        Map<String, Object> detailItemMap;
        List<Object> rateList;
        String type;
        String practice;
        String jsonString;
        List<HDT_WRP_rateDetail> rateListDes;
        for(Object singleDetail : detailsList){
            detailItemMap = (Map<String, Object>)singleDetail;
            type = String.valueOf(detailItemMap.get('vasType'));
            practice = String.valueOf(detailItemMap.get('practice'));

            if(!type.equalsIgnoreCase('CANONE RAI')){
                System.debug('>>> current type: ' + type);
                rateList = (List<Object>)detailItemMap.get('rate');
                dataTable.details.add(singleDetail);

                jsonString = JSON.serialize(rateList);
                rateListDes = (List<HDT_WRP_rateDetail>)JSON.deserialize(jsonString, List<HDT_WRP_rateDetail>.class);

                if(rateListDes != null && rateListDes.size() > 0){
                    for(HDT_WRP_rateDetail singleRate : rateListDes){
                        singleRate.practice = practice;
                    }
                    dataTable.rate.addAll(rateListDes);
                }

            }
        }
        
        //System.debug('>>> details -> ' + String.valueOf(dataTable.details));
        //System.debug('>>> rate -> ' + String.valueOf(dataTable.rate));

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

    public class HDT_WRP_rateDetail {
        @AuraEnabled public String practice;
        @AuraEnabled public String rateNumber;
        @AuraEnabled public String document;
        @AuraEnabled public String expiryDate;
        @AuraEnabled public String installmentAmount;
        @AuraEnabled public String installmentStatus;
    }

}