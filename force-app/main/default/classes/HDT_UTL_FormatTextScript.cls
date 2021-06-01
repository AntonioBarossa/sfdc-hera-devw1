public with sharing class HDT_UTL_FormatTextScript {
    
    private static String regEx= '<<\\{([\\s]?)+[A-Za-z0-9_.]+([\\s]?)+\\}>>';

    @InvocableMethod
    public static List<String> formatText(List<ConfigurazioneScript__c> scriptsRecord){
        //This Function get a Script record, get his text and binds the dynamic data from DB to it

        String scriptTxt = ' '+scriptsRecord[0].TextScript__c+' ';
        List<String> fieldsToMatch = getDataBinded(scriptTxt);
        if(!fieldsToMatch.isEmpty()){
            String query = makeSelectStatement(fieldsToMatch);
            query+=
                //'FROM wrts_prcgvr__Activity__c where Id = \''+
                ' FROM ConfigurazioneScript__c where Id = \''+
                scriptsRecord[0].id+'\' LIMIT 1';
            system.debug(query);
            ConfigurazioneScript__c scriptRecordFull = Database.query(query);
            return new List<String>{finalTextScript(scriptTxt, fieldsToMatch, scriptRecordFull)};
        }

        return new List<String>{scriptTxt.trim()};
        
    }


    private static String finalTextScript(String scriptTxt, List<String> fieldsToMatch, ConfigurazioneScript__c scriptRecordFull){
        //This Method put in the text all the data got from DB at the correct spot
        List<String> splittedScript = scriptTxt.split(regEx);
        String finalText = splittedScript[0];
        for(Integer matchingIndex = 0;matchingIndex < fieldsToMatch.size(); matchingIndex++){
            String textBlock = splittedScript[matchingIndex+1];//Index of corresponding block to corresponding field is shifted by 1
            finalText+=  getFieldValue(fieldsToMatch[matchingIndex], scriptRecordFull)+' '+textBlock;
        }
        return finalText;
    }


    private static String getFieldValue(String fieldPath, ConfigurazioneScript__c scriptRecordFull){
        //this method get dinamically field Value from generic sogbject, even from a related parent object
        List<String> relationshipNames = fieldPath.split('\\.');
        SObject relation=scriptRecordFull;
        String fieldValue;
        if(relationshipNames[0]=='global'){
            //not field but function like "today"
        }
        for(Integer indexParentField = 0; indexParentField<relationshipNames.size(); indexParentField++){
            if(indexParentField!=relationshipNames.size()-1){
                relation=relation.getSobject(relationshipNames[indexParentField]);
            }else{
                String dataFieldType = relation.getSobjectType().getDescribe().fields.getMap()
                                            .get(relationshipNames[indexParentField])
                                            .getDescribe()
                                            .getType().name();
                system.debug(dataFieldType);
                switch on dataFieldType{
                    when 'STRING'{
                        fieldValue= (String) relation.get(relationshipNames[indexParentField]);
                    }
                    when 'DATETIME'{
                        fieldValue= ((DATETIME) relation.get(relationshipNames[indexParentField])).format('dd.MM.yyyy');
                    }
                    when else {
                        fieldValue= STRING.valueOf(relation.get(relationshipNames[indexParentField]));
                    }
                }
                
            }
        }
        return fieldValue;
    }


    private static List<String> getDataBinded(String Text){
        //this method catches all dynamic fields in the text
        List<String> bindedFields = new List<String>();
        Matcher matcher=Pattern.compile(regEx).matcher(Text);
         
        while(matcher.find()){
            String preFormatData = matcher.group(0);
            preFormatData= preFormatData.removeEnd('}>>').removeStart('<<{');
            bindedFields.add(preFormatData.trim().toLowerCase());
        }
        system.debug(bindedFields);
        return bindedFields;
    }

    private static String makeSelectStatement(List<String> listFields){
        //this method remove duplicate values and format the dynamic soql

        String querySelectStatement='';
        Set<String> fieldsToSelect = new Set<String>();
        for(String field : listFields){
            fieldsToSelect.add(field);
        }
        for(String field : fieldsToSelect){
            querySelectStatement=querySelectStatement+', '+field;
        }
        return 'SELECT ' + (querySelectStatement.removeStart(','));
    }
}
