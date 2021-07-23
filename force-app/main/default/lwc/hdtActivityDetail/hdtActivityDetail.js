import { LightningElement, api } from 'lwc';
import getActivityById from '@salesforce/apex/HDT_LC_ActivityDetail.getActivityById';
import getActivityTemplateById from '@salesforce/apex/HDT_LC_ActivityDetail.getActivityTemplateById';
import getFieldsTemplateById from '@salesforce/apex/HDT_LC_ActivityDetail.getFieldsTemplateById';
import getDynamicSectionByFieldsTemplateId from '@salesforce/apex/HDT_LC_ActivityDetail.getDynamicSectionByFieldsTemplateId';
import getDynamicFieldsByDynamicSectionId from '@salesforce/apex/HDT_LC_ActivityDetail.getDynamicFieldsByDynamicSectionId';
export default class HdtActivityDetail extends LightningElement {
    @api recordId;

    connectedCallback(){
        const activity = getActivityById({"idActivity":this.recordId});
        const activityTemplate= getActivityTemplateById({"idActivityTemplate":this.activity.wrts_prcgvr__ActivityTemplate__c});
        const fieldsTemplate= getFieldsTemplateById({"idFieldsTemplate":this.activityTemplate.wrts_prcgvr__FieldsTemplate__c});
        const dynamicSection= getDynamicSectionByFieldsTemplateId({"idFieldsTemplate":this.fieldsTemplate.Id});
        const dynamicFields= getDynamicFieldsByDynamicSectionId({"idDynamicSection":this.dynamicSection.Id});
    }

}