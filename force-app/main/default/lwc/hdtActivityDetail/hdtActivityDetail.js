import { LightningElement, track, api } from 'lwc';

import getObjectFields from '@salesforce/apex/HDT_LC_ActivityDetail.getObjectFields';

export default class HdtActivityDetail extends LightningElement {
    @api objectApiName;
    @api recordId;
    @track show=false;
    @track objectList=[];
    @track activeSections=['Order','Activity','Case'];
    connectedCallback(){
       this.loadContext();
    }

    async loadContext(){
        const result= await getObjectFields({"idActivity":this.recordId});
        this.getObjectList(result);
        this.show=true;
    }

    getObjectList(objectMap){ 
        for(var key in objectMap){
            var campi=[];
            var i=0;
            for(var i in objectMap[key].fieldList){
                campi.push(objectMap[key].fieldList[i].wrts_prcgvr__Field__c);
            }
            if(key=='wrts_prcgvr__Activity__c'){
                this.objectList.push({api:key, label:'Activity' , fields:campi, id:objectMap[key].objectId});
            }else{
                this.objectList.push({api:key, label:key , fields:campi, id:objectMap[key].objectId});
            }
        }
    }

}