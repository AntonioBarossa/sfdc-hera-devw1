@SuppressWarnings('PMD.ExcessiveParameterList, PMD.IfStmtsMustUseBraces, PMD.IfElseStmtsMustUseBraces, PMD.AvoidDebugStatements')
public with sharing class HDT_UTL_EquipmentValidation implements HDT_UTL_CaseValidationInterface{
    
    Map<String, Object> fieldsMap=null;
    List<String> fieldsName;

    public String validate(String fields, String recordId){
        this.fieldsName = new HDT_UTL_Tqrif().fieldsName;
        ProcessEquipment__c equipment = getProcessEquipment(recordId);
        System.debug(LoggingLevel.DEBUG,'HDT_UTL_CaseValidations: validating Case ' + equipment);
        this.fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        
        return JSON.serialize(getValidationResult(equipment));

    }

    private HDT_WRP_EquipmentValidation getValidationResult(ProcessEquipment__c equipment){
        String caseType = equipment.Case__r.Type;
        List<String> keyList = new List<String>(this.fieldsMap.keySet());
        String prefix = keyList[0].startsWithIgnoreCase('old')? 'Old' : 'New';

        if(checkAllBlank(prefix))    return new HDT_WRP_EquipmentValidation('Error', 'Popolare almeno un campo');
        if(caseType == 'Associa Dotazioni')     return new HDT_WRP_EquipmentValidation('OK', 'Success');

        if(prefix == 'Old')  return new HDT_WRP_EquipmentValidation('OK', 'Success');

        return checkDeliveryEquipment(equipment);
    }

    private Boolean checkAllBlank(String prefix){
        for(String field : this.fieldsName){
            Object objStrValue = this.fieldsMap.get(prefix+field);
            if(STRING.isNotBlank(STRING.valueOf(objStrValue))){
                return false;
            }
        }
        return true;
    }

    private HDT_WRP_EquipmentValidation checkDeliveryEquipment(ProcessEquipment__c equipment){
        List<String> mandatoryFields = new List<String>();
        List<String> fieldsToBlank = new List<String>();

        for(String field : fieldsName){
            Boolean oldValueBlank = STRING.isBlank(STRING.valueOf(equipment.get('Old'+field)));
            Boolean newValueBlank = STRING.isBlank(STRING.valueOf(this.fieldsMap.get('New'+field)));

            if(oldValueBlank != newValueBlank){
                if(newValueBlank)   mandatoryFields.add('New'+field);
                else                fieldsToBlank.add('New'+field);
            }
        }

        if(mandatoryFields.isEmpty() && fieldsToBlank.isEmpty())    return new HDT_WRP_EquipmentValidation('OK', 'Success');
        
        HDT_WRP_EquipmentValidation result = new HDT_WRP_EquipmentValidation('Error', 'Popolare tutti e soli i campi valorizzati nella sezione precedente');
        result.mandatoryFields = mandatoryFields;
        result.fieldsToBlank = fieldsToBlank;
        return result;
    }



    


    private ProcessEquipment__c getProcessEquipment(Id processEquipmentId){
        String query = 'SELECT ' +
            'Old'+STRING.join(this.fieldsName, ', Old') +', ' + //aggiunta desinenza Old
            'New' + STRING.join(this.fieldsName, ', New') +' ' +//aggiunta desinenza New
            +', Case__r.Type ' +
            ' FROM ProcessEquipment__c ' +
            ' WHERE Id =:processEquipmentId ' +
            'WITH SECURITY_ENFORCED ';

        system.debug(LoggingLevel.DEBUG, query);
        List<ProcessEquipment__c> processes = (List<ProcessEquipment__c>) Database.query(STRING.escapeSingleQuotes(query));
        return processes[0];
    }

    class HDT_WRP_EquipmentValidation extends HDT_UTL_CaseValidationWrapper {
        List<String> mandatoryFields { get; set; }
        List<String> fieldsToBlank { get; set; }

        HDT_WRP_EquipmentValidation(String outcomeCode, String outcomeDescription){
            this.outcomeCode = outcomeCode;
            this.outcomeDescription = outcomeDescription;
        }
    }
}