import { LightningElement, wire } from 'lwc';
// import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// import SERVICE_POINT_OBJECT from '@salesforce/schema/ServicePoint__c';

export default class HdtTargetObjectRecordTypeSelection extends LightningElement {

    // @wire(getObjectInfo, { objectApiName: SERVICE_POINT_OBJECT })
    // objectInfo;

    // getRecordTypes(){
    //     let recordTypeInfos = this.objectInfo.data.recordTypeInfos;
    //     console.log('OK! ---- Record types: ', JSON.stringify(recordTypeInfos));

    //     var recordTypeOptions = [];
    //     for(var eachRecordtype in  recordTypeInfos)
    //     {
    //         if(recordTypeInfos[eachRecordtype].name !== 'Master') {
    //             recordTypeOptions.push(
    //                 { 
    //                     label: recordTypeInfos[eachRecordtype].name,
    //                     value: recordTypeInfos[eachRecordtype].recordTypeId 
    //                 }
    //             );
    //         }
            
    //     }

    //     return recordTypeOptions;
    // }

    recordTypeOptions = [
        { label: 'Elettrico', value: 'elettrico' },
        { label: 'Gas', value: 'gas' },
    ];
    recordType = this.recordTypeOptions[0];

    closeRecordTypeSelectionModal(){
        this.dispatchEvent(new CustomEvent('closerecordtypeselection'));
    }

    handleRecordTypeSelection(event){
        // this.recordType = event.target.value;
        this.recordType = this.recordTypeOptions[0];
        console.log(this.recordTypeOptions.filter(obj => obj.value == event.target.value));
    }

    next(){
        this.dispatchEvent(new CustomEvent('next', {detail:this.recordType}));
    }

}