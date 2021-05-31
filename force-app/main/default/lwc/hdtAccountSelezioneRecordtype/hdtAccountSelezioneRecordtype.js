import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import getRecordTypesForAccount from '@salesforce/apex/HDT_LC_AccountSelezionaRecordtype.getRecordTypesForAccount';

export default class HdtAccountSelezioneRecordtype extends LightningElement {

    @track showModal= true;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;

    @track recordType = {label:'',value: '', DeveloperName: ''};
    @track recordTypeOptions=[];

    get defaultRecordType(){
        return {label:'',value: this.objectInfo.data.defaultRecordTypeId};
    }

    getRecordTypeOptions(){
        
        getRecordTypesForAccount().then(data =>{
            console.log('hdtTargetObjectRecordTypeSelection - getRecordTypesForServicePoint: ', JSON.stringify(data));
            var list = data.filter(function(el){
                return (el.DeveloperName === 'HDT_RT_Business' || el.DeveloperName ==='HDT_RT_Residenziale');
            });
            for(var i = 0; i < list.length; i++){
                this.recordTypeOptions.unshift(list[i]);
            }
           // this.recordTypeOptions = list.sort(this.sortBy('DeveloperName', reverse));
           // this.recordTypeOptions = 
            console.log('*********' + JSON.stringify(this.recordTypeOptions));
        }).catch(error => {
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });

        return this.recordTypeOptions;
    }

    handleRecordTypeSelection(event){
        let selectedRecordType = this.recordTypeOptions.filter(obj => obj.value == event.target.value);
        this.recordType = selectedRecordType[0];
    }


    closeModal() {
        this.showModal = false;
        window.history.back();
    }

    openAccountForm(){
        if(this.recordType.value === ''){
            let selectedRecordType = this.recordTypeOptions.filter(obj => obj.value == this.defaultRecordType.value);
            this.recordType = selectedRecordType[0];
        }
        const selected= this.recordType;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail :{selected}
          });
          this.dispatchEvent(valueChangeEvent);
    }

    connectedCallback(){
        this.getRecordTypeOptions();
    }
}