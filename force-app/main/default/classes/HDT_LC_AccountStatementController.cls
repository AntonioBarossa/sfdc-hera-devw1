public class HDT_LC_AccountStatementController {

    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj getSecondLevelColumns(String tabValue) {
        return HDT_LC_AccountStatementCtrlHelper.getSecondLevelColumnsHelper(tabValue);
    }

    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj getTabConfiguration(String tabValue, String recordId) {

        System.debug('# GET COLUMNS #');
        System.debug('# Current tab -> ' + tabValue);
        //Boolean isMock = false;

        HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj columnsObj = new HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj();

        try{

            List<HDT_ColumnsFirstLevel__mdt> column_mdtList = new List<HDT_ColumnsFirstLevel__mdt>();
            column_mdtList = [
                SELECT MasterLabel, FieldName__c, DeveloperName, IsAmountField__c, IsSortable__c, FieldType__c, ShowTotAmountHere__c, ColumnOrder__c, IsVisible__c
                FROM HDT_ColumnsFirstLevel__mdt
                WHERE Tab__r.DeveloperName =: tabValue AND IsVisible__c = true
                ORDER BY ColumnOrder__c ASC
            ];

            if(column_mdtList.size()==0){
                columnsObj.success = false;
                columnsObj.message = 'No custom metadata found for coloumns';
                return columnsObj;
            }

            columnsObj.success = true;
            columnsObj.message = '';
            columnsObj.confObj = new HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail();
            columnsObj.columnObj = new List<HDT_WRP_AccountStatement.HDT_WRP_SingleColumn>();

            columnsObj.confObj = getConfObj(tabValue);

            columnsObj.confObj.recordCode = getAccountData(recordId)[0].Name;

            if(columnsObj.confObj.buttonList == null || columnsObj.confObj.buttonList.size()==0){
                columnsObj.success = false;
                columnsObj.message = 'Error to retrieve metadata: No data for buttons';
                return columnsObj;
            }

            HDT_WRP_AccountStatement.HDT_WRP_ColumnDetail cd;
            HDT_WRP_AccountStatement.HDT_WRP_SingleColumn sc;
            for(HDT_ColumnsFirstLevel__mdt c : column_mdtList){
                cd = new HDT_WRP_AccountStatement.HDT_WRP_ColumnDetail();
                cd.type = c.FieldType__c;
                cd.isAmount = c.IsAmountField__c;

                sc = new HDT_WRP_AccountStatement.HDT_WRP_SingleColumn();
                sc.label = c.MasterLabel;
                sc.fieldName = c.FieldName__c;
                sc.showSort = c.IsSortable__c;
                sc.showAmount = c.ShowTotAmountHere__c;
                sc.detail = cd;
                columnsObj.columnObj.add(sc);
            }

            //if(isMock){
            //    ColumnsObj mockFromString = (ColumnsObj)JSON.deserialize(jsonObjString, ColumnsObj.class);
            //    mockFromString.success = true;
            //    mockFromString.message = '';
            //    return mockFromString;
            //}

        } catch (Exception ex){
            columnsObj.success = false;
            columnsObj.message = 'Error to retrieve metadata: ' + ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']';
            return columnsObj;
        }

        System.debug('# HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj ' + JSON.serialize(columnsObj));
        return columnsObj;
    }

    public static List<Account> getAccountData(String accId){
        List<Account> accList = new List<Account>();
        accList = [SELECT Name FROM Account WHERE Id =: accId];
        return accList;
    }

    public static HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail getConfObj(String tabValue) {
                
        HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail objDetail = new HDT_WRP_AccountStatement.HDT_WRP_ConfTabObjDetail();
        objDetail.buttonList = new List<HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail>();

        List<HDT_TabConfiguration__mdt> mdtTabConfList = new List<HDT_TabConfiguration__mdt>();
        mdtTabConfList = [
            SELECT MasterLabel, HasSecondLevel__c, DeveloperName, SecondLevelAPI_Name__c, HasAmountField__c
            FROM HDT_TabConfiguration__mdt
            WHERE DeveloperName =: tabValue
            LIMIT 1
        ];

        if(mdtTabConfList.size()==0){
            return objDetail;
        }
        
        objDetail.tabCode = tabValue;
        objDetail.secondLevelAPIname = mdtTabConfList[0].SecondLevelAPI_Name__c;
        objDetail.hasSecondLevel = mdtTabConfList[0].HasSecondLevel__c;
        objDetail.hasAmountField = mdtTabConfList[0].HasAmountField__c;
        
        List<HDT_ButtonDetails__mdt> mdtButtonList = new List<HDT_ButtonDetails__mdt>();
        mdtButtonList = [
            SELECT MasterLabel, DeveloperName, ButtonCode__c,ButtonLevel__c,ButtonOrder__c,IsVisible__c, Tab__r.DeveloperName
            FROM HDT_ButtonDetails__mdt	
            WHERE Tab__r.DeveloperName =: tabValue
            ORDER BY ButtonOrder__c ASC
        ];

        if(mdtButtonList.size()==0){
            return objDetail;
        }

        for(HDT_ButtonDetails__mdt butMdt : mdtButtonList){
            objDetail.buttonList.add(new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail(butMdt.MasterLabel, butMdt.ButtonCode__c, butMdt.IsVisible__c));
        }
        
        return objDetail;
    }

    @AuraEnabled//Sync caller method
    public static Object callMulesoft(String techObj, String requestObj){
        System.debug('# Sync callMulesoft #');
        //return HDT_WS_MulesoftCallerHelper.createMulesoftCall(techObj, requestObj);
        return HDT_LC_AccountStatementCtrlHelper.createMulesoftCall(techObj, requestObj);
    }

    //------------------------------------------------------------------------------------------------------------------
    @AuraEnabled(continuation=true)//Async caller method
    public static Object callMulesoftAsync(String techObj, String requestObj){
        System.debug('# Async callMulesoft #');
        HDT_WS_MakeMulesoftCall.ResponseCtrl respObj = HDT_WS_MulesoftCallerAsync.createMulesoftCall(techObj, requestObj);

        if(respObj.success){
            System.debug('# continuation true #');
            // Create continuation. Argument is timeout in seconds.
            Continuation con = new Continuation(120);
            // Set callback method
            con.continuationMethod='processResponse';
            // Set state
            con.state = techObj;
            // Add callout request to continuation
            con.addHttpRequest(respObj.httpReq);
            // Return the continuation
            return con;
        } else {
            System.debug('# continuation false #');
            return respObj;
        }

    }

    @AuraEnabled
    public static Object processResponse(List<String> labels, Object state) {
        
        System.debug('#### processResponse ####');
        // Get the response by using the unique label
        HttpResponse response = Continuation.getResponse(labels[0]);

        // Set the result variable
        String responseStatus = response.getStatus();
        Integer statusCode = response.getStatusCode();

        System.debug('## Response status -> ' + responseStatus + ' - ' + statusCode);
        System.debug('## Continuation state -> ' + state);

        return HDT_WS_MulesoftCallerAsync.processResponse(String.valueOf(state), statusCode, response.getBody());

    }
    //------------------------------------------------------------------------------------------------------------------
    
    @AuraEnabled
    public static HDT_WRP_AccountStatement.HDT_WRP_ResponseObj sendFileToPrint(String dataList){
        System.debug('# saveNewOfferConfigured #');
        System.debug(dataList);

        HDT_WRP_AccountStatement.HDT_WRP_ResponseObj responseObj = new HDT_WRP_AccountStatement.HDT_WRP_ResponseObj();

        try{
            HDT_WS_SOAP_EngageOnePrint.ReturnObj returnObj = HDT_WS_SOAP_EngageOnePrint.sendFile(dataList);
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

    @AuraEnabled
    public static HDT_WRP_AccountStatement.HDT_WRP_ResponseObj operationBackend(String operation, List<String> idlist){

        System.debug('@ Operation -> ' + operation);
        System.debug('@ idlist -> ' + idlist);

        HDT_WRP_AccountStatement.HDT_WRP_ResponseObj respObj = new HDT_WRP_AccountStatement.HDT_WRP_ResponseObj();
        respObj.success = true;
        respObj.message = '';
        return respObj;
    }

    @AuraEnabled(Cacheable=true)
    public static HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist getFieldValues(){

        HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist pickObj = new HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist();

        try{
            pickObj.companyList = new List<HDT_WRP_AccountStatement.HDT_WRP_PicklistObj>();
            pickObj.joinLevelList = new List<HDT_WRP_AccountStatement.HDT_WRP_PicklistObj>();

            List<HDT_HeraCompany__mdt> companyList = new List<HDT_HeraCompany__mdt>();
            companyList = [
                SELECT DeveloperName, Label
                FROM HDT_HeraCompany__mdt
            ];
            HDT_WRP_AccountStatement.HDT_WRP_PicklistObj company;
            for(HDT_HeraCompany__mdt hc : companyList){
                company  = new HDT_WRP_AccountStatement.HDT_WRP_PicklistObj();
                company.label = hc.Label;
                company.value = hc.DeveloperName;
                pickObj.companyList.add(company);
            }

            //Schema.DescribeFieldResult fieldResult = HDT_RequestEstrattoConto__mdt.Aggregazione__c.getDescribe();
            Schema.DescribeFieldResult fieldResult = HDT_StatementRequest__mdt.Aggregation__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            HDT_WRP_AccountStatement.HDT_WRP_PicklistObj joinLevel;
            for( Schema.PicklistEntry f : ple){
                joinLevel = new HDT_WRP_AccountStatement.HDT_WRP_PicklistObj();
                joinLevel.label = f.getLabel();
                joinLevel.value = f.getValue();
                pickObj.joinLevelList.add(joinLevel);
            }     

            pickObj.success = true;

        } catch (Exception ex){
            pickObj.success = false;
            pickObj.message = String.valueOf(ex.getLineNumber()) + '; ' + ex.getMessage();
        }

        return pickObj;
    }

}