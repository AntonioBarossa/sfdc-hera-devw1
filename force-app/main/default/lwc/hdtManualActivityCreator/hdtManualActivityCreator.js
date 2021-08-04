import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createActivity from '@salesforce/apex/HDT_LC_ManualActivityCreator.createActivity';
import getAccounts from '@salesforce/apex/HDT_LC_ManualActivityCreator.getAccounts';

export default class HdtManualActivityCreator extends NavigationMixin(LightningElement) {
    
    selectedType;
    accountFilter;
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
        if(this.accountList){
            this.accountList.forEach(element => {
                if(element.Name.includes(this.accountFilter)) optionList.push({ label: element.Name, value: element.Id })
            });
        }
        return optionList;
    }
    
    get saveDisabled(){ return this.selectedType == null || this.selectedAccount == null; }
    get cancelDisabled(){ return this.saved; }

    connectedCallback(){
        this.showSpinner = true;
        getAccounts().then(result => this.accountList = result).finally(() => { this.showSpinner = false; });
    }

    handleTypeChange(event){ this.selectedType = event.target.value; }
    handleFilterChange(event){ this.accountFilter = event.target.value; }
    handleAccountChange(event){ this.selectedAccount = event.target.value; }

    handleSave(){ this.saved = true; }
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