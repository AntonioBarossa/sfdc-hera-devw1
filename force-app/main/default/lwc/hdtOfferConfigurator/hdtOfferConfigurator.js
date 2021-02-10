import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import saveNewOfferConfigured from '@salesforce/apex/HDT_LC_OfferConfiguratorController.saveNewOfferConfigured';
import getOfferMatrix from  '@salesforce/apex/HDT_LC_OfferConfiguratorController.getOfferMatrix';

export default class HdtOfferConfigurator extends NavigationMixin(LightningElement) {
    @track dataRows = [];
    @track selection;
    @api productid;
    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };

    errorObj = {
        showError: false,
        errorString:''
    };

    field1 = 'AAAAA';
    field2 = 'AAAAA';
    field3 = 'EE - Libero ven. Fuori rete con Lim';
    helpTxt1 = 'This field1 indicate that...';
    helpTxt2 = 'This field2 indicate that...';
    helpTxt3 = 'This field3 indicate that...';
    error;

    

    connectedCallback() {
        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'loadingdata slds-text-heading_small';

        this.getMatrixData();

    }

    handleSetvaluetoparent(event){
        let element = this.dataRows.find(ele  => ele.id === event.detail.rowId);
        var field = event.detail.fieldName;

        element[field].id = event.detail.recId;
        element[field].label = event.detail.label;

        //check row value and get error in case
        //put error to row
        let e = this.template.querySelector('[data-id="' + event.detail.rowId + '"]');
        //
        var rowChecked = this.checkRowValues(e);
        console.log('@ ' + rowChecked.success + ' - ' + rowChecked.message);
        if(rowChecked.success){
            //success

        } else {
            //error
            e.classList.add('alertRow');
        }

    }

    checkRowValues(rowElement) {
        console.log('# checkRowValues #');
        var retError = {
            success: true,
            message: 'nothing to declare'
        };
        return retError;
    }

    handleChange(event){
        console.log('# onchange checkbox #');
        var rowId = event.currentTarget.getAttribute('data-id');
        var checked = event.currentTarget.name;
        let element = this.dataRows.find(ele  => ele.id === rowId);
        element.checkUser = !checked;
    }

    goBackToRecord(){
        console.log('# goBackToRecord -> ' + this.productid);

        this.dataRows = [];

        console.log('# gotothepage #');

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.productid,
                objectApiName: 'Product2',
                actionName: 'view'
            }
        });

    }

    getMatrixData(){
        console.log('# get data from apex #');
        getOfferMatrix({id: 'tecOffId'})
        .then(result => {
            console.log('# save success #');
            console.log('# resp -> ' + result.success);

            var toastObj = {
                title: '',
                message: '',
                variant: ''
            };

            if(result.success){
                toastObj.title = 'Successo';
                toastObj.message = result.message;
                toastObj.variant = 'success';
                this.dataRows = result.rowList;
            } else {
                toastObj.title = 'Attenzione';
                toastObj.message = result.message;
                toastObj.variant = 'warning';
                this.errorObj = {
                    showError: true,
                    errorString: result.message
                };
            }

            this.spinnerObj.spinner = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: toastObj.title,
                    message: toastObj.message,
                    variant: toastObj.variant
                }),
            );

        })
        .catch(error => {
            this.errorObj.showError = true;
            this.errorObj.errorString = error.body.message;
            this.spinnerObj.spinner = false;
        });
    }

    saveAction(event){
        console.log('# Save offert configured #');

        var start = new Date();
        var t0 = start.getSeconds();

        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'savingdata slds-text-heading_small';

        var obj = this.sendToApex();

        var end = new Date();
        var t1 = end.getSeconds();
        var diff = t1-t0;
        
        if(diff<1){
            console.log('# setTimeout #');
            setTimeout(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: obj.title,
                        message: obj.message,
                        variant: obj.variant,
                    })
                );
        
                if(obj.success){
                    this.spinnerObj.spinner = false;
                    this.goBackToRecord();
                } else {
        
                }
            }, 2000);
        } else {
            console.log('# no time out #');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: obj.title,
                    message: obj.message,
                    variant: obj.variant,
                })
            );
    
            if(obj.success){
                this.spinnerObj.spinner = false;
                this.goBackToRecord();
            } else {
    
            }
        }

    }

    sendToApex(){
        console.log('# sendToApex #');

        var toastObj = {success: true, title: '', message: '', variant: ''};

        saveNewOfferConfigured({offerJson: JSON.stringify(this.dataRows)})
        .then(result => {
            console.log('# save success #');
            console.log('# resp -> ' + result.success);

            if(result.success){
                toastObj.success = true;
                toastObj.title = 'Successo';
                toastObj.message = result.message;
                toastObj.variant = 'success';
            } else {
                toastObj.success = false;
                toastObj.title = 'Attenzione';
                toastObj.message = result.message;
                toastObj.variant = 'warning';                  
            }
            
        })
        .catch(error => {
            this.errorObj.showError = true;
            this.errorObj.errorString = error.body.message;
            this.spinnerObj.spinner = false;

            toastObj.success = false;
            toastObj.title = 'Attenzione';
            toastObj.message = error.body.message;
            toastObj.variant = 'warning'; 

        });
        return toastObj;
    }

    back(event){
        console.log('back');
        this.errorObj.showError = false;
        console.log('back');
    }

}