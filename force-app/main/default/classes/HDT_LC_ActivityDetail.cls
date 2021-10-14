/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 23/07/2021
 * @description HDT_LC_ActivityDetail - Classe(query) chiamata da hdtActivityDetail
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public with sharing class HDT_LC_ActivityDetail {
    class HDT_WRP_ObjectFieldData{
        @AuraEnabled public Id objectId {get; set;}
        @AuraEnabled public String objectName {get; set;}//>> costanzo.lomele@webresults.it 18/09/21 - OrderNumber/CaseNumber cliccabile
        @AuraEnabled public list<wrts_prcgvr__DynamicField__c> fieldList {get; set;}

        //HDT_WRP_ObjectFieldData(){}
    }
    ///
    @AuraEnabled
    public static map<string,HDT_WRP_ObjectFieldData> getObjectFields(Id idActivity){

        map<string,HDT_WRP_ObjectFieldData> objectFields= new Map<String,HDT_WRP_ObjectFieldData>();
        list<wrts_prcgvr__ActivityTemplate__c> activityTemplate = new list<wrts_prcgvr__ActivityTemplate__c>();
        list<wrts_prcgvr__FieldsTemplate__c> fieldsTemplate = new list<wrts_prcgvr__FieldsTemplate__c>();
        list<wrts_prcgvr__DynamicSection__c> dynamicSection = new list<wrts_prcgvr__DynamicSection__c>();

        list<wrts_prcgvr__Activity__c> activity = [SELECT Id, Name, wrts_prcgvr__ActivityTemplate__c, Order__c, Order__r.OrderNumber, Case__c, Case__r.CaseNumber, Account__c, Account__r.Name, CreatedDate, StartDate__c //>> costanzo.lomele@webresults.it 18/09/21 - OrderNumber/CaseNumber cliccabile //>>>marco.arci@webresults.it Aggiunta Account
                                                    FROM wrts_prcgvr__Activity__c 
                                                    WHERE Id=:idActivity
                                                    WITH SECURITY_ENFORCED];
        boolean notShowStartDate = !((activity[0].CreatedDate).Date() != activity[0].StartDate__c && String.ISNOTBLANK(String.ValueOf(activity[0].StartDate__c))); 
        if(activity!=null && !activity.isEmpty() && activity[0].wrts_prcgvr__ActivityTemplate__c!=null){
            activityTemplate = [SELECT Id, wrts_prcgvr__FieldsTemplate__c 
                                FROM wrts_prcgvr__ActivityTemplate__c 
                                WHERE Id=:activity[0].wrts_prcgvr__ActivityTemplate__c 
                                WITH SECURITY_ENFORCED];
        }
        if(activityTemplate!=null && !activityTemplate.isEmpty() && activityTemplate[0].wrts_prcgvr__FieldsTemplate__c!=null){
            fieldsTemplate = [SELECT Id FROM wrts_prcgvr__FieldsTemplate__c 
                              WHERE Id=:activityTemplate[0].wrts_prcgvr__FieldsTemplate__c 
                              WITH SECURITY_ENFORCED];
        }
        if(fieldsTemplate!=null && !fieldsTemplate.isEmpty()){
            dynamicSection = [SELECT Id, wrts_prcgvr__Layout__c, wrts_prcgvr__Order__c 
                              FROM wrts_prcgvr__DynamicSection__c 
                              WHERE wrts_prcgvr__Layout__c IN: fieldsTemplate
                              WITH SECURITY_ENFORCED
                              ORDER BY wrts_prcgvr__Order__c];
        }
    /////////////////////
        if(dynamicSection!=null && !dynamicSection.isEmpty()){
            map<id,list<wrts_prcgvr__DynamicField__c>> mapSectionField= new map<id,list<wrts_prcgvr__DynamicField__c>>();
            for(integer i=0;i<dynamicSection.size();i++){
                list<wrts_prcgvr__DynamicField__c> listOfFields= new list<wrts_prcgvr__DynamicField__c>();
                mapSectionField.put(dynamicSection[i].Id,listOfFields);
            }
    //////////////////////      
            list<wrts_prcgvr__DynamicField__c> dynamicField = [SELECT Id, wrts_prcgvr__Section__c, wrts_prcgvr__ObjectName__c, wrts_prcgvr__Field__c 
                                                               FROM wrts_prcgvr__DynamicField__c 
                                                               WHERE wrts_prcgvr__Section__c IN: dynamicSection
                                                               WITH SECURITY_ENFORCED];
    /////////////////////       
            for(wrts_prcgvr__DynamicField__c item: dynamicField){
                for(Id mapItem: mapSectionField.keySet()){
                    if(mapItem==item.wrts_prcgvr__Section__c){
                        if(!('StartDate__c'.equalsIgnoreCase(item.wrts_prcgvr__Field__c) && notShowStartDate)){
                            mapSectionField.get(mapItem).add(item);
                        }
                    }
                }
            }
            dynamicField.clear();
            for(id mapItem: mapSectionField.keySet()){
                dynamicField.addAll(mapSectionField.get(mapItem));
            }
    /////////////////////
            for(wrts_prcgvr__DynamicField__c field: dynamicField){
                if(!objectFields.keyset().contains(field.wrts_prcgvr__ObjectName__c)){
                    HDT_WRP_ObjectFieldData wrp = new HDT_WRP_ObjectFieldData();
                    if(field.wrts_prcgvr__ObjectName__c=='wrts_prcgvr__Activity__c'){
                        wrp.objectId = (Id)activity[0].get('id');
                        wrp.objectName = (String)activity[0].get('Name');//>> costanzo.lomele@webresults.it 18/09/21 - OrderNumber/CaseNumber cliccabile
                    }else{
                        if(  field.wrts_prcgvr__ObjectName__c=='Order'){
                            wrp.objectId = (Id)activity[0].get('Order__c');
                            wrp.objectName = (String)activity[0].Order__r.OrderNumber;//>> costanzo.lomele@webresults.it 18/09/21 - OrderNumber/CaseNumber cliccabile
                        }else if(field.wrts_prcgvr__ObjectName__c=='Case'){
                            wrp.objectId = (Id)activity[0].get('Case__c');
                            wrp.objectName = (String)activity[0].Case__r.CaseNumber;//>> costanzo.lomele@webresults.it 18/09/21 - OrderNumber/CaseNumber cliccabile
                        }
                        //>>>START marco.arci@webresults.it Aggiunta Account nel wrapper
                        else if(field.wrts_prcgvr__ObjectName__c=='Account'){
                            wrp.objectId = (Id)activity[0].get('Account__c');
                            wrp.objectName = (String)activity[0].Account__r.Name;
                        }
                        //>>>END marco.arci@webresults.it Aggiunta Account nel wrapper
                    }
                    wrp.fieldList = new list<wrts_prcgvr__DynamicField__c>();

                    objectFields.put(field.wrts_prcgvr__ObjectName__c,wrp);
                }
                objectFields.get(field.wrts_prcgvr__ObjectName__c).fieldList.add(field);
            }
            //system.debug(JSON.serializePretty(objectFields));
        }
        //system.debug(JSON.serializePretty(objectFields));
        return objectFields;
    }
}