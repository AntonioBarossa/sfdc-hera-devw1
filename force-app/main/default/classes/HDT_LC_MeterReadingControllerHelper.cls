public inherited sharing class HDT_LC_MeterReadingControllerHelper {

    public static HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata getConfigurationDataHelper(){

        HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata columnsMetadata = new HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata();

        try{
            List<HDT_AccountDataEnrichment__mdt> contractMetadataList;
            contractMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(contractMetadataList, 'contract');

            if(contractMetadataList.size()==0){
                columnsMetadata.success = false;
                columnsMetadata.message = 'No metadata found for contract';
                return columnsMetadata;
            }

            List<HDT_AccountDataEnrichment__mdt> meterRadingMetadataList;
            meterRadingMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(meterRadingMetadataList, 'meterReading');

            if(meterRadingMetadataList.size()==0){
                columnsMetadata.success = false;
                columnsMetadata.message = 'No metadata found for meterRading';
                return columnsMetadata;
            }

            columnsMetadata.success = true;
            columnsMetadata.contractTable = contractMetadataList[0].ColumnData__c;
            columnsMetadata.meterReadingTable = meterRadingMetadataList[0].ColumnData__c;

            return columnsMetadata;

        } catch(Exception e){
            columnsMetadata.success = false;
            columnsMetadata.message = e.getMessage() + ' - at line [' + String.valueOf(e.getLineNumber()) + ']';
            return columnsMetadata;
        }

    }

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
            contrObj.message = '> ERROR > ' + e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber() + ']');
        }

        return contrObj;

    }

    private static HDT_WRP_MeterReading.HDT_WRP_ContractDetail convertContractToWrapper(Contract c, HDT_WRP_MeterReading.HDT_WRP_ContractDetail contrWrp){
        contrWrp = new HDT_WRP_MeterReading.HDT_WRP_ContractDetail();
        contrWrp.id = c.Id;
        contrWrp.contractNumber = c.SAPContractCode__c;
        contrWrp.status = c.Status;
        contrWrp.startDate = String.valueOf(c.StartDate);
        contrWrp.endDate = String.valueOf(c.EndDate);
        contrWrp.asset = c.ServicePoint__r.SAPImplantCode__c;
        contrWrp.service = c.ServicePoint__r.CommoditySector__c;
        return contrWrp;
    }

    public static HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj getMeterReadingRecordsHelper(String contractCode) {
        HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj meterReadingObj = new HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj();

        try{
            //meterReadingObj.data = new List<HDT_WRP_MeterReading.HDT_WRP_MeterReadingDetail>();

            HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = setHttpObject();

            HDT_WRP_MeterReading.HDT_WRP_HttpBody bodyWrp = new HDT_WRP_MeterReading.HDT_WRP_HttpBody();
            bodyWrp.codiceContratto = '';//contractCode;
            bodyWrp.codiceImpianto = '4002460003';
            bodyWrp.codicePod = '';
            bodyWrp.dataInizioLettura = '01/12/2005';
            bodyWrp.dataFineLettura = '31/12/2005';
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
            //HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj meterReadingData = (HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj)JSON.deserialize(responseCtrl.body, HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj.class);

            meterReadingObj.success = true;
            //meterReadingObj.data = meterReadingData.data;
            meterReadingObj.data = responseCtrl.body;

        } catch (Exception e){
            meterReadingObj.success = false;
            meterReadingObj.message = '> ERROR > ' + e.getMessage() + ' at line [' + String.valueOf(e.getLineNumber());
        }

        return meterReadingObj;
    }

    private static HDT_WS_MulesoftCaller.HDT_WRP_HttpObj setHttpObject(){

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = new HDT_WS_MulesoftCaller.HDT_WRP_HttpObj();
        httpObj.headersMap = new Map<String, String>();

        //httpObj.endPoint = 'https://monted-dev-ed.my.salesforce.com/services/apexrest/meterreading';
        //httpObj.headersMap.put('Authorization', 'Bearer ' + Label.MockSessionId);
        httpObj.endPoint = 'https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/service-console/readings/search';
        httpObj.headersMap.put('Authorization', 'Basic NDhmZTUxNjVhNDBjNDlhYTliZjRiM2Q5YmNhMjU1MmY6YTc0YjUwZGJhYWMwNDIxNWJmYmY4OWEyZWUzMTVhODA=');
       
        httpObj.httpMethod = 'POST';
        httpObj.headersMap.put('Content-Type', 'application/json');

        return httpObj;
    }

}