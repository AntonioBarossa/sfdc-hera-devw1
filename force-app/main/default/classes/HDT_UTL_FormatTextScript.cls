/*
 * File: HDT_UTL_FormatTextScript.cls
 * Project: HERA
 * File Created: Monday, 31st May 2021 2:02:00 pm
 * Author: fdefelice
 * -----
 * Last Modified: Tuesday, 1st June 2021 7:15:54 pm
 * Modified By: fdefelice
 * -----
 */



public with sharing virtual class HDT_UTL_FormatTextScript {
    
    protected String regEx= '<<\\{([\\s]?)+[A-Za-z0-9_.]+([\\s]?)+\\}>>';


    public String formatText(String textScript, String recordId){
        return formatText( textScript,  recordId,  null);
    }


    public String formatText(String textScript, String recordId, SOBject objectToQueryData){
        //This Function get a Script record, get his text and binds the dynamic data from DB to it
        String finalOutput ='';

        String scriptTxt = ' '+textScript+' ';
        List<String> fieldsToMatch = getDataBinded(scriptTxt);

        if(!fieldsToMatch.isEmpty()){
            if(objectToQueryData==null){
                objectToQueryData=getSobject(recordId, fieldsToMatch);
            }
            finalOutput = finalTextScript(scriptTxt, fieldsToMatch, objectToQueryData);
            return finalOutput.trim().replaceAll('\n', '<br/>');
        }
        return scriptTxt.trim().replaceAll('\n', '<br/>');
    }


    protected Sobject getSobject(String recordId, List<String> fieldsToQuery){
        String objectName = ((Id) recordId).getSobjectType().getDescribe().getName();
        String query = makeSelectStatement(fieldsToQuery);
        Sobject genericSObject;
        if(STRING.isNotBlank(query)){
            query+=
                //'FROM wrts_prcgvr__Activity__c where Id = \''+
                ' FROM '+objectName+' where Id = \''+
                recordId+'\' LIMIT 1';
            system.debug(query);
            try{
                genericSObject = (SObject) Database.query(query);
            }catch(Exception e){
                throw new HDT_UTL_FormatTextScriptException(
                        'ERRORE DATABASE QUERY, SOQL: # '
                            +query + ' # MESSAGE: '+e.getMessage());
            }
        }
        return genericSObject;
    }


    protected String finalTextScript(String scriptTxt, List<String> fieldsToMatch, SObject objectToQueryData){
        //This Method put in the text all the data got from DB at the correct spot
        List<String> splittedScript = scriptTxt.split(regEx);
        String finalText = splittedScript[0];
        for(Integer matchingIndex = 0;matchingIndex < fieldsToMatch.size(); matchingIndex++){
            String textBlock = splittedScript[matchingIndex+1];//Index of corresponding block to corresponding field is shifted by 1
            finalText+=  getBoldFieldValue(fieldsToMatch[matchingIndex], objectToQueryData)+''+textBlock;
        }
        return finalText;
    }

    protected String getBoldFieldValue(String fieldPath, SObject relation){
        return '<b>'+getFieldValue( fieldPath,  relation)+'</b>';
    }


    protected String getFieldValue(String fieldPath, SObject relation){
        //this method get dinamically field Value from generic sogbject, even from a related parent object
        List<String> relationshipNames = fieldPath.split('\\.');
        //SObject relation=scriptRecordFull;
        String fieldValue;
        if(relationshipNames[0]=='globaltag'){
            //not field but functions like "today" or other data, global.something bind "Global Tags"
            //return *valore globale da tornare, l'identificativo è relationshipNames[1]*
            return getGlobalTagValues(relationshipNames);
        }
        for(Integer indexParentField = 0; indexParentField<relationshipNames.size(); indexParentField++){
            String fieldOrRelation = relationshipNames[indexParentField];

            if(indexParentField!=relationshipNames.size()-1){
                relation=relation.getSobject(fieldOrRelation);
            }else{
                if(relation==null){
                    fieldValue='*valore mancante*';
                    return fieldValue ;
                }
                String dataFieldType = relation.getSobjectType().getDescribe().fields.getMap()
                                            .get(fieldOrRelation)
                                            .getDescribe()
                                            .getType().name();
                system.debug(dataFieldType);
                switch on dataFieldType{
                    when 'STRING'{
                        fieldValue= (String) relation.get(fieldOrRelation);
                    }
                    when 'DATETIME'{
                        fieldValue= ((DATETIME) relation.get(fieldOrRelation)).format('dd/MM/yyyy');
                    }
                    when 'DATE'{
                        fieldValue= ((DATE) relation.get(fieldOrRelation)).format();
                    }
                    when else {
                        fieldValue= STRING.valueOf(relation.get(fieldOrRelation));
                    }
                }
                
            }
        }
        return fieldValue;
    }


    protected List<String> getDataBinded(String Text){
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

    protected String makeSelectStatement(List<String> listFields){
        //this method remove duplicate values and format the dynamic soql

        String querySelectStatement='';
        Set<String> fieldsToSelect = new Set<String>();
        fieldsToSelect.addAll(listFields);
        for(String field : fieldsToSelect){
            if(!field.startsWith('globaltag')){//exclude global tags from query
                querySelectStatement=querySelectStatement+', '+field;
            }
        }
        if(String.isBlank(querySelectStatement)){
            return '';
        }
        return 'SELECT ' + (querySelectStatement.removeStart(','));
    }

    @TestVisible
    private static String getGlobalTagValues(List<String> relationshipNames){
        String tagName=relationshipNames[1];

        String tagValue='';
        switch on tagName{
            when 'today'{
                tagValue=Date.Today().format();
            }
            when 'section__d'{
                return '\n\n'+relationshipNames[2].replace('_', ' ')+'\n';
            }
            when else{
                tagValue='*valore mancante*';
            }
        }
        return ''+tagValue+'';
    }

    private class HDT_UTL_FormatTextScriptException extends Exception {}
}
