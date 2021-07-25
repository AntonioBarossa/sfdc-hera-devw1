import { LightningElement, track, api } from 'lwc';
/*
    import getActivityById from '@salesforce/apex/HDT_LC_ActivityDetail.getActivityById';
    import getActivityTemplateById from '@salesforce/apex/HDT_LC_ActivityDetail.getActivityTemplateById';
    import getFieldsTemplateById from '@salesforce/apex/HDT_LC_ActivityDetail.getFieldsTemplateById';
    import getDynamicSectionByFieldsTemplateId from '@salesforce/apex/HDT_LC_ActivityDetail.getDynamicSectionByFieldsTemplateId';
    import getDynamicFieldsByDynamicSectionId from '@salesforce/apex/HDT_LC_ActivityDetail.getDynamicFieldsByDynamicSectionId';
*/
import getDetail from '@salesforce/apex/HDT_LC_ActivityDetail.getDetail';

export default class HdtActivityDetail extends LightningElement {
    @api recordId;
    @track detail;
    connectedCallback(){
        /*
            const activity = getActivityById({"idActivity":this.recordId});
            const activityTemplate= getActivityTemplateById({"idActivityTemplate":this.activity.wrts_prcgvr__ActivityTemplate__c});
            const fieldsTemplate= getFieldsTemplateById({"idFieldsTemplate":this.activityTemplate.wrts_prcgvr__FieldsTemplate__c});
            const dynamicSection= getDynamicSectionByFieldsTemplateId({"idFieldsTemplate":this.fieldsTemplate.Id});
            const dynamicFields= getDynamicFieldByDynamicSectionId({"idDynamicSection":this.dynamicSection.Id});
        */
       this.loadContext();
    }

    async loadContext(){
        this.detail = await getDetail({"idActivity":this.recordId});
        this.handleLoad();
        this.show=true;
    }

    @track show=false;
    @track mapData = [];
    async handleLoad(){
        for(var key in this.detail){
            var arr=[];
            Array.prototype.forEach.call(this.detail[key], val => {
                arr.push(val.Id);
            });
            this.mapData.push({value:arr, key:key});
        }
    }
    

}