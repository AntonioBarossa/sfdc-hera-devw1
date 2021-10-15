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

    private static final String EMPTY_PLACEHOLDER = '[Vuoto]';
    
    protected String regEx= '\\{\\{[\\xa0\\s]?+([A-Za-z0-9_.]+)[\\xa0\\s]?+\\}\\}';
    //'<<\\{([\\s]?)+[A-Za-z0-9_.]+([\\s]?)+\\}>>';
    //protected String leftIncapsulatingData= '{{';
    //protected String rightIncapsulatingData= '}}';

    private Boolean isFirstSection=true;
    private Map<String,List<HDT_CallScriptValue__mdt>> overrideMap = new Map<String,List<HDT_CallScriptValue__mdt>>();
    private Map<String,String> constantMap = new Map<String,String>();

    public HDT_UTL_FormatTextScript(){
        readMetadata();
    }

    public String formatText(String textScript, String recordId){//standard method, call when you haven't already queried the record
        return formatText( textScript,  recordId,  null);
    }

    public String formatText(String textScript, SOBject objectToQueryData){//standard method, call when you haven't already queried the record
        return formatText( textScript,  '',  objectToQueryData);
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
            return finalOutput.trim();//.replaceAll('\n', '<br/>');//not needed when input is already rich text
        }
        return scriptTxt.trim();//.replaceAll('\n', '<br/>');
    }


    protected Sobject getSobject(String recordId, List<String> fieldsToQuery){
        //this method get an id and a list of fields, it returns a generic sobject
        String objectName = ((Id) recordId).getSobjectType().getDescribe().getName();
        String query = makeSelectStatement(fieldsToQuery);
        Sobject genericSObject;
        if(String.isNotBlank(query)){
            try{
                genericSObject = (SObject) Database.query(
                    String.escapeSingleQuotes(query) + ' FROM '+String.escapeSingleQuotes(objectName)+' WHERE Id = :recordId LIMIT 1'
                );
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
        String fieldOrRelation;
        //SObject relation=scriptRecordFull;
        String fieldValue;
        if(relationshipNames[0]=='globaltag'){
            //not field but functions like "today" or other data, global.something bind "Global Tags"
            //return *valore globale da tornare, l'identificativo è relationshipNames[1]*
            return getGlobalTagValues(relationshipNames, relation);
        }

        if (relationshipNames[0]=='constant'){
            return getConstantValue(relationshipNames);
        }

        for(Integer indexParentField = 0; indexParentField<relationshipNames.size(); indexParentField++){
            fieldOrRelation = relationshipNames[indexParentField];

            if(indexParentField!=relationshipNames.size()-1){
                relation=relation.getSobject(fieldOrRelation);
            }else{
                if(relation==null){
                    return fieldValue;
                }
                String dataFieldType = relation.getSobjectType().getDescribe().fields.getMap()
                                            .get(fieldOrRelation)
                                            .getDescribe()
                                            .getType().name();
                switch on dataFieldType{
                    when 'STRING'{
                        fieldValue = (String) relation.get(fieldOrRelation);
                    }
                    when 'DATETIME'{
                        Datetime dt = (Datetime) relation.get(fieldOrRelation);
                        if (dt!=null) {
                            fieldValue = dt.format('dd/MM/yyyy');
                        }
                    }
                    when 'DATE'{
                        Date d = (Date) relation.get(fieldOrRelation);
                        if (d!=null){
                            DateTime tempDate = DateTime.newInstance(d.year(), d.month(), d.day());
                            fieldValue = tempDate.format('dd/MM/yyyy');
                        }
                    }when 'CURRENCY'{
                        fieldValue = STRING.valueOf(relation.get(fieldOrRelation));
                    }
                    when else {
                        fieldValue = STRING.valueOf(relation.get(fieldOrRelation));
                    }
                }
                
            }
        }
        return overwriteValue(fieldValue, relation.getSobjectType().getDescribe().getName(), fieldOrRelation);
    }

    private void readMetadata() {
        for (HDT_CallScriptValue__mdt scriptValue:HDT_CallScriptValue__mdt.getAll().values()) {
            switch on scriptValue.Type__c {
                when 'OVERRIDE'{
                    String key = scriptValue.ObjectName__c+'-'+scriptValue.FieldName__c;
                    List<HDT_CallScriptValue__mdt> overrideValues = (overrideMap.containsKey(key.toLowerCase()))?
                        overrideMap.get(key.toLowerCase()):
                        new List<HDT_CallScriptValue__mdt>();
                    overrideValues.add(scriptValue);
                    overrideMap.put( key.toLowerCase(), overrideValues );
                }
                when 'CONSTANT'{
                    constantMap.put( scriptValue.ConstantName__c.toLowerCase(), scriptValue.Value__c );
                }
            }
        }
    }

    private String overwriteValue(String fieldValue, String sobjectApiName, String fieldApiName){

        //reading overrides from HDT_CallScriptValue__mdt
        String key = sobjectApiName+'-'+fieldApiName;
        if (overrideMap.containsKey(key.toLowerCase())) {
            List<HDT_CallScriptValue__mdt> overrideValues = overrideMap.get(key.toLowerCase());
            List<String> formatParams = new List<String>{fieldValue};

            for (HDT_CallScriptValue__mdt overrideValue:overrideValues) {
                if (String.isBlank(overrideValue.ValueToOverride__c) || overrideValue.ValueToOverride__c==fieldValue) {
                    fieldValue = String.format(overrideValue.Value__c, formatParams);
                }
            }
        }

        //overriding empty values with placeholder
        if (String.isBlank(fieldValue) || fieldValue=='null') {
            fieldValue = EMPTY_PLACEHOLDER;
        }

        return fieldValue;
    }


    protected List<String> getDataBinded(String text){
        //this method catches all dynamic fields in the text
        //generally can be used to extract all regex occurence in a string
        List<String> bindedFields = new List<String>();
        Matcher matcher=Pattern.compile(regEx).matcher(text);
         
        while(matcher.find()){
            //String preFormatData = matcher.group(0);
            //preFormatData= preFormatData.removeEnd(rightIncapsulatingData).removeStart(leftIncapsulatingData);
            //bindedFields.add(preFormatData.trim().toLowerCase());
            bindedFields.add(matcher.group(1).toLowerCase());
        }
        return bindedFields;
    }

    protected String makeSelectStatement(List<String> listFields){
        //this method remove duplicate values and format the dynamic soql

        String querySelectStatement='';
        Set<String> fieldsToSelect = new Set<String>();
        //fieldsToSelect.addAll(listFields);
        for(String field : listFields){
            if((!field.startsWith('globaltag') && !field.startsWith('constant')) || field.startsWith('globaltag.redirlink')){//exclude global tags from query
                //querySelectStatement=querySelectStatement+', '+field;
                fieldsToSelect.add(field.removeStart('globaltag.redirlink.').trim());
            }
        }
        querySelectStatement = String.join(new List<String>(fieldsToSelect), ', ');
        if(String.isBlank(querySelectStatement)){
            return '';
        }
        return 'SELECT ' + (querySelectStatement);
    }

    @TestVisible
    private String getGlobalTagValues(List<String> relationshipNames, Sobject relation){
        //edit this method to add global tags
        String tagName=relationshipNames[1];

        String tagValue='';
        switch on tagName{
            when 'today'{
                tagValue = Date.Today().format();
            }
            when 'now'{
                tagValue = Datetime.now().format('HH:mm');
            }
            when 'section__d'{
                //maybe deprecated, you can safely remove this when output and isFirstSection class variable
                if(isFirstSection){
                    isFirstSection=false;
                    return relationshipNames[2].replace('_', ' ')+'\n';

                }
                return '\n\n'+relationshipNames[2].replace('_', ' ')+'\n';
            }
            when 'redirlink' {
                String linkLabel='';
                linkLabel = getFieldValue(String.join(relationshipNames, '.').removeStart('globaltag.redirlink.'), relation);
                String idToRedirect = '';
                relationshipNames[relationshipNames.size()-1]='Id';
                idToRedirect = getFieldValue(String.join(relationshipNames, '.').removeStart('globaltag.redirlink.'), relation);
                return '<a href="/'+idToRedirect+'" target="_blank">'+linkLabel+'</a>';
            }
            when 'username'{
                return UserInfo.getName();
            }
            when else{
                tagValue='*valore mancante*';
            }
        }
        return ''+tagValue+'';
    }

    private String getConstantValue(List<String> relationshipNames){
        String constantName = relationshipNames[1];
        String key = constantName.toLowerCase();
        String tagValue = constantMap.containsKey(key)?constantMap.get(key):'*Costante '+key+' non trovata*';
        return ''+tagValue+'';
    }

    private class HDT_UTL_FormatTextScriptException extends Exception {}
}