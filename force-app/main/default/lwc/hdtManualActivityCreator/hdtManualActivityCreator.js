import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createActivity from '@salesforce/apex/HDT_LC_ManualActivityCreator.createActivity';
import getAccounts from '@salesforce/apex/HDT_LC_ManualActivityCreator.getAccounts';

export default class HdtManualActivityCreator extends NavigationMixin(LightningElement) {
    
    selectedType;
    selectedAccount;

    accountList;

    saved;
    
    get activityTypes(){
        return [ { label: 'Contattare il cliente',      value: 'CBS_CRP001__CONTATTARE_IL_CLIENTE' },
                 { label: 'Giro contatore da gestire',  value: 'CBS_AUT005__GIRO_CONTATORE_DA_GESTIRE' },
                 { label: 'Preavviso Cessazione',       value: 'CBS_MOR007_PREAVVISO_CESSAZIONE' } ];
    }
    
    get accounts(){
        let optionList = [];
        accounts.forEach(element => {
            if(element.Name.includes(this.accountFilter)) optionList.push({ label: element.Name, value: element.Id })
        });
        return optionList;
    }
    
    get saveDisabled(){
        return this.selectedType == null;
    }
    
    get cancelDisabled(){
        return this.saved;
    }

    connectedCallback(){
        getAccounts().then(result => this.accountList = result);
    }

    handleSave(){
        this.saved = true;
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