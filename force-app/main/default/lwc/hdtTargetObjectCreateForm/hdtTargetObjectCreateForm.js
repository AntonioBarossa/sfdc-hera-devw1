import { LightningElement, api } from 'lwc';
import getCustomSettings from '@salesforce/apex/HDT_LC_ServicePointCustomSettings.getCustomSettings';

export default class HdtTargetObjectCreateForm extends LightningElement {
    @api recordtype;

    connectedCallback(){
        getCustomSettings().then(data => {
            console.log(data);
        }).catch(error => {
            console.log(error.message);
        });
    }

    closeCreateTargetObjectModal(){
        this.dispatchEvent(new CustomEvent('closecreateform'));
    }

}