import { LightningElement,api,track } from 'lwc';
import getRecordTypeAccount from '@salesforce/apex/HDT_LC_AlertPrivacy.handleShowAlert';
export default class HdtAlertPrivacy extends LightningElement {
    @api recordId;
    @track showAlert = false;
    connectedCallback(){

        getRecordTypeAccount({orderId: this.recordId })
        .then(result => {
            console.log(JSON.stringify('result '+result));
            if(result){
                this.showAlert = true;
            }
        })
        .catch(error => {
            this.showAlert = false;
        });
    }
}