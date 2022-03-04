public inherited sharing class HDT_UTL_VasPractices extends HDT_UTL_PracticesSupport {

    HDT_WRP_Response responseObj;

    public override void checkResponse(){
        System.debug(LoggingLevel.DEBUG, '>>> checkResponse');
        responseObj = (HDT_WRP_Response)JSON.deserialize(res.getBody().replaceAll('"\"', '"'), HDT_WRP_Response.class);

        System.debug('>>> status: ' + String.valueOf(responseObj.status));
        success = responseObj.status.equalsIgnoreCase('success');

        if(!success){
            errorMessage = '';
            errorMessage += 'correlationId: ' + responseObj.correlationId + '; ';
            errorMessage += 'timestamp: ' + responseObj.timestamp + ';';

            for(HDT_WRP_ErrorDetails errorItem : responseObj.errorDetails){
                errorMessage += errorItem.code + '; ';
                errorMessage += errorItem.message + '; ';
                errorMessage += errorItem.additionalInfo + '; ';
            }
        }

    }

    public override void manageResponse(){
        System.debug(LoggingLevel.DEBUG, '>>> HDT_UTL_VasPractices');

        HDT_WRP_DataTable dataTable = new HDT_WRP_DataTable();
        dataTable.details = new List<HDT_WRP_DetailObj>();
        dataTable.rate = new List<HDT_WRP_RateDetail>();

        List<String> orderNumerList = new List<String>();
        Map<String, Id> orderMap = new Map<String, Id>();

        for(HDT_WRP_DetailObj singleDetail : responseObj.data.detail){

            if(!singleDetail.vasType.equalsIgnoreCase('CANONE RAI')){
                System.debug(LoggingLevel.DEBUG, '>>> current type: ' + singleDetail.vasType);
                orderNumerList.add(singleDetail.rds);

                if(singleDetail.rate != null && singleDetail.rate.size() > 0){
                    for(HDT_WRP_RateDetail singleRate : singleDetail.rate){
                        singleRate.practice = singleDetail.practice;
                    }
                    dataTable.rate.addAll(singleDetail.rate);
                }
                singleDetail.rate = null;
                dataTable.details.add(singleDetail);
            }
        }
        
        List<Order> orderList = new List<Order>();
        orderList = [
            SELECT Id, OrderNumber
            FROM Order
            WHERE OrderNumber IN :orderNumerList
            WITH SECURITY_ENFORCED
        ];

        for(Order singleOrder : orderList){
            orderMap.put(singleOrder.OrderNumber, singleOrder.Id);
        }

        for(HDT_WRP_DetailObj obj : dataTable.details){
            if(orderMap.containsKey(obj.rds)){
                obj.id = orderMap.get(obj.rds);
            } else {
                //obj.id = 'javascript:void(0)';
                obj.id = '/8011X000001oilqQAA';
            }
        }

        result = dataTable;
    }

    public class HDT_WRP_RequestResponse {
        public Boolean success;
        public String message;
        public String body;
    }

    public class HDT_WRP_DataTable {
        @AuraEnabled public List<HDT_WRP_DetailObj> details;
        @AuraEnabled public List<HDT_WRP_RateDetail> rate;
    }

    public class HDT_WRP_Response {
        public String status;
        public String correlationId;
        public String timestamp;
        public HDT_WRP_Data data;
        public List<HDT_WRP_ErrorDetails> errorDetails;
    }

    public class HDT_WRP_ErrorDetails {
        public String code;
        public String message;
        public String additionalInfo;
    }

    public class HDT_WRP_Data {
        public String partner;
        public List<HDT_WRP_DetailObj> detail;
    }

    public class HDT_WRP_DetailObj {
        @AuraEnabled public String id;
        @AuraEnabled public String practice;
        @AuraEnabled public String company;
        @AuraEnabled public String rds;
        @AuraEnabled public String practiceResultCode;
        @AuraEnabled public String descriptionResultCode;
        @AuraEnabled public String rateNumber;
        @AuraEnabled public String vasType;
        @AuraEnabled public String vasImport;
        @AuraEnabled public String orderSendingDate;
        @AuraEnabled public String orderInsertDate;
        @AuraEnabled public String shippingDateDdt;
        @AuraEnabled public String expectedDeliveryDate;
        @AuraEnabled public String withdrawalDate;
        @AuraEnabled public String rfid;
        public List<HDT_WRP_RateDetail> rate;
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