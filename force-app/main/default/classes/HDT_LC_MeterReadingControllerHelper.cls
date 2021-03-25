public inherited sharing class HDT_LC_MeterReadingControllerHelper {

    public static HDT_WRP_ContractObj getContractRecordsHelper(String accountId) {
        HDT_WRP_ContractObj contrObj = new HDT_WRP_ContractObj();

        try {

            List<Contract> contractList;
            contractList = HDT_QR_MeterReading.getAccountContracts(contractList, accountId);

            if(contractList.size()==0){
                contrObj.success = false;
                contrObj.message = 'No contract found for this account';
                return contrObj;                
            }

            contrObj.contractList = new List<HDT_WRP_ContractDetail>();
            for(Contract c : contractList){
                HDT_WRP_ContractDetail contrWrp;
                contrObj.contractList.add(convertContractToWrapper(c, contrWrp));
            }

            contrObj.success = true;

        } catch (Exception e){
            contrObj.success = false;
            contrObj.message = '> ERROR > ' + e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber());
        }

        return contrObj;

    }

    private static HDT_WRP_ContractDetail convertContractToWrapper(Contract c, HDT_WRP_ContractDetail contrWrp){
        contrWrp = new HDT_WRP_ContractDetail();
        contrWrp.id = c.Id;
        contrWrp.contractNumber = c.ContractNumber;
        contrWrp.status = c.Status;
        contrWrp.startDate = String.valueOf(c.StartDate);
        contrWrp.endDate = String.valueOf(c.EndDate);
        contrWrp.asset = c.ServicePoint__r.Name;
        contrWrp.service = 'ele';
        return contrWrp;
    }

    public static HDT_WRP_MeterReadingObj getMeterReadingRecordsHelper(String contractCode) {
        HDT_WRP_MeterReadingObj meterReadingObj = new HDT_WRP_MeterReadingObj();

        try{
            meterReadingObj.meterReadingList = new List<HDT_WRP_MeterReadingDetail>();
            meterReadingObj.meterReadingList.addAll(createMockRecords(contractCode));
            meterReadingObj.success = true;
        } catch (Exception e){
            meterReadingObj.success = false;
            meterReadingObj.message = '> ERROR > ' + e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber());
        }

        return meterReadingObj;
    }

    private static List<HDT_WRP_MeterReadingDetail> createMockRecords(String contract){
        List<HDT_WRP_MeterReadingDetail> meterReadingList = new List<HDT_WRP_MeterReadingDetail>();
        HDT_WRP_MeterReadingDetail detObj;
        for(Integer n=0; n<15; n++){
            detObj = new HDT_WRP_MeterReadingDetail();
            detObj.id = contract + String.valueOf(n); 
            detObj.contractId = contract;

            if(contract=='2002'){
                detObj.lectureDate = '01/08/2021';
            } else {
                detObj.lectureDate = '28/03/2019';
            }
            
            detObj.slot = 'Fascia ' + contract; 
            detObj.lectureInt = '575'; 
            detObj.lectureDecimal = '0.0001'; 
            detObj.assetCode = 'R0010004'; 
            detObj.contractCode = '300145966'; 
            detObj.status = 'Calcolabile'; 
            detObj.lectureType = 'Stima automatica'; 
            detObj.reason = 'Stima automatica';
            detObj.billingDate = '0'; 
            detObj.consumedAvg = '0.000'; 
            detObj.regType = 'Energia attiva'; 
            detObj.consumed = '';
            detObj.consumedType = 'KWH';
            detObj.sector = 'Energia Elettrica';
            detObj.reasonWhy = '';
            meterReadingList.add(detObj);
        }
        return meterReadingList;
    }

    public class HDT_WRP_ContractObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_ContractDetail> contractList;
    }

    public class HDT_WRP_MeterReadingObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_MeterReadingDetail> meterReadingList;
    }

    public class HDT_WRP_ContractDetail {
        @AuraEnabled public String id;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public String asset;
        @AuraEnabled public String service;
    }

    public class HDT_WRP_MeterReadingDetail {
        @AuraEnabled public String id; 
        @AuraEnabled public String contractId; 
        @AuraEnabled public String lectureDate;
        @AuraEnabled public String slot; 
        @AuraEnabled public String lectureInt; 
        @AuraEnabled public String lectureDecimal; 
        @AuraEnabled public String assetCode; 
        @AuraEnabled public String contractCode; 
        @AuraEnabled public String status; 
        @AuraEnabled public String lectureType; 
        @AuraEnabled public String reason;
        @AuraEnabled public String billingDate; 
        @AuraEnabled public String consumedAvg; 
        @AuraEnabled public String regType; 
        @AuraEnabled public String consumed;
        @AuraEnabled public String consumedType;
        @AuraEnabled public String sector;
        @AuraEnabled public String reasonWhy;
    }
}