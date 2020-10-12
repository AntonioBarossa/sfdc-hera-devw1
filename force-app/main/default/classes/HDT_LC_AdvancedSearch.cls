public with sharing class HDT_LC_AdvancedSearch {

    private static List<ServicePoint__c> servicePoints;
    private static Map<String, String> servicePointFields = getservicePointObjectFields();
    private static CS_SelezioneFornitura__c customSetting = getCustomSetting();

    /*
	 * Retrieve data from ServicePoint Object By ServiceCode
	 */
    @AuraEnabled(cacheable = true)
    public static List<Map<String, Object>> getServicePoints(String parameter) {
        Set<ServicePoint__c> servicePoints = new Set<ServicePoint__c>();
        if (parameter.length() < 6) {
            Integer.valueOf(parameter);
            servicePoints.addAll(getServicePointsByMeterSerialNumber(parameter));
        } else {
            servicePoints.addAll(getServicePointsByMeterSerialNumber(parameter));
            servicePoints.addAll(getServicePointsByCode(parameter));
        }
        checkTheNumberOfRecords(servicePoints.size());
        String[] customSettingFields = customSetting.OutputServicePoint__c.split(',');
        List<Map<String, Object>> output = new List<Map<String, Object>>();
        Map<String, Object> record = new Map<String, Object>();
        for (ServicePoint__c servicePointObject : servicePoints) {
            for (String customSettingField : customSettingFields) {
                if (!customSettingField.contains('.')) {
                    if (servicePointObject.get(customSettingField) == null) {
                        record.put(servicePointFields.get(customSettingField), '');
                    } else {
                        record.put(servicePointFields.get(customSettingField),
                                servicePointObject.get(customSettingField));
                    }
                }
                if (customSettingField.contains('__r')) {
                    if (servicePointObject.getSobject(customSettingField.substringBefore('.')) != null) {
                        String label = customSettingField.substringBefore('__r') + '__c';
                        label = servicePointFields.get(label);
                        record.put(label + ' ' + customSettingField.substringAfter('.'),
                                servicePointObject.getSobject(customSettingField.substringBefore('.')).get(
                                        customSettingField.substringAfter('.')));
                    }
                }
            }
            output.add(new Map<String, Object>(record));
            record.clear();
        }
        return output;
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, String> servicePointFields() {
        servicePointFields.put('customSetting', customSetting.OutputServicePoint__c);
        return servicePointFields;
    }

    /*
	 * Checking Number of records
	 */
    static void checkTheNumberOfRecords(Integer records) {
        if (records > (customSetting.Max_Record__c).intValue()) {
            throw new AuraHandledException('Number of records reached Maximum exceeded');
        }
    }

    /*
	 * Getting Custom Settimg 'CS_SelezioneFornitura'
	 */
    static CS_SelezioneFornitura__c getCustomSetting() {
        return [SELECT Max_Record__c, OutputServicePoint__c FROM CS_SelezioneFornitura__c][0];
    }

    /*
	 * Getting All get ServicePoint Fields as Map
	 */
    static Map<String, String> getservicePointObjectFields() {
        Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.ServicePoint__c.fields.getMap();
        Map<String, String> fields = new Map<String, String>();
        for (String key : fieldsMap.keyset()) {
            String name = fieldsMap.get(key).getDescribe().getName();
            String label = fieldsMap.get(key).getDescribe().getLabel();
            fields.put(name, label);
        }
        return fields;
    }

    /*
	 * Query for POD
	 */
    static List<ServicePoint__c> getServicePointsByCode(String code) {
        String stringCode = '%' + code.trim() + '%';
        String query = 'SELECT ' + customSetting.OutputServicePoint__c +
                ' FROM ServicePoint__c WHERE ServicePointCode__c LIKE :stringCode ';
        List<ServicePoint__c> servicePoints = Database.query(query);
        return servicePoints;
    }

    /*
	 * Query for Serial Number
	 */
    static List<ServicePoint__c> getServicePointsByMeterSerialNumber(String serialNumber) {
        String stringSerialNumber = '%' + serialNumber + '%';
        String query = 'SELECT ' + customSetting.OutputServicePoint__c +
                ' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber ';
        List<ServicePoint__c> servicePoints = Database.query(query);
        return servicePoints;
    }
}
