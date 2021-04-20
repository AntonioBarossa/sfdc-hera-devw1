import { api, LightningElement, track } from 'lwc';
import getAccountAlerts from '@salesforce/apex/HDT_LC_AccountAlerts.getAccountAlerts';


const columns = [
    { label: 'Tipologia Alert', fieldName: 'AlertType__c' },
    { label: 'Alert Attivo', fieldName: 'IsActive__c', type: 'boolean', editable : 'true'},
    { label: 'Email', fieldName: 'IsEmailChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'SMS', fieldName: 'IsSmsChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'Push', fieldName: 'IsPushChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'SOL', fieldName: 'IsSolChannelActive__c', type: 'boolean', editable : 'true'},
];

export default class HdtAccountAlerts extends LightningElement {

    @api recordId;
    @track alertColumns;
    @track data;

    getAccountAlerts(){
        try{
            getAccountAlerts({
                accountId: this.recordId
                })
                .then(result => {
                    console.log('result: ' + result);
                    this.data = JSON.parse(result);
                    
                })
                .catch(error => {
                    console.log('error ' + JSON.stringify(error));
                });
            }catch(error){
                console.error(error);
            }
    }

    connectedCallback() {
        console.log('account id: ' + this.recordId);
        this.alertColumns = columns;
        this.getAccountAlerts();
    }

}