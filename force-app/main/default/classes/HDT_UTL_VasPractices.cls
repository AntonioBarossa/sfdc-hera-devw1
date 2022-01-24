public inherited sharing class HDT_UTL_VasPractices extends HDT_UTL_PracticesSupport {

    public override void manageResponse(){
        System.debug('>>> HDT_UTL_VasPractices');

        HDT_WRP_DataTable dataTable = new HDT_WRP_DataTable();
        dataTable.details = new List<Object>();
        dataTable.rate = new List<Object>();

        System.debug('# ' + this.body);

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(body);

        Object statusResult = responseMap.get('status');
        System.debug('>>> status: ' + String.valueOf(statusResult));

        List<Object> dataList = (List<Object>)responseMap.get('data');
        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        List<Object> detailsList = (List<Object>)dataMap.get('details');

        Map<String, Object> detailItemMap;
        List<Object> rateList;
        String type;
        for(Object singleDetail : detailsList){
            detailItemMap = (Map<String, Object>)singleDetail;
            type = String.valueOf(detailItemMap.get('vasType'));

            if(!type.equalsIgnoreCase('CANONE RAI')){
                System.debug('>>> current type: ' + type);
                rateList = (List<Object>)detailItemMap.get('rate');
                dataTable.details.add(singleDetail);
                dataTable.rate.addAll(rateList);
            }
        }
        
        System.debug('>>> details -> ' + String.valueOf(dataTable.details));
        System.debug('>>> rate -> ' + String.valueOf(dataTable.rate));

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

}