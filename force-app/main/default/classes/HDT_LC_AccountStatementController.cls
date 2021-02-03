public class HDT_LC_AccountStatementController {

    @AuraEnabled(cacheable=true)
    public static SecLevColumnsObj getSecondLevelColumns(String tabValue) {

        SecLevColumnsObj obj = new SecLevColumnsObj();

        List<HDT_ColumnsSecondLevel__mdt> colSecList = new List<HDT_ColumnsSecondLevel__mdt>();
        colSecList = [
            SELECT MasterLabel, ColumnOrder__c, FieldName__c, InitialWidth__c, IsFilter__c, IsVisible__c, Sortable__c
            FROM HDT_ColumnsSecondLevel__mdt
            WHERE IsVisible__c = true AND Tab__r.DeveloperName =: tabValue
            ORDER BY ColumnOrder__c ASC
        ];

        if(colSecList.size()==0){
            obj.success = false;
            obj.message = 'No data for Second level';
        }

        obj.columnObj = new List<SingleSecCol>();

        SingleSecCol colObj;
        for(HDT_ColumnsSecondLevel__mdt colSec_mdt : colSecList){
            colObj = new SingleSecCol();
            colObj.isFilter = colSec_mdt.IsFilter__c;
            colObj.label = colSec_mdt.MasterLabel;
            colObj.fieldName = colSec_mdt.FieldName__c;
            colObj.sortable = colSec_mdt.Sortable__c;
            colObj.initialWidth = colSec_mdt.InitialWidth__c;
            obj.columnObj.add(colObj);
        }

        //SecLevColumnsObj mockFromString = (SecLevColumnsObj)JSON.deserialize(secondJsonObjString, SecLevColumnsObj.class);
        //mockFromString.success = true;
        //mockFromString.message = 'col from apex';

        obj.success = true;

        return obj;
    }

    @AuraEnabled(cacheable=true)
    public static ColumnsObj getTabConfiguration(String tabValue, String recordId) {

        System.debug('# GET COLUMNS #');
        System.debug('# Current tab -> ' + tabValue);
        //Boolean isMock = false;

        ColumnsObj columnsObj = new ColumnsObj();

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
            columnsObj.confObj = new ConfTabObjDetail();
            columnsObj.columnObj = new List<SingleColumn>();

            columnsObj.confObj = getConfObj(tabValue);

            columnsObj.confObj.recordCode = getAccountData(recordId)[0].Name;

            if(columnsObj.confObj.buttonList == null || columnsObj.confObj.buttonList.size()==0){
                columnsObj.success = false;
                columnsObj.message = 'Error to retrieve metadata: No data for buttons';
                return columnsObj;
            }

            ColumnDetail cd;
            SingleColumn sc;
            for(HDT_ColumnsFirstLevel__mdt c : column_mdtList){
                cd = new ColumnDetail();
                cd.type = c.FieldType__c;
                cd.isAmount = c.IsAmountField__c;

                sc = new SingleColumn();
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

        System.debug('# columnsObj ' + JSON.serialize(columnsObj));
        return columnsObj;
    }

    public static List<Account> getAccountData(String accId){
        List<Account> accList = new List<Account>();
        accList = [SELECT Name FROM Account WHERE Id =: accId];
        return accList;
    }

    public static ConfTabObjDetail getConfObj(String tabValue) {
                
        ConfTabObjDetail objDetail = new ConfTabObjDetail();
        objDetail.buttonList = new List<ButtonObjDetail>();

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
            objDetail.buttonList.add(new ButtonObjDetail(butMdt.MasterLabel, butMdt.ButtonCode__c, butMdt.IsVisible__c));
        }
        
        return objDetail;
    }

    @AuraEnabled//Sync caller method
    public static Object callMulesoft(String techObj, String requestObj){
        System.debug('# Sync callMulesoft #');
        return HDT_WS_MulesoftCallerHelper.createMulesoftCall(techObj, requestObj);
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
    public static ResponseObj sendFileToPrint(String dataList){
        System.debug('# saveNewOfferConfigured #');
        System.debug(dataList);

        ResponseObj responseObj = new ResponseObj();

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
    public static ResponseObj operationBackend(String operation, List<String> idlist){

        System.debug('@ Operation -> ' + operation);
        System.debug('@ idlist -> ' + idlist);

        ResponseObj respObj = new ResponseObj();
        respObj.success = true;
        respObj.message = '';
        return respObj;
    }

    @AuraEnabled(Cacheable=true)
    public static ReturnPicklist getFieldValues(){

        ReturnPicklist pickObj = new ReturnPicklist();

        try{
            pickObj.companyList = new List<PicklistObj>();
            pickObj.joinLevelList = new List<PicklistObj>();

            List<HDT_HeraCompany__mdt> companyList = new List<HDT_HeraCompany__mdt>();
            companyList = [
                SELECT DeveloperName, Label
                FROM HDT_HeraCompany__mdt
            ];
            PicklistObj company;
            for(HDT_HeraCompany__mdt hc : companyList){
                company  = new PicklistObj();
                company.label = hc.Label;
                company.value = hc.DeveloperName;
                pickObj.companyList.add(company);
            }

            //Schema.DescribeFieldResult fieldResult = HDT_RequestEstrattoConto__mdt.Aggregazione__c.getDescribe();
            Schema.DescribeFieldResult fieldResult = HDT_StatementRequest__mdt.Aggregation__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            PicklistObj joinLevel;
            for( Schema.PicklistEntry f : ple){
                joinLevel = new PicklistObj();
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

    public class ConfTabObjDetail {
        @AuraEnabled public String recordCode;
        @AuraEnabled public String tabCode;
        @AuraEnabled public Boolean hasSecondLevel;
        @AuraEnabled public Boolean hasAmountField;
        @AuraEnabled public String secondLevelAPIname;
        @AuraEnabled public List<ButtonObjDetail> buttonList;
    }

    public class ButtonObjDetail {
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public Boolean enable;
        
        public ButtonObjDetail(String labelTemp, String nameTemp, Boolean enableTemp){
            label = labelTemp;
            name = nameTemp;
            enable = enableTemp;
        }
    }

    public class ColumnsObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public ConfTabObjDetail confObj;
        @AuraEnabled public List<SingleColumn> columnObj;
    }

    public class SingleColumn {
        @AuraEnabled public ColumnDetail detail;
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean showSort;
        @AuraEnabled public Boolean showAmount;
    }

    public class ColumnDetail {
        @AuraEnabled public String type;
        @AuraEnabled public Boolean isAmount;
    }

    public class ResponseObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean dataError;
        @AuraEnabled public String bodyBase64;
    }

    public class ReturnPicklist {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<PicklistObj> companyList;
        @AuraEnabled public List<PicklistObj> joinLevelList;
    }

    public class PicklistObj {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    //SECOND LEVEL COLUMN OBJ
    public class SecLevColumnsObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<SingleSecCol> columnObj;
    }

    public class SingleSecCol {
        @AuraEnabled public Boolean isFilter;
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean sortable;
        @AuraEnabled public Decimal initialWidth;
    }

}