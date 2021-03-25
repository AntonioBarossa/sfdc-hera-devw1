public inherited sharing class HDT_LC_MeterReadingControllerHelper {

    public static HDT_WRP_MeterReading.HDT_WRP_ContractObj getContractRecordsHelper(String accountId) {
        HDT_WRP_MeterReading.HDT_WRP_ContractObj contrObj = new HDT_WRP_MeterReading.HDT_WRP_ContractObj();

        try {

            List<Contract> contractList;
            contractList = HDT_QR_MeterReading.getAccountContracts(contractList, accountId);

            if(contractList.size()==0){
                contrObj.success = false;
                contrObj.message = 'No contract found for this account';
                return contrObj;                
            }

            contrObj.contractList = new List<HDT_WRP_MeterReading.HDT_WRP_ContractDetail>();
            for(Contract c : contractList){
                HDT_WRP_MeterReading.HDT_WRP_ContractDetail contrWrp;
                contrObj.contractList.add(convertContractToWrapper(c, contrWrp));
            }

            contrObj.success = true;

        } catch (Exception e){
            contrObj.success = false;
            contrObj.message = '> ERROR > ' + e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber());
        }

        return contrObj;

    }

    private static HDT_WRP_MeterReading.HDT_WRP_ContractDetail convertContractToWrapper(Contract c, HDT_WRP_MeterReading.HDT_WRP_ContractDetail contrWrp){
        contrWrp = new HDT_WRP_MeterReading.HDT_WRP_ContractDetail();
        contrWrp.id = c.Id;
        contrWrp.contractNumber = c.ContractNumber;
        contrWrp.status = c.Status;
        contrWrp.startDate = String.valueOf(c.StartDate);
        contrWrp.endDate = String.valueOf(c.EndDate);
        contrWrp.asset = c.ServicePoint__r.Name;
        contrWrp.service = 'ele';
        return contrWrp;
    }

    public static HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj getMeterReadingRecordsHelper(String contractCode) {
        HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj meterReadingObj = new HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj();

        try{
            meterReadingObj.data = new List<HDT_WRP_MeterReading.HDT_WRP_MeterReadingDetail>();

            HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = setHttpObject();

            HDT_WRP_MeterReading.HDT_WRP_HttpBody bodyWrp = new HDT_WRP_MeterReading.HDT_WRP_HttpBody();
            bodyWrp.codiceContratto = contractCode;
            bodyWrp.codiceImpianto = '';
            bodyWrp.codicePod = '';
            bodyWrp.dataInizioLettura = '';
            bodyWrp.dataFineLettura = '';
            bodyWrp.letturaReale = '';

            String body = JSON.serialize(bodyWrp, true);
            System.debug('>>> body obj > ');
            System.debug(body);
            HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(body, httpObj);
     
            if(!responseCtrl.success){
                meterReadingObj.success = false;
                meterReadingObj.message = responseCtrl.message;
                return meterReadingObj;
            }

            HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj restMessage = (HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj)JSON.deserialize(responseCtrl.body, HDT_WRP_MulesoftResponse.HDT_WRP_ReturnObj.class);

            if(restMessage.status != 'success'){
                meterReadingObj.success = false;
                meterReadingObj.message = 'Mulesoft side [code: ' + restMessage.errorDetails.code;
                meterReadingObj.message += ']; Detail: ' + restMessage.errorDetails.message;
                meterReadingObj.message += '; Additional Info' + restMessage.errorDetails.additionalInfo;
                return meterReadingObj;
            }
    
            //here we have to deserialize body to wrapper obj
            HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj meterReadingData = (HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj)JSON.deserialize(responseCtrl.body, HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj.class);
            System.debug('>>> ' + meterReadingData);

            //meterReadingObj.data.addAll(createMockRecords(contractCode));
            meterReadingObj.data = meterReadingData.data;
            meterReadingObj.success = true;

        } catch (Exception e){
            meterReadingObj.success = false;
            meterReadingObj.message = '> ERROR > ' + e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber());
        }

        return meterReadingObj;
    }

    private static HDT_WS_MulesoftCaller.HDT_WRP_HttpObj setHttpObject(){

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = new HDT_WS_MulesoftCaller.HDT_WRP_HttpObj();
        httpObj.headersMap = new Map<String, String>();

        httpObj.endPoint = 'https://monted-dev-ed.my.salesforce.com/services/apexrest/meterreading';
        httpObj.httpMethod = 'POST';            
        httpObj.headersMap.put('Authorization', 'Bearer ' + Label.MockSessionId);
        httpObj.headersMap.put('Content-Type', 'application/json');

        return httpObj;
    }

    private static List<HDT_WRP_MeterReading.HDT_WRP_MeterReadingDetail> createMockRecords(String contract){
        List<HDT_WRP_MeterReading.HDT_WRP_MeterReadingDetail> data = new List<HDT_WRP_MeterReading.HDT_WRP_MeterReadingDetail>();
        HDT_WRP_MeterReading.HDT_WRP_MeterReadingDetail detObj;
        for(Integer n=0; n<15; n++){
            detObj = new HDT_WRP_MeterReading.HDT_WRP_MeterReadingDetail();
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
            data.add(detObj);
        }
        return data;
    }

}