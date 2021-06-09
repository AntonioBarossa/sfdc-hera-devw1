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

    connectedCallback(){
        console.log(this.recordId + ' ' + this.objectApiName);
        this.getHistory();
    }

    getHistory(){
        getDocumentalPhaseHistory({
            recordId: this.recordId,
            objectApiName: this.objectApiName,
        }).then(result => {
            this.data = result;
            console.log(JSON.stringify(result));
        })
        .catch(error => {
            console.error(error);
        });
    }
}