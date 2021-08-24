import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createActivity from '@salesforce/apex/HDT_LC_ManualActivityCreator.createActivity';
import getAccounts from '@salesforce/apex/HDT_LC_ManualActivityCreator.getAccounts';

export default class HdtManualActivityCreator extends NavigationMixin(LightningElement) {
    
    selectedType;
    accountFilter;
    selectedAccount;

    @track completeAccountOptionList;

    saveClicked;
    showSpinner;
    showToast;
    inError;

    toastMessage;
    
    get activityOptions(){
        return [ { label: 'Contattare il cliente',      value: 'CBS_CRP001__CONTATTARE_IL_CLIENTE' },
                 { label: 'Giro contatore da gestire',  value: 'CBS_AUT005__GIRO_CONTATORE_DA_GESTIRE' },
                 { label: 'Preavviso Cessazione',       value: 'CBS_MOR007_PREAVVISO_CESSAZIONE' } ];
    }
    
    get accountOptions(){
        if(this.accountFilter && this.accountFilter != ''){
            let filteredOptionList = [];
            this.completeAccountOptionList.forEach( element => {
                if(element.label.includes(this.accountFilter)) filteredOptionList.push(element);
            });
            return filteredOptionList;
        }
        else return this.completeAccountOptionList;
    }
    
    get saveDisabled(){ return this.selectedType == null || this.selectedAccount == null; }
    get cancelDisabled(){ return this.saveClicked; }
    get toastClass(){
        if(this.inError) return 'slds-notify slds-notify_toast slds-theme_error';
        else return 'slds-notify slds-notify_toast slds-theme_success';
    }

    connectedCallback(){
        this.showSpinner = true;
        getAccounts()
            .then(result => {
                let optionList = [];
                result.forEach( element => optionList.push({ label: element.Name, value: element.Id }) );
                this.completeAccountOptionList = optionList;
            })
            .catch(error => {
                console.error(err);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    handleTypeChange(event){ this.selectedType = event.target.value; }
    handleAccountChange(event){ this.selectedAccount = event.target.value; }
    handleFilterChange(event){
        this.accountFilter = event.target.value;
        this.selectedAccount = null;
        this.template.querySelector('[data-id="accountCombobox"]').value = null;
    }

    handleSave(){
        this.saveClicked = true;
        this.showSpinner = true;
        createActivity({type: this.selectedType, accountId: this.selectedAccount})
            .then(result => {
                if(result != null){
                    this.toastMessage = 'Activity created succesfully!';
                    this.showToast = true;
                    this[NavigationMixin.Navigate]({
                        'type': 'standard__recordPage',
                        'attributes': {
                            'recordId': result,
                            'objectApiName': 'wrts_prcgvr__Activity__c',
                            'actionName': 'view'
                        }
                    });
                }
                else{
                    this.toastMessage = 'Error creating activity!';
                    this.inError = true;
                    this.showToast = true;
                }
            })
            .catch(error => {
                console.error(err);
            })
            .finally(() => {
                this.showSpinner = false;
                this.dispatchEvent(new CustomEvent('save', {}));
            });
    }

    handleCancel(){
        this[NavigationMixin.Navigate]({
            'type': 'standard__objectPage',
            'attributes': {
                'objectApiName': 'wrts_prcgvr__Activity__c',
                'actionName': 'home'
            }
        });
    }
}