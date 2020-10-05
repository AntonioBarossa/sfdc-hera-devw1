import { LightningElement, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import SERVICE_POINT_OBJECT from '@salesforce/schema/ServicePoint__c';

export default class HdtTargetObjectRecordTypeSelection extends LightningElement {

    @wire(getObjectInfo, { objectApiName: SERVICE_POINT_OBJECT })
    objectInfo;

    @track recordType = {label:'',value: ''};

    get defaultRecordType(){
        return {label:'',value: this.objectInfo.data.defaultRecordTypeId};
    }

    get recordTypeOptions(){
        
        let recordTypeOptions = [];

        let recordTypeInfos = this.objectInfo.data.recordTypeInfos;

        for(var eachRecordtype in  recordTypeInfos)
        {
            if(recordTypeInfos[eachRecordtype].name !== 'Master') {
                recordTypeOptions.push(
                    { 
                        label: recordTypeInfos[eachRecordtype].name,
                        value: recordTypeInfos[eachRecordtype].recordTypeId 
                    }
                );
            }
            
        }

        return recordTypeOptions;
    }

    closeRecordTypeSelectionModal(){
        this.dispatchEvent(new CustomEvent('closerecordtypeselection'));
    }

    handleRecordTypeSelection(event){
        let selectedRecordType = this.recordTypeOptions.filter(obj => obj.value == event.target.value);
        this.recordType = selectedRecordType[0];
        console.log(selectedRecordType[0]);
    }

    next(){

        if(this.recordType.value === ''){
            let selectedRecordType = this.recordTypeOptions.filter(obj => obj.value == this.defaultRecordType.value);
            this.recordType = selectedRecordType[0];
        }

        this.dispatchEvent(new CustomEvent('next', {detail:this.recordType}));
    }

}