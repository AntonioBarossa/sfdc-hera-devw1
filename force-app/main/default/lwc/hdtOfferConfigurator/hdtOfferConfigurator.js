import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import saveNewOfferConfigured from '@salesforce/apex/HDT_LC_OfferConfiguratorController.saveNewOfferConfigured';
import getOfferMatrix from  '@salesforce/apex/HDT_LC_OfferConfiguratorController.getOfferMatrix';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Name'];

export default class HdtOfferConfigurator extends NavigationMixin(LightningElement) {
    @track dataRows = [];
    @track selection;
    @api productid;
    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };
    @track modalObj = {
        isVisible: false,
        header: '',
        body: '',
        operation: ''
    }
    errorObj = {
        showError: false,
        errorString:''
    };

    field1;
    field2;
    field3;
    field4;
    helpTxt1 = 'This field1 indicate that...';
    helpTxt2 = 'This field2 indicate that...';
    helpTxt3 = 'This field3 indicate that...';
    error;

    @wire(getRecord, { recordId: '$productid', fields: ['Product2.Version__c', 'Product2.Template__c', 'Product2.RateCategory__r.Name', 'Product2.ProductCode'] })
    wiredOptions({ error, data }) {
        if (data) {
            this.field1 = data.fields.Template__c.value;
            this.field2 = data.fields.Version__c.value;
            this.field3 = data.fields.RateCategory__r.value.fields.Name.value;
            this.field4 = data.fields.ProductCode.value;
            console.log(JSON.stringify(data));    
        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log("# error: ", this.error);
        }
    }

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

        const goback = new CustomEvent("goback", {
            detail:  {prodId: this.productid}
        });

        // Dispatches the event.
        this.dispatchEvent(goback);

        //this[NavigationMixin.Navigate]({
        //    type: 'standard__recordPage',
        //    attributes: {
        //        recordId: this.productid,
        //        objectApiName: 'Product2',
        //        actionName: 'view'
        //    }
        //});

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

    openConfirmation(event){
        try {
            switch (event.target.name) {
                case 'saveAction':
                    this.modalObj.header = 'Salva la configurazione';
                    this.modalObj.body = 'Vuoi confermare il salvataggio?';
                    break;
                case 'goBackToRecord':
                    this.modalObj.header = 'Chiudi il configuratore';
                    this.modalObj.body = 'Perderai tutte le tue configurazioni, vuoi procedere?';
            }

            this.modalObj.isVisible = true;
            this.modalObj.operation = event.target.name;

        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

    buttonHandler(event){
        try {
            this[event.target.name](event);
        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
            this.errorObj.showError = true;
            this.errorObj.errorString = e.message;
        }
    }

    modalResponse(event){
        if(event.detail.decision === 'conf'){
            this[event.detail.operation](event);
        }
        this.modalObj.isVisible = false;
    }

}