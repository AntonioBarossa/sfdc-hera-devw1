import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import SERVICE_POINT_OBJECT from '@salesforce/schema/ServicePoint__c';
import getRecordTypesForServicePoint from '@salesforce/apex/HDT_LC_TargetObjectRecordTypeSelection.getRecordTypesForServicePoint';

export default class HdtTargetObjectRecordTypeSelection extends LightningElement {

    recordTypeOptions = [];

    @wire(getObjectInfo, { objectApiName: SERVICE_POINT_OBJECT })
    objectInfo;

    @track recordType = {label:'',value: '', DeveloperName: ''};

    get defaultRecordType(){
        return {label:'',value: this.objectInfo.data.defaultRecordTypeId};
    }

    getRecordTypeOptions(){

        getRecordTypesForServicePoint().then(data =>{
            console.log('hdtTargetObjectRecordTypeSelection - getRecordTypesForServicePoint: ', JSON.stringify(data));
            this.recordTypeOptions = data.filter(function(el){
                return el.DeveloperName !== 'Master';
            });
            console.log(JSON.stringify(this.recordTypeOptions));

        }).catch(error => {
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    closeRecordTypeSelectionModal(){
        this.dispatchEvent(new CustomEvent('closerecordtypeselection'));
    }

    handleRecordTypeSelection(event){
        let selectedRecordType = this.recordTypeOptions.filter(obj => obj.value == event.target.value);
        this.recordType = selectedRecordType[0];
    }

    next(){

        if(this.recordType.value === ''){
            let selectedRecordType = this.recordTypeOptions.filter(obj => obj.value == this.defaultRecordType.value);
            this.recordType = selectedRecordType[0];
        }

        this.dispatchEvent(new CustomEvent('next', {detail:this.recordType}));
    }

    connectedCallback(){
        this.getRecordTypeOptions();
    }

}