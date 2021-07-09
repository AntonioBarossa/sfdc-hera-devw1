import { LightningElement, api, track } from 'lwc';
import getDocumentalPhaseHistory from '@salesforce/apex/HDT_LC_DocumentalPhaseHistory.getDocumentalPhaseHistory';
const columns  = [
    { label: 'Origine', fieldName: 'OldValue' },
    { label: 'Destinazione', fieldName: 'NewValue'},
    { label: 'Data', fieldName: 'CreatedDate', type: 'date' }
    ];

export default class HdtDocumentalPhaseHistory extends LightningElement {
    @api recordId;
    @api objectApiName;
    data = [];
    columns = columns;
    @track sendMode;
    @track signMode;
    @track email;
    @track phone;
    @track address;
    @track dataLoaded=false;;
    connectedCallback(){
        console.log(this.recordId + ' ' + this.objectApiName);
        this.getHistory();
        this.setEditFormVariables();
    }

    setEditFormVariables(){
        if(this.objectApiName && this.objectApiName.localeCompare('Case') === 0){
            this.sendMode = 'SendMode__c';
            this.signMode = 'SignMode__c';
            this.email = 'Email__c';
            this.phone = 'PhoneNumber__c';
            this.address = 'DeliveryAddress__c';
            this.dataLoaded = true;
        }
    }

    getHistory(){
        getDocumentalPhaseHistory({
            recordId: this.recordId,
            objectApiName: this.objectApiName,
        }).then(result => {
            if(result != null && result.length>0)
                this.data = result;
            else   
                this.data = null;
        })
        .catch(error => {
            console.error(error);
        });
    }
}