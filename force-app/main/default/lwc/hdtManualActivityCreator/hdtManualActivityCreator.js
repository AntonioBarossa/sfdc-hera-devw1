import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createActivity from '@salesforce/apex/HDT_LC_ManualActivityCreator.createActivity';

export default class HdtManualActivityCreator extends NavigationMixin(LightningElement) {
    
    selectedType;
    saved;
    
    get activityTypes(){
        return [ { label: 'Contattare il cliente',      value: 'CBS_CRP001__CONTATTARE_IL_CLIENTE' },
                 { label: 'Giro contatore da gestire',  value: 'CBS_AUT005__GIRO_CONTATORE_DA_GESTIRE' },
                 { label: 'Preavviso Cessazione',       value: 'CBS_MOR007_PREAVVISO_CESSAZIONE' } ];
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