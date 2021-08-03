import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createActivity from '@salesforce/apex/HDT_LC_ManualActivityCreator.createActivity';

export default class HdtManualActivityCreator extends NavigationMixin(LightningElement) {
    
    selectedType;
    saved;

    get activityTypes(){
        return [ { label: 'Tipo 1', value: 'one' },
                 { label: 'Tipo 2', value: 'two' },
                 { label: 'Tipo 3', value: 'three' },
                 { label: 'Tipo 4', value: 'four' } ];
    }
    
    get saveDisabled(){
        return selectedType == null;
    }
    
    get cancelDisabled(){
        return saved;
    }

    handleSave(){
        saved = true;
    }

    handleCancel(){
        this[NavigationMixin.Navigate]({
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": "wrts_prcgvr__Activity__c",
                "actionName": "home"
            }
        });
    }
}