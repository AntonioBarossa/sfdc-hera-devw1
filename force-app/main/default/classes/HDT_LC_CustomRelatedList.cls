public with sharing class HDT_LC_CustomRelatedList {

    private static final Map<String, String> FIELD_TYPES = new Map<String, String> {
        'BOOLEAN' => 'boolean',
        'CURRENCY' => 'currency',
        'DATE' => 'date-local',
        'DATETIME' => 'date',
        'EMAIL' => 'email',
        'DOUBLE' => 'number',
        'PERCENT' => 'percent',
        'PHONE' => 'phone'
    };

    private static final Integer QUERY_LIMIT = 7;
    
    @AuraEnabled
    public static Map<String, Object> getRecordsToDisplay(Id parentRecordId, String parentRecordTargetField, String childObjectApiName, String childLookupField, String fieldsToRetrieve, String nameField, Boolean retrieveAll, Boolean fetchColumns){
        
        Map<String, Object> result = new Map<String, Object>();

        try {

            Schema.DescribeSObjectResult childObjectType = Schema.getGlobalDescribe().get(childObjectApiName).getDescribe();
            Map<String, Schema.SObjectField> childObjectFields = childObjectType.fields.getMap();
            
            String relationShipsToAddToQuery = '';

            JSONGenerator gen = JSON.createGenerator(true);
    
            if (fetchColumns) {

                gen.writeStartArray();

                for (String field : fieldsToRetrieve.split(',')) {
                    
                    Schema.DescribeFieldResult fieldDescribe = childObjectFields.get(field)?.getDescribe();

                    gen.writeStartObject();

                    if (field.contains('.')) {

                        // system.debug(field.trim());
                        // system.debug((field.trim()).split('.'));

                        List<String> relationShip = field.trim().split('\\.');
                        String relationShipField = relationShip.get(0);

                        if (!relationShipField.containsIgnoreCase('__r')) {
                            relationShipField += 'Id';
                        } else {
                            relationShipField = relationShipField.replace('__r', '__c');
                        }

                        fieldDescribe = childObjectFields.get(relationShipField).getDescribe().getReferenceTo().get(0).getDescribe().fields.getMap().get(relationShip.get(1)).getDescribe();

                        if (fieldDescribe.isNameField()) {
                            
                            gen.writeStringField('fieldName', relationShipField);
                            relationShipsToAddToQuery += ',' + relationShipField;

                            String label = ' (' + String.valueOf(childObjectFields.get(relationShipField).getDescribe().getLabel()) + ')';

                            generateUrlLabel(gen, fieldDescribe.getLabel() + label, field.trim());

                        } else {

                            gen.writeStringField('fieldName', field.trim());

                        }

                    } else {

                        gen.writeStringField('fieldName', field.trim());

                        String currentFieldType = String.valueOf(fieldDescribe?.getType());

                        if (currentFieldType == 'ID') {
                            
                            fieldDescribe = childObjectFields.get(nameField).getDescribe();                            
                            generateUrlLabel(gen, fieldDescribe.getLabel(), nameField);

                        } else {

                            generateGenericLabel(gen, String.valueOf(fieldDescribe.getLabel()), FIELD_TYPES.get(currentFieldType));

                        }

                    }

                    gen.writeEndObject();

                }

                gen.writeEndArray();

            }

            SObject parentRecord = Database.query('SELECT ' + parentRecordTargetField + ' FROM ' + parentRecordId.getSobjectType() + ' WHERE Id =: parentRecordId');

            String queryString = 'SELECT ' + fieldsToRetrieve + (fieldsToRetrieve.containsIgnoreCase(',' + nameField + ',') ? '' : ', ' + nameField) + relationShipsToAddToQuery;
            queryString += ' FROM ' + childObjectApiName + 
                           ' WHERE ' + childLookupField + ' = \'' + parentRecord.get(parentRecordTargetField) + '\'' + 
                           ' ORDER By ' + (String.isNotBlank(nameField) ? nameField : fieldsToRetrieve.split(',').get(0));

            if (!retrieveAll) {

                queryString += ' LIMIT ' + QUERY_LIMIT;

            }

            System.debug('queryString ' + queryString);

            result.put('columns', gen.getAsString());
            result.put('relationshipsAddedToQuery', relationShipsToAddToQuery);
            result.put('objectLabel', childObjectType.getLabelPlural());
            result.put('childRecords', Database.query(queryString));

            return result;

        } catch (Exception e) {
            System.debug('exMessage ' + e.getMessage());
            System.debug('exStack ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void generateUrlLabel(JSONGenerator gen, String label, String nameField) {

        gen.writeBooleanField('sortable', true);
        gen.writeStringField('label', label);
        gen.writeStringField('type', 'url');
        gen.writeStringField('target', '_self');
        gen.writeObjectField('typeAttributes', JSOn.deserializeUntyped('{"label": { "fieldName": "' + nameField + '"}}'));

    }

    private static void generateGenericLabel(JSONGenerator gen, String label, String type) {

        gen.writeStringField('type', String.isNotBlank(type) ? type : 'text');
        gen.writeStringField('label', label);

        if (!type.equals('boolean')) gen.writeBooleanField('sortable', true);

        switch on type {
            when 'date' {
                gen.writeObjectField('typeAttributes', JSOn.deserializeUntyped('{"day": "2-digit", "month": "2-digit", "year": "numeric", "hour": "2-digit", "minute": "2-digit"}'));
            }
            when 'date-local' {
                gen.writeObjectField('typeAttributes', JSOn.deserializeUntyped('{"day": "2-digit", "month": "2-digit", "year": "numeric"}'));
            }
        }

    }

}