public with sharing class HDT_LC_ActivtyMassiveReassignmentTool {
    @AuraEnabled
    public static Map<String, Object> getData() {
        try {
            HDT_UserInputFlow__mdt mdt = [SELECT ReadOnlyFields__c FROM HDT_UserInputFlow__mdt WHERE DeveloperName = 'Activity_Massive_Reassignment_Fields' WITH SECURITY_ENFORCED];
            List<Object> columns = (List<Object>) JSON.deserializeUntyped(mdt.ReadOnlyFields__c);

            String fieldsString = '';
            for(Object column : columns) {
                fieldsString += (String) ((Map<String,Object>) column).get('fieldName') + ', ';
            }
            fieldsString = fieldsString.removeEnd(', ');

            List<wrts_prcgvr__Activity__c> rows = Database.query('SELECT ' + fieldsString + ' FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Status__c NOT IN (\'Chiusa\', \'Completed\') ORDER BY CreatedDate DESC LIMIT 1000');

            Map<String, Object> result = new Map<String,Object> {
                'columns' => columns,
                'rows' => rows
            };

            return result;
        } catch (Exception e) {
            // return e.getMessage();
            return new Map<String,Object> {
                'error' => e.getMessage() + ' AT LINE ' + e.getLineNumber()
            };
        }
    }
}