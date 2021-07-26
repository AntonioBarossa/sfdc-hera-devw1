import { LightningElement, track, api } from 'lwc';
/*
    import getActivityById from '@salesforce/apex/HDT_LC_ActivityDetail.getActivityById';
    import getActivityTemplateById from '@salesforce/apex/HDT_LC_ActivityDetail.getActivityTemplateById';
    import getFieldsTemplateById from '@salesforce/apex/HDT_LC_ActivityDetail.getFieldsTemplateById';
    import getDynamicSectionByFieldsTemplateId from '@salesforce/apex/HDT_LC_ActivityDetail.getDynamicSectionByFieldsTemplateId';
    import getDynamicFieldsByDynamicSectionId from '@salesforce/apex/HDT_LC_ActivityDetail.getDynamicFieldsByDynamicSectionId';
*/
import getObjectFields from '@salesforce/apex/HDT_LC_ActivityDetail.getObjectFields';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class HdtActivityDetail extends LightningElement {
    @api objectApiName;
    @api recordId;

    @track details=[];
    @track show=false;
    @track activity;
    @track activityTemplate;
    @track fieldsTemplate;
    @track dynamicSection;
    @track dynamicField=[];

    connectedCallback(){
        /*
            const activity = getActivityById({"idActivity":this.recordId});
            const activityTemplate= getActivityTemplateById({"idActivityTemplate":this.activity.wrts_prcgvr__ActivityTemplate__c});
            const fieldsTemplate= getFieldsTemplateById({"idFieldsTemplate":this.activityTemplate.wrts_prcgvr__FieldsTemplate__c});
            const dynamicSection= getDynamicSectionByFieldsTemplateId({"idFieldsTemplate":this.fieldsTemplate.Id});
            const dynamicField= getDynamicFieldByDynamicSectionId({"idDynamicSection":this.dynamicSection.Id});
        */
       this.loadContext();
    }

    async loadContext(){
        const result= await getObjectFields({"idActivity":this.recordId});
        //window.alert(result);
        this.getObjectList(result);
        this.show=true;
    }
    @track objectList=[];
    getObjectList(objectMap){ 
        for(var key in objectMap){
            var campi=[];
            //window.alert(key);
            //window.alert(objectMap[key].objectId);
            //window.alert(mapObject[key].fieldList);
            var i=0;
            for(var i in objectMap[key].fieldList){
                //window.alert(i);
                campi.push(objectMap[key].fieldList[i].wrts_prcgvr__Field__c);
            }
            //window.alert(campi);
            this.objectList.push({name:key, fields:campi, id:objectMap[key].objectId});
        }
        //window.alert(this.objectList[0].name+', '+this.objectList[0].id+', '+this.objectList[0].fields);
        //window.alert(this.objectList[1].name+', '+this.objectList[1].id+', '+this.objectList[1].fields);
    }

    /*
    async allIds(mapObject){
        for(var key in mapObject){
            var arr=[];
            switch(key){
                case 'activity': //index 0
                    var arr=[];
                    Array.prototype.forEach.call(mapObject[key], val => {
                        arr.push(val.Id);
                    });
                    this.details.push({value:arr, key:key});
                    break;

                case 'activityTemplate': //index 1
                    var arr=[];
                    Array.prototype.forEach.call(mapObject[key], val => {
                        arr.push(val.Id);
                    });
                    this.details.push({value:arr, key:key});
                    break;

                case 'fieldsTemplate': //index 2
                    var arr=[];
                    Array.prototype.forEach.call(mapObject[key], val => {
                        arr.push(val.Id);
                    });
                    this.details.push({value:arr, key:key});
                    break;

                case 'dynamicSection': //index 3
                    var arr=[];
                    Array.prototype.forEach.call(mapObject[key], val => {
                        arr.push(val.Id);
                    });
                    var arru=[];
                    var nameFields=[];
                    Array.prototype.forEach.call(mapObject['dynamicField'], valu => {
                        for(var i in arr){
                            if(valu.wrts_prcgvr__Section__c==i){
                                arru.push(valu.Id);
                                nameFields.push(valu.wrts_prcgvr__Field__c);
                            }
                        }
                    });
                    this.details.push({value:arru, fields:nameFields, key:key});
                    break;
                
                case 'dynamicField': //index 4
                    var arr=[];
                    var nameFields=[];
                    Array.prototype.forEach.call(mapObject[key], val => {
                        arr.push(val.Id);
                        nameFields.push(val.wrts_prcgvr__Field__c);
                    });
                    this.details.push({value:arr, name:nameFields, key:key});
                    break;

                default:
                    break;
            }
        }
    }
    */
    /*
            Array.prototype.forEach.call(mapObject[key], val => {
                arr.push(val.Id);
            });
            this.details.push({value:arr, key:key});
            */
}